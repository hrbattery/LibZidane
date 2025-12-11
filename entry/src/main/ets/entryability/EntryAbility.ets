import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { DarkModeEnum, SettingsConstants } from '../common/const/SettingsConstants';
import { StorageConstants } from '../common/const/StorageConstants';
import { appInit, initPreferences,
  listenSystemLanguageChange,
  setColorMode, setLanguage } from '../common/system/AbilityUtil';
import { windowUtil } from '../common/system/WindowUtil';
import { preferencesUtils } from '../model/storage/PreferencesUtils';

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    initPreferences(this.context);
    const darkModeSetting =
      preferencesUtils.getSync<DarkModeEnum>(StorageConstants.DEFAULT_PREF, 'dark_mode', DarkModeEnum.AUTO)
    const languageSetting = preferencesUtils.getSync<number>(StorageConstants.DEFAULT_PREF, 'language', -1)

    setColorMode(this.context.getApplicationContext(), darkModeSetting)
    if (languageSetting !== 0) {
      setLanguage(SettingsConstants.LANGUAGE_VALUE[languageSetting])
    }
    listenSystemLanguageChange()

    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  async onWindowStageCreate(windowStage: window.WindowStage): Promise<void> {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('view/pages/Home', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
      windowUtil.init(windowStage.getMainWindowSync())
    });

    await appInit(this.context)
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }
}