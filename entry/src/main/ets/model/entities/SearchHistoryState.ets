@ObservedV2
export class SearchHistoryState {
  /**
   * Array of recent search keywords
   */
  @Trace searchHistory: string[] = [];

  /**
   * Constructor with default empty array
   */
  constructor() {
    this.searchHistory = [];
  }
}