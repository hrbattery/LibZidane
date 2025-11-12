import { common } from '@kit.AbilityKit';
import { notificationManager } from '@kit.NotificationKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { AppStorageV2 } from '@kit.ArkUI';

import { getExtensions, getLanguages } from '../../api/InfoApi';
import { preferencesUtils } from '../data/PreferencesUtils';
import { StorageConstants } from '../const/StorageConstants';
import { SettingsModel } from '../../models/SettingsModel';


export async function appInit(context: common.UIAbilityContext) {
  AppStorage.setOrCreate("base_url", "https://1lib.sk");

  notificationManager.requestEnableNotification(context).catch((reason: BusinessError) => {
    console.log(reason.message)
  }).then(() => {})

  await initPreferences(context);
  await initAppStorage()

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

async function initPreferences(context: common.UIAbilityContext) {
  preferencesUtils.loadPreference(context, StorageConstants.DEFAULT_PREF)
}

async function initAppStorage() {
  let settingsModel = AppStorageV2.connect(SettingsModel, "settingsModel", () => new SettingsModel())!
  settingsModel.hasCookie = await preferencesUtils.has(StorageConstants.DEFAULT_PREF, "cookie")
}