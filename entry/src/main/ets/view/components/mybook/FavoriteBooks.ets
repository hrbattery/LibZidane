import { FavoriteViewModel } from "../../../viewModel/mybook/FavoriteViewModel";
import { MyBookComponent } from "./MyBookComponent";

@ComponentV2
export struct FavoriteBooks {
  @Local viewModel: FavoriteViewModel = new FavoriteViewModel()
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