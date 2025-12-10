import { CoverData } from '../../model/entities/BookModel';
import { NetworkRequestViewModel } from '../common/NetworkRequestViewModel';

@ObservedV2
export abstract class LibraryComponentViewModel extends NetworkRequestViewModel {
  /**
   * data source to book cover waterflow
   */
  @Trace coverDataSource: CoverData[] = []
  /**
   * flag to determine this page requires login status or not
   */
  @Trace needLoginStatus: boolean = true

  public abstract loadDataSource(): Promise<void>
}