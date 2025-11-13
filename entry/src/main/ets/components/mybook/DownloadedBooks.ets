import { DownloadedViewModel } from "../../viewModel/mybook/DownloadedViewModel";
import { MyBookComponent } from "./MyBookComponent";

@ComponentV2
export struct DownloadedBooks {
  @Local viewModel: DownloadedViewModel = new DownloadedViewModel()
  @Param @Require sortOrder: string

  @Event updateEntriesAmount: (amount: number) => void;

  @Monitor("viewModel.pagination")
  onUpdatePagination() {
    this.updateEntriesAmount(this.viewModel.pagination?.total_items ?? 0)
  }

  build() {
    MyBookComponent({
      viewModel: this.viewModel,
      sortOrder: this.sortOrder
    })
  }
}