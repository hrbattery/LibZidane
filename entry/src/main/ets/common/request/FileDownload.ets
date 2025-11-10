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
import { BusinessError, request } from '@kit.BasicServicesKit';
import { filesize } from "../../thirdparty/filesize/filesize"


class FileDownload {
  async downloadBook(context: common.UIAbilityContext, downloadData: DownloadFileData, bookData: FullBookDataType) {
    const cachePath = path.join(context.cacheDir, downloadData.fileName)
    const filesPath = await this.getDownloadPath(context, downloadData.fileName)
    if (filesPath) {
      if (await FileUtil.access(filesPath.path)) {
        DialogUtil.showConfirmDialog({ title:'提示', message:'文件已存在'})
        return;
      }
      if (await FileUtil.access(cachePath)) {
        await fs.unlink(cachePath)
      }
      try {
        ToastUtil.showToast("开始下载：" + downloadData.fileName)

        const downloadTask: request.DownloadTask = await request.downloadFile(context, {
          url: downloadData.downloadLink,
          filePath: cachePath
        })
        downloadTask.on('complete', async () => {
          await this.onComplete(cachePath, filesPath, bookData, downloadData);
        })
        downloadTask.on('progress', (receivedSize: number, totalSize: number) => {
          const receiveSizeText: string = filesize(receivedSize)
          const totalSizeText: string = filesize(totalSize)
          notificationUtil.download(
            bookData.id,
            `正在下载 (${receiveSizeText} / ${totalSizeText})`,
            downloadData.fileName,
            (receivedSize / totalSize) * 100
          )
        })
        downloadTask.on('fail', async () => {
          await fs.unlink(cachePath)
        })
      } catch (err) {
        this.onError(err, bookData, downloadData);
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

  private onProgress(id: number, fileName: string, progress: number) {
    // todo: 显示已下载和总大小的具体数值，显示在通知标题中
    notificationUtil.download(id, '正在下载', fileName, progress)
  }

  private async onComplete(cachePath: string, filesPath: fileUri.FileUri, bookData: FullBookDataType,
    downloadData: DownloadFileData) {
    await fs.moveFile(cachePath, filesPath.path);
    // todo: 通知回调，可以点击跳转到下载文件目录处
    notificationUtil.publish(bookData.id, '下载完成', downloadData.fileName);
    // relationStore.addPair(fileUri, bookData)
    ToastUtil.showToast(`下载完成: ${downloadData.fileName}`);
  }

  private onError(err: BusinessError, bookData: FullBookDataType, downloadData: DownloadFileData) {
    ToastUtil.showToast('下载时出错: ' + err.message);
    notificationUtil.publish(bookData.id, '下载失败', downloadData.fileName);
    LogUtil.error(`下载时出错: ${JSON.stringify(err)}`);
  }
}

export const fileDownload = new FileDownload()