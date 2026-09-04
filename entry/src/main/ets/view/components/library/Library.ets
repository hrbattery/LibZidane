import { FLOATING_TAB_BAR_INSET } from '../common/NavigationStyle';
import { RecommendedBooks } from "./RecommendedBooks"
import { MostPopularBooks } from "./MostPopularBooks"

@ComponentV2
export struct Library {
  @Provider() floatingTabBarInset: number = FLOATING_TAB_BAR_INSET;
  @Local tabCurrentIndex: number = 0

  build() {
    Column() {
      Tabs({ index: this.tabCurrentIndex }) {
        TabContent() {
          RecommendedBooks()
        }
        .tabBar($r("app.string.ui_library_recommended_tab"))
        TabContent() {
          MostPopularBooks()
        }
        .tabBar($r("app.string.ui_library_most_popular_tab"))
      }
      .barMode(BarMode.Fixed)
      .onChange((index) => {
        this.tabCurrentIndex = index;
      })
    }
  }
}