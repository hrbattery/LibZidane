import { getDownloaded, getFavorite } from "../api/UserApi"
import { BookData, BookDataType } from "../models/BookModel"
import { LogUtil as logger } from "@pura/harmony-utils"
import { BookInfoList, BookInfoListParam } from "../components/BookInfoList"
import { PaginationDataSource } from "../common/ResponseTypes"
import { Constants } from "../common/const/Constants"

@ComponentV2
export struct MyBook {
  @Local tabCurrentIndex: number = 0

  @Local favoritesBooks: BookData[] = []
  @Local favoritesPagination: PaginationDataSource | undefined;
  @Param favoriteOrder: number = 0; // 排序方式：saved_date, saved_dateA

  @Local downloadedBooks: BookData[] = []
  @Local downloadedPagination: PaginationDataSource | undefined;
  @Param downloadedOrder: number = 0; // 排序方式：downloaded_date, downloaded_dateA, titleA, title, filesize, filesizeA, year

  // 暴露给父组件的事件回调
  @Event onSortRequest?: (orderBy: string) => void;
  @Event onMyBookTabIndexChange?: (index: number) => void;

  // 监听收藏排序参数变化
  @Monitor('favoriteOrder') 
  onFavoriteOrderChange(): void {
    if (this.tabCurrentIndex === 0) {
      this.loadFavoritesDataSource();
    }
  }

  // 监听下载排序参数变化
  @Monitor('downloadedOrder')
  onDownloadedOrderChange(): void {
    if (this.tabCurrentIndex === 1) {
      this.loadDownloadedDataSource();
    }
  }

  @Monitor('tabCurrentIndex')
  onTabIndexChange(): void {
    if (this.onMyBookTabIndexChange) {
      this.onMyBookTabIndexChange(this.tabCurrentIndex);
    }
  }

  async loadFavoritesDataSource(): Promise<void> {
    try {
      let favorites = await getFavorite({
        order: Constants.FAVORITES_SORT_KEY[this.favoriteOrder]["value"]
      });
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
          page: this.favoritesPagination?.current + 1,
          order: Constants.FAVORITES_SORT_KEY[this.favoriteOrder]["value"]
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
      let downloaded = await getDownloaded({
        order: Constants.DOWNLOADED_SORT_KEY[this.downloadedOrder]["value"]
      });
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
          page: this.downloadedPagination?.current + 1,
          order: Constants.DOWNLOADED_SORT_KEY[this.downloadedOrder]["value"]
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
      }
      .barMode(BarMode.Fixed)
      .onChange((index: number) => {
        this.tabCurrentIndex = index;
      })
    }
  }
}