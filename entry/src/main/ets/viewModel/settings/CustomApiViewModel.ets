import { ToastUtil } from "@pura/harmony-utils";
import { normalizeApiDomain } from "../../common/request/DomainValidation";
import ReqInst from "../../common/request/Request";
import { BaseResponse } from "../../common/types/ResponseTypes";

@ObservedV2
export class CustomApiViewModel {
  /**
   * Current used custom API list
   */
  @Trace customApis: string[] = []

  removeApi(index: number) {
    this.customApis.splice(index, 1);
  }

  async addApi(newApi: string) {
    let normalizedURl = "";
    try {
      normalizedURl = normalizeApiDomain(newApi);
    } catch (e) {
      ToastUtil.showToast($r("app.string.notif_custom_api_unavailable"))
      throw new Error("This API domain is unavailable. Please check if the input is correct or try again later.")
    }

    if (this.isApiAlreadyExisted(normalizedURl)) {
      ToastUtil.showToast($r("app.string.notif_custom_api_existed"))
      throw new Error("API domain already existed.")
    }
    if (!await this.isUsableApiDomain(normalizedURl)) {
      ToastUtil.showToast($r("app.string.notif_custom_api_unavailable"))
      throw new Error("This API domain is unavailable. Please check if the input is correct or try again later.")
    }
    this.customApis.push(normalizedURl);
  }

  private isApiAlreadyExisted(newApi: string): boolean {
    return this.customApis.find((value) => value == newApi) !== undefined;
  }

  private async isUsableApiDomain(newApi: string): Promise<boolean> {
    try {
      let response = await ReqInst.get<BaseResponse>('/eapi/info', {
        baseURL: newApi
      });
      return response.success == 1;
    } catch {
      return false;
    }
  }
}