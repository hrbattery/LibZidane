import { MostPopularViewModel } from '../../viewModel/library/MostPopularViewModel'
import { LibraryComponent } from './LibraryComponent'

@ComponentV2
export struct MostPopularBooks {
  @Local viewModel: MostPopularViewModel = new MostPopularViewModel()

  build() {
    LibraryComponent({
      viewModel: this.viewModel
    })
  }
}