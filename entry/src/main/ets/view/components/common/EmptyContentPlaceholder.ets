/**
 * 空内容占位组件
 * 用于在无内容可展示时显示占位内容
 */
@Preview
@ComponentV2
export struct EmptyContentPlaceholder {
  build() {
    Column({ space: 20 }) {
      // 图标
      Image($r('app.media.empty'))
        .width(120)
        .height(120)
        .objectFit(ImageFit.Contain)
        .fillColor($r("sys.color.icon_primary"))

      // 提示文本
      Text($r("app.string.ui_placeholder_empty"))
        .fontSize(16)
        .textAlign(TextAlign.Center)
        .padding({ left: 40, right: 40 });
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}