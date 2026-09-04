import { ListTopFade } from '../common/ListTopFade';
import { SearchViewModel } from '../../../viewModel/search/SearchResultViewModel';

import { BookInfoList } from '../common/BookInfoList';
import { EmptyContentPlaceholder } from '../common/EmptyContentPlaceholder';
import { ErrorStatePlaceholder } from '../common/ErrorStatePlaceholder';

@ComponentV2
export struct SearchResults {
  @Local topFadeOffset: number = 0;
  /**
   * view model of component
   */
  @Param @Require viewModel: SearchViewModel;
  @Provider() showSkeleton: boolean = this.viewModel.isLoading

  @Monitor("viewModel.isLoading")
  setShowSkeleton() {
    this.showSkeleton = this.viewModel.isLoading && this.viewModel.bookDataSource.length === 0
  }

  @Computed
  get showNormal() {
    return this.viewModel.bookDataSource.length > 0
  }

  @Computed
  get showErrorPlaceholder() {
    return !this.viewModel.isLoading
      && this.viewModel.isLoadFailed
  }

  @Computed
  get showEmptyPlaceholder() {
    return !this.viewModel.isLoading
      && this.viewModel.bookDataSource.length === 0
      && this.viewModel.searchKeyword
  }

  build() {
    Refresh({ refreshing: $$this.viewModel.isRefreshing }) {
      if (this.showNormal) {
        this.NormalContent()
      } else if (this.showErrorPlaceholder) {
        ErrorStatePlaceholder({
          onRefreshClick: async () => {
            if (!this.viewModel.isRefreshing) {
              this.viewModel.isRefreshing = true
              await this.viewModel.loadDataSource()
              this.viewModel.isRefreshing = false
            }
          }
        })
      } else if (this.showEmptyPlaceholder) {
        EmptyContentPlaceholder()
      } else {
        this.NormalContent()
      }
    }
    // Attach to Refresh so pulling its content does not move the top fade.
    .overlay(ListTopFade(this.showNormal ? this.topFadeOffset : 0), { align: Alignment.Top })
    .onRefreshing(async () => {
      await this.viewModel.loadDataSource()
      this.viewModel.isRefreshing = false
    })
  }

  @Builder
  NormalContent() {
    BookInfoList({
      onScrollOffsetChange: offset => { this.topFadeOffset = offset; },
      bookDataSource: this.viewModel.bookDataSource,
      pagination: this.viewModel.pagination,
      onLoadNewData: () => this.viewModel.loadNewData()
    })
    Footer(this.viewModel.isLoadingNew)
  }
}

@Builder
function Footer(isLoadingNew: boolean) {
  Row() {
    LoadingProgress().height(32).width(48)
    Text($r("app.string.ui_common_loading"))
  }.width("100%")
  .height(64)
  .justifyContent(FlexAlign.Center)
  .visibility(isLoadingNew ? Visibility.Visible : Visibility.Hidden)
}