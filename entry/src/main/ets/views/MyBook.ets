import { getDownloaded, getFavorite } from "../api/UserApi"
import { BookData, BookDataType } from "../models/BookModel"
import { LogUtil as logger } from "@pura/harmony-utils"
import { BookInfoList, BookInfoListParam } from "../components/BookInfoList"

@ComponentV2
export struct MyBook {
  @Local tabCurrentIndex: number = 0

  @Local favouritesItemAmount: number | undefined;
  @Local downloadedItemAmount: number | undefined;

  async loadFavoriteDataSource(order?: string, page?: number, limit?: number): Promise<BookInfoListParam> {
    try {
      let favorites = await getFavorite(order, page, limit);
      if (favorites !== null) {
        return {
          books: favorites.books.map(element => {
            return new BookData(element as BookDataType)
          }),
          pagination: favorites.pagination
        }
      }
    } catch (e) {
      logger.error(e)
      // todo: toast error or use a 404 page
    }
    return {
      books: [],
      pagination: undefined
    }
  }

  async loadDownloadedDataSource(order?: string, page?: number, limit?: number): Promise<BookInfoListParam> {
    try {
      let downloaded = await getDownloaded(order, page, limit);
      if (downloaded !== null) {
        return {
          books: downloaded.books.map(element => {
            return new BookData(element as BookDataType)
          }),
          pagination: downloaded.pagination
        }
      }
    } catch (e) {
      logger.error(e)
      // todo: toast error or use a 404 page
    }
    return {
      books: [],
      pagination: undefined
    }
  }

  build() {
    Column() {
      Tabs({index: this.tabCurrentIndex}) {
        TabContent() {
          BookInfoList({
            onInitialData: (order?: string, page?: number, limit?: number): Promise<BookInfoListParam> => this.loadFavoriteDataSource(order, page, limit),
            onLoadNewData: (order?: string, page?: number, limit?: number): Promise<BookInfoListParam> => this.loadFavoriteDataSource(order, page, limit),
            onRefreshData: (order?: string, page?: number, limit?: number): Promise<BookInfoListParam> => this.loadFavoriteDataSource(order, page, limit),
            updateAmount: (amount: number | undefined) => {
              this.favouritesItemAmount = amount
            }
          })
        }
        .tabBar('选集' + (this.favouritesItemAmount ? ` ( ${this.favouritesItemAmount} )` : ''))
        TabContent() {
          BookInfoList({
            onInitialData: (order?: string, page?: number, limit?: number): Promise<BookInfoListParam> => this.loadDownloadedDataSource(order, page, limit),
            onLoadNewData: (order?: string, page?: number, limit?: number): Promise<BookInfoListParam> => this.loadDownloadedDataSource(order, page, limit),
            onRefreshData: (order?: string, page?: number, limit?: number): Promise<BookInfoListParam> => this.loadDownloadedDataSource(order, page, limit),
            updateAmount: (amount: number | undefined) => {
              this.downloadedItemAmount = amount
            }
          })
        }
        .tabBar('已下载' + (this.downloadedItemAmount ? ` ( ${this.downloadedItemAmount} )` : ''))
      }.barMode(BarMode.Fixed)
    }
  }
}