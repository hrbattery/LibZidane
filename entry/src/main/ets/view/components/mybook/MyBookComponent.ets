import { LibraryComponentViewModel } from "../../../viewModel/library/LibraryComponentViewModel"
import { MyBookComponentViewModel } from "../../../viewModel/mybook/MyBookComponentViewModel";

import { BookCoverWaterFlow } from "../common/BookCoverWaterFlow"
import { BookInfoList } from "../common/BookInfoList";
import { ErrorStatePlaceholder } from "../common/ErrorStatePlaceholder"

@ComponentV2
export struct MyBookComponent {
  /**
   * view model of component
   */
  @Param @Require sortOrder: string;
  @Param @Require viewModel: MyBookComponentViewModel;

  @Monitor('sortOrder')
  onSortOrderChange(): void {
    this.viewModel.loadDataSource(this.sortOrder);
  }

  async aboutToAppear(): Promise<void> {
    await this.viewModel.loadDataSource(this.sortOrder)
  }

  build() {
    Refresh({ refreshing: this.viewModel.isRefreshing!! }) {
      // todo: empty placeholder && skeleton
      if (this.viewModel.isLoadFailed) {
        ErrorStatePlaceholder({
          onRefreshClick: async () => await this.viewModel.loadDataSource(this.sortOrder)
        })
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