import { url } from '@kit.ArkTS';
import { getBookInfo } from '../api/BookApi';

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

/** Keep each unfinished book independently, ordered by most recent selection. */
@ObservedV2
export class OnlineReaderLibrary {
  @Trace sessions: OnlineReaderState[] = [];
  @Trace current: OnlineReaderState = new OnlineReaderState();

  /** Select a retained session, creating and loading it only on first open. */
  async open(bookId: number, hash: string, title: string, cover: string = ''): Promise<void> {
    let session = this.sessions.find(item => item.bookId === bookId && item.hash === hash);
    if (session) {
      this.resume(session);
      return;
    }
    session = new OnlineReaderState();
    const loading = session.open(bookId, hash, title, cover);
    this.sessions = [session, ...this.sessions];
    this.current = session;
    await loading;
  }

  /** Bring a listed book to the front without replacing its URL or web node. */
  resume(session: OnlineReaderState): void {
    if (!this.sessions.includes(session)) {
      return;
    }
    this.sessions = [session, ...this.sessions.filter(item => item !== session)];
    this.current = session;
  }

  /** Close only the selected book; other unfinished books remain available. */
  close(session: OnlineReaderState): void {
    this.sessions = this.sessions.filter(item => item !== session);
    if (this.current === session) {
      this.current = new OnlineReaderState();
    }
    session.close();
  }

  /** Invalidate all account-bound sessions on logout or app destruction. */
  closeAll(): void {
    this.sessions.forEach(session => session.close());
    this.sessions = [];
    this.current = new OnlineReaderState();
  }
}

export const onlineReaderLibrary = new OnlineReaderLibrary();
