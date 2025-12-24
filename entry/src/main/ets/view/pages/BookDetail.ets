import { common } from '@kit.AbilityKit';
import { BookDetailParam } from '../../model/entities/BookModel';
import { BookDetailViewModel } from '../../viewModel/bookdetail/BookDetailViewModel';
import { BookDetailDescription } from '../components/bookdetail/BookDetailDescription';
import { BookDetailHeader } from '../components/bookdetail/BookDetailHeader';
import { BookCoverWaterFlow } from '../components/common/BookCoverWaterFlow';


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

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          if (this.viewModel.bookData !== undefined) {
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
      }
    }
    .onReady(async (context: NavDestinationContext) => {
      let param = context.pathInfo.param as BookDetailParam;
      this.viewModel.bookId = param.bookId;
      this.viewModel.hash = param.hash;
      await this.viewModel.loadPageData()
    })
    .menus(this.navMenu)
  }
}