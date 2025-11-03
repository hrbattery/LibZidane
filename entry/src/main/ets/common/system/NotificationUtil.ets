import { notificationManager } from '@kit.NotificationKit';
import { LogUtil as logger } from '@pura/harmony-utils';

const TAG = '[NotificationUtil] '
class NotificationUtil {
  private lastNotifyMap: Map<number, number> = new Map();
  private readonly THROTTLE_DELAY: number = 100;

  private checkThrottle(id: number): boolean {
    const lastTime = this.lastNotifyMap.get(id) || 0;
    const currentTime = Date.now();

    if (currentTime - lastTime < this.THROTTLE_DELAY) {
      logger.debug(TAG, `通知${id}触发频率限制`);
      return true;
    }

    this.lastNotifyMap.set(id, currentTime);
    return false;
  }

  publish(id: number, title: string, fileName: string) {
    let notificationRequest: notificationManager.NotificationRequest = {
      id: id,
      content: {
        notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
        normal: {
          title: title,
          text: fileName
        }
      }
    }

    notificationManager.publish(notificationRequest)
      .then(() => logger.debug(TAG, '发送通知成功：' + title))
      .catch((err:Error) => {
        logger.error(TAG, '发送通知失败' + err.message)
      });
  }

  download(id: number, title: string, fileName: string, progress: number) {
    if (this.checkThrottle(id)) return;
    let notificationRequest: notificationManager.NotificationRequest = {
      id: id,
      content: {
        notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
        normal: {
          title: title,
          text: fileName
        }
      },
      // 构造进度条模板，name字段当前需要固定配置为downloadTemplate
      template: {
        name: 'downloadTemplate',
        data: { title: title, fileName: fileName, progressValue: progress }
      }
    }

    // 发布通知
    notificationManager.publish(notificationRequest)
      .then(() => logger.debug(TAG, '发送通知成功：进度' + progress))
      .catch((err:Error) => {
        logger.error(TAG, '发送通知失败：' + err.message)
      });
  }

  /**
   * 取消通知
   * @param id
   */
  cancel(id: number) {
    notificationManager.cancel(id, (err: Error) => {
      logger.error(TAG, '取消通知失败：' + err.message)
    })
  }

  /**
   * 取消所有通知
   */
  cancelAll() {
    notificationManager.cancelAll((err: Error) => {
      logger.error(TAG, '取消通知失败' + err.message)
    })
  }
}

export const notificationUtil = new NotificationUtil()