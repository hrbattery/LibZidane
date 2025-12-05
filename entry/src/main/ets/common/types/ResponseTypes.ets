// DataSource types
export interface CoverDataSource {
  id: number,
  title: string,
  author: string,
  cover: string,
  hash: string
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

export interface DownloadFileDataSource {
  downloadLink: string,
  description: string,
  author: string,
  extension: string,
  allowDownload: boolean
}

export interface FormatsDataSource {
  id: number,
  hash: string,
  extension: string,
  filesize: number,
  filesizeString: string,
}

export interface UserProfileDataSource {
  id: number,
  email: string,
  name: string,
  kindle_email: string,
  remix_userkey: string,
  donations_active: number | null, // 目前有效的捐赠金额
  donations_expire: string | null,
  downloads_today: number,
  downloads_limit: number,
  confirmed: number,
  isPremium: number
}

export interface DonationDataSource {
  amount: number,
  refunded: number,
  date: string
}

export interface DomainDataSource {
  domain: string,
  contentAvailable: boolean,
  isRedirector: boolean
}

// Response types

/**
 * eapi/book/most-popular
 */
export interface MostPopularResponse {
  success: number,
  books: CoverDataSource[]
}

/**
 * eapi/book/{bookId}/{hash}
 */
export interface BookInfoResponse {
  success: number,
  book: BookInfoDataSource
}

/**
 * eapi/book/search
 */
export interface SearchInfoResponse {
  success: number,
  books: BookInfoDataSource[],
  exactBooksCount: number,
  pagination: PaginationDataSource
}

/**
 * eapi/book/{bookId}/{hash}/similar
 */
export type SimilarResponse = MostPopularResponse;

/**
 * eapi/book/{bookId}/{hash}/file
 */
export interface DownloadFileResponse {
  success: number,
  file: DownloadFileDataSource
}

/**
 * eapi/book/{bookId}/{hash}/formats
 */
export interface FormatsResponse {
  success: number,
  books: FormatsDataSource[]
}

/**
 * eapi/user/book/recommended
 */
export type RecommendedResponse = MostPopularResponse;

/**
 * eapi/user/book/downloaded
 */
export interface DownloadedResponse {
  success: number,
  books: DownloadedDataSource[],
  pagination: PaginationDataSource
}

/**
 * eapi/user/book/saved
 */
export interface FavoriteResponse {
  success: number,
  books: FavoriteDataSource[],
  pagination: PaginationDataSource
}

/**
 * eapi/user/book/{bookId}/save
 */
export interface SaveBookResponse {
  success: number
}

/**
 * eapi/user/book/{bookId}/unsave
 */
export interface UnsaveBookResponse {
  success: number
}

/**
 * eapi/user/profile
 */
export interface UserProfileResponse {
  success: number,
  user: UserProfileDataSource
}

/**
 * eapi/user/donations
 */
export interface DonationResponse {
  success: number,
  donations: DonationDataSource[]
}

/**
 * eapi/info/languages
 */
export interface LanguagesResponse {
  success: number,
  languages: Record<string, string>
}

/**
 * eapi/info/extensions
 */
export interface ExtensionsResponse {
  success: number,
  extensions: string[]
}

/**
 * eapi/info/domains
 */
export interface DomainsResponse {
  success: number,
  domains: DomainDataSource[]
}