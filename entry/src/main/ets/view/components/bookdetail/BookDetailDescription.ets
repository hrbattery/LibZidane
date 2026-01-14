import { UISkeleton, SkeletonTheme } from '@hw-agconnect/ui-skeleton';
import { StorageConstants } from '../../../common/const/StorageConstants';
import { FullBookData } from '../../../model/entities/BookModel';
import { preferencesUtils } from '../../../model/storage/PreferencesUtils';
import { createNWeb, disposeNWeb, getNWeb } from '../common/PrebuildWeb';
import { bookDescriptionTabWrap } from './BookDescriptionTab';

@ComponentV2
export struct BookDetailDescription {
  @Param @Require bookData: FullBookData
  @Local darkMode: WebDarkMode =
    preferencesUtils.getSync(StorageConstants.DEFAULT_PREF, StorageConstants.PREFKEY_DARK_MODE, WebDarkMode.Auto)
  @Consumer() showSkeleton: boolean = false

  @Monitor("bookData")
  onBookDataLoad(): void {
    if (this.bookData?.description) {
      createNWeb(bookDescriptionTabWrap, this.bookData.description, this.getUIContext());
    }
  }

  aboutToDisappear(): void {
    disposeNWeb(this.bookData.description)
  }

  build() {
    Tabs() {
      TabContent() {
        if (this.showSkeleton) {
          Grid() {
            Repeat(Array(5).fill(null))
              .each(() => {
                GridItem() {
                  UISkeleton({
                    options: [
                      {
                        height: 16,
                        width: "90%"
                      }
                    ],
                    theme: SkeletonTheme.TEXT
                  })
                }.align(Alignment.Start)
                .height(24)
                GridItem() {
                  UISkeleton({
                    options: [
                      {
                        height: 16,
                        width: "90%"
                      }
                    ],
                    theme: SkeletonTheme.TEXT
                  })
                }.align(Alignment.Start)
                .height(24)
              })
              .key((item: null, index) => index.toString())
          }
          .GridExtend()
        } else if (this.bookData) {
          this.BookAboutTab(this.bookData)
        }
      }
      .height("auto")
      .tabBar($r("app.string.ui_bookdetail_about"));

      TabContent() {
        if (this.showSkeleton) {
          Column() {
            UISkeleton({
              options: [
                { height: 16, width: "90%" },
                { height: 16, width: "90%" },
                { height: 16, width: "90%" }
              ],
              theme: SkeletonTheme.PARAGRAPH,
              alignCol: FlexAlign.Center,
              alignRow: FlexAlign.Center
            })
              .align(Alignment.Center)
              .height(64)
          }
        } else if (this.bookData) {
          this.BookDescriptionTab(this.bookData)
        }
      }
      .height("auto")
      .tabBar($r("app.string.ui_bookdetail_description"));
    }
    .height("auto")
    .barMode(BarMode.Fixed)
  }

  @Builder
  BookDescriptionTab(bookData: FullBookData) {
    NodeContainer(getNWeb(bookData.description))
      .width("100%")
  }

  @Builder
  BookAboutTab(bookData: FullBookData) {
    Grid() {
      if (bookData.year !== undefined && bookData.year !== 0) {
        this.BookInfoKeyGridItem($r("app.string.ui_bookdetail_about_year"));
        this.BookInfoValueGridItem(`${bookData.year}`);
      }
      if (bookData.content_type) {
        this.BookInfoKeyGridItem($r("app.string.ui_bookdetail_about_content_type"));
        this.BookInfoValueGridItem(`${bookData.content_type}`);
      }
      if (bookData.volume) {
        this.BookInfoKeyGridItem($r("app.string.ui_bookdetail_about_volume"));
        this.BookInfoValueGridItem(`${bookData.volume}`);
      }
      if (bookData.edition) {
        this.BookInfoKeyGridItem($r("app.string.ui_bookdetail_about_edition"));
        this.BookInfoValueGridItem(`${bookData.edition}`);
      }
      if (bookData.publisher) {
        this.BookInfoKeyGridItem($r("app.string.ui_bookdetail_about_publisher"));
        this.BookInfoValueGridItem(`${bookData.publisher}`);
      }
      if (bookData.language) {
        this.BookInfoKeyGridItem($r("app.string.ui_bookdetail_about_lang"));
        this.BookInfoValueGridItem(`${bookData.language}`);
      }
      if (bookData.pages) {
        this.BookInfoKeyGridItem($r("app.string.ui_bookdetail_about_pages"));
        this.BookInfoValueGridItem(`${bookData.pages}`);
      }
      if (bookData.isbn10 && bookData.isbn10.length > 0) {
        this.BookInfoKeyGridItem($r("app.string.ui_bookdetail_about_isbn10"));
        this.BookInfoValueGridItem(`${bookData.isbn10.join(",")}`);
      }
      if (bookData.isbn13 && bookData.isbn13.length > 0) {
        this.BookInfoKeyGridItem($r("app.string.ui_bookdetail_about_isbn13"));
        this.BookInfoValueGridItem(`${bookData.isbn13.join(",")}`);
      }
      if (bookData.series) {
        this.BookInfoKeyGridItem($r("app.string.ui_bookdetail_about_series"));
        this.BookInfoValueGridItem(`${bookData.series}`);
      }
      if (bookData.extension && bookData.filesizeString) {
        this.BookInfoKeyGridItem($r("app.string.ui_bookdetail_about_file"));
        this.BookInfoValueGridItem(`${bookData.extension}, ${bookData.filesizeString}`);
        // fixme: 考虑只有ext或只有filesize的情况
      }
    }
    .GridExtend()
  }

  @Builder
  BookInfoKeyGridItem(text: ResourceStr) {
    GridItem() {
      Text(text)
        .textAlign(TextAlign.Start)
        .fontColor($r("sys.color.font_secondary"))
    }.align(Alignment.Start)
    .transition(TransitionEffect.OPACITY.animation({duration: 500}))
  }

  @Builder
  BookInfoValueGridItem(text: ResourceStr) {
    GridItem() {
      Text(text)
        .textAlign(TextAlign.Start)
    }.align(Alignment.Start)
    .transition(TransitionEffect.OPACITY.animation({duration: 500}))
  }
}

@Extend(Grid)
function GridExtend() {
  .columnsGap(10)
  .rowsGap(15)
  .margin({ left: 10, right: 10 })
  .columnsTemplate('2fr 3fr')
  .enableScrollInteraction(false)
  .supportAnimation(false)
}
