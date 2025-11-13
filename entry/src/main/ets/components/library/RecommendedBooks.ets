import { RecommendedViewModel } from "../../viewModel/library/RecommendedViewModel"
import { LibraryComponent } from "./LibraryComponent"

@ComponentV2
export struct RecommendedBooks {
  @Local viewModel: RecommendedViewModel = new RecommendedViewModel()

  build() {
    LibraryComponent({
      viewModel: this.viewModel
    })
  }
}