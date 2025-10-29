import { LengthMetrics } from "@kit.ArkUI"
import { ToastUtil } from "@pura/harmony-utils"

@Builder
export function SearchPageBuilder() {
  SearchPage()
}

@ComponentV2
struct SearchPage {
  @Local searchResults: string[] = []
  @Local keyword: string = ""
  @Local searchController: SearchController = new SearchController()

  pathStack: NavPathStack | undefined = undefined;

  async aboutToAppear(): Promise<void> {
    this.pathStack = this.queryNavigationInfo()?.pathStack;
  }

  build() {
    NavDestination() {
      Column() {
        // 搜索结果列表
        List() {
          Repeat(this.searchResults).each(
            (ri) => {
              ListItem() {
                Text(ri.item)
              }
            })
        }
        .height("100%")
        .width("100%")
      }
    }
    .title(this.Head())
  }

  @Builder
  Head() {
    Column() {
      Search({
        placeholder: "搜索内容",
        value: this.keyword,
        icon: '/resources/base/media/search.svg',
        controller: this.searchController
      })
        .defaultFocus(true)
        .layoutWeight(1)
        .searchButton('搜索')
        .onChange((value) => {
          if(!value) {
            this.keyword = ''
          }
        })
        .onSubmit(async (value) => {
          if (!value) {
            ToastUtil.showToast('请输入搜索内容')
          } else {
            this.keyword = value
          }
        })
    }
    .margin({ left: 10, right: 10 })
  }
}
