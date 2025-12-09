import { CoverData } from '../../model/entities/BookModel';
import { AppViewModel } from '../AppViewModel';

@ObservedV2
export abstract class LibraryComponentViewModel extends AppViewModel {
  /**
   * data source to book cover waterflow
   */
  @Trace coverDataSource: CoverData[] = []
  /**
   * state to determine show skeleton or not
   */
  @Trace isLoading: boolean = true
  /**
   * state to determine show error placeholder or empty placeholder
   */
  @Trace isLoadFailed: boolean = false
  /**
   * state to determine show refreshing component or not
   */
  @Trace isRefreshing: boolean = false
  /**
   * flag to determine this page requires login status or not
   */
  @Trace needLoginStatus: boolean = true

  public abstract loadDataSource(): Promise<void>
}