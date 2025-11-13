import { CoverData } from "../../models/BookModel";

@ObservedV2
export abstract class LibraryComponentViewModel {
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

  public abstract loadDataSource(): Promise<void>
}