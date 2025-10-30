import { LengthMetrics } from "@kit.ArkUI"
import { ToastUtil } from "@pura/harmony-utils"
import { getSearch } from "../api/BookApi"
import { LogUtil as logger } from "@pura/harmony-utils"
import { BookInfoList, BookInfoListParam } from "../components/BookInfoList"
import { BookData, BookDataType } from "../models/BookModel"
import { PaginationDataSource } from "../common/DataSourceTypes"

@Builder
export function SearchPageBuilder() {
  SearchPage()
}

@ComponentV2
struct SearchPage {
  @Local searchKeyword: string = ""
  @Local searchController: SearchController = new SearchController()

  // bookInfoList datasource
  @Local searchResultBooks: BookData[] = []
  @Local searchResultPagination: PaginationDataSource | undefined = undefined;

  pathStack: NavPathStack | undefined = undefined;

  @Monitor('searchKeyword')
  clearDataSource() {
    if (this.searchKeyword === '') {
      this.searchResultBooks = [];
      this.searchResultPagination = undefined;
    }
  }

  async aboutToAppear(): Promise<void> {
    this.pathStack = this.queryNavigationInfo()?.pathStack;
  }

  async loadSearchDataSource(): Promise<void> {
    if (this.searchKeyword && this.searchKeyword !== '') {
      try {
        // todo: support all params
        let favorites = await getSearch({
          message: this.searchKeyword,
          e: 0,
          order: 'bestmatch'
        });
        if (favorites !== null) {
          this.searchResultBooks = favorites.books.map(element => new BookData(element as BookDataType))
          this.searchResultPagination = favorites.pagination
        }
      } catch (e) {
        logger.error(e)
        // todo: toast error or use a 404 page
      }
    }
  }

  async loadNewSearchData(): Promise<void> {
    if (this.searchResultPagination && this.searchKeyword && this.searchKeyword !== '') {
      try {
        // todo: support all params
        let favorites = await getSearch({
          message: this.searchKeyword,
          e: 0,
          page: this.searchResultPagination.current + 1,
          order: 'bestmatch'
        });
        if (favorites !== null) {
          this.searchResultBooks.push(...favorites.books.map(element => new BookData(element as BookDataType)))
          this.searchResultPagination = favorites.pagination
        }
      } catch (e) {
        logger.error(e)
        // todo: toast error or use a 404 page
      }
    }
  }

  build() {
    NavDestination() {
      Column() {
        BookInfoList({
          bookDataSource: this.searchResultBooks,
          pagination: this.searchResultPagination,
          onInitialData: (): Promise<void> => this.loadSearchDataSource(),
          onLoadNewData: (): Promise<void> => this.loadNewSearchData(),
          onRefreshData: (): Promise<void> => this.loadSearchDataSource()
        })
      }
    }
    .title(this.SearchInput())
    .menus([
      {
        value: "搜索选项",
        icon: $r("app.media.slider_vertical_3"),
        action: () => {}
      }
    ])
  }

  @Builder
  SearchInput() {
    Column() {
      Search({
        placeholder: "搜索内容",
        value: this.searchKeyword,
        icon: '/resources/base/media/search.svg',
        controller: this.searchController
      })
        .defaultFocus(true)
        .layoutWeight(1)
        .searchButton('搜索')
        .onChange((value) => {
          if(!value) {
            this.searchKeyword = ''
          }
        })
        .onSubmit(async (value) => {
          if (!value) {
            ToastUtil.showToast('请输入搜索内容')
          } else {
            this.searchKeyword = value
            this.loadSearchDataSource()
          }
        })
    }
    .margin({ left: 10, right: 10 })
  }
}
