import { common } from '@kit.AbilityKit';
import { uniformTypeDescriptor as utd } from '@kit.ArkData';
import { webview } from '@kit.ArkWeb';
import { BusinessError } from '@kit.BasicServicesKit';
import { systemShare } from '@kit.ShareKit';
import { LogUtil as logger } from '@pura/harmony-utils';
import { bookDataCache } from '../../common/cache/BookDataCache';
import { getBookFormat, getBookInfo, getSimilar } from '../../model/api/BookApi';
import { saveBook, unsaveBook } from '../../model/api/UserApi';
import { BookDetailParam, BookFormatType, CoverData, FullBookData } from '../../model/entities/BookModel';
import { CoverDataFactory, FullBookDataFactory } from '../../model/factory/BookModelFactory';
import { BookFormatSheet } from '../components/bookdetail/BookFormatSheet';
import { BookCover } from '../components/common/BookCover';
import { BookCoverWaterFlow } from '../components/common/BookCoverWaterFlow';


@Builder
export function BookDetailBuilder() {
  BookDetailPage()
}

@ComponentV2
struct BookDetailPage {
  pathStack: NavPathStack | undefined = undefined;
  @Local bookId: number = 0
  @Local hash: string = "";
  @Local bookData: FullBookData | undefined = undefined
  @Local isUserFavorite: boolean = false
  @Local navMenu: NavigationMenuItem[] = [
    {
      'value': "分享",
      'icon': $r("app.media.share"),
      'action': () => this.shareBook()
    },
    {
      'value': "收藏",
      'icon': $r("app.media.star"),
      'action': () => this.onClickStar()
    }
  ]
  @Local bookFormats: BookFormatType[] = []
  @Local isShowSelectFormatSheet: boolean = false
  @Local similarBookCoverDataSource: CoverData[] = []
  webController: webview.WebviewController = new webview.WebviewController()
  richStrHead: string = '<head><meta name="viewport" content="width=device-width, initial-scale=1"></head>'

  @Monitor('isUserFavorite')
  triggerStarButtonChange() {
    // todo: 看看能不能改良这段代码逻辑，现在直接赋值太粗暴了，用别的装饰器试试
    if (this.isUserFavorite) {
      this.navMenu = [
        {
          'value': "分享",
          'icon': $r("app.media.share"),
          'action': () => {
          }
        },
        {
          'value': "收藏",
          'icon': $r("app.media.star_fill"),
          'action': () => this.onClickStar()
        }
      ]
    } else {
      this.navMenu = [
        {
          'value': "分享",
          'icon': $r("app.media.share"),
          'action': () => {
          }
        },
        {
          'value': "收藏",
          'icon': $r("app.media.star"),
          'action': () => this.onClickStar()
        }
      ]
    }
  }

  shareBook() {
    const baseUrl = AppStorage.get("base_url") as string ?? "https://z-library.sk"

    if (this.bookData) {
      let shareData: systemShare.SharedData = new systemShare.SharedData({
        utd: utd.UniformDataType.HYPERLINK,
        content: baseUrl + this.bookData.href,
        title: this.bookData.title,
        description: baseUrl + this.bookData.href
      });

      let controller: systemShare.ShareController = new systemShare.ShareController(shareData);
      let context = this.getUIContext().getHostContext() as common.UIAbilityContext;
      controller.show(context, {
        selectionMode: systemShare.SelectionMode.SINGLE,
        previewMode: systemShare.SharePreviewMode.DEFAULT,
      }).then(() => {
        logger.info('ShareController show success.');
      }).catch((error: BusinessError) => {
        logger.error(`ShareController show error. code: ${error.code}, message: ${error.message}`);
      });
    }
  }

  async onClickStar(): Promise<void> {
    try {
      this.isUserFavorite = !this.isUserFavorite
      !this.isUserFavorite ? await unsaveBook(this.bookId) : await saveBook(this.bookId);
      bookDataCache.clearCache(`${this.bookId}_${this.hash}`);
    } catch (e) {
      logger.error(e)
      this.isUserFavorite = !this.isUserFavorite
      // todo: toast error or use a 404 page
    }
  }

  async loadBookData() {
    const cache = bookDataCache.getCache(`${this.bookId}_${this.hash}`);
    if (!cache) {
      try {
        let bookData = await getBookInfo(this.bookId, this.hash);
        if (bookData) {
          this.bookData = FullBookDataFactory.fromBookCommonDataSource(bookData);
          bookDataCache.setCache(`${this.bookId}_${this.hash}`, this.bookData)
        }
      } catch (e) {
        logger.error(e)
        // todo: toast error or use a 404 page
      }
    } else {
      this.bookData = cache
    }
    this.isUserFavorite = !!this.bookData?._isFavorite
  }

