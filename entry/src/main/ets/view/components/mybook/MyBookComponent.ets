import { ListTopFade } from '../common/ListTopFade';
import { MyBookComponentViewModel } from '../../../viewModel/mybook/MyBookComponentViewModel';

import { BookInfoList } from '../common/BookInfoList';
import { EmptyContentPlaceholder } from '../common/EmptyContentPlaceholder';
import { ErrorStatePlaceholder } from '../common/ErrorStatePlaceholder';
import { LogoutStatePlaceholder } from '../common/LogoutStatePlaceholder';

@ComponentV2
export struct MyBookComponent {
  @Local topFadeOffset: number = 0;
  /**
   * view model of component
   */
  @Param @Require sortOrder: string;
  @Param @Require viewModel: MyBookComponentViewModel;
  @Provider() onRemove: (index: number) => Promise<void> = async (index: number) => await this.viewModel.onRemove(index)
  @Provider() showSkeleton: boolean = this.viewModel.isLoading

  @Monitor("viewModel.isLoading")
  setShowSkeleton() {
    this.showSkeleton = this.viewModel.isLoading && this.viewModel.bookDataSource.length === 0
  }

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
          onScrollOffsetChange: offset => { this.topFadeOffset = offset; },
          bookDataSource: this.viewModel.bookDataSource,
          pagination: this.viewModel.pagination,
          onLoadNewData: () => this.viewModel.loadNewData(this.sortOrder)
        })
        Footer(this.viewModel.isLoadingNew)
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
          onScrollOffsetChange: offset => { this.topFadeOffset = offset; },
          bookDataSource: this.viewModel.bookDataSource,
          pagination: this.viewModel.pagination,
          onLoadNewData: () => this.viewModel.loadNewData(this.sortOrder)
        })
        Footer(this.viewModel.isLoadingNew)
      }
    }
    // Attach to Refresh so pulling its content does not move the top fade.
    .overlay(ListTopFade(this.showNormal ? this.topFadeOffset : 0), { align: Alignment.Top })
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