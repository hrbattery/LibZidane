import { HdsNavigation, HdsNavigationTitleMode, HdsTabs, HdsTabsController } from '@kit.UIDesignKit';
import { NAVIGATION_STYLE, NAVIGATION_MATERIAL, hdsMenus } from '../components/common/NavigationStyle';
import { Library } from '../components/library/Library';
import { MyBook } from '../components/mybook/MyBook';
import { LogUtil as logger } from "@pura/harmony-utils"
import { DialogHelper } from "@pura/harmony-dialog"
import { Constants } from '../../common/const/Constants';
import { Settings } from '../components/settings/Settings';
import { PersistenceV2 } from '@kit.ArkUI';
import { AppState } from '../../model/entities/AppState';
import { OnlineReaderLibrary, OnlineReaderState, onlineReaderLibrary } from '../../model/entities/OnlineReaderState';
import { ReaderSidebar } from '../components/reader/ReaderSidebar';
import { windowUtil } from '../../common/system/WindowUtil';
import { WidthBreakpointType } from '../../common/system/BreakpointUtil';
import { releaseReaderWeb } from '../components/reader/OnlineReaderWeb';

const TAG = "[Home] "
@Entry
@ComponentV2
struct Home {
  @Local readers: OnlineReaderLibrary = onlineReaderLibrary;
  @Local readerSidebarVisible: boolean = false;
  @Local appState: AppState = PersistenceV2.connect(AppState, 'appState', () => new AppState())!;
  @Local index: number = 0;
  @Local tabCurrentIndex: number = 0;
  @Local tabController: HdsTabsController = new HdsTabsController()
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