  async loadSimilar() {
    let similar = await getSimilar(this.bookId, this.hash);
    this.similarBookCoverDataSource = similar.map(element => {
      return CoverDataFactory.fromCoverDataSource(element)
    })
  }

  showSelectFormatSheet(): void {
    this.isShowSelectFormatSheet = true;
  }

  handleSelectFormatSheet(): void {
    this.isShowSelectFormatSheet = false;
  }

  async loadDownloadFormats() {
    this.bookFormats = await getBookFormat(this.bookId, this.hash) as BookFormatType[];
  }

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          if (this.bookData !== undefined) {
            Flex({
              direction: FlexDirection.Column,
              justifyContent: FlexAlign.SpaceAround,
              alignItems: ItemAlign.Center
            }) {
              BookCover({
                coverData: this.bookData
              })
                .width("30%")
                .constraintSize({
                  maxWidth: 120
                })
              Text(this.bookData.title)
                .fontSize("16vp")
                .fontColor("#ffffffff")
                .fontWeight(FontWeight.Bold)
                .margin({ "left": "10vp", "right": "10vp" })
                .textAlign(TextAlign.Center)
              Text(this.bookData.author)
                .fontSize("14vp")
                .fontColor("#ffdadada")
                .textAlign(TextAlign.Center)
                .margin({ "left": "10vp", "right": "10vp" })
                .onClick(() => {
                  this.pathStack?.pushPathByName("Search", this.bookData?.author)
                })
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
                .onClick(() => this.showSelectFormatSheet())
                .bindSheet(this.isShowSelectFormatSheet!!, this.BookFormatSheetBuilder(
                  this.bookData,
                  this.bookFormats,
                  () => this.handleSelectFormatSheet()
                ), {
                  detents: [SheetSize.MEDIUM, SheetSize.LARGE, 600],
                  preferType: SheetType.BOTTOM,
                  title: { title: '选择格式' },
                  scrollSizeMode: ScrollSizeMode.CONTINUOUS
                })
            }
            .height("60%")
            .width("100%")
            .backgroundColor("#4A688A")

            this.BookDetailDescription(this.bookData)

            Text("您可能对以下内容感兴趣")
              .fontSize(18)
              .margin({
                top: 15,
                bottom: 4,
                left: 10
              })
              .alignSelf(ItemAlign.Start)
            BookCoverWaterFlow({
              coverDataSource: this.similarBookCoverDataSource
            })
              .padding({ left: 5, right: 5 })
          }
        }
      }
    }
    .onReady(async (context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
      let param = context.pathInfo.param as BookDetailParam;
      this.bookId = param.bookId;
      this.hash = param.hash;
      await Promise.all([
        this.loadBookData(),
        this.loadDownloadFormats(),
        this.loadSimilar()
      ])
    })
    .menus(this.navMenu)
  }

  @Builder
  BookDetailDescription(bookData: FullBookData) {
    Tabs() {
      TabContent() {
        Grid() {
          if (bookData.year !== undefined && bookData.year !== 0) {
            this.BookInfoKeyGridItem("年份：");
            this.BookInfoValueGridItem(`${bookData.year}`);
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
          if (bookData.identifier) {
            this.BookInfoKeyGridItem("ISBN 10:");
            this.BookInfoValueGridItem(`${bookData.identifier}`);

            // fixme: series parse
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
        .supportAnimation(false);
      }
      .height("auto")
      .tabBar('书');

      TabContent() {
        Web({ src: '', controller: this.webController, renderMode: RenderMode.SYNC_RENDER })
          .onControllerAttached(() => {
            this.webController.loadData(this.richStrHead + this.bookData?.description, 'text/html', 'UTF-8', ' ', ' ');
          })
          .width('100%')
          .layoutMode(WebLayoutMode.FIT_CONTENT)
          .overScrollMode(OverScrollMode.NEVER)
          .zoomAccess(false)
          .minFontSize(14)
          .javaScriptAccess(false);
      }
      .tabBar('描述');
    }
    .height("auto")
    .barMode(BarMode.Fixed)
  }

  @Builder
  BookInfoKeyGridItem(text: string) {
    GridItem() {
      Text(text)
        .textAlign(TextAlign.Center)
        .fontColor("#D6D5D8")
    }.align(Alignment.Start)
  }

  @Builder
  BookInfoValueGridItem(text: string) {
    GridItem() {
      Text(text)
        .textAlign(TextAlign.Center)
    }.align(Alignment.Start)
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