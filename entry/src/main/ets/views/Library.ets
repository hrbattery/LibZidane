import { getBookInfo, getMostPopular } from "../api/BookApi"
import { BookDetailParam, CoverData, FullBookDataType } from "../models/BookModel"
import { LogUtil as logger } from "@pura/harmony-utils"
import { getRecommended } from "../api/UserApi"
import { BookCover } from "../components/BookCover"
import { BookCoverWaterFlow } from "../components/BookCoverWaterFlow"

/**
 *
 */

@ComponentV2
export struct Library {
  @Local tabCurrentIndex: number = 0

  async loadMostPopularDataSource() {
    try {
      let mostPopulars = await getMostPopular();
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
      // todo: toast error or use a 404 page
    }
    return []
  }

  async loadRecommendedDataSource() {
    try {
      let recommends = await getRecommended();
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
      // todo: toast error or use a 404 page
    }
    return []
  }

  build() {
    Column() {
      // TextInput({ placeholder: 'Search for...' })
      //   .width('90%')
      //   .height(45)
      //   .fontSize(16)
      //   .backgroundColor('#F0F2F4')
      //   .onChange(value => this.searchText = value)

      Tabs({index: this.tabCurrentIndex}) {
        TabContent() {
          BookCoverWaterFlow({
            onInitialData: this.loadRecommendedDataSource
          })
        }
        .tabBar('推荐的')
        TabContent() {
          BookCoverWaterFlow({
            onInitialData: this.loadMostPopularDataSource
          })
        }
        .tabBar('最受欢迎的')
      }.barMode(BarMode.Fixed)

    }
  }
}