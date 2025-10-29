@ObservedV2
export class CoverData {
  id: number;
  hash: string;
  @Trace name: string;
  @Trace author: string;
  @Trace img: string;

  constructor(id: number, hash: string, name: string, author: string, img: string) {
    this.id = id;
    this.hash = hash;
    this.name = name;
    this.author = author;
    this.img = img;
  }
}

@ObservedV2
export class BookData {
  id: number;
  hash: string;
  @Trace cover: CoverData;
  @Trace title: string;
  @Trace author: string;
  @Trace publisher: string | undefined;
  @Trace year: number;
  @Trace language: string;
  @Trace extension: string;
  @Trace filesizeString: string;
  @Trace date_download: string | undefined

  constructor(bookData: BookDataType) {
    this.id = bookData.id;
    this.hash = bookData.hash;
    this.cover = new CoverData(
      bookData.id,
      bookData.hash,
      bookData.title,
      bookData.author,
      bookData.cover
    );
    this.title = bookData.title;
    this.author = bookData.author;
    this.publisher = bookData.publisher;
    this.year = bookData.year;
    this.language = bookData.language;
    this.extension = bookData.extension;
    this.filesizeString = bookData.filesizeString
    this.date_download = bookData.date_download
  }
}

@ObservedV2
export class FullBookData {

}

export interface BookDataType {
  id: number;
  hash: string;
  title: string;
  cover: string;
  author: string;
  publisher?: string;
  year: number;
  language: string;
  extension: string;
  filesizeString: string;
  date_download?: string;
}

export interface FullBookDataType {
  id: number,
  content_type: string,
  title: string,
  author: string,
  volume?: string,
  year: number,
  edition?: string,
  publisher?: string,
  identifier?: string,
  language?: string,
  pages?: number,
  series?: string,
  cover: string,
  terms_hash?: string,
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
  interestScore?: string,
  qualityScore?: string,
  dl?: string,
  readOnlineUrl?: string,
  date_download?: string,
  readOnlineAvailable?: boolean,
  description: string,
  _isUserSavedBook?: boolean
}

export interface BookDetailParam {
  bookId: number,
  hash: string
}