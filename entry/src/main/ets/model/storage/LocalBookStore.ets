import { fileIo as fs } from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit';
import {
  LocalBookEntry, LocalBookRecord, LocalBookSelection, localBookFileName, localBookKey, localBookSuffix
} from '../entities/LocalBookRecord';

/** Owns only files under local-books; metadata publication is the commit point. */
export class LocalBookStore {
  private readonly root: string;
  private activeDownloads: Set<string> = new Set();
  private listeners: Set<() => void> = new Set();

  constructor(root: string) {
    this.root = root;
    if (!fs.accessSync(root)) {
      fs.mkdirSync(root, true);
    }
    this.cleanIncompleteBooks();
  }

  /** Register a shelf refresh callback. */
  public subscribe(listener: () => void): void {
    this.listeners.add(listener);
  }

  /** Release a shelf callback when its component disappears. */
  public unsubscribe(listener: () => void): void {
    this.listeners.delete(listener);
  }

  /** Refresh subscribers after a commit, deletion, or return to the foreground. */
  public notifyChanged(): void {
    this.listeners.forEach(listener => {
      try {
        listener();
      } catch (error) {
        // A detached or broken UI listener must not change the outcome of a committed file operation.
        console.error(`Local shelf listener failed: ${error}`);
      }
    });
  }

  /** Acquire before querying a download URL so rapid taps cannot consume extra quota. */
  public beginDownload(id: number, hash: string): boolean {
    const key = localBookKey(id, hash);
    if (this.activeDownloads.has(key)) {
      return false;
    }
    this.activeDownloads.add(key);
    return true;
  }

  /** Release a version reservation on every terminal download path. */
  public endDownload(id: number, hash: string): void {
    this.activeDownloads.delete(localBookKey(id, hash));
  }

  /** Read committed books, retaining missing files as unavailable entries. */
  public list(): LocalBookEntry[] {
    const entries: LocalBookEntry[] = [];
    for (const key of fs.listFileSync(this.root)) {
      if (!fs.statSync(`${this.root}/${key}`).isDirectory()) {
        continue;
      }
      const record = this.readRecord(key);
      if (record) {
        const cover = `${this.root}/${key}/cover`;
        entries.push({ record: record, available: this.isAvailable(record),
          coverPath: fs.accessSync(cover) ? cover : '' });
      }
    }
    return entries.sort((left, right) => right.record.downloadedAt - left.record.downloadedAt);
  }

  /** Look up an exact version before requesting another download. */
  public find(id: number, hash: string): LocalBookRecord | undefined {
    return this.readRecord(localBookKey(id, hash));
  }

  /** Resolve only the deterministic path owned by this store. */
  public filePath(record: LocalBookRecord): string {
    return `${this.root}/${localBookKey(record.id, record.hash)}/book.${localBookSuffix(record.extension)}`;
  }

  /** A missing, truncated, or empty file cannot be opened as a completed download. */
  public isAvailable(record: LocalBookRecord): boolean {
    const file = this.filePath(record);
    return fs.accessSync(file) && fs.statSync(file).isFile() && fs.statSync(file).size === record.size;
  }

  /**
   * Move a finished download into its version directory, then atomically publish metadata.
   * Failed commits are rolled back; callers must not announce success before this returns.
   */
  public commit(selection: LocalBookSelection, cachePath: string, fileName: string): LocalBookRecord {
    const key = localBookKey(selection.id, selection.hash);
    const directory = `${this.root}/${key}`;
    const previous = this.readRecord(key);
    if (previous && this.isAvailable(previous)) {
      throw new Error('This version is already stored');
    }
    const size = fs.statSync(cachePath).size;
    if (size <= 0) {
      throw new Error('The downloaded file is empty');
    }
    if (fs.accessSync(directory)) {
      fs.rmdirSync(directory);
    }
    fs.mkdirSync(directory);
    const record: LocalBookRecord = {
      version: 1, id: selection.id, hash: selection.hash, title: selection.title, author: selection.author,
      extension: selection.extension.toLowerCase(), fileName: localBookFileName(fileName, selection.extension),
      size: size, downloadedAt: Date.now(), filePath: `${key}/book.${localBookSuffix(selection.extension)}`
    };
    try {
      fs.moveFileSync(cachePath, this.filePath(record));
      const metadata = fs.openSync(`${directory}/record.tmp`, fs.OpenMode.CREATE | fs.OpenMode.WRITE_ONLY);
      try {
        fs.writeSync(metadata.fd, JSON.stringify(record));
        fs.fsyncSync(metadata.fd);
      } finally {
        fs.closeSync(metadata);
      }
      if (fs.readTextSync(`${directory}/record.tmp`) !== JSON.stringify(record)) {
        throw new Error('Incomplete local book metadata write');
      }
      fs.renameSync(`${directory}/record.tmp`, `${directory}/record.json`);
    } catch (error) {
      fs.rmdirSync(directory);
      throw error as Error;
    }
    this.notifyChanged();
    return record;
  }

