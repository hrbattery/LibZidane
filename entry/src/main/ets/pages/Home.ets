import { Library } from '../views/Library';
import { MyBook } from '../views/MyBook';
import { LogUtil as logger } from "@pura/harmony-utils"
@Entry
@ComponentV2
struct Home {
  @Local index: number = 0;
  @Local tabCurrentIndex: number = 0;
  @Local tabController: TabsController = new TabsController()
  @Provider("navPathStack") navPathStack: NavPathStack = new NavPathStack()
  @Local titleMap: string[] = ["图书馆", "我的书籍"]
  @Local menuItems: NavigationMenuItem[] = this.getMenuItems()

  build() {
    Navigation(this.navPathStack) {
      Tabs({ controller: this.tabController, index: this.tabCurrentIndex }) {
        TabContent() {
          Library()
        }
        .tabBar("图书馆")

        TabContent() {
          MyBook()
        }
        .tabBar("我的书籍")
      }
      .height('100%')
      .width('100%')
      .edgeEffect(EdgeEffect.Spring)
      .barPosition(BarPosition.End)
      .onAnimationStart((from, target) => {
        this.index = target;
        this.menuItems = this.getMenuItems();
      })
      // .onChange((index) => {
      //   this.menuItems = this.getMenuItems();
      // })
    }
    .menus(this.menuItems)
    .title(this.titleMap[this.index])
    .titleMode(NavigationTitleMode.Mini)
    .hideBackButton(true)
    // .hideBackButton(true)
    // .hideNavBar(true)
    // .hideTitleBar(true)
    // .hideToolBar(true)
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
          'value': "排序",
          'icon': $r("app.media.sort"),
          'action': ()=> {logger.debug("sort")}
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

  gotoSearchPage() {
    this.navPathStack.pushPathByName("Search", undefined)
  }
}