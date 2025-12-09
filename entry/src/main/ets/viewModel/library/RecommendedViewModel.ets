import { LogUtil as logger } from '@pura/harmony-utils';

import { getRecommended } from '../../model/api/UserApi';
import { CoverDataFactory } from '../../model/factory/BookModelFactory';
import { LibraryComponentViewModel } from './LibraryComponentViewModel';

@ObservedV2
export class RecommendedViewModel extends LibraryComponentViewModel {
  private async loadRecommendedDataSource() {
    this.isLoading = true;
    try {
      let recommends = await getRecommended();
      this.isLoadFailed = false;
      this.isLoading = false;
      return recommends.map(element => {
        return CoverDataFactory.fromCoverDataSource(element)
      })
    } catch (e) {
      logger.error(e)
      this.isLoadFailed = true;
      this.isLoading = false;
    }
    return []
  }

  async loadDataSource(): Promise<void> {
    this.coverDataSource = await this.loadRecommendedDataSource()
  }
}