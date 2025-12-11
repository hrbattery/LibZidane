import { LogUtil as logger } from '@pura/harmony-utils';
import { saveBook, unsaveBook } from '../../../model/api/UserApi';
import { BookData } from '../../../model/entities/BookModel';
import { BookCover } from './BookCover';

@ComponentV2
export struct BookInfoListItem {
  @Require @Param bookData: BookData;

  async onClickStar(): Promise<void> {
    try {
      // todo: 总之改改这段
      this.bookData._isFavorite = !this.bookData._isFavorite
      !this.bookData._isFavorite ? await unsaveBook(this.bookData.id) : await saveBook(this.bookData.id);
    } catch (e) {
      logger.error(e)
      this.bookData._isFavorite = !this.bookData._isFavorite
      // todo: toast error or use a 404 page
    }
  }

  build() {
    Column({ space: 8 }) {
      Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.Start }) {
        BookCover({ coverData: this.bookData, altHeight: 120 })
          .width("40%")
          .alignSelf(ItemAlign.Center)
          .constraintSize({
            maxHeight: 120
          })

        Column() {
          Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceBetween }) {
            Column({ space: 2 }) {
              Text(this.bookData.title)
                .fontSize(14)
                .fontWeight(FontWeight.Bold)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .wordBreak(WordBreak.BREAK_ALL)
                .maxLines(2)
              Text(this.bookData.author)
                .fontSize(14)
                .fontColor($r("sys.color.font_emphasize"))
                .wordBreak(WordBreak.BREAK_ALL)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .maxLines(1)
              if (this.bookData.publisher) {
                Text(this.bookData.publisher)
                  .fontSize(12)
                  .fontColor($r("sys.color.font_secondary"))
                  .wordBreak(WordBreak.BREAK_ALL)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .maxLines(1)
              }
            }
            .alignItems(HorizontalAlign.Start)

            if (this.bookData._isFavorite !== undefined) {
              if (this.bookData._isFavorite) {
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

          if (this.bookData.date_download) {
            Text() {
              Span($r("app.string.ui_bookinfo_downloaded"))
              Span(` ${new Date(this.bookData.date_download).toLocaleDateString()}`)
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

      this.SubBookInfo(12, $r("sys.color.font_secondary"))
    }
    .margin({ top: 8, bottom: 8 })
  }

  @Builder
  SubBookInfo(fontSize: number, color: ResourceColor) {
    Row({ space: 8 }) {
      if (this.bookData.year !== 0) {
        Text(`${this.bookData.year}`).fontSize(fontSize).fontColor(color);
        Divider().vertical(true);
      }
      Text() {
        SymbolSpan($r("sys.symbol.worldclock"));
      }.fontSize(fontSize).fontColor(color);

      Text(this.bookData.language).fontSize(fontSize).fontColor(color);
      Divider().vertical(true);
      Text() {
        SymbolSpan($r("sys.symbol.doc_text"));
      }.fontSize(fontSize).fontColor(color);

      Text(`${this.bookData.extension}, ${this.bookData.filesizeString}`).fontSize(fontSize).fontColor(color);
    }
    .height(fontSize)
    .width("100%")
  }
}
