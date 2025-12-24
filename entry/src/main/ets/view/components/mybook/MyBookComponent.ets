import { MyBookComponentViewModel } from '../../../viewModel/mybook/MyBookComponentViewModel';

import { BookInfoList } from '../common/BookInfoList';
import { EmptyContentPlaceholder } from '../common/EmptyContentPlaceholder';
import { ErrorStatePlaceholder } from '../common/ErrorStatePlaceholder';
import { LogoutStatePlaceholder } from '../common/LogoutStatePlaceholder';

@ComponentV2
export struct MyBookComponent {
  /**
   * view model of component
   */
  @Param @Require sortOrder: string;
  @Param @Require viewModel: MyBookComponentViewModel;
  @Provider() onRemove: (index: number) => Promise<void> = async (index: number) => await this.viewModel.onRemove(index)

  @Monitor('sortOrder')
  onSortOrderChange(): void {
    this.viewModel.loadDataSource(this.sortOrder);
  }

  async aboutToAppear(): Promise<void> {
    await this.viewModel.loadDataSource(this.sortOrder)
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
  get showLogoutPlaceholder() {
    return !this.viewModel.isLoading
      && !this.viewModel.appState.loginState
  }

  @Computed
  get showEmptyPlaceholder() {
    return !this.viewModel.isLoading
      && !this.viewModel.isLoadFailed
      && this.viewModel.bookDataSource.length === 0
  }

  build() {
    Refresh({ refreshing: $$this.viewModel.isRefreshing }) {
      if (this.showNormal) {
        BookInfoList({
          bookDataSource: this.viewModel.bookDataSource,
          pagination: this.viewModel.pagination,
          onLoadNewData: () => this.viewModel.loadNewData(this.sortOrder)
        })
        Footer(this.viewModel.isLoadingNew)
      } else if (this.showSkeleton) {
        // todo: skeleton impl
      } else if (this.showLogoutPlaceholder) {
        LogoutStatePlaceholder()
      } else if (this.showErrorPlaceholder) {
        ErrorStatePlaceholder({
          onRefreshClick: async () => {
            if (!this.viewModel.isRefreshing) {
              this.viewModel.isRefreshing = true
              await this.viewModel.loadDataSource(this.sortOrder)
              this.viewModel.isRefreshing = false
            }
          }
        })
      } else if (this.showEmptyPlaceholder) {
        EmptyContentPlaceholder()
      } else {
        BookInfoList({
          bookDataSource: this.viewModel.bookDataSource,
          pagination: this.viewModel.pagination,
          onLoadNewData: () => this.viewModel.loadNewData(this.sortOrder)
        })
        Footer(this.viewModel.isLoadingNew)
      }
    }
    .onRefreshing(async () => {
      await this.viewModel.loadDataSource(this.sortOrder)
      this.viewModel.isRefreshing = false
    })
    .width("100%")
    .height("100%")
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