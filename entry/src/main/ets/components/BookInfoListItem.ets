import { saveBook, unsaveBook } from '../api/UserApi';
import { BookData } from '../models/BookModel';
import { BookCover } from './BookCover';
import { LogUtil as logger } from "@pura/harmony-utils"

@ComponentV2
export struct BookInfoListItem {
  @Require @Param bookData: BookData;

  build() {
    Column(){
      Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.Start}) {
        BookCover({ coverData: this.bookData.cover, altHeight: 130})
          .width("100vp")
          .alignSelf(ItemAlign.Center)

        Column() {
          Flex({direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceBetween}) {
            Column() {
              Text(this.bookData.title)
                .fontSize("16vp")
                .fontWeight(FontWeight.Bold)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .wordBreak(WordBreak.BREAK_ALL)
                .margin({ bottom: "4vp", top: "4vp" })
                .maxLines(2)
              Text(this.bookData.author)
                .fontSize("14vp")
                .fontColor("#a900bbff")
                .wordBreak(WordBreak.BREAK_ALL)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .maxLines(1)
              if (this.bookData.publisher) {
                Text(this.bookData.publisher)
                  .fontSize("12vp")
                  .fontColor(Color.Gray)
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
                  .fillColor("#a900bbff")
                  .margin({left: 20})
                  .onClick(async () => await this.onClickStar())
              } else {
                Image($r("app.media.star"))
                  .height(24)
                  .width(24)
                  .alignSelf(ItemAlign.Start)
                  .fillColor("#a900bbff")
                  .margin({left: 20})
                  .onClick(async () => await this.onClickStar())
              }
            }
          }

          Row() {
            if (this.bookData.year !== 0) {
              Text(`${this.bookData.year}`).fontSize("14vp")
              Divider().vertical(true).margin({ left: 8, right: 8 })
            }
            Text(this.bookData.language).fontSize("14vp")
            Divider().vertical(true).margin({ left: 8, right: 8 })
            Text(`${this.bookData.extension}, ${this.bookData.filesizeString}`).fontSize("14vp")
          }
          // .justifyContent(FlexAlign.Start)
          .height("14vp")
        }
        .width("100%")
        .height("100%")
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(HorizontalAlign.Start)
        .padding({left: "10vp", right: "10vp", top: "5vp", bottom: "5vp"})
      }
      .padding({left: "10vp", right: "10vp"})
      .margin({top: "4vp", bottom: "4vp"})
      .height("130vp")
      .width("100%")
      if (this.bookData.date_download) {
        Text(`下载 ${new Date(this.bookData.date_download).toLocaleDateString()}`)
          .alignSelf(ItemAlign.Start)
          .margin({left: "10vp", bottom: "4vp"})
          .fontSize("12vp")
          .fontColor(Color.Gray)
      }
      Divider()
    }
  }

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
}
