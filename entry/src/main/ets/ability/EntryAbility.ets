import { AbilityConstant, Configuration, UIAbility, Want } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { DarkModeEnum, SettingsConstants } from '../common/const/SettingsConstants';
import { StorageConstants } from '../common/const/StorageConstants';
import { appInit, initPreferences,
  listenSystemLanguageChange,
  setColorMode, setAppPreferLanguage } from '../common/system/AbilityUtil';
import { windowUtil } from '../common/system/WindowUtil';
import { preferencesUtils } from '../model/storage/PreferencesUtils';
import { getLocalBookStore } from '../model/storage/LocalBookStore';

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    initPreferences(this.context);
    const darkModeSetting =
      preferencesUtils.getSync<DarkModeEnum>(
        StorageConstants.DEFAULT_PREF,
        StorageConstants.PREFKEY_DARK_MODE,
        DarkModeEnum.AUTO
      )
    const languageSetting = preferencesUtils.getSync<number>(
      StorageConstants.DEFAULT_PREF,
      StorageConstants.PREFKEY_LANGUAGE,
      -1
    )

    setColorMode(this.context.getApplicationContext(), darkModeSetting)
    if (languageSetting !== 0) {
      setAppPreferLanguage(SettingsConstants.LANGUAGE_VALUE[languageSetting])
    }
    listenSystemLanguageChange()

    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  /** Initialize the independent local shelf and load the main page. */
  async onWindowStageCreate(windowStage: window.WindowStage): Promise<void> {
    try {
      getLocalBookStore(this.context);
    } catch (error) {
      // The local shelf displays a retryable error; online pages remain available.
      hilog.error(DOMAIN, 'LocalBooks', 'Initialize local shelf failed: %{public}s', String(error));
    }
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

  /** Refresh system-bar contrast after the application or system theme changes. */
  onConfigurationUpdate(newConfig: Configuration): void {
    windowUtil.updateSystemBars();
  }

  onWindowStageDestroy(): void {
    windowUtil.cancelListeners();
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  /** Recheck managed files when returning from an external reader or file picker. */
  onForeground(): void {
    try {
      getLocalBookStore(this.context).notifyChanged();
    } catch (error) {
      hilog.error(DOMAIN, 'LocalBooks', 'Refresh local shelf failed: %{public}s', String(error));
    }
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }
}
