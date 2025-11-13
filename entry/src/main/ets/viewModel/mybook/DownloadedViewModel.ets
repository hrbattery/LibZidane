import { LogUtil as logger } from '@pura/harmony-utils';
import { getDownloaded } from '../../model/api/UserApi';
import { BookData, BookDataType } from '../../model/entities/BookModel';
import { MyBookComponentViewModel } from './MyBookComponentViewModel';

@ObservedV2
export class DownloadedViewModel extends MyBookComponentViewModel {
  private async loadDownloadedDataSource(sortOrder: string) {
    this.isLoading = true;
    try {
      let downloaded = await getDownloaded({
        order: sortOrder
      });
      this.isLoadFailed = false;
      this.isLoading = false;
      if (downloaded !== null) {
        this.bookDataSource = downloaded.books.map(element => new BookData(element as BookDataType))
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
    await this.loadDownloadedDataSource(sortOrder)
  }

  async loadNewData(sortOrder: string): Promise<void> {
    if (!this.isLoadingNew) {
      this.isLoadingNew = true
      await this.loadNewDownloaded(sortOrder)
      this.isLoadingNew = false
    }
  }
}