  /** Add an optional local cover after the book has committed; no remote URL is persisted. */
  public saveCover(record: LocalBookRecord, data: ArrayBuffer): void {
    const current = this.find(record.id, record.hash);
    if (!current || current.downloadedAt !== record.downloadedAt) {
      return;
    }
    const directory = `${this.root}/${localBookKey(record.id, record.hash)}`;
    const file = fs.openSync(`${directory}/cover.tmp`, fs.OpenMode.CREATE | fs.OpenMode.WRITE_ONLY | fs.OpenMode.TRUNC);
    try {
      fs.writeSync(file.fd, data);
    } finally {
      fs.closeSync(file);
    }
    fs.renameSync(`${directory}/cover.tmp`, `${directory}/cover`);
    this.notifyChanged();
  }

  /** Delete only this version's application-owned directory, never an exported file. */
  public remove(record: LocalBookRecord): void {
    if (this.activeDownloads.has(localBookKey(record.id, record.hash))) {
      throw new Error('This version is downloading');
    }
    const directory = `${this.root}/${localBookKey(record.id, record.hash)}`;
    // Keep metadata until book/cover removal succeeds so a failed deletion remains visible.
    if (fs.accessSync(directory)) {
      for (const name of fs.listFileSync(directory)) {
        if (name !== 'record.json') {
          fs.unlinkSync(`${directory}/${name}`);
        }
      }
      fs.rmdirSync(directory);
    }
    this.notifyChanged();
  }

  /** Validate persisted metadata before exposing it or considering a directory complete. */
  private readRecord(key: string): LocalBookRecord | undefined {
    const metadata = `${this.root}/${key}/record.json`;
    if (!fs.accessSync(metadata)) {
      return undefined;
    }
    // I/O errors must propagate; only malformed JSON is treated as an incomplete record.
    const contents = fs.readTextSync(metadata);
    let record: LocalBookRecord;
    try {
      record = JSON.parse(contents) as LocalBookRecord;
    } catch {
      return undefined;
    }
    if (!record || record.version !== 1 || !Number.isSafeInteger(record.id) || record.id <= 0 ||
      typeof record.hash !== 'string' || !record.hash || typeof record.title !== 'string' ||
      typeof record.author !== 'string' || typeof record.extension !== 'string' ||
      typeof record.fileName !== 'string' || !Number.isFinite(record.size) || record.size <= 0 ||
      !Number.isFinite(record.downloadedAt) || record.downloadedAt <= 0 ||
      localBookKey(record.id, record.hash) !== key ||
      record.filePath !== `${key}/book.${localBookSuffix(record.extension)}`) {
      return undefined;
    }
    return record;
  }

  /** Run once at initialization, never while live downloads are committing. */
  private cleanIncompleteBooks(): void {
    for (const key of fs.listFileSync(this.root)) {
      const directory = `${this.root}/${key}`;
      if (fs.statSync(directory).isDirectory() && !this.readRecord(key)) {
        fs.rmdirSync(directory);
      }
    }
  }
}

let store: LocalBookStore | undefined;

/** One application-wide store keeps startup cleanup and download reservations consistent. */
export function getLocalBookStore(context: common.Context): LocalBookStore {
  if (!store) {
    store = new LocalBookStore(`${context.filesDir}/local-books`);
  }
  return store;
}
