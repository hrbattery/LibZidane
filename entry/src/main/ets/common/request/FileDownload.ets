import { FullBookDataType } from "../../models/BookModel";
import { DownloadFileData } from "../../models/DownloadModel";
import { path } from '@mysoft/path'
import { fileUri, picker } from '@kit.CoreFileKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit';
import ReqInst from "./Request";
import { Any, DialogUtil, FileUtil, LogUtil, ToastUtil } from "@pura/harmony-utils";
import { AxiosProgressEvent } from "@ohos/axios";
import { notificationUtil } from "../system/NotificationUtil";


class FileDownload {
  async downloadBook(context: common.UIAbilityContext, downloadData: DownloadFileData, bookData: FullBookDataType) {
    const cachePath = path.join(context.cacheDir, downloadData.fileName)
    const filesPath = await this.getDownloadPath(context, downloadData.fileName)
    if (filesPath) {
      if (await FileUtil.access(filesPath.path)) {
        DialogUtil.showConfirmDialog({ title:'提示', message:'文件已存在'})
        return;
      }
      try {
        ToastUtil.showToast("开始下载：" + downloadData.fileName)
        await ReqInst.get<Any>(downloadData.downloadLink, {
          timeout: 0,
          filePath: cachePath,
          onDownloadProgress: (progressEvent: AxiosProgressEvent) => {
            // todo: 显示已下载和总大小的具体数值，显示在通知标题中
            notificationUtil.download(bookData.id, '正在下载', downloadData.fileName, (progressEvent.loaded / progressEvent.total!) * 100)
          }
        })
        await fs.moveFile(cachePath, filesPath.path)
        // todo: 通知回调，可以点击跳转到下载文件目录处
        notificationUtil.publish(bookData.id, '下载完成', downloadData.fileName)
        // relationStore.addPair(fileUri, bookData)
        ToastUtil.showToast(`下载完成: ${downloadData.fileName}`)
      } catch (err) {
        ToastUtil.showToast('下载时出错: ' + err.message)
        notificationUtil.publish(bookData.id, '下载失败', downloadData.fileName)
        LogUtil.error(`下载时出错: ${JSON.stringify(err)}`)
      } finally {
        await fs.unlink(cachePath)
      }
    }
  }

  private async getDownloadPath(context: common.UIAbilityContext, fileName: string): Promise<fileUri.FileUri | null> {
    let uri: string = '';
    const documentViewPicker = new picker.DocumentViewPicker(context);
    const documentSaveOptions = new picker.DocumentSaveOptions();
    documentSaveOptions.pickerMode = picker.DocumentPickerMode.DOWNLOAD;

    try {
      const documentSaveResult = await documentViewPicker.save(documentSaveOptions);
      uri = documentSaveResult[0];
      const testFilePath = new fileUri.FileUri(`${uri}/${fileName}`);
      return testFilePath;
    } catch (err) {
      console.error(`Invoke documentViewPicker.save failed, code is ${err.code}, message is ${err.message}`);
    };
    return null;
  }

  private onProgress() {
    // notification.update
  }

  private onComplete() {
    // notification.update(FINISH)
    // toast

  }

  private onError() {
    // notification.cancel
    // toast
  }
}

export const fileDownload = new FileDownload()