import { SettingsLogin } from "../../pages/settings/Login";

/**
 * 错误状态占位组件
 * 用于在因加载失败时显示不同的占位内容
 */
@Preview
@ComponentV2
export struct ErrorStatePlaceholder {
  pathStack: NavPathStack | undefined = undefined;
  /**
   * 是否未登录状态
   */
  @Param isNotLoggedIn: boolean = false;
  
  /**
   * 提示文本
   */
  @Param message: string = '暂无相关书籍数据';

  /**
   * 刷新按钮点击回调
   */
  @Event onRefreshClick: () => void;

  @Local isShowLoginSheet: boolean = false

  aboutToAppear(): void {
    this.pathStack = this.queryNavigationInfo()?.pathStack;
  }

  build() {
    Column({ space: 20 }){
      // 图标
      Image(this.isNotLoggedIn ? $r('app.media.exclamationmark_circle') : $r('app.media.link_slash'))
        .width(120)
        .height(120)
        .objectFit(ImageFit.Contain);

      // 提示文本
      Text(this.getMessage())
        .fontSize(16)
        .fontColor('#666666')
        .textAlign(TextAlign.Center)
        .padding({ left: 40, right: 40 });

      // 操作按钮
      if (this.isNotLoggedIn) {
        Button('登录账号')
          .width(180)
          .height(44)
          .fontSize(16)
          .backgroundColor('#007AFF')
          .fontColor(Color.White)
          .borderRadius(22)
          .onClick(() => this.onLoginClick())
          .bindSheet(!!this.isShowLoginSheet, this.LoginSheetBuilder(), {
            height: SheetSize.LARGE,
            preferType: SheetType.BOTTOM,
            title: { title: '登录' },
          })
      } else {
        Button('刷新页面')
          .width(180)
          .height(44)
          .fontSize(16)
          .backgroundColor('#EFEFF4')
          .fontColor('#007AFF')
          .borderRadius(22)
          .onClick(() => this.onRefreshClick());
      }
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .padding({ top: 100 })

  }
  
  /**
   * 获取显示的提示文本
   */
  private getMessage(): string {
    if (this.message) {
      return this.message;
    }
    
    return this.isNotLoggedIn 
      ? '请先登录以查看您的书籍内容' 
      : '暂无相关书籍数据';
  }

  private onLoginClick() {
    this.isShowLoginSheet = true
  }

  @Builder
  LoginSheetBuilder() {
    SettingsLogin()
  }
}