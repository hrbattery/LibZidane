import { RecommendedBooks } from "./RecommendedBooks"
import { MostPopularBooks } from "./MostPopularBooks"

@ComponentV2
export struct Library {
  @Local tabCurrentIndex: number = 0

  build() {
    Column() {
      Tabs({ index: this.tabCurrentIndex!! }) {
        TabContent() {
          RecommendedBooks()
        }
        .tabBar('推荐的')
        TabContent() {
          MostPopularBooks()
        }
        .tabBar('最受欢迎的')
      }.barMode(BarMode.Fixed)
    }
  }
}