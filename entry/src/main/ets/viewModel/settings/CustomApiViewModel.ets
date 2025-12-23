import { ToastUtil } from '@pura/harmony-utils';
import { Constants } from '../../common/const/Constants';
import { StorageConstants } from '../../common/const/StorageConstants';
import { normalizeApiDomain } from '../../common/request/DomainValidation';
import ReqInst from '../../common/request/Request';
import { BaseResponse } from '../../common/types/ResponseTypes';
import { preferencesUtils } from '../../model/storage/PreferencesUtils';

@ObservedV2
export class CustomApiViewModel {
  /**
   * Current used custom API list
   */
  @Trace customApis: string[] =
    preferencesUtils.getSync<string[]>(StorageConstants.DEFAULT_PREF, StorageConstants.PREFKEY_CUSTOM_APIS, [])
  @Trace curActiveApi: string =
    preferencesUtils.getSync<string>(StorageConstants.DEFAULT_PREF, StorageConstants.PREFKEY_CURRENT_ACTIVE_API,
    Constants.DEFAULT_ZLIB_DOMAIN)

  @Monitor('customApis.0', 'customApis.length')
  updateCurActiveApi() {
    preferencesUtils.putSync(
      StorageConstants.DEFAULT_PREF,
      StorageConstants.PREFKEY_CURRENT_ACTIVE_API,
      this.customApis.length > 0 ? this.customApis[0] : Constants.DEFAULT_ZLIB_DOMAIN
    )
    this.curActiveApi = this.customApis.length > 0 ? this.customApis[0] : Constants.DEFAULT_ZLIB_DOMAIN
  }

  removeApi(index: number) {
    this.customApis.splice(index, 1);
    preferencesUtils.putSync(StorageConstants.DEFAULT_PREF, StorageConstants.PREFKEY_CUSTOM_APIS, this.customApis)
  }

  async addApi(newApi: string) {
    let normalizedURl = "";
    try {
      normalizedURl = normalizeApiDomain(newApi);
    } catch (e) {
      ToastUtil.showToast($r("app.string.notif_custom_api_invalid"))
      throw new Error("This API domain is not a valid URL. Please check if the input is correct or not.")
    }

    if (this.isApiAlreadyExisted(normalizedURl)) {
      ToastUtil.showToast($r("app.string.notif_custom_api_existed"))
      throw new Error("API domain already existed.")
    }

    if (!await this.isUsableApiDomain(normalizedURl)) {
      ToastUtil.showToast($r("app.string.notif_custom_api_unavailable"))
      throw new Error("This API domain is unavailable. Please check if the input is correct or try again later.")
    }

    this.customApis.unshift(normalizedURl)
    preferencesUtils.putSync(StorageConstants.DEFAULT_PREF, StorageConstants.PREFKEY_CUSTOM_APIS, this.customApis)
  }

  onMove(from: number, to:number) {
    const temp = this.customApis.splice(from, 1);
    this.customApis.splice(to, 0, temp[0]);
    preferencesUtils.putSync(StorageConstants.DEFAULT_PREF, StorageConstants.PREFKEY_CUSTOM_APIS, this.customApis)
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