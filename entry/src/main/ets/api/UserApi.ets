import {
  CoverDataSource, DownloadedResponse,
  FavoriteResponse,
  MostPopularResponse,
  SaveBookResponse,
  UnsaveBookResponse} from "../common/types/ResponseTypes";
import ReqInst from "../common/request/Request";
import { LogUtil as logger } from "@pura/harmony-utils"
import { DownloadedQueryType, FavoriteQueryType } from "../common/types/QueryTypes";

/*
 * todo:
 * /eapi/user/book/{id}/delete (GET)
 * /eapi/user/donations (GET)
 * /eapi/user/profile (GET)
 *
 * not going to do:
 * /eapi/user/hide-banner (GET)
 * /eapi/user/password-recovery (POST); body parameters: email
 * /eapi/user/registration (POST); body parameters: email, password, name
 * /eapi/user/email/confirmation/resend (POST)
 * /eapi/user/update (POST); body parameters: email, password, name, kindle_email
 * */

export async function getRecommended(): Promise<Array<CoverDataSource>> {
  let response = await ReqInst.get<MostPopularResponse>("/eapi/user/book/recommended");
  logger.debug(response)
  if (response.success === 1) {
    return response.books;
  }
  return [];
}

export async function getDownloaded(params?: DownloadedQueryType): Promise<DownloadedResponse | null> {
  let response = await ReqInst.get<DownloadedResponse>("/eapi/user/book/downloaded", { params: params });
  logger.debug(response)
  if (response.success === 1) {
    return response
  }
  return null
}

export async function getFavorite(params?: FavoriteQueryType): Promise<FavoriteResponse | null> {
  let response = await ReqInst.get<FavoriteResponse>("/eapi/user/book/saved", { params: params });
  logger.debug(response)
  if (response.success === 1) {
    return response
  }
  return null
}

export async function saveBook(bookId: number): Promise<boolean> {
  let response = await ReqInst.get<SaveBookResponse>(`/eapi/user/book/${bookId}/save`);
  logger.debug(response)
  if (response.success === 1) {
    return true
  }
  return false
}

export async function unsaveBook(bookId: number): Promise<boolean> {
  let response = await ReqInst.get<UnsaveBookResponse>(`/eapi/user/book/${bookId}/unsave`);
  logger.debug(response)
  if (response.success === 1) {
    return true
  }
  return false
}