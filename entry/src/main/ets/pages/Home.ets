import { Library } from '../views/Library';
import { MyBook } from '../views/MyBook';
import { LogUtil as logger } from "@pura/harmony-utils"
import { DialogHelper } from "@pura/harmony-dialog"
import { Constants } from '../common/const/Constants';
import { Settings } from '../views/Settings';

@Entry
@ComponentV2
struct Home {
  @Local index: number = 0;
  @Local tabCurrentIndex: number = 0;
  @Local tabController: TabsController = new TabsController()
  @Local titleMap: string[] = ["图书馆", "我的书籍", "设置"]
  @Local navMenuItems: NavigationMenuItem[] = this.getMenuItems()

  @Local myBookTabIndex: number = 0;
  @Local sortMenuItems: SheetInfo[] = this.getSortMenuItems()
  @Local favoriteSortOrder: number = 0; // 收藏排序：saved_date, saved_dateA
  @Local downloadedSortOrder: number = 0; // 下载排序：downloaded_date, downloaded_dateA, titleA, title, filesize, filesizeA, year

  @Provider("navPathStack") navPathStack: NavPathStack = new NavPathStack()

  build() {
    Navigation(this.navPathStack) {
      Tabs({ controller: this.tabController, index: this.tabCurrentIndex }) {
        TabContent() {
          Library()
        }
        .tabBar("图书馆")

        TabContent() {
          MyBook({
            favoriteOrder: this.favoriteSortOrder,
            downloadedOrder: this.downloadedSortOrder,
            onSortRequest: (orderBy: string) => {
              // 这个事件可以用来从子组件向父组件传递排序相关的信息
              logger.debug(`从MyBook组件接收排序请求: ${orderBy}`);
            },
            onMyBookTabIndexChange: (index: number) => {
              this.myBookTabIndex = index;
              this.sortMenuItems = this.getSortMenuItems()
            }
          })
        }
        .tabBar("我的书籍")

        TabContent() {
          Settings()
        }
        .tabBar("设置")
      }
      .height('100%')
      .width('100%')
      .edgeEffect(EdgeEffect.Spring)
      .barPosition(BarPosition.End)
      .onAnimationStart((from, target) => {
        this.index = target;
        this.navMenuItems = this.getMenuItems();
      })
      // .onChange((index) => {
      //   this.menuItems = this.getMenuItems();
      // })
    }
    .menus(this.navMenuItems)
    .title(this.titleMap[this.index])
    .titleMode(NavigationTitleMode.Mini)
    .hideBackButton(true)
  }

  @Builder ToolBar() {
    Row() {
      this.ToolBarItem(0, '图书馆')
      this.ToolBarItem(1, '我的书籍')
    }
    .backgroundColor(Color.Transparent)
    .justifyContent(FlexAlign.SpaceEvenly)
    .width('100%')
  }

  @Builder ToolBarItem(index: number, text: string | ResourceStr) {
    Column({ space: 3 }) {
      // Image(this.index == index ? activeIcon : icon)
      //   .width(Constants.SIZE_ICON_BUTTON_BAR)
      //   .fillColor(this.index == index ? $r('app.color.app_red') : Color.Gray)
      Text(text)
        .fontSize(16)
        .fontColor(this.index == index ? Color.Green : Color.Gray)
    }
    .layoutWeight(1)
    .onClick(() => {
      this.tabController.changeIndex(index)
      // this.index = index;
    })
  }

  getMenuItems(): NavigationMenuItem[] {
    if (this.index === 0) {
      return [
        {
          'value': "搜索",
          'icon': $r("app.media.search"),
          'action': () => this.gotoSearchPage()
        },
      ]
    } else if (this.index === 1) {
      return [
        {
          'value': '排序',
          'icon': $r("app.media.sort"),
          'action': () => this.handleSortClick()
        },
        {
          'value': "搜索",
          'icon': $r("app.media.search"),
          'action': () => this.gotoSearchPage()
        },
      ]
    } else {
      return []
    }
  }

  getSortMenuItems(): SheetInfo[] {
    if (this.myBookTabIndex === 0) {
      return Constants.FAVORITES_SORT_KEY.map((value, index) => {
        return {
          title: value["key"],
          action: () => this.favoriteSortOrder = index
        } as SheetInfo
      })
    } else {
      return Constants.DOWNLOADED_SORT_KEY.map((value, index) => {
        return {
          title: value["key"],
          action: () => this.downloadedSortOrder = index
        } as SheetInfo
      })
    }
  }

  // 处理排序按钮点击事件
  handleSortClick(): void {
    const dialogId = DialogHelper.showSelectDialog({
      selectedIndex: this.myBookTabIndex === 0 ? this.favoriteSortOrder : this.downloadedSortOrder,
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

  gotoSearchPage() {
    this.navPathStack.pushPathByName("Search", undefined)
  }
}