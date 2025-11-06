import { common } from '@kit.AbilityKit';
import { notificationManager } from '@kit.NotificationKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { getExtensions, getLanguages } from '../api/InfoApi';


export function appInit(context: common.UIAbilityContext) {
  notificationManager.requestEnableNotification(context).catch((reason: BusinessError) => {
    console.log(reason.message)
  }).then(() => {})

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