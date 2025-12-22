import { LogUtil as logger } from '@pura/harmony-utils';
import { CustomApiViewModel } from '../../../viewModel/settings/CustomApiViewModel';

@Builder
export function CustomApiBuilder() {
  CustomApi()
}

@Preview
@ComponentV2
struct CustomApi {
  @Local viewModel: CustomApiViewModel = new CustomApiViewModel()

  build() {
    NavDestination() {
      Column() {
        Column() {
          Text($r("app.string.ui_custom_api_declaimer"))
          Text() {
            Span($r("app.string.ui_custom_api_current_active"))
          }
        }
        .alignItems(HorizontalAlign.Start)
        .alignSelf(ItemAlign.Start)

        this.CustomApiContainer()
      }
      .height("100%")
      .width("100%")
      .padding({ top: 20, left: 20, right: 20 })
      .backgroundColor($r("sys.color.background_secondary"))
    }
    .title($r("app.string.ui_setting_general_custom_api"))
  }

  @Builder
  CustomApiContainer() {
    List() {
      ListItem() {
        AddNewEntry({
          cb: async (text: string): Promise<void> => await this.viewModel.addApi(text)
        })
      }

      Repeat(this.viewModel.customApis)
        .each((ri) => {
          ListItem() {
            ApiEntry({
              ri: ri,
              cb: (index): void => this.viewModel.removeApi(index)
            })
          }
        })
        .onMove((from: number, to: number) => this.viewModel.onMove(from, to));
    }
    .width("100%")
    .borderRadius(20)
    .padding(10)
    .margin({ top: 20 })
    .backgroundColor($r("sys.color.comp_background_primary"))
  }
}


@ComponentV2
struct ApiEntry {
  @Param @Require ri: RepeatItem<string>
  @Event cb: (index: number) => void

  build() {
    Row({ space: 2 }) {
      Image($r("app.media.list_item_drag"))
        .height(15)
        .fillColor($r("sys.color.icon_primary"))
        .draggable(false)
      Text(this.ri.item)
      Button() {
        Image($r("app.media.subtract"))
          .height(20)
          .width(20)
          .draggable(false)
      }
      .backgroundColor(Color.Transparent)
      .type(ButtonType.Circle)
      .onClick(() => this.cb(this.ri.index))
    }
    .height(44)
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.SpaceBetween)
    .width("100%")
    .padding(2)
  }
}

@ComponentV2
struct AddNewEntry {
  @Local newApiText: string = ""
  @Event $newApiText: (val: string) => void = (val: string) => { this.newApiText = val; }
  @Event cb: (text: string) => Promise<void>

  build() {
    Row({ space: 2 }) {
      TextInput({ text: this.newApiText })
        .showUnderline(true)
        .width("90%")
        .height(40)
        .onChange((val) => this.$newApiText(val))
      Button() {
        Image($r("app.media.add"))
          .height(20)
          .width(20)
          .draggable(false)
      }
      .onClick(async () => {
        try {
          await this.cb(this.newApiText)
          this.newApiText = "";
        } catch (e) {
          logger.error(e.message)
        }
      })
      .backgroundColor(Color.Transparent)
      .type(ButtonType.Circle)
    }
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.SpaceBetween)
    .width("100%")
    .height(44)
    .padding(2)
  }
}