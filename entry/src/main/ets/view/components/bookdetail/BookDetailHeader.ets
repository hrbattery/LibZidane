import { UISkeleton, SkeletonTheme } from '@hw-agconnect/ui-skeleton'
import { windowUtil } from '../../../common/system/WindowUtil'
import { BookFormatType, FullBookData } from '../../../model/entities/BookModel'
import { BookCover } from '../common/BookCover'
import { BookFormatSheet } from './BookFormatSheet'

@ComponentV2
export struct BookDetailHeader {
  @Param @Require bookData: FullBookData
  @Param @Require bookFormats: BookFormatType[]
  @Local isShowSelectFormatSheet: boolean = false
  @Consumer() showSkeleton: boolean = false
  pathStack: NavPathStack | undefined = undefined;

  aboutToAppear(): void {
    this.pathStack = this.queryNavigationInfo()?.pathStack;
  }

  showSelectFormatSheet(): void {
    this.isShowSelectFormatSheet = true;
  }

  handleSelectFormatSheet(): void {
    this.isShowSelectFormatSheet = false;
  }

  build() {
    if (windowUtil.mainWindowInfo.widthBp <= WidthBreakpoint.WIDTH_SM) {
      Column({ space: 24 }) {
        BookCover({
          coverData: this.bookData
        })
          .width("30%")
          .constraintSize({
            maxWidth: 120
          });
        this.BookMainInfos()
      }
      .headerFancy()
      .alignItems(HorizontalAlign.Center)
    } else {
      Row({ space: 24 }) {
        BookCover({
          coverData: this.bookData
        })
          .width("50%")
          .constraintSize({
            maxWidth: 200
          });
        Column({ space: 32 }) {
          this.BookMainInfos()
        }
        .width("50%")
        .alignItems(HorizontalAlign.Center)
      }
      .headerFancy()
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Center)
    }
  }

  @Builder
  BookMainInfos() {
    if (this.showSkeleton) {
      Column() {
        UISkeleton({
          options: [
            { height: 18, width: "80%" },
            { height: 18, width: "80%" },
            { height: 18, width: "80%", margin: { bottom: windowUtil.mainWindowInfo.widthBp <= WidthBreakpoint.WIDTH_SM ? 24: 32 } },
            { height: 16, width: "60%", margin: { bottom: windowUtil.mainWindowInfo.widthBp <= WidthBreakpoint.WIDTH_SM ? 24: 32 } },
            { height: 16, width: "80%" }
          ],
          theme: SkeletonTheme.TEXT,
          alignCol: FlexAlign.Center,
          alignRow: FlexAlign.Center
        })
      }
      .height(160)

    } else {
      Text(this.bookData.title)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .textAlign(TextAlign.Center)
      Text(this.bookData.author)
        .fontSize(16)
        .fontColor($r("sys.color.font_secondary"))
        .textAlign(TextAlign.Center)
        .onClick(() => {
          this.pathStack?.pushPathByName("Search", this.bookData.author)
        })
      this.BookSubInfos(this.bookData, 16, $r("sys.color.font_primary"))

      Button($r("app.string.ui_bookdetail_download_btn"))
        .width("90%")
        .onClick(() => this.showSelectFormatSheet())
        .bindSheet(this.isShowSelectFormatSheet, this.BookFormatSheetBuilder(
          this.bookData,
          this.bookFormats,
          () => this.handleSelectFormatSheet()
        ), {
          detents: [SheetSize.MEDIUM, SheetSize.LARGE, 600],
          preferType: SheetType.BOTTOM,
          title: { title: $r("app.string.ui_bookdetail_downloadsheet_title") },
          scrollSizeMode: ScrollSizeMode.CONTINUOUS
        })
    }
  }

  @Builder
  BookSubInfos(bookData: FullBookData, fontSize: number, color: ResourceColor) {
    Row({ space: 8 }) {
      if (bookData.year !== 0) {
        Text(`${bookData.year}`).fontSize(fontSize).fontColor(color);
        Divider().vertical(true);
      }
      Text() {
        SymbolSpan($r("sys.symbol.worldclock"));
      }.fontSize(fontSize).fontColor(color);

      Text(bookData.language).fontSize(fontSize).fontColor(color);
      Divider().vertical(true);
      Text() {
        SymbolSpan($r("sys.symbol.doc_text"));
      }.fontSize(fontSize).fontColor(color);

      Text(`${bookData.extension}, ${bookData.filesizeString}`).fontSize(fontSize).fontColor(color);
    }
    .justifyContent(FlexAlign.Center)
    .height(fontSize)
    .width("100%")
  }

  @Builder
  BookFormatSheetBuilder(mainBookData: FullBookData, formats: BookFormatType[], onClose: () => void) {
    BookFormatSheet({
      mainBookData: mainBookData,
      formats: formats,
      onClose: onClose
    })
  }
}

@Styles
function headerFancy() {
  .width("100%")
  .padding({
    top: 24,
    bottom: 24,
    left: 16,
    right: 16
  })
  .margin({ left: 16, right: 16 })
  .backgroundColor($r("sys.color.background_secondary"))
}
