import { LogUtil as logger, ToastUtil } from '@pura/harmony-utils';
import { deepCopy } from '../../common/CommonUtils';
import { PaginationDataSource } from '../../common/types/ResponseTypes';
import { deleteBook, getDownloaded, getProfile } from '../../model/api/UserApi';
import { BookData, BookDataType } from '../../model/entities/BookModel';
import { BookDataFactory } from '../../model/factory/BookModelFactory';
import { MyBookComponentViewModel } from './MyBookComponentViewModel';

@ObservedV2
export class DownloadedViewModel extends MyBookComponentViewModel {
  @Trace downloadToday: number = 0;
  @Trace downloadLimit: number = 10;
  @Trace currentTime: number = Date.now()

  @Computed
  get timeToResetLimit(): [number, number] {
    // 计算下一个 UTC+3 0 点的 UTC 时间
    const ONE_DAY = 86400000; // 一天的毫秒数
    const THREE_HOURS = 10800000; // 3小时的毫秒数

    // 当前 UTC+3 时间
    const utc3Now = this.currentTime + THREE_HOURS;
    // 下一个 UTC+3 0 点的 UTC 时间
    const nextZeroUTC = Math.ceil(utc3Now / ONE_DAY) * ONE_DAY - THREE_HOURS;

    // 计算剩余毫秒数
    const remainingMs = nextZeroUTC - this.currentTime;

    // 转换为小时、分钟
    const hours = Math.floor(remainingMs / 3600000);
    const minutes = Math.floor((remainingMs % 3600000) / 60000);

    // 格式化为字符串
    return [hours, minutes];
  }

  private async loadDownloadedDataSource(sortOrder: string) {
    this.isLoading = true;
    try {
      let downloaded = await getDownloaded({
        order: sortOrder
      });
      this.isLoadFailed = false;
      this.isLoading = false;
      if (downloaded !== null) {
        this.bookDataSource = downloaded.books.map(element => BookDataFactory.fromBookCommonDataSource(element))
        this.pagination = downloaded.pagination
      }
    } catch (e) {
      logger.error(e)
      this.isLoadFailed = true;
      this.isLoading = false;
    }
  }

  private async loadNewDownloaded(sortOrder: string): Promise<void> {
    if (this.pagination) {
      try {
        let downloaded = await getDownloaded({
          page: this.pagination?.current + 1,
          order: sortOrder
        });
        this.isLoadFailed = false;
        this.isLoading = false;
        if (downloaded !== null) {
          this.bookDataSource.push(...downloaded.books.map(element => new BookData(element as BookDataType)))
          this.pagination = downloaded.pagination
        }
      } catch (e) {
        logger.error(e)
        this.isLoadFailed = true;
        this.isLoading = false;
      }
    }
  }

  async loadDataSource(sortOrder: string): Promise<void> {
    await Promise.all([
      this.loadDownloadedDataSource(sortOrder),
      this.loadProfile()
    ])
  }

  async loadNewData(sortOrder: string): Promise<void> {
    if (!this.isLoadingNew) {
      this.isLoadingNew = true
      await Promise.all([
        await this.loadNewDownloaded(sortOrder),
        this.loadProfile()
      ])
      this.isLoadingNew = false
    }
  }

  public async onRemove(index: number): Promise<void> {
    const bookData = this.bookDataSource[index];
    try {
      const response = await deleteBook(bookData.id)
      if (response) {
        ToastUtil.showToast($r("app.string.notif_remove_book_success"))
        this.bookDataSource.splice(index, 1);
        if (this.pagination !== undefined) {
          const newPagination = deepCopy(this.pagination) as PaginationDataSource
          newPagination.total_items -= 1;
          this.pagination = newPagination;
        }
      }
    } catch (e) {
      logger.error(e)
      ToastUtil.showToast($r("app.string.notif_remove_book_failed"))
    }
  }

  public async loadProfile(): Promise<void> {
    try {
      const response = await getProfile();
      if (response) {
        this.downloadToday = response.downloads_today;
        this.downloadLimit = response.downloads_limit
      }
    } catch (e) {
      logger.error(e)
    }
  }
}