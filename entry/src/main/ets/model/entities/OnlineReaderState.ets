import { url } from '@kit.ArkTS';
import { getBookInfo } from '../api/BookApi';
import { preferencesUtils } from '../storage/PreferencesUtils';
import { StorageConstants } from '../../common/const/StorageConstants';

/** Only stable book metadata is written to local preferences. */
interface RecentReadingBook {
  bookId: number;
  hash: string;
  title: string;
  cover: string;
}

/** Validate without rewriting the case-sensitive signed reader address. */
export function isOnlineReaderUrl(value: string): boolean {
  try {
    const parsed = url.URL.parseURL(value);
    return parsed.protocol === 'https:' && parsed.hostname !== '' &&
      parsed.username === '' && parsed.password === '';
  } catch {
    return false;
  }
}

/** One book's in-memory reading session; signed URLs are never persisted. */
@ObservedV2
export class OnlineReaderState {
  @Trace bookId: number = 0;
  @Trace hash: string = '';
  @Trace title: string = '';
  @Trace cover: string = '';
  @Trace readerUrl: string = '';
  @Trace loading: boolean = false;
  @Trace failed: boolean = false;
  @Trace unavailable: boolean = false;
  private requestVersion: number = 0;

  /** Resume the same book without replacing its web page, or load a new book. */
  async open(bookId: number, hash: string, title: string, cover: string = ''): Promise<void> {
    if (this.bookId === bookId && this.hash === hash) {
      return;
    }
    this.bookId = bookId;
    this.hash = hash;
    this.title = title;
    this.cover = cover;
    await this.reload();
  }

  /** Fetch a fresh signed link; late responses cannot revive a closed or replaced book. */
  async reload(): Promise<void> {
    if (this.bookId === 0) {
      return;
    }
    const version = ++this.requestVersion;
    this.readerUrl = '';
    this.loading = true;
    this.failed = false;
    this.unavailable = false;
    try {
      const book = await getBookInfo(this.bookId, this.hash);
      if (version !== this.requestVersion) {
        return;
      }
      if (!book) {
        this.failed = true;
      } else if (!book.readOnlineAvailable || !book.readOnlineUrl) {
        this.unavailable = true;
      } else if (!isOnlineReaderUrl(book.readOnlineUrl)) {
        this.failed = true;
      } else {
        this.readerUrl = book.readOnlineUrl;
      }
    } catch {
      if (version === this.requestVersion) {
        this.failed = true;
      }
    } finally {
      if (version === this.requestVersion) {
        this.loading = false;
      }
    }
  }

  /** End the session and invalidate any outstanding link request. */
  close(): void {
    ++this.requestVersion;
    this.bookId = 0;
    this.hash = '';
    this.title = '';
    this.cover = '';
    this.readerUrl = '';
    this.loading = false;
    this.failed = false;
    this.unavailable = false;
  }
}

/** Persist recent books while retaining open web sessions independently in memory. */
@ObservedV2
export class OnlineReaderLibrary {
  @Trace sessions: OnlineReaderState[] = [];
  @Trace current: OnlineReaderState = new OnlineReaderState();
  private restored: boolean = false;

  /** Restore metadata once after preferences initialize, without opening any remote reader. */
  restore(): void {
    if (this.restored) {
      return;
    }
    const entries = preferencesUtils.getSync<string[]>(StorageConstants.DEFAULT_PREF,
      StorageConstants.PREFKEY_RECENT_READING_BOOKS, []);
    const sessions: OnlineReaderState[] = [];
    for (const entry of entries) {
      try {
        const record = JSON.parse(entry) as RecentReadingBook;
        if (!record || !Number.isInteger(record.bookId) || record.bookId <= 0 ||
          typeof record.hash !== 'string' || record.hash === '' ||
          typeof record.title !== 'string' || typeof record.cover !== 'string' ||
          sessions.some(session => session.bookId === record.bookId && session.hash === record.hash)) {
          continue;
        }
        const session = new OnlineReaderState();
        session.bookId = record.bookId;
        session.hash = record.hash;
        session.title = record.title;
        session.cover = record.cover;
        sessions.push(session);
      } catch {
        // A damaged record must not prevent other recent books from appearing.
      }
    }
    this.sessions = sessions;
    this.restored = true;
  }

  /** Flush each user change immediately; never serialize web state or temporary signed URLs. */
  private save(): void {
    const entries = this.sessions.map((session: OnlineReaderState): string => {
      const record: RecentReadingBook = {
        bookId: session.bookId, hash: session.hash, title: session.title, cover: session.cover
      };
      return JSON.stringify(record);
    });
    preferencesUtils.putSync(StorageConstants.DEFAULT_PREF,
      StorageConstants.PREFKEY_RECENT_READING_BOOKS, entries);
  }

  /** Select a retained session, creating and loading it only on first open. */
  async open(bookId: number, hash: string, title: string, cover: string = ''): Promise<void> {
    this.restore();
    let session = this.sessions.find(item => item.bookId === bookId && item.hash === hash);
    if (session) {
      await this.resume(session);
      return;
    }
    session = new OnlineReaderState();
    const loading = session.open(bookId, hash, title, cover);
    this.sessions = [session, ...this.sessions];
    this.current = session;
    this.save();
    await loading;
  }

  /** Reuse a live page, or fetch a fresh link when selecting a restored book. */
  async resume(session: OnlineReaderState): Promise<void> {
    if (!this.sessions.includes(session)) {
      return;
    }
    this.sessions = [session, ...this.sessions.filter(item => item !== session)];
    this.current = session;
    this.save();
    if (session.readerUrl === '' && !session.loading) {
      await session.reload();
    }
  }

  /** Close only the selected book; other unfinished books remain available. */
  close(session: OnlineReaderState): void {
    this.sessions = this.sessions.filter(item => item !== session);
    if (this.current === session) {
      this.current = new OnlineReaderState();
    }
    session.close();
    this.save();
  }

  /** Remove account-bound history and invalidate outstanding requests on logout. */
  closeAll(): void {
    this.release();
    this.save();
  }

  /** Release memory on Home destruction without deleting the persisted reading list. */
  release(): void {
    this.sessions.forEach(session => session.close());
    this.sessions = [];
    this.current = new OnlineReaderState();
    this.restored = false;
  }
}

export const onlineReaderLibrary = new OnlineReaderLibrary();
