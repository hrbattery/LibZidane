import { SettingsConstants } from "../../../common/const/SettingsConstants";
import { StorageConstants } from "../../../common/const/StorageConstants";
import { preferencesUtils } from "../../../common/data/PreferencesUtils";
import { DarkMode } from "./DarkMode";
import { LanguageSetting } from "./LanguageSetting";
import { AppStorageV2 } from '@kit.ArkUI';
import { SettingsModel } from "../../../models/SettingsModel";

@ComponentV2
export struct Settings {
  // 导入所需的颜色和组件
  private readonly bgColor = $r("app.color.settings_bg_color");
  private readonly dividerColor: Color = Color.Gray;
  private readonly textColor: Color = Color.Black;
  private readonly sectionHeaderTextStyle: TextStyle = {
    fontSize: 16,
    fontWeight: FontWeight.Bold
  };

  private pathStack: NavPathStack | undefined = undefined;
  @Local settingsModel: SettingsModel = AppStorageV2.connect(SettingsModel, "settingsModel")!

  async aboutToAppear(): Promise<void> {
    this.pathStack = this.queryNavigationInfo()?.pathStack;
  }

  async build() {
    Column() {
      // 账户部分
      Text('账号')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .padding({ left: 16, top: 16, bottom: 16 })
        .alignSelf(ItemAlign.Start)

      Column() {
        if (!this.settingsModel.hasCookie) {
          ItemCard({
            text: '登录（账号/cookie）',
            action: () => {
              this.pathStack?.pushPathByName("Settings_Login", null)
            }
          })

          Divider()
            .margin({ left: 8, right: 8})
            .color(this.dividerColor)
        }

        ItemCard({
          text: '捐赠和捐赠记录',
          action: () => {
            this.pathStack?.pushPathByName("Settings_Donation", null)
          }
        })
      }
      .backgroundColor(Color.White)
      .margin({ left: 16, right: 16 })
      .borderRadius(20)

      // 通用部分
      Text('通用')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .padding({ left: 16, top: 16, bottom: 16 })
        .alignSelf(ItemAlign.Start)

      Column() {
        LanguageSetting().borderRadius(20)
        Divider()
          .margin({ left: 8, right: 8})
          .color(this.dividerColor)
        DarkMode().borderRadius(20)
        Divider()
          .margin({ left: 8, right: 8})
          .color(this.dividerColor)

        ItemCard({
          text: '关于应用',
          action: () => {
            this.pathStack?.pushPathByName("Settings_About", null)
          }
        })
      }
      .backgroundColor(Color.White)
      .margin({ left: 16, right: 16 })
      .borderRadius(20)

      // 登出按钮
      if (this.settingsModel.hasCookie) {
        Column() {
          Button('登出')
            .width('100%')
            .height(48)
            .fontSize(16)
            .fontColor(Color.White)
            .onClick(async () => {
              await preferencesUtils.delete(StorageConstants.DEFAULT_PREF, 'cookie')
              this.settingsModel.hasCookie = false
            })
        }
        .margin(16)
      }
    }
    .backgroundColor(this.bgColor)
    .height('100%')
    .width('100%')
  }
}


@ComponentV2
struct ItemCard {
  @Param @Require text: string | ResourceStr;
  @Event action: () => void

  build() {
    Button({type: ButtonType.ROUNDED_RECTANGLE}) {
      Row({ space: 10 }) {
        Text(this.text)
          .fontSize(16)
          .textAlign(TextAlign.Center)
          .fontWeight(FontWeight.Medium)
          .textAlign(TextAlign.Start)
          .layoutWeight(1)
        Image($r('app.media.chevron_right'))
          .width(16)
          .fillColor(Color.Gray)
          .draggable(false)
      }
    }
    .backgroundColor(Color.Transparent)
    .width('100%')
    .padding(10)
    .onClick(() => this.action())
  }
}

@Builder
function AboutPageBuilder() {

}