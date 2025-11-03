import { common } from '@kit.AbilityKit';
import { notificationManager } from '@kit.NotificationKit';


export async function appInit(context: common.UIAbilityContext) {
  notificationManager.requestEnableNotification(context).then(() => {})
}