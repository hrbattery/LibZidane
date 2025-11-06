import {
  BookCommonDataSource,
  BookInfoResponse, CoverDataSource,
  DownloadFileDataSource,
  DownloadFileResponse,
  FormatsDataSource,
  FormatsResponse,
  MostPopularResponse,
  SearchInfoResponse,
  SimilarResponse } from "../common/ResponseTypes";
import ReqInst from "../common/request/Request";
import { LogUtil as logger } from "@pura/harmony-utils"
import { SearchQueryType } from "../common/QueryTypes";

/*
 * todo:
 * /eapi/book/recently (GET)
 * /eapi/book/{id}/{hash}/formats (GET)
 * /eapi/book/{id}/{hash}/send-to-{type} (GET)
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

export async function getBookFormat(bookId: number, hash: string): Promise<FormatsDataSource[]> {
  let response = await ReqInst.get<FormatsResponse>(`/eapi/book/${bookId}/${hash}/formats`);
  logger.debug(response)
  if (response.success === 1) {
    return response.books
  }
  return []
}

export async function getBookDownloadUrl(bookId: number, hash: string): Promise<DownloadFileDataSource | null> {
  let response = await ReqInst.get<DownloadFileResponse>(`/eapi/book/${bookId}/${hash}/file`);
  logger.debug(response)
  if (response.success === 1) {
    return response.file
  }
  return null
}
