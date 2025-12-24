import { LogUtil as logger } from '@pura/harmony-utils';
import { saveBook, unsaveBook } from '../../../model/api/UserApi';
import { BookData, BookDetailParam } from '../../../model/entities/BookModel';
import { BookCover } from './BookCover';
import { i18n } from '@kit.LocalizationKit';
import { AnimateType, SkeletonTheme, UISkeleton } from '@hw-agconnect/ui-skeleton';

@ComponentV2
export struct BookInfoListItem {
  @Require @Param bookDataItem: RepeatItem<BookData>;
  @Local showMenu: boolean = false;
  @Consumer() onRemove?: (index: number) => Promise<void> = undefined
  @Consumer() showSkeleton: boolean = false;

  async onClickStar(): Promise<void> {
    try {
      // todo: 总之改改这段
      this.bookDataItem.item._isFavorite = !this.bookDataItem.item._isFavorite
      !this.bookDataItem.item._isFavorite ? await unsaveBook(this.bookDataItem.item.id) : await saveBook(this.bookDataItem.item.id);
    } catch (e) {
      logger.error(e)
      this.bookDataItem.item._isFavorite = !this.bookDataItem.item._isFavorite
      // todo: toast error or use a 404 page
    }
  }

  build() {
    Column({ space: 8 }) {
      Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.Start }) {
        BookCover({ coverData: this.bookDataItem.item, altHeight: 120 })
          .width("35.4%")
          .alignSelf(ItemAlign.Center)
          .constraintSize({
            maxHeight: 120
          })

        Column() {
          Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceBetween }) {
            Column({ space: 2 }) {
              if (this.showSkeleton) {
                Column() {
                  UISkeleton({
                    options: [
                      { height: 14, width: "80%" },
                      { height: 14, width: "50%" },
                      { height: 12, width: "50%" }
                    ],
                    theme: SkeletonTheme.PARAGRAPH,
                  })
                }.constraintSize({
                  maxWidth: 180
                })
              } else {
                Text(this.bookDataItem.item.title)
                  .fontSize(14)
                  .fontWeight(FontWeight.Bold)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .wordBreak(WordBreak.BREAK_ALL)
                  .maxLines(2)
                Text(this.bookDataItem.item.author)
                  .fontSize(14)
                  .fontColor($r("sys.color.font_emphasize"))
                  .wordBreak(WordBreak.BREAK_ALL)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .maxLines(1)
                if (this.bookDataItem.item.publisher) {
                  Text(this.bookDataItem.item.publisher)
                    .fontSize(12)
                    .fontColor($r("sys.color.font_secondary"))
                    .wordBreak(WordBreak.BREAK_ALL)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .maxLines(1)
                }
              }
            }
            .alignItems(HorizontalAlign.Start)

            if (this.bookDataItem.item !== null && this.bookDataItem.item._isFavorite !== undefined) {
              if (this.bookDataItem.item._isFavorite) {
                Image($r("app.media.star_fill"))
                  .height(24)
                  .width(24)
                  .alignSelf(ItemAlign.Start)
                  .fillColor($r("sys.color.icon_emphasize"))
                  .margin({ left: 20 })
                  .onClick(async () => await this.onClickStar())
              } else {
                Image($r("app.media.star"))
                  .height(24)
                  .width(24)
                  .alignSelf(ItemAlign.Start)
                  .fillColor($r("sys.color.icon_emphasize"))
                  .margin({ left: 20 })
                  .onClick(async () => await this.onClickStar())
              }
            }
          }

          if (this.bookDataItem.item !== null && this.bookDataItem.item.date_download) {
            Text() {
              Span($r("app.string.ui_bookinfo_downloaded"))
              Span(` ${new Date(this.bookDataItem.item.date_download).toLocaleDateString(i18n.System.getAppPreferredLanguage())}`)
            }
              .alignSelf(ItemAlign.Start)
              .fontSize(12)
              .fontColor($r("sys.color.font_secondary"))
          }
        }
        .width("100%")
        .height("100%")
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(HorizontalAlign.Start)
        .padding({ left: 10, right: 10 })
      }
      .height(120)
      .width("100%")

      if (this.showSkeleton) {
        Column() {
          UISkeleton({
            options: [
              { height: 12, width: "50%" }
            ],
            theme: SkeletonTheme.TEXT,
          })
        }
        .height(12)
      } else {
        this.SubBookInfo(12, $r("sys.color.font_secondary"))
      }
    }
    .backgroundColor($r("sys.color.background_primary"))
    .padding({ top: 8, bottom: 8, left: 10, right: 10 })
    .bindContextMenu(this.showMenu, this.BookInfoMenu, {
      preview: MenuPreviewMode.IMAGE,
      previewAnimationOptions: {
        hoverScale: [0.9, 1.2]
      },
      aboutToDisappear: () => this.showMenu = false
    })
    .gesture(
      LongPressGesture({ repeat: false })
        .onAction(() => {
          if (this.onRemove !== undefined && !this.showSkeleton) {
            this.showMenu = true
          }
        }),
      GestureMask.IgnoreInternal
    )
  }

  @Builder
  BookInfoMenu() {
    Menu() {
      MenuItem({ content: "删除" })
        .onClick(async () => {
          await this.onRemove!(this.bookDataItem.index)
        })
    }
  }

  @Builder
  SubBookInfo(fontSize: number, color: ResourceColor) {
    Row({ space: 8 }) {
      if (this.bookDataItem.item.year !== 0) {
        Text(`${this.bookDataItem.item.year}`).fontSize(fontSize).fontColor(color);
        Divider().vertical(true);
      }
      Text() {
        SymbolSpan($r("sys.symbol.worldclock"));
      }.fontSize(fontSize).fontColor(color);

      Text(this.bookDataItem.item.language).fontSize(fontSize).fontColor(color);
      Divider().vertical(true);
      Text() {
        SymbolSpan($r("sys.symbol.doc_text"));
      }.fontSize(fontSize).fontColor(color);

      Text(`${this.bookDataItem.item.extension}, ${this.bookDataItem.item.filesizeString}`).fontSize(fontSize).fontColor(color);
    }
    .height(fontSize)
    .width("100%")
  }
}
