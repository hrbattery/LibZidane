import { AppViewModel } from "./AppViewModel";

/**
 * If a view model need to load with async method, common variables can be extracted.
 */
@ObservedV2
export abstract class NetworkRequestViewModel extends AppViewModel {
  /**
   * state to determine show skeleton or not
   */
  @Trace isLoading: boolean = false
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
}