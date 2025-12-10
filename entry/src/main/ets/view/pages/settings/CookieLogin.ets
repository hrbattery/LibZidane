import { PersistenceV2 } from '@kit.ArkUI';
import { webview } from '@kit.ArkWeb';

import { DialogUtil, LogUtil as logger, ToastUtil } from '@pura/harmony-utils';
import { setCookie } from '../../../common/request/Request';
import { AppState } from '../../../model/entities/AppState';

@Builder
export function CookieLoginBuilder() {
  CookieLogin()
}

/**
 * 网页登录页面
 */
@ComponentV2
export struct CookieLogin {
  @Local isLoading: boolean = true
  private userAgent: string =
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
  private pathStack: NavPathStack | undefined = undefined;
  private baseUrl = AppStorage.get("base_url") as string ?? "https://z-library.sk"
  controller: webview.WebviewController = new webview.WebviewController()
  menus: NavigationMenuItem[] = [
    {
      value: 'refresh',
      icon: $r('app.media.refresh'),
      action: () => {
        this.controller.removeCache(true)
        this.loadUrl()
      }
    }
  ]

  private loadUrl() {
    this.isLoading = true
    this.controller.setCustomUserAgent(this.userAgent)
    this.controller.loadUrl(this.baseUrl)
  }

  aboutToAppear(): void {
    this.pathStack = this.queryNavigationInfo()?.pathStack;
  }

  build() {
    NavDestination() {
      Column() {
        this.Bar()
        Stack() {
          Web({
            src: '',
            controller: this.controller
          })
            .allowWindowOpenMethod(true)
            .databaseAccess(true)
            .horizontalScrollBarAccess(true)
            .verticalScrollBarAccess(true)
            .fileAccess(true)
            .domStorageAccess(true)
            .javaScriptAccess(true)
            .imageAccess(true)
            .onlineImageAccess(true)
            .overScrollMode(OverScrollMode.ALWAYS)
            .width('100%')
            .height('100%')
            .onProgressChange((e) => {
              if (e.newProgress == 100) {
                this.isLoading = false
              }
            })
            .onControllerAttached(() => {
              try {
                this.loadUrl()
              } catch (error) {
                console.error('Login Web Error: ' + error.message)
              }
            })

          if (this.isLoading) {
            Stack({ alignContent: Alignment.Center }) {
              this.Loading()
            }
            .height('100%')
            .width('100%')
          }
        }
        .width('100%')
        .height('100%')
      }
      .height('100%')
      .width('100%')
    }
    .menus(this.menus)
    .title('Cookie 登录')
  }

  getCookie(): boolean {
    try {
      let cookie = webview.WebCookieManager.fetchCookieSync(this.baseUrl)
      if (this.isCookieValid(cookie)) {
        setCookie(cookie.split(";"))
        PersistenceV2.connect(AppState, 'appState', () => new AppState())!.loginState = true
        return true;
      } else {
        ToastUtil.showToast('获取登录信息失败，请确认是否已在网页内登录！')
        return false
      }
    } catch (error) {
      logger.error('获取Cookie失败', error.message)
      ToastUtil.showToast('获取Cookie失败：' + error.message)
      return false
    }
  }

  isCookieValid(cookie: string): boolean {
    const hasUserKey = cookie.includes('remix_userkey')
    const hasUserID = cookie.includes('remix_userid')

    return hasUserKey && hasUserID
  }

  @Builder
  Loading() {
    Column() {
      LoadingProgress()
        .width(40)
    }
    .backgroundColor(Color.Transparent)
    .padding({
      left: 15,
      right: 15,
      bottom: 10,
      top: 10
    })
  }

  @Builder
  Bar() {
    Row() {
      Button() {
        Row({ space: 5 }) {
          Image($r('app.media.info_circle'))
            .height('80%')
            .fillColor($r("sys.color.icon_primary"))
          Text('如何登录?')
            .height('80%')
        }
        .padding({ right: 10 })
      }
      .height(40)
      .alignSelf(ItemAlign.End)
      .backgroundColor(Color.Transparent)
      .onClick(() => {
        DialogUtil.showConfirmDialog({
          title: '如何登录',
          message: '等待网页加载，之后在当前网页中登录你的账号\n' +
            '待在网页中登录完成后，点击"获取登录Cookie"按钮，之后等待登录完成\n'
        })
      })

      Button('获取登录Cookie').onClick(() => {
        let result = this.getCookie()
        if (result) {
          ToastUtil.showToast('登录成功!')
          webview.WebCookieManager.clearAllCookiesSync();
          this.pathStack?.clear(true)
        } else {
          ToastUtil.showToast('登录失败')
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