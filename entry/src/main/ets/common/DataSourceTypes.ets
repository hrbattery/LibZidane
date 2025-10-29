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

export interface BookInfoDataSource {
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

export interface DownloadedDataSource extends BookInfoDataSource {
  date_download: string
}

export interface FavoriteDataSource extends BookInfoDataSource {
  date_saved: string
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

export type SimilarResponse = MostPopularResponse;