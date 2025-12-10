import { webview } from '@kit.ArkWeb';
import { FullBookData } from "../../../model/entities/BookModel"

@ComponentV2
export struct BookDetailDescription {
  @Param @Require bookData: FullBookData

  webController: webview.WebviewController = new webview.WebviewController()
  richStrHead: string = '<head><meta name="viewport" content="width=device-width, initial-scale=1"></head>'

  build() {
    Tabs() {
      TabContent() {
        this.BookInfomationTab(this.bookData)
      }
      .height("auto")
      .tabBar('书');

      TabContent() {
        this.BookDescriptionTab(this.bookData)
      }
      .height("auto")
      .tabBar('描述');
    }
    .height("auto")
    .barMode(BarMode.Fixed)
  }

  @Builder
  BookDescriptionTab(bookData: FullBookData) {
    Web({ src: '', controller: this.webController, renderMode: RenderMode.SYNC_RENDER })
      .onControllerAttached(() => {
        this.webController.loadData(this.richStrHead + bookData?.description, 'text/html', 'UTF-8', ' ', ' ');
      })
      .width('100%')
      .layoutMode(WebLayoutMode.FIT_CONTENT)
      .overScrollMode(OverScrollMode.NEVER)
      .zoomAccess(false)
      .minFontSize(14)
      .javaScriptAccess(false)
  }

  @Builder
  BookInfomationTab(bookData: FullBookData) {
    Grid() {
      if (bookData.year !== undefined && bookData.year !== 0) {
        this.BookInfoKeyGridItem("年份：");
        this.BookInfoValueGridItem(`${bookData.year}`);
      }
      if (bookData.content_type) {
        this.BookInfoKeyGridItem("内容类型:");
        this.BookInfoValueGridItem(`${bookData.content_type}`);
      }
      if (bookData.volume) {
        this.BookInfoKeyGridItem("卷:");
        this.BookInfoValueGridItem(`${bookData.volume}`);
      }
      if (bookData.edition) {
        this.BookInfoKeyGridItem("版本:");
        this.BookInfoValueGridItem(`${bookData.edition}`);
      }
      if (bookData.publisher) {
        this.BookInfoKeyGridItem("出版社:");
        this.BookInfoValueGridItem(`${bookData.publisher}`);
      }
      if (bookData.language) {
        this.BookInfoKeyGridItem("语言:");
        this.BookInfoValueGridItem(`${bookData.language}`);
      }
      if (bookData.pages) {
        this.BookInfoKeyGridItem("页数:");
        this.BookInfoValueGridItem(`${bookData.pages}`);
      }
      if (bookData.isbn10 && bookData.isbn10.length > 0) {
        this.BookInfoKeyGridItem("ISBN 10:");
        this.BookInfoValueGridItem(`${bookData.isbn10.join(",")}`);
      }
      if (bookData.isbn13 && bookData.isbn13.length > 0) {
        this.BookInfoKeyGridItem("ISBN 13:");
        this.BookInfoValueGridItem(`${bookData.isbn13.join(",")}`);
      }
      if (bookData.series) {
        this.BookInfoKeyGridItem("系列:");
        this.BookInfoValueGridItem(`${bookData.series}`);
      }
      if (bookData.extension && bookData.filesizeString) {
        this.BookInfoKeyGridItem("文件:");
        this.BookInfoValueGridItem(`${bookData.extension}, ${bookData.filesizeString}`);
        // fixme: 考虑只有ext或只有filesize的情况
      }
    }
    .columnsGap(10)
    .rowsGap(15)
    .margin({ left: 10, right: 10 })
    .columnsTemplate('1fr 3fr')
    .enableScrollInteraction(false)
    .supportAnimation(false)
  }

  @Builder
  BookInfoKeyGridItem(text: string) {
    GridItem() {
      Text(text)
        .textAlign(TextAlign.Center)
        .fontColor($r("sys.color.font_secondary"))
    }.align(Alignment.Start)
  }

  @Builder
  BookInfoValueGridItem(text: string) {
    GridItem() {
      Text(text)
        .textAlign(TextAlign.Center)
    }.align(Alignment.Start)
  }
}
