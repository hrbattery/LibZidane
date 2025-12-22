import { DarkModeEnum, SettingsConstants } from '../../../common/const/SettingsConstants'
import { StorageConstants } from '../../../common/const/StorageConstants'
import { setColorMode } from '../../../common/system/AbilityUtil'
import { preferencesUtils } from '../../../model/storage/PreferencesUtils'

@ComponentV2
export struct DarkMode {
  @Local selectedIndex: number =
    preferencesUtils.getSync<number>(StorageConstants.DEFAULT_PREF, StorageConstants.PREFKEY_DARK_MODE, 2)

  build() {
    Row() {
      Text($r("app.string.ui_setting_general_dark_mode"))
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .textAlign(TextAlign.Start)
        .layoutWeight(1)
      Select([
        { value: $r("app.string.ui_setting_general_dark_mode_light") },
        { value: $r("app.string.ui_setting_general_dark_mode_dark") },
        { value: $r("app.string.ui_setting_general_dark_mode_auto") }
      ])
        .selected(this.selectedIndex)
        .value(SettingsConstants.DARK_MODE[this.selectedIndex] ?? $r("app.string.ui_setting_general_dark_mode_auto"))
        .constraintSize({
          minHeight: 0,
          maxHeight: '100%'
        })
        .height(32)
        .onSelect((index: number) => {
          this.selectedIndex = index;
          setColorMode(this.getUIContext().getHostContext()!.getApplicationContext(), index as DarkModeEnum)
          preferencesUtils.putSync(StorageConstants.DEFAULT_PREF, 'dark_mode', index as DarkModeEnum)
        })
    }
    .backgroundColor(Color.Transparent)
    .width('100%')
    .padding(10)
  }
}