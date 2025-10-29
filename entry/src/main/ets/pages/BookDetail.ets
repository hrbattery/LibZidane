import { getBookInfo, getSimilar } from '../api/BookApi';
import { BookCover } from '../components/BookCover'
import { BookDetailParam, CoverData, FullBookDataType } from '../models/BookModel'
import { LogUtil as logger } from "@pura/harmony-utils"
import { webview } from '@kit.ArkWeb';
import { BookCoverWaterFlow } from '../components/BookCoverWaterFlow';
import { bookDataCache } from '../common/cache/BookDataCache';


@Builder
export function BookDetailBuilder() {
  BookDetailPage()
}

@ComponentV2
struct BookDetailPage {
  pathStack: NavPathStack | undefined = undefined;
  @Local bookId: number = 0
  @Local hash: string = "";

  build() {
    NavDestination() {
      BookDetail({
        bookId: this.bookId,
        hash: this.hash
      })
    }
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
      let param = context.pathInfo.param as BookDetailParam;
      this.bookId = param.bookId;
      this.hash = param.hash;
    })
    .menus([
      {
        'value': "分享",
        'icon': $r("app.media.share"),
        'action': ()=> {}
      },
      {
        'value': "收藏",
        'icon': $r("app.media.star"),
        'action': ()=> {}
      }
    ])
  }
}

@ComponentV2
struct BookDetail {
  @Param @Require bookId: number
  @Param @Require hash: string;
  @Local bookData: FullBookDataType | undefined = undefined

  webController: webview.WebviewController = new webview.WebviewController()
  richStrHead: string = '<head><meta name="viewport" content="width=device-width, initial-scale=1"></head>'

  async aboutToAppear(): Promise<void> {
    await this.loadBookData();
  }

  async loadBookData() {
    const cache = bookDataCache.getCache(`${this.bookId}_${this.hash}`);
    if (!cache) {
      try {
        let bookData = await getBookInfo(this.bookId, this.hash) as FullBookDataType;
        this.bookData = bookData;
        bookDataCache.setCache(`${this.bookId}_${this.hash}`, bookData)
      } catch (e) {
        logger.error(e)
        // todo: toast error or use a 404 page
      }
    } else {
      this.bookData = cache
    }
  }

  async loadSimilar() {
    let similar = await getSimilar(this.bookId, this.hash);
    return similar.map(element => {
      return new CoverData(
        element.id,
        element.hash,
        element.title,
        element.author,
        element.cover
      )
    })
  }

  build() {
    Scroll() {
      Column() {
        if (this.bookData !== undefined) {
          Flex({
            direction: FlexDirection.Column,
            justifyContent: FlexAlign.SpaceAround,
            alignItems: ItemAlign.Center
          }) {
            BookCover({
              coverData: new CoverData(
                this.bookData.id,
                this.bookData.hash,
                this.bookData.title,
                this.bookData.author,
                this.bookData.cover
              )
            }).width("30%")
            Text(this.bookData.title)
              .fontSize("16vp")
              .fontColor("#ffffffff")
              .fontWeight(FontWeight.Bold)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .margin({"left": "10vp", "right": "10vp"})
              .textAlign(TextAlign.Center)
            Text(this.bookData.author)
              .fontSize("14vp")
              .fontColor("#ffdadada")
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .textAlign(TextAlign.Center)
              .margin({"left": "10vp", "right": "10vp"})
            Row() {
              if (this.bookData.year !== 0) {
                Text(`${this.bookData.year}`)
                  .fontSize("14vp")
                  .fontColor("#ffffffff")
                Divider()
                  .vertical(true)
                  .margin({ left: 8, right: 8 })
              }
              Text(this.bookData.language)
                .fontSize("14vp")
                .fontColor("#ffffffff")
              Divider()
                .vertical(true)
                .margin({ left: 8, right: 8 })
              Text(`${this.bookData.extension}, ${this.bookData.filesizeString}`)
                .fontSize("14vp")
                .fontColor("#ffffffff")
            }
            // .justifyContent(FlexAlign.Start)
            .height("14vp")

            Button('下载')
              .width("90%")
          }
          .height("60%")
          .width("100%")
          .backgroundColor("#4A688A")

          Tabs() {
            TabContent() {
              Grid() {
                if (this.bookData.year !== undefined && this.bookData.year !== 0) {
                  this.BookInfoKeyGridItem("年份：")
                  this.BookInfoValueGridItem(`${this.bookData.year}`)
                }
                if (this.bookData.edition) {
                  this.BookInfoKeyGridItem("版本:")
                  this.BookInfoValueGridItem(`${this.bookData.edition}`)
                }
                if (this.bookData.publisher) {
                  this.BookInfoKeyGridItem("出版社:")
                  this.BookInfoValueGridItem(`${this.bookData.publisher}`)
                }
                if (this.bookData.language) {
                  this.BookInfoKeyGridItem("语言:")
                  this.BookInfoValueGridItem(`${this.bookData.language}`)
                }
                if (this.bookData.pages) {
                  this.BookInfoKeyGridItem("页数:")
                  this.BookInfoValueGridItem(`${this.bookData.pages}`)
                }
                if (this.bookData.identifier) {
                  this.BookInfoKeyGridItem("ISBN 10:")
                  this.BookInfoValueGridItem(`${this.bookData.identifier}`)

                  // fixme: series parse
                }
                if (this.bookData.series) {
                  this.BookInfoKeyGridItem("系列:")
                  this.BookInfoValueGridItem(`${this.bookData.series}`)
                }
                if (this.bookData.extension && this.bookData.filesizeString) {
                  this.BookInfoKeyGridItem("文件:")
                  this.BookInfoValueGridItem(`${this.bookData.extension}, ${this.bookData.filesizeString}`)
                  // fixme: 考虑只有ext或只有filesize的情况
                }
              }
              .columnsTemplate('1fr 3fr')
              .enableScrollInteraction(false)
              .supportAnimation(false)
            }
            .height("auto")
            .tabBar('书')

            TabContent() {
              Web({ src: '', controller: this.webController, renderMode: RenderMode.SYNC_RENDER })
                .onControllerAttached(() => { // 当Controller成功绑定到Web组件时触发该回调
                  this.webController.loadData(this.richStrHead + this.bookData?.description, 'text/html', 'UTF-8', ' ', ' ')
                })
                .width('100%')
                .layoutMode(WebLayoutMode.FIT_CONTENT)
                .overScrollMode(OverScrollMode.NEVER)
                .zoomAccess(false)
                .minFontSize(14)
                .javaScriptAccess(false)
            }
            .tabBar('描述')
          }
          .height("auto")
          .barMode(BarMode.Fixed)

          Text("您可能对以下内容感兴趣")
            .fontSize("18vp")
            .margin({
              top: "15vp",
              bottom: "4vp",
              left: "4vp"
            })
            .alignSelf(ItemAlign.Start)
          BookCoverWaterFlow({
            onInitialData: (): Promise<CoverData[]> => this.loadSimilar()
          })
        }
      }
    }
  }

  @Builder
  BookInfoKeyGridItem(text: string) {
    GridItem() {
      Text(text)
        .textAlign(TextAlign.Center)
        .margin({
          top: 15,
          left: 15,
        })
        .fontColor("#D6D5D8")
    }.align(Alignment.Start)
  }

  @Builder
  BookInfoValueGridItem(text: string) {
    GridItem() {
      Text(text)
        .textAlign(TextAlign.Center)
        .margin({
          top: 15
        })
    }.align(Alignment.Start)
  }
}