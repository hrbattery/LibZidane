export interface CoverDataSource {
  id: number,
  title: string,
  author: string,
  cover: string,
  hash: string
}

export interface MostPopularResponse {
  success: number,
  books: CoverDataSource[]
}

export interface PaginationDataSource {
  limit: number,
  current: number,
  before: boolean | number,
  next: boolean | number,
  total_items: number,
  total_pages: number
}

export interface BookCommonDataSource {
  id: number,
  content_type: string,
  title: string,
  author: string,
  volume: string,
  year: number,
  edition: string,
  publisher: string,
  identifier: string,
  language: string,
  pages: number,
  series: string,
  cover: string,
  terms_hash: string,
  active: number,
  deleted: number,
  filesize: number,
  filesizeString: string,
  extension: string,
  md5: string,
  sha256: string,
  href: string,
  hash: string,
  kindleAvailable: boolean,
  sendToEmailAvailable: boolean,
  interestScore: string,
  qualityScore: string,
  dl: string,
  readOnlineUrl: string,
  readOnlineAvailable: boolean,
  description: string
}

export interface DownloadedDataSource extends BookCommonDataSource {
  date_download: string
}

export interface FavoriteDataSource extends BookCommonDataSource {
  date_saved: string
}

export interface BookInfoDataSource extends BookCommonDataSource {
  _isUserSavedBook: boolean
}

export interface DownloadedResponse {
  success: number,
  books: DownloadedDataSource[],
  pagination: PaginationDataSource
}

export interface FavoriteResponse {
  success: number,
  books: FavoriteDataSource[],
  pagination: PaginationDataSource
}

export interface BookInfoResponse {
  success: number,
  book: BookInfoDataSource
}

export interface SearchInfoResponse {
  success: number,
  books: BookInfoDataSource[],
  exactBooksCount: number,
  pagination: PaginationDataSource
}

export interface SaveBookResponse {
  success: number
}

export interface UnsaveBookResponse {
  success: number
}

export type SimilarResponse = MostPopularResponse;

export interface DownloadFileDataSource {
  downloadLink: string,
  description: string,
  author: string,
  extension: string,
  allowDownload: boolean
}

export interface DownloadFileResponse {
  success: number,
  file: DownloadFileDataSource
}

export interface FormatsDataSource {
  id: number,
  hash: string,
  extension: string,
  filesize: number,
  filesizeString: string,
}

export interface FormatsResponse {
  success: number,
  books: FormatsDataSource[]
}

export interface LanguagesResponse {
  success: number,
  languages: Record<string, string>
}

export interface ExtensionsResponse {
  success: number,
  extensions: string[]
}