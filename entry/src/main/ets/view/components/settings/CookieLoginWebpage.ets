import { StorageConstants } from "../../../common/const/StorageConstants";
import { preferencesUtils } from "../../../model/storage/PreferencesUtils";
import { PrebuildWebCompData } from "../common/PrebuildWeb";

let isLoading: boolean = false;
let userAgent: string =
  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
@Builder
function CookieLoginPageBuilder(data: PrebuildWebCompData) {
  Stack() {
    Web({ src: '', controller: data.controller })
      .onPageBegin(() => {
        // 调用onActive，开启渲染。
        data.controller.onActive();
      })
      .onFirstMeaningfulPaint(() => {
        if (!data.shouldInactive) {
          return;
        }
        // 在预渲染完成时触发，停止渲染。
        data.controller.onInactive();
        data.shouldInactive = false;
      })
      .onProgressChange((e) => {
        if (e.newProgress == 100) {
          isLoading = false
        }
      })
      .onControllerAttached(() => {
        try {
          isLoading = true
          data.controller.setCustomUserAgent(userAgent)
          data.controller.loadUrl(data.url)
        } catch (error) {
          console.error('Login Web Error: ' + error.message)
        }
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
      .darkMode(preferencesUtils.getSync(StorageConstants.DEFAULT_PREF, 'dark_mode', WebDarkMode.Auto))
      .forceDarkAccess(true)

    if (isLoading) {
      Stack({ alignContent: Alignment.Center }) {
        Loading()
      }
      .height('100%')
      .width('100%')
    }
  }
  .width('100%')
  .height('100%')
}

@Builder
function Loading() {
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

export const cookieLoginPageWrap = wrapBuilder<PrebuildWebCompData[]>(CookieLoginPageBuilder);