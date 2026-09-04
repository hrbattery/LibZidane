import { OnlineReaderState, onlineReaderLibrary } from '../../model/entities/OnlineReaderState';
import { prebuildWebCompController } from '../components/common/PrebuildWeb';
import { prepareReaderWeb, releaseReaderWeb, setReaderWebActive } from '../components/reader/OnlineReaderWeb';

/** Open a reader destination while the web node survives ordinary back navigation. */
@Builder
export function OnlineReaderBuilder() {
  OnlineReader()
}

@ComponentV2
struct OnlineReader {
  @Local reader: OnlineReaderState = onlineReaderLibrary.current;
  @Local nodeReady: boolean = false;
  private node: prebuildWebCompController | undefined = undefined;
  private pathStack: NavPathStack | undefined = undefined;
  private attachedUrl: string = '';

  /** Attach the retained page, or replace it after explicitly fetching a fresh URL. */
  @Monitor('reader.readerUrl')
  prepareNode(): void {
    if (this.attachedUrl !== '' && this.attachedUrl !== this.reader.readerUrl) {
      releaseReaderWeb(this.attachedUrl);
    }
    this.node = prepareReaderWeb(this.reader.readerUrl, this.getUIContext());
    this.attachedUrl = this.reader.readerUrl;
    this.nodeReady = this.node !== undefined;
  }

  /** Closing releases the reader; the normal back button only minimizes it. */
  closeReader(): void {
    this.pathStack?.pop();
    releaseReaderWeb(this.reader.readerUrl);
    onlineReaderLibrary.close(this.reader);
  }

  /** Show native loading/error states around the retained online reader. */
  build() {
    NavDestination() {
      Column() {
        if (this.nodeReady) {
          NodeContainer(this.node).width('100%').layoutWeight(1)
        } else {
          Column({ space: 16 }) {
            if (this.reader.loading) {
              LoadingProgress().width(40).height(40)
            } else {
              Text(this.reader.unavailable ? $r('app.string.ui_reader_unavailable') :
                $r('app.string.ui_reader_load_failed'))
                .textAlign(TextAlign.Center)
              Button($r('app.string.ui_placeholder_refresh_btn'))
                .onClick(() => this.reader.reload())
            }
          }
          .padding(24)
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        }
      }
      .width('100%')
      .height('100%')
    }
    .title(this.reader.title)
    .menus([
      { value: $r('app.string.ui_placeholder_refresh_btn'), icon: $r('app.media.refresh'),
        action: () => this.reader.reload() },
      { value: $r('app.string.ui_reader_close'), icon: $r('app.media.xmark_circle'),
        action: () => this.closeReader() }
    ])
    .onReady(context => {
      this.pathStack = context.pathStack;
      this.prepareNode();
    })
    .onShown(() => {
      setReaderWebActive(this.reader.readerUrl, true);
    })
    .onHidden(() => {
      setReaderWebActive(this.reader.readerUrl, false);
    })
  }
}
