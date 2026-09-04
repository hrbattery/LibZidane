import { UIContext } from '@kit.ArkUI';
import { webview } from '@kit.ArkWeb';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { isOnlineReaderUrl } from '../../../model/entities/OnlineReaderState';
import { createNWeb, disposeNWeb, getNWeb, getNWebController,
  PrebuildWebCompData, prebuildWebCompController } from '../common/PrebuildWeb';

const retainedUrls: Set<string> = new Set();

/** Create one retained web node per book address without releasing other books. */
export function prepareReaderWeb(address: string, context: UIContext): prebuildWebCompController | undefined {
  if (address === '') {
    return undefined;
  }
  if (!retainedUrls.has(address)) {
    createNWeb(readerWebWrap, address, context);
    retainedUrls.add(address);
  }
  return getNWeb(address);
}

/** Stop offscreen rendering without unloading the current chapter. */
export function setReaderWebActive(address: string, active: boolean): void {
  const controller = getNWebController(address);
  try {
    if (active) {
      controller?.onActive();
    } else {
      controller?.onInactive();
    }
  } catch {
    // The controller may not yet be attached while the node is being created.
  }
}

/** Release one book, or all retained nodes on logout and Home destruction. */
export function releaseReaderWeb(address?: string): void {
  if (address !== undefined) {
    if (retainedUrls.delete(address)) {
      disposeNWeb(address);
    }
  } else {
    retainedUrls.forEach((value: string): void => { disposeNWeb(value); });
    retainedUrls.clear();
  }
}

@Builder
function ReaderWebBuilder(data: PrebuildWebCompData) {
  ReaderWeb({ address: data.url, controller: data.controller })
}

const readerWebWrap = wrapBuilder<PrebuildWebCompData[]>(ReaderWebBuilder);

@ComponentV2
struct ReaderWeb {
  @Param address: string = '';
  @Param @Require controller: webview.WebviewController;
  @Local loading: boolean = true;
  @Local failed: boolean = false;

  /** Keep subresource errors from hiding an otherwise usable reader page. */
  build() {
    Stack() {
      Web({ src: this.address, controller: this.controller, renderMode: RenderMode.SYNC_RENDER })
        .javaScriptAccess(true)
        .domStorageAccess(true)
        .fileAccess(false)
        .onLoadIntercept(event => {
          return !!event && event.data.isMainFrame() && !isOnlineReaderUrl(event.data.getRequestUrl());
        })
        .onPageBegin(() => {
          this.failed = false;
          this.loading = true;
        })
        .onPageEnd(() => { this.loading = false; })
        .onErrorReceive(event => {
          if (event?.request.isMainFrame()) {
            hilog.warn(0x0000, 'OnlineReader', 'Main-frame network error: %{public}d', event.error.getErrorCode());
            this.loading = false;
            this.failed = true;
          }
        })
        .onHttpErrorReceive(event => {
          if (event?.request.isMainFrame()) {
            hilog.warn(0x0000, 'OnlineReader', 'Main-frame HTTP status: %{public}d', event.response.getResponseCode());
            this.loading = false;
            this.failed = true;
          }
        })
        .width('100%')
        .height('100%')
      if (this.failed) {
        Column({ space: 16 }) {
          Text($r('app.string.ui_reader_load_failed'))
            .textAlign(TextAlign.Center)
        }
        .padding(24)
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .backgroundColor($r('sys.color.background_primary'))
      } else if (this.loading) {
        LoadingProgress().width(40).height(40)
      }
    }
    .width('100%')
    .height('100%')
  }
}
