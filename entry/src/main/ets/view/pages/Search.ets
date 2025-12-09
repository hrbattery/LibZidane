import { DialogHelper } from '@pura/harmony-dialog'
import { LogUtil as logger, ToastUtil } from '@pura/harmony-utils'
import { Constants } from '../../common/const/Constants'
import { SearchViewModel } from '../../viewModel/search/SearchResultViewModel'
import { SearchOptionDialog } from '../components/search/SearchOptionDialog'
import { SearchResults } from '../components/search/SearchResults'

@Builder
export function SearchPageBuilder() {
  SearchPage()
}

@ComponentV2
struct SearchPage {
  @Local viewModel: SearchViewModel = new SearchViewModel()

  getSortMenuItems(): SheetInfo[] {
    return Constants.SEARCH_SORT_KEY.map((value, index) => {
      return {
        title: value["key"],
        action: () => this.viewModel.searchSortOrderIndex = index
      } as SheetInfo
    })
  }

  handleSortClick(): void {
    const dialogId = DialogHelper.showSelectDialog({
      selectedIndex: this.viewModel.searchSortOrderIndex,
      title: "排序方式",
      radioContent: this.getSortMenuItems(),
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

  private handleSearchOptionsClick() {
    DialogHelper.showCustomContentDialog({
      contentBuilder: () => this.SearchOptionDialogBuilder(),
      onAction: () => {
        // 用命令模式来暂存更改，然后在onAction这里再决定是否要使用对应的更改
        // 这样的话，传递过去的object也可以确定是只读的了
        // 这样的话，不如将SearchOption设计成一个类，有对应的command和applyCommand方法
        // 还可以抽象出类似的类，都可以用在这种需要暂存更改、但将apply更改的决定权交到另一个地方的场景了
        this.viewModel.searchFilterOption.apply()
      },
      uiContext: this.getUIContext(),
      title: '搜索选项',
      backgroundColor: '#FFFFFF'
    })
  }

  @Builder
  SearchOptionDialogBuilder() {
    Scroll() {
      SearchOptionDialog({
        options: this.viewModel.searchFilterOption
      }).height("60%")
    }
  }

  @Builder
  SearchInput() {
    Column() {
      Search({
        placeholder: "搜索内容",
        value: this.viewModel.searchKeyword
      })
        .defaultFocus(true)
        .layoutWeight(1)
        .searchButton('搜索')
        .onChange((value) => {
          if (!value) {
            this.viewModel.searchKeyword = ''
          }
        })
        .onSubmit(async (value) => {
          if (!value) {
            ToastUtil.showToast('请输入搜索内容')
          } else {
            this.viewModel.searchKeyword = value
            this.viewModel.loadDataSource()
          }
        })
    }
    .margin({ left: 10, right: 10 })
  }

  @Builder
  SearchResultAmount() {
    if (this.viewModel.pagination) {
      Text(`找到 ${this.viewModel.pagination?.total_items} 本书`)
        .alignSelf(ItemAlign.Start)
        .textAlign(TextAlign.Center)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 4, left: 10, bottom: 4 })
    }
  }

  build() {
    NavDestination() {
      Column() {
        this.SearchResultAmount()
        SearchResults({
          viewModel: this.viewModel
        })
      }
      .width("100%")
    }
    .title(this.SearchInput())
    .menus([
      {
        value: '排序',
        icon: $r("app.media.sort"),
        action: () => this.handleSortClick()
      },
      {
        value: "搜索选项",
        icon: $r("app.media.slider_vertical_3"),
        action: () => this.handleSearchOptionsClick()
      }
    ])
    .onReady((context: NavDestinationContext) => {
      let param = context.pathInfo.param as string;
      if (param && param !== "") {
        this.viewModel.searchKeyword = param;
      }
    })
  }
}
