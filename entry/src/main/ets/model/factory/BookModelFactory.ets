import { BookCommonDataSource, CoverDataSource } from '../../common/types/ResponseTypes';
import {
  BookData,
  BookDataType,
  CoverData,
  CoverDataType,
  FullBookData,
  FullBookDataType
} from '../entities/BookModel';

export class CoverDataFactory {
  static fromCoverDataSource(data: CoverDataSource): CoverData {
    let param: CoverDataType = {
      id: data.id,
      hash: data.hash,
      title: data.title,
      author: data.author,
      cover: data.cover
    };
    return new CoverData(param);
  }
}

export class BookDataFactory {
  static fromBookCommonDataSource<T extends BookCommonDataSource>(data: T): BookData {
    let param: BookDataType = {
      id: data.id,
      hash: data.hash,
      title: data.title,
      author: data.author,
      cover: data.cover,
      publisher: data.publisher,
      language: data.language,
      year: data.year,
      extension: data.extension,
      filesizeString: data.filesizeString,
    }

    param.date_download = BookDataFactory.getField(data, "date_download");
    param.date_saved = BookDataFactory.getField(data, "date_saved");
    param._isFavorite = BookDataFactory.getField(data, "_isUserSavedBook") ?? (param.date_saved ? true : undefined)
    return new BookData(param);
  }

  private static getField<T, S>(
    data: T,
    fieldName: string
  ): S {
    const dataAny = data as object;
    return dataAny[fieldName];
  }
}

export class FullBookDataFactory {
  static fromBookCommonDataSource(data: BookCommonDataSource) {
    let param: FullBookDataType = {
      id: data.id,
      hash: data.hash,
      title: data.title,
      author: data.author,
      cover: data.cover,
      publisher: data.publisher,
      language: data.language,
      year: data.year,
      extension: data.extension,
      filesizeString: data.filesizeString,
      content_type: data.content_type,
      volume: data.volume,
      edition: data.edition,
      identifier: data.identifier,
      pages: data.pages,
      series: data.series,
      deleted: data.deleted,
      md5: data.md5,
      sha256: data.sha256,
      href: data.href,
      dl: data.dl,
      description: data.description,
      filesize: data.filesize
    }

    param.date_download = FullBookDataFactory.getField(data, "date_download");
    param.date_saved = FullBookDataFactory.getField(data, "date_saved");
    param._isFavorite = FullBookDataFactory.getField(data, "_isUserSavedBook") ?? (param.date_saved ? true : undefined)

    if (data.identifier && typeof data.identifier === 'string') {
      FullBookDataFactory.parseIdentifier(data.identifier, param);
    }

    return new FullBookData(param);
  }

  private static getField<T, S>(
    data: T,
    fieldName: string
  ): S {
    const dataAny = data as object;
    return dataAny[fieldName];
  }

  private static parseIdentifier(identifier: string, param: FullBookDataType) {
    let identifiers: string[] = identifier.split(",");
    let isbn10: string[] = [];
    let isbn13: string[] = [];

    for (const s of identifiers) {
      if (s.length === 10) {
        isbn10.push(s);
      } else if (s.length === 13) {
        isbn13.push(s);
      }
    }

    param.isbn10 = isbn10;
    param.isbn13 = isbn13;
  }
}