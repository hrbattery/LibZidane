import {
  BookCommonDataSource,
  BookInfoResponse, CoverDataSource, MostPopularResponse,
  SearchInfoResponse,
  SimilarResponse } from "../common/DataSourceTypes";
import ReqInst from "../common/request/Request";
import { Any, LogUtil as logger } from "@pura/harmony-utils"
import { SearchQueryType } from "../common/QueryTypes";

/*
 * todo:
 * /eapi/book/recently (GET)
 * /eapi/book/{id}/{hash}/formats (GET)
 * /eapi/book/search (POST); body parameters: message, yearFrom, yearTo, languages, extensions, e, page, limit, order
 * /eapi/book/{id}/{hash}/send-to-{type} (GET)
 * /eapi/book/{id}/{hash} (GET); query: switchLanguage
 * /eapi/book/{id}/{hash}/similar (GET)
 */

export async function getMostPopular(): Promise<CoverDataSource[]> {
  let response = await ReqInst.get<MostPopularResponse>("/eapi/book/most-popular");
  logger.debug(response)
  if (response.success === 1) {
    return response.books;
  }
  return [];
}

export async function getBookInfo(bookId: number, hash: string): Promise<BookCommonDataSource | undefined> {
  let response = await ReqInst.get<BookInfoResponse>(`/eapi/book/${bookId}/${hash}`);
  logger.debug(response)
  if (response.success) {
    return response.book;
  }
  return undefined;
}

export async function getSimilar(bookId: number, hash: string): Promise<CoverDataSource[]> {
  let response = await ReqInst.get<SimilarResponse>(`/eapi/book/${bookId}/${hash}/similar`);
  logger.debug(response)
  if (response.success) {
    return response.books;
  }
  return [];
}

export async function getSearch(param: SearchQueryType): Promise<SearchInfoResponse | null> {
  let response = await ReqInst.post<SearchInfoResponse, SearchQueryType>("/eapi/book/search", param);
  logger.debug(response)
  if (response.success === 1) {
    return response
  }
  return null
}