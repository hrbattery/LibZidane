import { LengthMetrics } from "@kit.ArkUI"
import { DialogUtil, ToastUtil } from "@pura/harmony-utils"
import { getSearch } from "../api/BookApi"
import { LogUtil as logger } from "@pura/harmony-utils"
import { BookInfoList, BookInfoListParam } from "../components/BookInfoList"
import { BookData, BookDataType } from "../models/BookModel"
import { PaginationDataSource } from "../common/ResponseTypes"
import { DialogHelper } from "@pura/harmony-dialog"
import { SearchOptionDialog } from "../components/SearchOptionDialog"
import { SearchFilterOptions } from "../models/SearchFilterOptionModel"
import { Constants } from "../common/const/Constants"

@Builder
export function SearchPageBuilder() {
  SearchPage()
}

@ComponentV2
struct SearchPage {
  @Local searchKeyword: string = ""
  @Local searchSortOrder: number = 0
  @Local sortMenuItems: SheetInfo[] = this.getSortMenuItems()
  @Local searchController: SearchController = new SearchController()
  @Local searchFilterOption: SearchFilterOptions = new SearchFilterOptions()

  // bookInfoList datasource
  @Local searchResultBooks: BookData[] = []
  @Local searchResultPagination: PaginationDataSource | undefined = undefined;

  pathStack: NavPathStack | undefined = undefined;
  private _languageOptions: Record<string, string> = AppStorage.get("language_options") ?? {}

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
        // todo: support order
        let favorites = await getSearch({
          message: this.searchKeyword,
          yearFrom: this.searchFilterOption.startYear === '不限' ? undefined : this.searchFilterOption.startYear,
          yearTo: this.searchFilterOption.endYear === '不限' ? undefined : this.searchFilterOption.endYear,
          languages: this.searchFilterOption.selectedLanguages.map((ele) => this._languageOptions[ele]),
          extensions: this.searchFilterOption.selectedExtensions,
          e: this.searchFilterOption.exactMatch ? 1: 0,
          order: Constants.SEARCH_SORT_KEY[this.searchSortOrder]["value"]
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
          yearFrom: this.searchFilterOption.startYear === '不限' ? undefined : this.searchFilterOption.startYear,
          yearTo: this.searchFilterOption.endYear === '不限' ? undefined : this.searchFilterOption.endYear,
          languages: this.searchFilterOption.selectedLanguages.map((ele) => this._languageOptions[ele]),
          extensions: this.searchFilterOption.selectedExtensions,
          e: this.searchFilterOption.exactMatch ? 1: 0,
          page: this.searchResultPagination.current + 1,
          order: Constants.SEARCH_SORT_KEY[this.searchSortOrder]["value"]
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

  handleSortClick(): void {
    const dialogId = DialogHelper.showSelectDialog({
      selectedIndex: this.searchSortOrder,
      title: "排序方式",
      radioContent: this.sortMenuItems,
      onCheckedChanged: (index: number): void => {
        closeDialog()
        logger.debug(`onCheckedChanged: index=${index}`)
      },
      onAction: (action: number, dialogId: string, value: string): void => {
        logger.debug(`onAction: action=${action}, dialogId=${dialogId}, value=${value}`)
      }
    })

    const closeDialog: () => void = () => {
      DialogHelper.closeDialog(dialogId);
    }
  }

  getSortMenuItems(): SheetInfo[] {
    return Constants.SEARCH_SORT_KEY.map((value, index) => {
      return {
        title: value["key"],
        action: () => this.searchSortOrder = index
      } as SheetInfo
    })
  }

  @Builder
  SearchOptionDialogBuilder() {
    Scroll() {
      SearchOptionDialog({
        options: this.searchFilterOption
      })
      .height("60%")
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
        'value': '排序',
        'icon': $r("app.media.sort"),
        'action': () => this.handleSortClick()
      },
      {
        value: "搜索选项",
        icon: $r("app.media.slider_vertical_3"),
        action: () => {
          DialogHelper.showCustomContentDialog({
            contentBuilder: () => this.SearchOptionDialogBuilder(),
            onAction: () => {
              // 用命令模式来暂存更改，然后在onAction这里再决定是否要使用对应的更改
              // 这样的话，传递过去的object也可以确定是只读的了
              // 这样的话，不如将SearchOption设计成一个类，有对应的command和applyCommand方法
              // 还可以抽象出类似的类，都可以用在这种需要暂存更改、但将apply更改的决定权交到另一个地方的场景了
              this.searchFilterOption.apply()
            },
            uiContext: this.getUIContext(),
            title: '搜索选项',
            backgroundColor: '#FFFFFF'
          })
        }
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
