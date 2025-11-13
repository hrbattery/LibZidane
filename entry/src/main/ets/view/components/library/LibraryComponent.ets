import { LibraryComponentViewModel } from "../../../viewModel/library/LibraryComponentViewModel"

import { BookCoverWaterFlow } from "../common/BookCoverWaterFlow"
import { ErrorStatePlaceholder } from "../common/ErrorStatePlaceholder"

@ComponentV2
export struct LibraryComponent {
  /**
   * view model of component
   */
  @Param @Require viewModel: LibraryComponentViewModel;

  async aboutToAppear(): Promise<void> {
    await this.viewModel.loadDataSource()
  }

  build() {
    Refresh({ refreshing: this.viewModel.isRefreshing!! }) {
      // todo: empty placeholder && skeleton
      if (this.viewModel.isLoadFailed) {
        ErrorStatePlaceholder({
          onRefreshClick: async () => await this.viewModel.loadDataSource()
        })
      } else {
        BookCoverWaterFlow({
          coverDataSource: this.viewModel.coverDataSource
        })
      }
    }
    .onRefreshing(async () => {
      await this.viewModel.loadDataSource()
      this.viewModel.isRefreshing = false
    })
  }
}