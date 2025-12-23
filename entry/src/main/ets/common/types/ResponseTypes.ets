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

export interface BookCommonDataSource extends CoverDataSource {
  content_type: string, // 内容类型
  volume: string, // 卷
  year: number, // 年份
  edition: string, // 版本
  publisher: string, // 出版社
  identifier: string | null, // ISBN码
  language: string, // 语言
  pages: number, // 页数
  series: string, // 系列
  terms_hash: string,
  active: number,
  deleted: number, // 是否已删除 - 无法下载
  filesize: number, // 文件大小
  filesizeString: string, // 文件大小 - 字符串
  extension: string, // 文件扩展名
  md5: string, // 文件md5
  sha256: string, // 文件sha256
  href: string, // 书籍url
  kindleAvailable: boolean, // 是否可以发送到kindle
  sendToEmailAvailable: boolean, // 是否可以发送到email
  interestScore: string,
  qualityScore: string,
  dl: string, // 文件下载链接
  readOnlineUrl: string, // 在线阅读链接
  readOnlineAvailable: boolean, // 是否可以在线阅读
  description: string // 书籍描述
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

export interface BaseResponse {
  success: number
}

/**
 * eapi/book/most-popular
 */
export interface MostPopularResponse extends BaseResponse {
  books: CoverDataSource[]
}

/**
 * eapi/book/{bookId}/{hash}
 */
export interface BookInfoResponse extends BaseResponse {
  book: BookInfoDataSource
}

/**
 * eapi/book/search
 */
export interface SearchInfoResponse extends BaseResponse {
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
export interface DownloadFileResponse extends BaseResponse {
  file: DownloadFileDataSource
}

/**
 * eapi/book/{bookId}/{hash}/formats
 */
export interface FormatsResponse extends BaseResponse {
  books: FormatsDataSource[]
}

/**
 * eapi/user/book/recommended
 */
export type RecommendedResponse = MostPopularResponse;

/**
 * eapi/user/book/downloaded
 */
export interface DownloadedResponse extends BaseResponse {
  books: DownloadedDataSource[],
  pagination: PaginationDataSource
}

/**
 * eapi/user/book/saved
 */
export interface FavoriteResponse extends BaseResponse {
  books: FavoriteDataSource[],
  pagination: PaginationDataSource
}

/**
 * eapi/user/book/{bookId}/save
 */
export type SaveBookResponse = BaseResponse

/**
 * eapi/user/book/{bookId}/unsave
 */
export type UnsaveBookResponse = BaseResponse

/**
 * eapi/user/profile
 */
export interface UserProfileResponse extends BaseResponse {
  user: UserProfileDataSource
}

/**
 * eapi/user/donations
 */
export interface DonationResponse extends BaseResponse {
  donations: DonationDataSource[]
}

/**
 * eapi/user/book/{bookId}/delete
 */
export type DeleteBookResponse = BaseResponse


/**
 * eapi/info/languages
 */
export interface LanguagesResponse extends BaseResponse {
  languages: Record<string, string>
}

/**
 * eapi/info/extensions
 */
export interface ExtensionsResponse extends BaseResponse {
  extensions: string[]
}

/**
 * eapi/info/domains
 */
export interface DomainsResponse extends BaseResponse {
  domains: DomainDataSource[]
}