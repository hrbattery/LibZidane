import {
  BookInfoDataSource,
  BookInfoResponse, CoverDataSource, MostPopularResponse,
  SimilarResponse } from "../common/DataSourceTypes";
import ReqInst from "../common/request/Request";
import { LogUtil as logger } from "@pura/harmony-utils"

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

export async function getBookInfo(bookId: number, hash: string): Promise<BookInfoDataSource | undefined> {
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