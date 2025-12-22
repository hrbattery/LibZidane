import { StorageConstants } from '../../../common/const/StorageConstants';
import { preferencesUtils } from '../../../model/storage/PreferencesUtils';
import { PrebuildWebCompData } from '../common/PrebuildWeb';

const richStrHead: string = '<head><meta name="viewport" content="width=device-width, initial-scale=1"></head>'

@Builder
function BookDescriptionTabBuilder(data: PrebuildWebCompData) {
  Column() {
    Web({ src: '', controller: data.controller, renderMode: RenderMode.SYNC_RENDER })
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
      .onControllerAttached(() => {
        data.controller.loadData(richStrHead + data.url, 'text/html', 'UTF-8', ' ', ' ');
      })
      .width('100%')
      .layoutMode(WebLayoutMode.FIT_CONTENT)
      .overScrollMode(OverScrollMode.NEVER)
      .zoomAccess(false)
      .minFontSize(14)
      .javaScriptAccess(false)
      .darkMode(preferencesUtils.getSync(StorageConstants.DEFAULT_PREF, StorageConstants.PREFKEY_DARK_MODE,
        WebDarkMode.Auto))
      .forceDarkAccess(true)
      .width("100%")
      .height("100%")
  }
}

export const bookDescriptionTabWrap = wrapBuilder<PrebuildWebCompData[]>(BookDescriptionTabBuilder);