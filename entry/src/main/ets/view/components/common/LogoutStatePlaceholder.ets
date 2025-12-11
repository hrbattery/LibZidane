
/**
 * 登出状态占位组件
 * 用于在因未登录时组件占位所需
 */
@Preview
@ComponentV2
export struct LogoutStatePlaceholder {
  @Local isShowLoginSheet: boolean = false
  pathStack: NavPathStack | undefined = undefined;

  aboutToAppear(): void {
    this.pathStack = this.queryNavigationInfo()?.pathStack;
  }

  build() {
    Column({ space: 20 }) {
      // 图标
      Image($r('app.media.exclamationmark_circle'))
        .width(120)
        .height(120)
        .objectFit(ImageFit.Contain)
        .fillColor($r("sys.color.icon_primary"))

      // 提示文本
      Text($r("app.string.ui_placeholder_require_login"))
        .fontSize(16)
        .textAlign(TextAlign.Center)
        .padding({ left: 40, right: 40 });

      // 操作按钮
      Button($r("app.string.ui_placeholder_login_btn"))
        .width(180)
        .height(44)
        .fontSize(16)
        .borderRadius(22)
        .onClick(() => this.onLoginClick())
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  private onLoginClick() {
    this.pathStack?.pushPathByName("Settings_Login", null)
  }
}