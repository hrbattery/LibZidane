import { SettingsConstants } from "../../common/const/SettingsConstants"

@ComponentV2
export struct DarkMode {
  @Local selected: number = 2

  build() {
    Row() {
      Text("深色模式")
        .fontSize(16)
        .textAlign(TextAlign.Center)
        .fontWeight(FontWeight.Medium)
        .textAlign(TextAlign.Start)
        .layoutWeight(1)
      Select([{ value: "浅色" }, { value: "深色" }, { value: "跟随系统" }])
        .selected(this.selected)
        .value(this.selected ? SettingsConstants.DARK_MODE[this.selected] : '跟随系统')
        .constraintSize({
          minHeight: 0,
          maxHeight: '100%'
        })
        .height(32)
        .onSelect((index: number) => {
          // AppStorage.setOrCreate(StorageConstants.PLAY_QUALITY,index)
          // PreferencesUtils.putPreferenceValue('Settings', StorageConstants.PLAY_QUALITY, index)
        })
    }
    .backgroundColor(Color.Transparent)
    .width('100%')
    .padding(10)
  }
}