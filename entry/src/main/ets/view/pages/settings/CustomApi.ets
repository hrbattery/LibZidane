import { CustomApiViewModel } from '../../../viewModel/settings/CustomApiViewModel'

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
          Text("Z-Library 使用多个可能的 API 域名来提供可用的服务。")
          Text("如果仍然无法提供可用的服务，而您有可用、可信的 Z-Library 域名，可以添加自定义 API 域名。LibZidane 会优先使用自定义 API 域名。")
          Text("注意：用户凭证等数据会被发送到自定义 API 域名。请自行承担使用自定义 API 域名的风险。")
          Text("当前正在使用：")
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
    .title('自定义 API')
  }

  @Builder
  CustomApiContainer() {
    List() {
      ListItem() {
        this.AddNewEntry(this.viewModel.newApi, (): void => this.viewModel.addApi())
      }

      Repeat(this.viewModel.customApis)
        .each((ri) => {
          ListItem() {
            this.ApiEntry(ri, (index): void => this.viewModel.removeApi(index))
          }
        })
    }
    .width("100%")
    .borderRadius(20)
    .padding(10)
    .margin({ top: 20 })
    .backgroundColor($r("sys.color.comp_background_primary"))
  }

  @Builder
  ApiEntry(ri: RepeatItem<string>, onClick: (index: number) => void) {
    Row({ space: 2 }) {
      Image($r("app.media.list_item_drag"))
        .height(15)
        .fillColor($r("sys.color.icon_primary"))
      Text(ri.item)
      Button() {
        Image($r("app.media.subtract"))
          .height(20)
          .width(20)
      }
      .backgroundColor(Color.Transparent)
      .type(ButtonType.Circle)
      .onClick(() => onClick(ri.index))
    }
    .height(40)
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.SpaceBetween)
    .width("100%")
    .padding(2)
  }

  @Builder
  AddNewEntry(newApiText: string, onClick: () => void) {
    Row({ space: 2 }) {
      TextInput({ text: newApiText })
        .showUnderline(true)
        .underlineColor(Color.Gray)
        .width("90%")
      Button() {
        Image($r("app.media.add"))
          .height(20)
          .width(20)
      }
      .onClick(() => onClick())
      .backgroundColor(Color.Transparent)
      .type(ButtonType.Circle)
    }
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.SpaceBetween)
    .width("100%")
    .height(40)
    .padding(2)
  }
}