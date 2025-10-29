import {
  CoverDataSource, DownloadedResponse,
  FavoriteResponse,
  MostPopularResponse } from "../common/DataSourceTypes";
import ReqInst from "../common/request/Request";
import { LogUtil as logger } from "@pura/harmony-utils"

/*
 * todo:
 * /eapi/user/book/{id}/delete (GET)
 * /eapi/user/book/{bookId}/unsave (GET)
 * /eapi/user/donations (GET)
 * /eapi/user/book/{bookId}/save (GET)
 * /eapi/user/profile (GET)
 *
 * not going to do:
 * /eapi/user/donations (GET)
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

export async function getDownloaded(order?: string, page?: number, limit?: number): Promise<DownloadedResponse | null> {
  const config: Record<string, string | number> = {};
  if (order !== undefined) {
    config["order"] = order;
  }
  if (page !== undefined) {
    config['page'] = page;
  }
  if (limit !== undefined) {
    config["limit"] = limit;
  }

  let response = await ReqInst.get<DownloadedResponse>("/eapi/user/book/downloaded", { params: config });
  logger.debug(response)
  if (response.success === 1) {
    return response
  }
  return null
}

export async function getFavorite(order?: string, page?: number, limit?: number): Promise<FavoriteResponse | null> {
  const config: Record<string, string | number> = {};
  if (order !== undefined) {
    config["order"] = order;
  }
  if (page !== undefined) {
    config['page'] = page;
  }
  if (limit !== undefined) {
    config["limit"] = limit;
  }

  let response = await ReqInst.get<FavoriteResponse>("/eapi/user/book/saved", { params: config });
  logger.debug(response)
  if (response.success === 1) {
    return response
  }
  return null
}
