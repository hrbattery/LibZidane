import { common } from '@kit.AbilityKit';
import { ToastUtil } from '@pura/harmony-utils';

@Builder
export function AboutPageBuilder() {
  AboutPage()
}

@Preview
@ComponentV2
struct AboutPage {
  private githubUrl: string = 'https://github.com/hrbattery/LibZidane'
  private version: string | undefined =
    this.getUIContext().getHostContext()?.resourceManager.getStringByNameSync("app_version");

  build() {
    NavDestination() {
      Column({ space: 20 }) {
        // 应用图标
        Image($r('app.media.lz_icon'))
          .borderRadius(20)
          .width(120)
          .height(120)
          .margin({ top: 40 })
          .objectFit(ImageFit.Contain)
          .fillColor($r("sys.color.icon_primary"))

        // 应用名称
        Text($r('app.string.app_name')) // 配置在resources/base/element/string.json
          .fontSize(26)
          .fontWeight(FontWeight.Bold)

        // GitHub地址
        Image($r("app.media.github"))
          .onClick(() => {
            const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
            context.openLink(this.githubUrl, { appLinkingOnly: false })
              .then(() => {
                console.info('跳转成功');
              })
              .catch(() => {
                ToastUtil.showToast(`打开失败，请检查链接: ${this.githubUrl}`, { duration: 2000 });
              });
          })
          .fillColor($r("sys.color.icon_primary"))
          .height(30)

        // 应用简介
        Text($r('app.string.app_description'))
          .fontSize(16)
          .padding({ left: 20, right: 20 })
          .textAlign(TextAlign.Center)

        // 版本信息
        Text(`版本: ${this.version}`) // 版本号建议通过资源配置
          .fontSize(18)
      }
      .width('100%')
      .height('100%')
      .padding(20)
    }
    .title("关于应用")
  }
}