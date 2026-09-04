import { HdsNavDestination } from '@kit.UIDesignKit';
import { destinationTitle } from '../components/common/NavigationStyle';
import { common } from '@kit.AbilityKit';
import { BookDetailParam } from '../../model/entities/BookModel';
import { BookDetailViewModel } from '../../viewModel/bookdetail/BookDetailViewModel';
import { BookDetailDescription } from '../components/bookdetail/BookDetailDescription';
import { BookDetailHeader } from '../components/bookdetail/BookDetailHeader';
import { BookCoverWaterFlow } from '../components/common/BookCoverWaterFlow';
import { windowUtil } from '../../common/system/WindowUtil';


@Builder
export function BookDetailBuilder() {
  BookDetailPage()
}

@ComponentV2
struct BookDetailPage {
  @Local viewModel: BookDetailViewModel = new BookDetailViewModel()
  @Provider() showSkeleton: boolean = this.viewModel.isLoading

  @Monitor("viewModel.isLoading")
  setShowSkeleton() {
    this.showSkeleton = this.viewModel.isLoading
  }

  @Computed
  get navMenu(): NavigationMenuItem[] {
    if (this.showSkeleton) {
      return []
    }
    if (this.viewModel.isUserFavorite) {
      return [
        {
          'value': $r("app.string.ui_bookdetail_menu_share"),
          'icon': $r("app.media.share"),
          'action': () => this.viewModel.shareBook(this.getUIContext().getHostContext() as common.UIAbilityContext)
        },
        {
          'value': $r("app.string.ui_bookdetail_menu_favorite"),
          'icon': $r("app.media.star_fill"),
          'action': () => this.viewModel.onClickStar()
        }
      ]
    } else {
      return [
        {
          'value': $r("app.string.ui_bookdetail_menu_share"),
          'icon': $r("app.media.share"),
          'action': () => this.viewModel.shareBook(this.getUIContext().getHostContext() as common.UIAbilityContext)
        },
        {
          'value': $r("app.string.ui_bookdetail_menu_favorite"),
          'icon': $r("app.media.star"),
          'action': () => this.viewModel.onClickStar()
        }
      ]
    }
  }

  /** 复用首页的渐变配色并反转方向，固定遮盖底部边缘且不拦截手势。 */
  @Builder
  BottomFade() {
    Row() {}
      .width('100%')
      .height(32)
      .linearGradient({
        direction: GradientDirection.Top,
        colors: [[$r('app.color.book_list_top_fade'), 0], [$r('app.color.book_list_top_fade_transparent'), 1]]
      })
      .hitTestBehavior(HitTestMode.None)
  }

  /** 让书籍内容滚动至底部手势区，同时在滚动末尾为最后一行保留可见空间。 */
  build() {
    HdsNavDestination() {
      Scroll() {
        Column() {
          BookDetailHeader({
            bookData: this.viewModel.bookData,
            bookFormats: this.viewModel.bookFormats
          })

          BookDetailDescription({ bookData: this.viewModel.bookData })

          Text($r("app.string.ui_bookdetail_recommended"))
            .fontSize(18)
            .margin({ top: 15, bottom: 4, left: 10 })
            .alignSelf(ItemAlign.Start)

          BookCoverWaterFlow({
            coverDataSource: this.viewModel.similarBookCoverDataSource
          })
            .padding({ left: 5, right: 5 })
        }
      }
      .contentEndOffset(windowUtil.mainWindowInfo.bottomInset)
      .overlay(this.BottomFade(), { align: Alignment.Bottom })
    }
    .onReady(async (context: NavDestinationContext) => {
      let param = context.pathInfo.param as BookDetailParam;
      this.viewModel.bookId = param.bookId;
      this.viewModel.hash = param.hash;
      await this.viewModel.loadPageData()
    })
    .titleBar(destinationTitle('', this.navMenu))
    .ignoreLayoutSafeArea([LayoutSafeAreaType.SYSTEM], [LayoutSafeAreaEdge.BOTTOM])
  }
}
