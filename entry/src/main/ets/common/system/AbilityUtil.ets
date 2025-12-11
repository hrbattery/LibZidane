import { common, ConfigurationConstant } from '@kit.AbilityKit';
import { BusinessError, commonEventManager } from '@kit.BasicServicesKit';
import { notificationManager } from '@kit.NotificationKit';
import { LogUtil as logger } from '@pura/harmony-utils';

import { getExtensions, getLanguages } from '../../model/api/InfoApi';
import { preferencesUtils } from '../../model/storage/PreferencesUtils';
import { DarkModeEnum, SettingsConstants } from '../const/SettingsConstants';
import { StorageConstants } from '../const/StorageConstants';
import { i18n } from '@kit.LocalizationKit';

const TAG = '[AbilityUtil] '

export async function appInit(context: common.UIAbilityContext) {
  AppStorage.setOrCreate("base_url", "https://z-library.sk");

  notificationManager.requestEnableNotification(context).catch((reason: BusinessError) => {
    console.log(reason.message)
  }).then(() => {})

  // await initAppStorage()

  // get languages options
  // todo: 获取语言与header中的app language键值挂钩，等设置项做了之后作为preference存储、添加到header后再获取语言选项
  getLanguages().then((languages: Record<string, string>) => {
    let reverseLanguages: Record<string, string> = {};
    for (const entry of Object.entries(languages)) {
      reverseLanguages[entry[1]] = entry[0]
    }
    AppStorage.setOrCreate("language_options", reverseLanguages);
  })

  getExtensions().then((extensions: string[]) => {
    AppStorage.setOrCreate("extension_options", extensions);
  })
}

export function initPreferences(context: common.UIAbilityContext) {
  preferencesUtils.loadPreferenceSync(context, StorageConstants.DEFAULT_PREF)
}

// async function initAppStorage() {
//   let settingsModel = AppStorageV2.connect(SettingsModel, "settingsModel", () => new SettingsModel())!
//   settingsModel.loginState = await preferencesUtils.has(StorageConstants.DEFAULT_PREF, "cookie")
// }

export function setColorMode(context: common.ApplicationContext, index: DarkModeEnum) {
  try {
    switch (index) {
      case DarkModeEnum.LIGHT:
        context.setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT);
        break;
      case DarkModeEnum.DARK:
        context.setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_DARK);
        break;
      case DarkModeEnum.AUTO:
      default:
        context.setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
        break;
    }
  } catch (err) {
    logger.error(TAG, `Failed to set colorMode. Cause: ${JSON.stringify(err)}`);
  }
}

export function setLanguage(language: string) {
  try {
    if (language === 'default') {
      // 因为设置偏好语言为'default'后，应用语言将跟随系统语言，应用冷启动才能生效
      // 因此先获取当前系统语言、强制设置一次后再设置成default、保证之后也生效
      // 但实际上现在在设置为default后切换系统语言，依然无法自动变更
      const systemLang = i18n.System.getFirstPreferredLanguage()
      i18n.System.setAppPreferredLanguage(systemLang)
    }
    i18n.System.setAppPreferredLanguage(language)
  } catch (err) {
    logger.error(TAG, `Failed to set colorMode. Cause: ${JSON.stringify(err)}`);
  }
}

export function listenSystemLanguageChange() {
  let subscribeInfo: commonEventManager.CommonEventSubscribeInfo = {
    events: [commonEventManager.Support.COMMON_EVENT_LOCALE_CHANGED]
  };
  // 创建订阅者
  commonEventManager.createSubscriber(subscribeInfo)
    .then((commonEventSubscriber: commonEventManager.CommonEventSubscriber) => {
      commonEventManager.subscribe(commonEventSubscriber, () => {
        const languageSetting = preferencesUtils.getSync<number>(StorageConstants.DEFAULT_PREF, 'language', -1)

        if (languageSetting === 0) {
          setLanguage(SettingsConstants.LANGUAGE_VALUE[languageSetting])
        }
      })
    })
}