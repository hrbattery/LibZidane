import ReqInst from "../../common/request/Request";
import { DomainDataSource,
  DomainsResponse,
  ExtensionsResponse, LanguagesResponse } from "../../common/types/ResponseTypes";
import { LogUtil as logger } from "@pura/harmony-utils"
/*
 * todo:
 * /eapi/info/plans (GET); query: switchLanguage
 * /eapi/info (GET); query: switchLanguage
 * */
export async function getLanguages(): Promise<Record<string, string>> {
  let response = await ReqInst.get<LanguagesResponse>('/eapi/info/languages');
  logger.debug(response)
  if (response.success) {
    return response.languages;
  }
  return {};
}

export async function getExtensions(): Promise<string[]> {
  let response = await ReqInst.get<ExtensionsResponse>('/eapi/info/extensions');
  logger.debug(response)
  if (response.success) {
    return response.extensions;
  }
  return [];
}

export async function getDomains(): Promise<DomainDataSource[]> {
  let response = await ReqInst.get<DomainsResponse>('/eapi/info/domains');
  logger.debug(response)
  if (response.success) {
    return response.domains;
  }
  return [];
}