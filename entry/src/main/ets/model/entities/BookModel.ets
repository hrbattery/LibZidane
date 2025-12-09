/**
 * Datasource type for displaying book cover
 */
@ObservedV2
export class CoverData {
  id: number;
  hash: string;
  @Trace title: string;
  @Trace author: string;
  @Trace cover: string;

  constructor(data: CoverDataType) {
    this.id = data.id;
    this.hash = data.hash;
    this.title = data.title;
    this.author = data.author;
    this.cover = data.cover;
  }
}

/**
 * Datasource type for displaying book list
 */
@ObservedV2
export class BookData extends CoverData {
  @Trace publisher: string | undefined;
  @Trace year: number;
  @Trace language?: string;
  @Trace extension: string;
  @Trace filesizeString: string;
  @Trace date_download: string | undefined
  @Trace _isFavorite: boolean | undefined

  constructor(bookData: BookDataType) {
    super(bookData);
    this.publisher = bookData.publisher;
    this.year = bookData.year;
    this.language = bookData.language;
    this.extension = bookData.extension;
    this.filesizeString = bookData.filesizeString
    this.date_download = bookData.date_download
    this._isFavorite = bookData._isFavorite
  }
}

/**
 * Datasource type for displaying book detail page
 */
@ObservedV2
export class FullBookData extends BookData {
  @Trace content_type: string
  @Trace volume?: string
  @Trace edition?: string
  @Trace identifier?: string
  @Trace pages?: number
  @Trace series?: string
  @Trace deleted: number
  @Trace md5: string
  @Trace sha256: string
  @Trace href: string
  @Trace dl?: string
  @Trace description: string
  @Trace isbn10?: string[]
  @Trace isbn13?: string[]

  constructor(bookData: FullBookDataType) {
    super(bookData);
    this.content_type = bookData.content_type;
    this.volume = bookData.volume;
    this.edition = bookData.edition;
    this.identifier = bookData.identifier;
    this.pages = bookData.pages
    this.series = bookData.series
    this.deleted = bookData.deleted
    this.md5 = bookData.md5
    this.sha256 = bookData.sha256
    this.href = bookData.href
    this.dl = bookData.dl
    this.description = bookData.description
    this.isbn10 = bookData.isbn10
    this.isbn13 = bookData.isbn13
  }
}

export interface CoverDataType {
  id: number,
  title: string,
  author: string,
  cover: string,
  hash: string
}

export interface BookDataType extends CoverDataType {
  publisher?: string;
  year: number;
  language?: string;
  extension: string;
  filesizeString: string;
  date_download?: string;
  date_saved?: string
  _isFavorite?: boolean
}

export interface FullBookDataType extends BookDataType, BookFormatType {
  content_type: string,
  volume?: string,
  edition?: string,
  identifier?: string,
  pages?: number,
  series?: string,
  deleted: number,
  md5: string,
  sha256: string,
  href: string,
  dl?: string,
  description: string,
  isbn10?: string[],
  isbn13?: string[]
}

export interface BookDetailParam {
  bookId: number,
  hash: string
}

export interface BookFormatType {
  id: number,
  hash: string,
  extension: string,
  filesize: number,
  filesizeString: string,
}