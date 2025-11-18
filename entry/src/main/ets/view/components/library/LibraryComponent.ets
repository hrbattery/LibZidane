import { LibraryComponentViewModel } from "../../../viewModel/library/LibraryComponentViewModel"

import { BookCoverWaterFlow } from "../common/BookCoverWaterFlow"
import { EmptyContentPlaceholder } from "../common/EmptyContentPlaceholder";
import { ErrorStatePlaceholder } from "../common/ErrorStatePlaceholder"
import { LogoutStatePlaceholder } from "../common/LogoutStatePlaceholder";

@ComponentV2
export struct LibraryComponent {
  /**
   * view model of component
   */
  @Param @Require viewModel: LibraryComponentViewModel;

  async aboutToAppear(): Promise<void> {
    await this.viewModel.loadDataSource()
  }

  @Computed
  get showNormal() {
    return this.viewModel.coverDataSource.length > 0
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
      && this.viewModel.needLoginStatus
      && !this.viewModel.appState.loginState
  }

  @Computed
  get showEmptyPlaceholder() {
    return !this.viewModel.isLoading
    && !this.viewModel.isLoadFailed
    && this.viewModel.coverDataSource.length === 0
  }

  build() {
    Refresh({ refreshing: this.viewModel.isRefreshing!! }) {
      if (this.showNormal) {
        BookCoverWaterFlow({
          coverDataSource: this.viewModel.coverDataSource
        })
      } else if (this.showSkeleton) {
        // todo: skeleton impl
      } else if (this.showLogoutPlaceholder) {
        LogoutStatePlaceholder()
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