import { SettingsConstants } from "../../common/const/SettingsConstants"

@ComponentV2
export struct LanguageSetting {
  @Local selected: number = 0

  build() {
    Row({ space: 10 }) {
      Text("语言设置")
        .fontSize(16)
        .textAlign(TextAlign.Center)
        .fontWeight(FontWeight.Medium)
        .textAlign(TextAlign.Start)
        .layoutWeight(1)
      Select([{ value: "中文" }, { value: "English" }])
        .selected(this.selected)
        .value(this.selected ? SettingsConstants.LANGUAGE[this.selected] : '中文')
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