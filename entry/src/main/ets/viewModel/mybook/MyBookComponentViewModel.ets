import { PaginationDataSource } from "../../common/types/ResponseTypes";
import { BookData } from "../../models/BookModel";

@ObservedV2
export abstract class MyBookComponentViewModel {
  /**
   * data source to book info list
   */
  @Trace bookDataSource: BookData[] = []

  /**
   * data source for pagination data of book info list
   */
  @Trace pagination: PaginationDataSource | undefined = undefined;

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
   * state to determine show loadingNew component or not
   */
  @Trace isLoadingNew: boolean = false

  public abstract loadDataSource(sortOrder: string): Promise<void>

  public abstract loadNewData(sortOrder: string): Promise<void>
}