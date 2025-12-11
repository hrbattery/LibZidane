import { Library } from '../components/library/Library';
import { MyBook } from '../components/mybook/MyBook';
import { LogUtil as logger } from "@pura/harmony-utils"
import { DialogHelper } from "@pura/harmony-dialog"
import { Constants } from '../../common/const/Constants';
import { Settings } from '../components/settings/Settings';

const TAG = "[Home] "
@Entry
@ComponentV2
struct Home {
  @Local index: number = 0;
  @Local tabCurrentIndex: number = 0;
  @Local tabController: TabsController = new TabsController()
  @Local titleMap: ResourceStr[] = [
    $r("app.string.ui_home_library_tab"),
    $r("app.string.ui_home_mybook_tab"),
    $r("app.string.ui_home_setting_tab")
  ]
  @Local navMenuItems: NavigationMenuItem[] = this.getMenuItems();

  @Local myBookTabIndex: number = 0;
  @Local sortMenuItems: SheetInfo[] = this.getSortMenuItems()
  @Local favoriteSortOrder: number = 0; // 收藏排序：saved_date, saved_dateA
  @Local downloadedSortOrder: number = 0; // 下载排序：downloaded_date, downloaded_dateA, titleA, title, filesize, filesizeA, year

  navPathStack: NavPathStack = new NavPathStack()

  build() {
    Navigation(this.navPathStack) {
      Tabs({ controller: this.tabController, index: this.tabCurrentIndex!! }) {
        TabContent() {
          Library()
        }
        .tabBar($r("app.string.ui_home_library_tab"))

        TabContent() {
          MyBook({
            favoriteOrder: this.favoriteSortOrder,
            downloadedOrder: this.downloadedSortOrder,

            onMyBookTabIndexChange: (index: number) => {
              this.myBookTabIndex = index;
              this.sortMenuItems = this.getSortMenuItems()
            }
          })
        }
        .tabBar($r("app.string.ui_home_mybook_tab"))

        TabContent() {
          Settings()
        }
        .tabBar($r("app.string.ui_home_setting_tab"))
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
    .mode(NavigationMode.Stack)
  }

  // @Builder ToolBar() {
  //   Row() {
  //     this.ToolBarItem(0, '图书馆')
  //     this.ToolBarItem(1, '我的书籍')
  //   }
  //   .backgroundColor(Color.Transparent)
  //   .justifyContent(FlexAlign.SpaceEvenly)
  //   .width('100%')
  // }

  // @Builder ToolBarItem(index: number, text: string | ResourceStr) {
  //   Column({ space: 3 }) {
  //     // Image(this.index == index ? activeIcon : icon)
  //     //   .width(Constants.SIZE_ICON_BUTTON_BAR)
  //     //   .fillColor(this.index == index ? $r('app.color.app_red') : Color.Gray)
  //     Text(text)
  //       .fontSize(16)
  //       .fontColor(this.index == index ? Color.Green : Color.Gray)
  //   }
  //   .layoutWeight(1)
  //   .onClick(() => {
  //     this.tabController.changeIndex(index)
  //     // this.index = index;
  //   })
  // }

  getMenuItems(): NavigationMenuItem[] {
    if (this.index === 0) {
      return [
        {
          'value': $r("app.string.ui_home_menu_search"),
          'icon': $r("app.media.search"),
          'action': () => this.gotoSearchPage()
        },
      ]
    } else if (this.index === 1) {
      return [
        {
          'value': $r("app.string.ui_home_menu_sort"),
          'icon': $r("app.media.sort"),
          'action': () => this.handleSortClick()
        },
        {
          'value': $r("app.string.ui_home_menu_search"),
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
      title: $r("app.string.ui_home_menu_sort_by"),
      radioContent: this.sortMenuItems,
      confirm: $r("app.string.ui_common_cancel_btn"),
      onCheckedChanged: (index: number): void => {
        closeDialog()
        logger.debug(TAG, `onCheckedChanged: index=${index}`)
      },
      onAction: (action: number, dialogId: string, value: string): void => {
        logger.debug(TAG, `onAction: action=${action}, dialogId=${dialogId}, value=${value}`)
      }
    })

    const closeDialog: () => void = () => {
      DialogHelper.closeDialog(dialogId);
    }
  }

  gotoSearchPage() {
    this.navPathStack.pushPathByName("Search", null)
  }
}