import { getDownloaded, getFavorite } from "../api/UserApi"
import { BookData, BookDataType } from "../models/BookModel"
import { LogUtil as logger } from "@pura/harmony-utils"
import { BookInfoList, BookInfoListParam } from "../components/BookInfoList"
import { PaginationDataSource } from "../common/DataSourceTypes"

@ComponentV2
export struct MyBook {
  @Local tabCurrentIndex: number = 0

  @Local favoritesBooks: BookData[] = []
  @Local favoritesPagination: PaginationDataSource | undefined;

  @Local downloadedBooks: BookData[] = []
  @Local downloadedPagination: PaginationDataSource | undefined;

  async loadFavoritesDataSource(): Promise<void> {
    try {
      let favorites = await getFavorite();
      if (favorites !== null) {
        this.favoritesBooks = favorites.books.map(element => new BookData(element as BookDataType))
        this.favoritesPagination = favorites.pagination
      }
    } catch (e) {
      logger.error(e)
      // todo: toast error or use a 404 page
    }
  }

  async loadNewFavorites(): Promise<void> {
    if (this.favoritesPagination) {
      try {
        let favorites = await getFavorite({
          page: this.favoritesPagination?.current + 1
        });
        if (favorites !== null) {
          this.favoritesBooks.push(...favorites.books.map(element => new BookData(element as BookDataType)))
          this.favoritesPagination = favorites.pagination
        }
      } catch (e) {
        logger.error(e)
        // todo: toast error or use a 404 page
      }
    }
  }

  async loadDownloadedDataSource(): Promise<void> {
    try {
      let downloaded = await getDownloaded();
      if (downloaded !== null) {
        this.downloadedBooks = downloaded.books.map(element => new BookData(element as BookDataType))
        this.downloadedPagination = downloaded.pagination
      }
    } catch (e) {
      logger.error(e)
      // todo: toast error or use a 404 page
    }
  }

  async loadNewDownloads(): Promise<void> {
    if (this.downloadedPagination) {
      try {
        let downloaded = await getDownloaded({
          page: this.downloadedPagination?.current + 1
        });
        if (downloaded !== null) {
          this.downloadedBooks.push(...downloaded.books.map(element => new BookData(element as BookDataType)))
          this.downloadedPagination = downloaded.pagination
        }
      } catch (e) {
        logger.error(e)
        // todo: toast error or use a 404 page
      }
    }
  }

  build() {
    Column() {
      Tabs({index: this.tabCurrentIndex}) {
        TabContent() {
          BookInfoList({
            bookDataSource: this.favoritesBooks,
            pagination: this.favoritesPagination,
            onInitialData: (): Promise<void> => this.loadFavoritesDataSource(),
            onLoadNewData: (): Promise<void> => this.loadNewFavorites(),
            onRefreshData: (): Promise<void> => this.loadFavoritesDataSource()
          })
        }
        .tabBar('选集' + (this.favoritesPagination ? ` ( ${this.favoritesPagination.total_items} )` : ''))
        TabContent() {
          BookInfoList({
            bookDataSource: this.downloadedBooks,
            pagination: this.downloadedPagination,
            onInitialData: (): Promise<void> => this.loadDownloadedDataSource(),
            onLoadNewData: (): Promise<void> => this.loadNewDownloads(),
            onRefreshData: (): Promise<void> => this.loadDownloadedDataSource()
          })
        }
        .tabBar('已下载' + (this.downloadedPagination ? ` ( ${this.downloadedPagination.total_items} )` : ''))
      }.barMode(BarMode.Fixed)
    }
  }
}