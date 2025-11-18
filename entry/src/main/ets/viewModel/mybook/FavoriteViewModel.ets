import { LogUtil as logger } from '@pura/harmony-utils';

import { getFavorite } from '../../model/api/UserApi';
import { BookData, BookDataType } from '../../model/entities/BookModel';
import { MyBookComponentViewModel } from './MyBookComponentViewModel';

@ObservedV2
export class FavoriteViewModel extends MyBookComponentViewModel {
  private async loadFavoritesDataSource(sortOrder: string) {
    this.isLoading = true;
    try {
      let favorites = await getFavorite({
        order: sortOrder
      });
      this.isLoadFailed = false;
      this.isLoading = false;
      if (favorites !== null) {
        this.bookDataSource = favorites.books.map(element => new BookData(element as BookDataType))
        this.pagination = favorites.pagination
      }
    } catch (e) {
      logger.error(e)
      this.isLoadFailed = true;
      this.isLoading = false;
    }
  }

  private async loadNewFavorites(sortOrder: string): Promise<void> {
    if (this.pagination) {
      try {
        let favorites = await getFavorite({
          page: this.pagination?.current + 1,
          order: sortOrder
        });
        this.isLoadFailed = false;
        this.isLoading = false;
        if (favorites !== null) {
          this.bookDataSource.push(...favorites.books.map(element => new BookData(element as BookDataType)))
          this.pagination = favorites.pagination
        }
      } catch (e) {
        logger.error(e)
        this.isLoadFailed = true;
        this.isLoading = false;
      }
    }
  }

  async loadDataSource(sortOrder: string): Promise<void> {
    await this.loadFavoritesDataSource(sortOrder)
  }

  async loadNewData(sortOrder: string): Promise<void> {
    if (!this.isLoadingNew) {
      this.isLoadingNew = true
      await this.loadNewFavorites(sortOrder)
      this.isLoadingNew = false
    }
  }
}