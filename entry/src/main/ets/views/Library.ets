import { getMostPopular } from "../api/BookApi"
import { CoverData } from "../models/BookModel"
import { LogUtil as logger } from "@pura/harmony-utils"
import { getRecommended } from "../api/UserApi"
import { BookCoverWaterFlow } from "../components/BookCoverWaterFlow"
import { ErrorStatePlaceholder } from "../components/ErrorStatePlaceholder"

@ComponentV2
export struct Library {
  @Local tabCurrentIndex: number = 0
  @Local isShowMostPopularEmpty: boolean = false;
  @Local isShowRecommendedEmpty: boolean = false

  async loadMostPopularDataSource() {
    try {
      let mostPopulars = await getMostPopular();
      this.isShowMostPopularEmpty = false;
      return mostPopulars.map(element => {
        return new CoverData(
          element.id,
          element.hash,
          element.title,
          element.author,
          element.cover
        )
      })
    } catch (e) {
      logger.error(e)
      this.isShowMostPopularEmpty = true;
    }
    return []
  }

  async loadRecommendedDataSource() {
    try {
      let recommends = await getRecommended();
      this.isShowRecommendedEmpty = false;
       return recommends.map(element => {
        return new CoverData(
          element.id,
          element.hash,
          element.title,
          element.author,
          element.cover
        )
      })
    } catch (e) {
      logger.error(e)
      this.isShowRecommendedEmpty = true;
    }
    return []
  }

  build() {
    Column() {
      Tabs({index: this.tabCurrentIndex}) {
        TabContent() {
          if (this.isShowRecommendedEmpty) {
            ErrorStatePlaceholder({
              onRefreshClick: async () => await this.loadRecommendedDataSource()
            })
          } else {
            BookCoverWaterFlow({
              onInitialData: async () => await this.loadRecommendedDataSource(),
              onRefreshData: async () => await this.loadRecommendedDataSource()
            })
          }

        }
        .tabBar('推荐的')
        TabContent() {
          if (this.isShowMostPopularEmpty) {
            ErrorStatePlaceholder({
              onRefreshClick: async () => await this.loadMostPopularDataSource()
            })
          } else {
            BookCoverWaterFlow({
              onInitialData: async () => await this.loadMostPopularDataSource(),
              onRefreshData: async () => await this.loadMostPopularDataSource()
            })
          }
        }
        .tabBar('最受欢迎的')
      }.barMode(BarMode.Fixed)
    }
  }
}