  /** Open the hidden reading drawer from the title button without intercepting system back gestures. */
  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      this.MainNavigation()
      if (this.readerSidebarVisible) {
        Row() {}
          .width('100%')
          .height('100%')
          .backgroundColor('#40000000')
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
          .onClick(() => this.showReaderSidebar(false))
          .transition(TransitionEffect.OPACITY)
        ReaderSidebar({
          library: this.readers,
          onResume: session => this.resumeOnlineReader(session),
          onCloseBook: session => this.closeOnlineReader(session),
          onDismiss: () => this.showReaderSidebar(false)
        })
          .width(this.readerSidebarWidth)
          .height('100%')
          .transition(TransitionEffect.move(TransitionEdge.START))
          .gesture(PanGesture({ direction: PanDirection.Left, distance: 24 })
            .onActionEnd(() => this.showReaderSidebar(false)))
      }
    }
    .width('100%')
    .height('100%')
    // Background paints through the system safe areas; controls keep their safe layout.
    .background($r('sys.color.background_primary'))
  }

  /** Keep portrait proportions and cap wide-window covers with a compact single-column drawer. */
  @Computed
  get readerSidebarWidth(): Length {
    return new WidthBreakpointType<Length>('82%', '33.333%', 240, 240)
      .getValue(windowUtil.mainWindowInfo.widthBp);
  }

  /** Animate opening and dismissal through the same drawer state. */
  showReaderSidebar(visible: boolean): void {
    this.getUIContext().animateTo({ duration: 200 }, () => {
      this.readerSidebarVisible = visible;
    });
  }

  /** Dismiss the drawer before the system back action exits the home page. */
  onBackPress(): boolean {
    if (this.readerSidebarVisible) {
      this.showReaderSidebar(false);
      return true;
    }
    return false;
  }

  /** Clear all account-bound reading sessions on logout. */
  @Monitor('appState.loginState')
  onReaderAccountChange(): void {
    if (!this.appState.loginState) {
      this.readers.closeAll();
      releaseReaderWeb();
      this.readerSidebarVisible = false;
      this.navPathStack.removeByName('OnlineReader');
    }
  }

  /** Restore recent book metadata after the app has initialized its preferences. */
  aboutToAppear(): void {
    this.readers.restore();
  }

  /** Release web pages while keeping recent books available after a restart. */
  aboutToDisappear(): void {
    this.readers.release();
    releaseReaderWeb();
  }

  /** Close one listed book without affecting any other retained reader. */
  closeOnlineReader(session: OnlineReaderState): void {
    releaseReaderWeb(session.readerUrl);
    this.readers.close(session);
  }

  /** Resume the selected session and leave the original navigation stack intact. */
  async resumeOnlineReader(session: OnlineReaderState): Promise<void> {
    const loading = this.readers.resume(session);
    this.readerSidebarVisible = false;
    this.navPathStack.pushPathByName('OnlineReader', null);
    await loading;
  }

  /** Place the drawer button before the root title; destinations retain their native back button. */
  @Builder
  HomeTitle() {
    Row({ space: 8 }) {
      Button() {
        Stack() {
          Image($r('app.media.reader_sidebar')).width(24).height(24)
            .fillColor($r('sys.color.icon_primary'))
          if (this.readers.sessions.length > 0) {
            Text(`${this.readers.sessions.length}`)
              .fontSize(10)
              .fontColor(Color.White)
              .backgroundColor($r('sys.color.comp_background_emphasize'))
              .constraintSize({ minWidth: 14 })
              .height(14)
              .padding({ left: 2, right: 2 })
              .textAlign(TextAlign.Center)
              .borderRadius(7)
              .offset({ x: 12, y: -10 })
          }
        }
        .width(40).height(40)
      }
      .width(44).height(44)
      .backgroundColor(Color.Transparent)
      .accessibilityText($r('app.string.ui_reader_sidebar_title'))
      .onClick(() => this.showReaderSidebar(true))
      Text(this.titleMap[this.index])
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .layoutWeight(1)
    }
    .height('100%')
    .padding({ left: 8, right: this.navMenuItems.length * 48 + 40 })
    .hitTestBehavior(HitTestMode.Transparent)
  }

  /** Native floating tabs retain the app's compact text labels. */
  @Builder
  RootTabLabel(index: number) {
    Text(this.titleMap[index])
      .fontSize(14)
      .fontWeight(this.index === index ? FontWeight.Bold : FontWeight.Medium)
      .fontColor(this.index === index ? $r('sys.color.font_emphasize') : $r('sys.color.font_secondary'))
      .maxLines(1)
      .height(48)
      .width('100%')
      .textAlign(TextAlign.Center)
  }

  /** Keep the existing tab content and right-side menu actions. */
  @Builder
  MainNavigation() {
    HdsNavigation(this.navPathStack) {
      HdsTabs({ controller: this.tabController, index: this.tabCurrentIndex }) {
        TabContent() {
          Library()
        }
        .tabBar(this.RootTabLabel(0))

        TabContent() {
          MyBook({
            active: this.index === 1,
            favoriteOrder: this.favoriteSortOrder,
            downloadedOrder: this.downloadedSortOrder,

            onMyBookTabIndexChange: (index: number) => {
              this.myBookTabIndex = index;
              this.sortMenuItems = this.getSortMenuItems()
              this.navMenuItems = this.getMenuItems()
            }
          })
        }
        .tabBar(this.RootTabLabel(1))

        TabContent() {
          Settings()
        }
        .tabBar(this.RootTabLabel(2))
      }
      .height('100%')
      .width('100%')
      .barPosition(BarPosition.End)
      .barOverlap(true)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      .barFloatingStyle({
        barBottomMargin: 8 + windowUtil.mainWindowInfo.bottomInset,
        systemMaterialEffect: NAVIGATION_MATERIAL
      })
      .onAnimationStart((from, target) => {
        this.index = target;
        this.navMenuItems = this.getMenuItems();
      })
      .onChange((index) => {
        this.tabCurrentIndex = index;
      })
      // .onChange((index) => {
      //   this.menuItems = this.getMenuItems();
      // })
    }
    .titleBar({
      enableComponentSafeArea: true,
      style: NAVIGATION_STYLE,
      content: {
        title: { mainTitle: '' },
        menu: { value: hdsMenus(this.navMenuItems) },
        stackBuilder: () => this.HomeTitle()
      }
    })
    .titleMode(HdsNavigationTitleMode.MINI)
    .ignoreLayoutSafeArea([LayoutSafeAreaType.SYSTEM], [LayoutSafeAreaEdge.BOTTOM])
    .hideBackButton(true)
    .mode(NavigationMode.Stack)
    .width('100%')
    .height('100%')
    .onNavBarStateChange(visible => {
      if (!visible) {
        this.readerSidebarVisible = false;
      }
    })
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
    } else if (this.index === 1 && this.myBookTabIndex !== 2) {
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
