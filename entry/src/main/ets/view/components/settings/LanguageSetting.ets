import { SettingsConstants } from '../../../common/const/SettingsConstants'
import { StorageConstants } from '../../../common/const/StorageConstants'
import { setLanguage } from '../../../common/system/AbilityUtil'
import { preferencesUtils } from '../../../model/storage/PreferencesUtils'

@ComponentV2
export struct LanguageSetting {
  @Local selected: number = preferencesUtils.getSync<number>(StorageConstants.DEFAULT_PREF, 'language', 0)
  private langList: ResourceStr[] = SettingsConstants.LANGUAGE_KEY

  build() {
    Row() {
      Text($r("app.string.ui_setting_general_language"))
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .textAlign(TextAlign.Start)
        .layoutWeight(1)
      Select(this.langList.map((key): SelectOption => {
        return { value: key }
      }))
        .selected(this.selected!!)
        .value(this.langList[this.selected] ?? $r("app.string.ui_setting_general_language_auto"))
        .constraintSize({
          minHeight: 0,
          maxHeight: '100%'
        })
        .height(32)
        .onSelect((index: number) => {
          const currentLangIndex = preferencesUtils.getSync<number>(StorageConstants.DEFAULT_PREF, 'language', 0)
          if (index !== currentLangIndex) {
            setLanguage(SettingsConstants.LANGUAGE_VALUE[index])
            preferencesUtils.putSync(StorageConstants.DEFAULT_PREF, 'language', index)
          }
        })
    }
    .backgroundColor(Color.Transparent)
    .width('100%')
    .padding(10)
  }
}