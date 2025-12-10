import { DarkModeEnum, SettingsConstants } from '../../../common/const/SettingsConstants'
import { StorageConstants } from '../../../common/const/StorageConstants'
import { setColorMode } from '../../../common/system/AbilityUtil'
import { preferencesUtils } from '../../../model/storage/PreferencesUtils'

@ComponentV2
export struct DarkMode {
  @Local selectedIndex: number =
    preferencesUtils.getSync<number>(StorageConstants.DEFAULT_PREF, 'dark_mode', 2)

  build() {
    Row() {
      Text("深色模式")
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .textAlign(TextAlign.Start)
        .layoutWeight(1)
      Select([{ value: "浅色" }, { value: "深色" }, { value: "跟随系统" }])
        .selected(this.selectedIndex!!)
        .value(SettingsConstants.DARK_MODE[this.selectedIndex] ?? '跟随系统')
        .constraintSize({
          minHeight: 0,
          maxHeight: '100%'
        })
        .height(32)
        .onSelect((index: number) => {
          setColorMode(this.getUIContext().getHostContext()!.getApplicationContext(), index as DarkModeEnum)
          preferencesUtils.putSync(StorageConstants.DEFAULT_PREF, 'dark_mode', index as DarkModeEnum)
        })
    }
    .backgroundColor(Color.Transparent)
    .width('100%')
    .padding(10)
  }
}