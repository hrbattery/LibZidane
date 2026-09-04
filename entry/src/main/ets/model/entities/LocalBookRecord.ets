/** Metadata supplied by the selected download version, independent of account state. */
export interface LocalBookSelection {
  id: number;
  hash: string;
  title: string;
  author: string;
  extension: string;
  cover: string;
}

/** Persistent metadata; paths are relative to the application's local-books directory. */
export interface LocalBookRecord {
  version: number;
  id: number;
  hash: string;
  title: string;
  author: string;
  extension: string;
  fileName: string;
  size: number;
  downloadedAt: number;
  filePath: string;
}

/** File availability is checked on refresh rather than persisted. */
export interface LocalBookEntry {
  record: LocalBookRecord;
  available: boolean;
  coverPath: string;
}

/** Encode the version identity, never a server-provided filename, into a directory name. */
export function localBookKey(id: number, hash: string): string {
  return `${id}_${encodeURIComponent(hash)}`;
}

/** Restrict the on-disk suffix while retaining the actual format in metadata. */
export function localBookSuffix(extension: string): string {
  const suffix = extension.toLowerCase();
  return /^[a-z0-9]{1,16}$/.test(suffix) ? suffix : 'bin';
}

/** Keep exported names inside the destination selected by the user. */
export function localBookFileName(name: string, extension: string): string {
  const cleaned = name.replace(/[\\/:*?"<>|\u0000-\u001f]/g, '_').trim();
  return cleaned && cleaned !== '.' && cleaned !== '..' ? cleaned : `book.${localBookSuffix(extension)}`;
}
