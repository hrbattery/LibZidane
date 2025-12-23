import { LogUtil as logger, ToastUtil } from '@pura/harmony-utils';
import { deepCopy } from '../../common/CommonUtils';
import { PaginationDataSource } from '../../common/types/ResponseTypes';
import { deleteBook, getDownloaded } from '../../model/api/UserApi';
import { BookData, BookDataType } from '../../model/entities/BookModel';
import { BookDataFactory } from '../../model/factory/BookModelFactory';
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
    await this.loadDownloadedDataSource(sortOrder)
  }

  async loadNewData(sortOrder: string): Promise<void> {
    if (!this.isLoadingNew) {
      this.isLoadingNew = true
      await this.loadNewDownloaded(sortOrder)
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
}