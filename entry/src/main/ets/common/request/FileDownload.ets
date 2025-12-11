import { common } from '@kit.AbilityKit';
import { BusinessError, request } from '@kit.BasicServicesKit';
import { fileUri, fileIo as fs, picker } from '@kit.CoreFileKit';
import { path } from '@mysoft/path';
import { DialogUtil, FileUtil, LogUtil, ToastUtil } from '@pura/harmony-utils';
import { FullBookData } from '../../model/entities/BookModel';
import { DownloadFileData } from '../../model/entities/DownloadModel';
import { notificationUtil } from '../system/NotificationUtil';
import { filesize } from '../thirdparty/filesize/filesize';


class FileDownload {
  async downloadBook(context: common.UIAbilityContext, downloadData: DownloadFileData, bookData: FullBookData) {
    const cachePath = path.join(context.cacheDir, downloadData.fileName)
    const filesPath = await this.getDownloadPath(context, downloadData.fileName)

    const NOTIF_FILE_DOWNLOADING_RESID: number = $r('app.string.notif_file_downloading').id
    if (filesPath) {
      if (await FileUtil.access(filesPath.path)) {
        DialogUtil.showConfirmDialog({
          title: $r("app.string.notif_file_existed_title"),
          message: $r("app.string.notif_file_existed_message")
        })
        return;
      }
      if (await FileUtil.access(cachePath)) {
        await fs.unlink(cachePath)
      }
      try {
        ToastUtil.showToast(context.resourceManager.getStringSync(
          $r('app.string.notif_start_download').id,
          downloadData.fileName
        ))

        const downloadTask: request.DownloadTask = await request.downloadFile(context, {
          url: downloadData.downloadLink,
          filePath: cachePath
        })
        downloadTask.on('complete', async () => {
          await this.onComplete(context, cachePath, filesPath, bookData, downloadData);
        })
        downloadTask.on('progress', (receivedSize: number, totalSize: number) => {
          const receiveSizeText: string = filesize(receivedSize)
          const totalSizeText: string = filesize(totalSize)
          const notificationString: string = context.resourceManager.getStringSync(
            NOTIF_FILE_DOWNLOADING_RESID,
            receiveSizeText,
            totalSizeText
          )
          notificationUtil.download(
            bookData.id,
            notificationString,
            // `正在下载 (${receiveSizeText} / ${totalSizeText})`,
            downloadData.fileName,
            (receivedSize / totalSize) * 100
          )
        })
        downloadTask.on('fail', async () => {
          await fs.unlink(cachePath)
        })
      } catch (err) {
        this.onError(err, context, bookData, downloadData);
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
    }
    ;
    return null;
  }

  private async onComplete(context: common.UIAbilityContext, cachePath: string, filesPath: fileUri.FileUri, bookData: FullBookData,
    downloadData: DownloadFileData) {
    await fs.moveFile(cachePath, filesPath.path);

    const notificationString: string = context.resourceManager.getStringSync(
      $r("app.string.notif_download_accomplish").id
    )

    // todo: 通知回调，可以点击跳转到下载文件目录处
    notificationUtil.publish(bookData.id, notificationString, downloadData.fileName);
    // relationStore.addPair(fileUri, bookData)
    ToastUtil.showToast(`${notificationString}: ${downloadData.fileName}`);
  }

  private onError(err: BusinessError, context: common.UIAbilityContext, bookData: FullBookData, downloadData: DownloadFileData) {
    const notificationString: string = context.resourceManager.getStringSync(
      $r("app.string.notif_download_failed").id
    )
    ToastUtil.showToast($r("app.string.notif_download_error") + err.message);
    notificationUtil.publish(bookData.id, notificationString, downloadData.fileName);
    LogUtil.error($r("app.string.notif_download_error") + JSON.stringify(err));
  }
}

export const fileDownload = new FileDownload()