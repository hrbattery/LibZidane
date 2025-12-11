import { bundleManager, common } from '@kit.AbilityKit';
import { ToastUtil } from '@pura/harmony-utils';

@Builder
export function AboutPageBuilder() {
  AboutPage()
}

@Preview
@ComponentV2
struct AboutPage {
  private githubUrl: string = 'https://github.com/hrbattery/LibZidane'
  private version: string =
    bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag.GET_BUNDLE_INFO_DEFAULT).versionName;

  build() {
    NavDestination() {
      Column({ space: 20 }) {
        Image($r('app.media.lz_icon'))
          .borderRadius(20)
          .width(120)
          .height(120)
          .margin({ top: 40 })
          .objectFit(ImageFit.Contain)
          .fillColor($r("sys.color.icon_primary"))

        Text($r('app.string.app_name'))
          .fontSize(26)
          .fontWeight(FontWeight.Bold)

        Image($r("app.media.github"))
          .onClick(() => {
            const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
            context.openLink(this.githubUrl, { appLinkingOnly: false })
              .catch(() => {
                ToastUtil.showToast(
                  this.getUIContext().getHostContext()!.resourceManager.getStringSync(
                    $r("app.string.notif_open_link_failed").id,
                    this.githubUrl
                  ), { duration: 2000 });
              });
          })
          .fillColor($r("sys.color.icon_primary"))
          .height(30)

        Text($r('app.string.app_description'))
          .fontSize(16)
          .padding({ left: 20, right: 20 })
          .textAlign(TextAlign.Center)

        // 版本信息
        Text(this.getUIContext().getHostContext()!.resourceManager.getStringSync(
          $r("app.string.ui_setting_general_about_version").id,
          this.version
        )) // 版本号建议通过资源配置
          .fontSize(18)
      }
      .width('100%')
      .height('100%')
      .padding(20)
    }
    .title($r("app.string.ui_setting_general_about"))
  }
}