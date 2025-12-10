/**
 * 错误状态占位组件
 * 用于在因加载失败时显示占位内容
 */
@Preview
@ComponentV2
export struct ErrorStatePlaceholder {
  /**
   * 提示文本
   */
  @Param message: string = '暂无相关书籍数据';
  /**
   * 刷新按钮点击回调
   */
  @Event onRefreshClick: () => void;

  build() {
    Column({ space: 20 }) {
      // 图标
      Image($r('app.media.link_slash'))
        .width(120)
        .height(120)
        .objectFit(ImageFit.Contain)
        .fillColor($r("sys.color.icon_primary"))

      // 提示文本
      Text(this.message)
        .fontSize(16)
        .textAlign(TextAlign.Center)
        .padding({ left: 40, right: 40 });

      // 操作按钮
      Button('刷新页面')
        .width(180)
        .height(44)
        .fontSize(16)
        .borderRadius(22)
        .onClick(() => this.onRefreshClick());
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}