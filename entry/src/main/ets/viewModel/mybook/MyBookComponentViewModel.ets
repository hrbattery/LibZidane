import { PaginationDataSource } from '../../common/types/ResponseTypes';
import { BookData } from '../../model/entities/BookModel';
import { NetworkRequestViewModel } from '../common/NetworkRequestViewModel';

@ObservedV2
export abstract class MyBookComponentViewModel extends NetworkRequestViewModel {
  /**
   * data source to book info list
   */
  @Trace bookDataSource: BookData[] = []
  /**
   * data source for pagination data of book info list
   */
  @Trace pagination: PaginationDataSource | undefined = undefined;

  public abstract loadDataSource(sortOrder: string): Promise<void>

  public abstract loadNewData(sortOrder: string): Promise<void>
}