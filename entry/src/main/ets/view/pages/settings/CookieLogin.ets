import { PersistenceV2 } from '@kit.ArkUI';
import { webview } from '@kit.ArkWeb';

import { DialogUtil, LogUtil as logger, ToastUtil } from '@pura/harmony-utils';
import { StorageConstants } from '../../../common/const/StorageConstants';
import { setCookie } from '../../../common/request/Request';
import { AppState } from '../../../model/entities/AppState';
import { preferencesUtils } from '../../../model/storage/PreferencesUtils';
import { createNWeb, disposeNWeb, getNWeb, getNWebController } from '../../components/common/PrebuildWeb';
import { cookieLoginPageWrap } from '../../components/settings/CookieLoginWebpage';

@Builder
export function CookieLoginBuilder() {
  CookieLogin()
}

/**
 * 网页登录页面
 */
@ComponentV2
export struct CookieLogin {
  private userAgent: string =
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
  private pathStack: NavPathStack | undefined = undefined;
  private baseUrl = AppStorage.get("base_url") as string ?? "https://z-library.sk"
  controller: webview.WebviewController | undefined
  menus: NavigationMenuItem[] = [
    {
      value: 'refresh',
      icon: $r('app.media.refresh'),
      action: () => {
        this.controller?.removeCache(true)
        this.loadUrl()
      }
    }
  ]

  private loadUrl() {
    this.controller?.setCustomUserAgent(this.userAgent)
    this.controller?.loadUrl(this.baseUrl)
  }

  aboutToDisappear(): void {
    disposeNWeb(this.baseUrl)
    this.controller = undefined
  }

  aboutToAppear(): void {
    this.pathStack = this.queryNavigationInfo()?.pathStack;
    createNWeb(cookieLoginPageWrap, this.baseUrl, this.getUIContext());
    this.controller = getNWebController(this.baseUrl);
  }

  build() {
    NavDestination() {
      Column() {
        this.Bar()
        NodeContainer(getNWeb(this.baseUrl))
          .width("100%")
      }
      .height('100%')
      .width('100%')
    }
    .menus(this.menus)
    .title($r("app.string.ui_cookie_login"))
  }

  getCookie(): boolean {
    try {
      let cookie = webview.WebCookieManager.fetchCookieSync(this.baseUrl)
      if (this.isCookieValid(cookie)) {
        setCookie(cookie.split(";"))
        PersistenceV2.connect(AppState, 'appState', () => new AppState())!.loginState = true
        return true;
      } else {
        ToastUtil.showToast($r("app.string.notif_cookie_login_get_cookie_invalid"))
        return false
      }
    } catch (error) {
      logger.error('Obtain cookie failed: ', error.message)
      ToastUtil.showToast(this.getUIContext().getHostContext()!.resourceManager.getStringSync(
        $r("app.string.notif_cookie_login_get_cookie_failed").id,
        error.message
      ))
      return false
    }
  }

  isCookieValid(cookie: string): boolean {
    const hasUserKey = cookie.includes('remix_userkey')
    const hasUserID = cookie.includes('remix_userid')

    return hasUserKey && hasUserID
  }

  // @Builder
  // Loading() {
  //   Column() {
  //     LoadingProgress()
  //       .width(40)
  //   }
  //   .backgroundColor(Color.Transparent)
  //   .padding({
  //     left: 15,
  //     right: 15,
  //     bottom: 10,
  //     top: 10
  //   })
  // }

  @Builder
  Bar() {
    Row() {
      Button() {
        Row({ space: 5 }) {
          Image($r('app.media.info_circle'))
            .height('80%')
            .fillColor($r("sys.color.icon_primary"))
          Text($r("app.string.notif_cookie_login_howto"))
            .height('80%')
        }
        .padding({ left: 10, right: 10 })
      }
      .height(40)
      .alignSelf(ItemAlign.End)
      .backgroundColor(Color.Transparent)
      .onClick(() => {
        DialogUtil.showConfirmDialog({
          title: $r("app.string.notif_cookie_login_howto"),
          message: $r("app.string.notif_cookie_login_howto_msg"),
          alignment: DialogAlignment.Center,
          confirm: $r("app.string.ui_common_confirm_btn")
        })
      })

      Button($r("app.string.ui_cookie_login_get_cookie_btn")).onClick(() => {
        let result = this.getCookie()
        if (result) {
          ToastUtil.showToast($r("app.string.notif_login_success"))
          webview.WebCookieManager.clearAllCookiesSync();
          this.pathStack?.clear(true)
        } else {
          ToastUtil.showToast($r("app.string.notif_login_failed"))
        }
      })
        .height(40)
        .alignSelf(ItemAlign.End)
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
    .width('100%')
    .padding(10)
  }
}