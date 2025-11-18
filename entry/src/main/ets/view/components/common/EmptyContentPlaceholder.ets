/**
 * 空内容占位组件
 * 用于在无内容可展示时显示占位内容
 */
@Preview
@ComponentV2
export struct EmptyContentPlaceholder {
  /**
   * 提示文本
   */
  @Param message: string = '暂无相关书籍数据';

  build() {
    Column({ space: 20 }) {
      // 图标
      Image($r('app.media.xmark_circle'))
        .width(120)
        .height(120)
        .objectFit(ImageFit.Contain);

      // 提示文本
      Text(this.message)
        .fontSize(16)
        .fontColor('#666666')
        .textAlign(TextAlign.Center)
        .padding({ left: 40, right: 40 });
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .padding({ top: 100 })
  }
}