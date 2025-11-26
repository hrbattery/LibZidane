import { SearchViewModel } from '../../../viewModel/search/SearchResultViewModel';

import { BookInfoList } from '../common/BookInfoList';
import { EmptyContentPlaceholder } from '../common/EmptyContentPlaceholder';
import { ErrorStatePlaceholder } from '../common/ErrorStatePlaceholder';

@ComponentV2
export struct SearchResults {
  /**
   * view model of component
   */
  @Param @Require viewModel: SearchViewModel;

  async aboutToAppear(): Promise<void> {
    await this.viewModel.loadDataSource()
  }

  @Computed
  get showNormal() {
    return this.viewModel.bookDataSource.length > 0
  }

  @Computed
  get showSkeleton() {
    return this.viewModel.isLoading
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
  }

  build() {
    Refresh({ refreshing: this.viewModel.isRefreshing!! }) {
      if (this.showNormal) {
        // this.SearchResultAmount()
        this.NormalContent()
      } else if (this.showSkeleton) {
        // todo: skeleton impl
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
        // this.SearchResultAmount()
        EmptyContentPlaceholder()
      } else {
        // this.SearchResultAmount()
        this.NormalContent()
      }
    }
    .onRefreshing(async () => {
      await this.viewModel.loadDataSource()
      this.viewModel.isRefreshing = false
    })
  }

  @Builder
  NormalContent() {
    BookInfoList({
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
    Text("加载中")
  }.width("100%")
  .height(64)
  .justifyContent(FlexAlign.Center)
  .visibility(isLoadingNew ? Visibility.Visible : Visibility.Hidden)
}