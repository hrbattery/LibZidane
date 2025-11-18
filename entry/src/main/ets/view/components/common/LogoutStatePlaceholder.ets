import { SettingsLogin } from "../../pages/settings/Login";

/**
 * 登出状态占位组件
 * 用于在因未登录时组件占位所需
 */
@Preview
@ComponentV2
export struct LogoutStatePlaceholder {
  @Local isShowLoginSheet: boolean = false

  @Param message: string = '请先登录以查看您的书籍内容';

  pathStack: NavPathStack | undefined = undefined;
  
  aboutToAppear(): void {
    this.pathStack = this.queryNavigationInfo()?.pathStack;
  }

  build() {
    Column({ space: 20 }){
      // 图标
      Image($r('app.media.exclamationmark_circle'))
        .width(120)
        .height(120)
        .objectFit(ImageFit.Contain);

      // 提示文本
      Text(this.message)
        .fontSize(16)
        .fontColor('#666666')
        .textAlign(TextAlign.Center)
        .padding({ left: 40, right: 40 });

      // 操作按钮
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
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .padding({ top: 100 })

  }

  private onLoginClick() {
    this.isShowLoginSheet = true
  }

  @Builder
  LoginSheetBuilder() {
    SettingsLogin()
  }
}