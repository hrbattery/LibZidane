import { common } from '@kit.AbilityKit';
import { request } from '@kit.BasicServicesKit';
import { url } from '@kit.ArkTS';
import { fileIo as fs } from '@kit.CoreFileKit';
import axios, { AxiosResponse } from '@ohos/axios';
import { LogUtil, ToastUtil } from '@pura/harmony-utils';
import { DialogAction, DialogHelper } from '@pura/harmony-dialog';
import { LocalBookRecord, LocalBookSelection, localBookKey } from '../../model/entities/LocalBookRecord';
import { DownloadFileData } from '../../model/entities/DownloadModel';
import { getBookDownloadUrl } from '../../model/api/BookApi';
import { getLocalBookStore, LocalBookStore } from '../../model/storage/LocalBookStore';
import { openLocalBook, exportLocalBook } from '../system/LocalBookFileActions';
import { notificationUtil } from '../system/NotificationUtil';
import { filesize } from '../thirdparty/filesize/filesize';

class FileDownload {
  private cacheReady: boolean = false;

  /** Reserve the selected version before fetching its URL and publish only committed books. */
  public async downloadBook(context: common.UIAbilityContext, selection: LocalBookSelection): Promise<void> {
    let store: LocalBookStore;
    try {
      store = getLocalBookStore(context);
    } catch (error) {
      LogUtil.error(`Local shelf initialization failed: ${error}`);
      ToastUtil.showToast($r('app.string.local_books_save_failed'));
      return;
    }
    if (!store.beginDownload(selection.id, selection.hash)) {
      ToastUtil.showToast($r('app.string.local_books_downloading'));
      return;
    }
    let cachePath = '';
    try {
      const existing = store.find(selection.id, selection.hash);
      if (existing && store.isAvailable(existing)) {
        await this.openExisting(context, existing);
        return;
      }
      cachePath = this.prepareCache(context, selection);
      const download = await this.getDownloadData(selection);
      ToastUtil.showToast($r('app.string.local_books_download_started'));
      await this.transfer(context, download, cachePath, selection.id);
      const record = store.commit(selection, cachePath, download.fileName);
      const message = context.resourceManager.getStringSync($r('app.string.local_books_download_complete').id);
      try {
        notificationUtil.publish(selection.id, message, record.fileName);
        ToastUtil.showToast(message);
      } catch (error) {
        LogUtil.warn(`Book saved, but completion notification failed: ${error}`);
      }
      // Covers are optional and must never turn a successful book download into a failure.
      this.downloadCover(store, record, selection.cover);
    } catch (error) {
      LogUtil.error(`Book download/save failed: ${error}`);
      const message = context.resourceManager.getStringSync($r('app.string.local_books_save_failed').id);
      try {
        notificationUtil.publish(selection.id, message, selection.title);
      } catch (notificationError) {
        LogUtil.warn(`Download failure notification unavailable: ${notificationError}`);
      }
      ToastUtil.showToast(message);
    } finally {
      try {
        if (cachePath && fs.accessSync(cachePath)) {
          fs.unlinkSync(cachePath);
        }
      } catch (error) {
        LogUtil.error(`Download cache cleanup failed: ${error}`);
      }
      store.endDownload(selection.id, selection.hash);
    }
  }

  /** Clean only our abandoned cache directory, once before this process starts downloading. */
  private prepareCache(context: common.UIAbilityContext, selection: LocalBookSelection): string {
    const directory = `${context.cacheDir}/local-books-downloads`;
    if (!this.cacheReady) {
      if (fs.accessSync(directory)) {
        fs.rmdirSync(directory);
      }
      fs.mkdirSync(directory);
      this.cacheReady = true;
    }
    if (!fs.accessSync(directory)) {
      fs.mkdirSync(directory);
    }
    return `${directory}/${localBookKey(selection.id, selection.hash)}.part`;
  }

  /** Resolve the exact selected version; the remote filename is never a storage path. */
  private async getDownloadData(selection: LocalBookSelection): Promise<DownloadFileData> {
    const info = await getBookDownloadUrl(selection.id, selection.hash);
    if (!info) {
      throw new Error('No download URL was returned');
    }
    const params = new url.URLParams(url.URL.parseURL(info.downloadLink).search);
    return { downloadLink: info.downloadLink,
      fileName: params.get('filename') || `${selection.title}.${selection.extension}` };
  }

  /** Bridge system download events to one terminal promise; callers own cleanup and errors. */
  private async transfer(context: common.UIAbilityContext, data: DownloadFileData,
    cachePath: string, notificationId: number): Promise<void> {
    const task = await request.downloadFile(context, { url: data.downloadLink, filePath: cachePath });
    await new Promise<void>((resolve, reject) => {
      const finish = (error?: Error): void => {
        task.off('complete');
        task.off('fail');
        task.off('progress');
        if (error) {
          reject(error);
        } else {
          resolve();
        }
      };
      task.on('complete', () => finish());
      task.on('fail', () => finish(new Error('System download failed')));
      task.on('progress', (received: number, total: number) => {
        const message = context.resourceManager.getStringSync($r('app.string.notif_file_downloading').id,
          filesize(received), filesize(total));
        notificationUtil.download(notificationId, message, data.fileName, total > 0 ? received / total * 100 : 0);
      });
    });
  }

  /** Reuse a local version; if no reader opens it, offer an explicit export action. */
  private async openExisting(context: common.UIAbilityContext, record: LocalBookRecord): Promise<void> {
    try {
      await openLocalBook(context, record);
    } catch {
      DialogHelper.showAlertDialog({
        title: $r('app.string.local_books_open_failed'),
        content: $r('app.string.local_books_reader_hint'),
        primaryButton: $r('app.string.ui_common_cancel_btn'),
        secondaryButton: $r('app.string.local_books_export'),
        onAction: async (action: DialogAction) => {
          if (action === DialogAction.TWO) {
            try {
              if (await exportLocalBook(context, record)) {
                ToastUtil.showToast($r('app.string.local_books_exported'));
              }
            } catch {
              ToastUtil.showToast($r('app.string.local_books_export_failed'));
            }
          }
        }
      });
    }
  }

  /** Fetch a bounded optional cover without adding account cookies to image requests. */
  private async downloadCover(store: LocalBookStore, record: LocalBookRecord, cover: string): Promise<void> {
    if (!cover) {
      return;
    }
    try {
      const response: AxiosResponse<ArrayBuffer> = await axios.get<ArrayBuffer, AxiosResponse<ArrayBuffer>>(cover, {
        responseType: 'array_buffer', timeout: 10000, maxContentLength: 5 * 1024 * 1024
      });
      store.saveCover(record, response.data);
    } catch (error) {
      LogUtil.warn(`Optional book cover was not saved: ${error}`);
    }
  }
}

export const fileDownload = new FileDownload();
