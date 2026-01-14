import { LogUtil as logger, ToastUtil } from '@pura/harmony-utils';
import { PersistenceV2 } from '@kit.ArkUI';

import { Constants } from '../../common/const/Constants';
import { PaginationDataSource } from '../../common/types/ResponseTypes';
import { getSearch } from '../../model/api/BookApi';
import { BookData, BookDataType } from '../../model/entities/BookModel';
import { SearchFilterOptions } from '../../model/entities/SearchFilterOptionModel';
import { SearchHistoryState } from '../../model/entities/SearchHistoryState';
import { BookDataFactory } from '../../model/factory/BookModelFactory';
import { NetworkRequestViewModel } from '../common/NetworkRequestViewModel';

@ObservedV2
export class SearchViewModel extends NetworkRequestViewModel {
  /**
   * keyword used to search books
   */
  @Trace searchKeyword: string = ""
  /**
   * search order used to search books
   */
  @Trace searchSortOrderIndex: number = 0;
  /**
   * search filter option used to search books
   */
  @Trace searchFilterOption: SearchFilterOptions = new SearchFilterOptions();
  /**
   * data source to book info list
   */
  @Trace bookDataSource: BookData[] = []
  /**
   * data source for pagination data of book info list
   */
  @Trace pagination: PaginationDataSource | undefined = undefined;
  /**
   * search history state managed by PersistenceV2
   */
  @Trace searchHistoryState: SearchHistoryState = PersistenceV2.connect(SearchHistoryState, 'searchHistoryState', () => new SearchHistoryState())!
  /**
   * flag to control search history expansion state
   */
  @Trace isHistoryExpanded: boolean = false;

  private _languageOptions: Record<string, string> = AppStorage.get("language_options") ?? {}

  @Monitor('searchSortOrderIndex','searchFilterOption.exactMatch','searchFilterOption.startYear','searchFilterOption.endYear','searchFilterOption.selectedLanguages','searchFilterOption.selectedExtensions')
  async onSearchParamChange(): Promise<void> {
    await this.loadDataSource();
  }

  @Computed
  get searchSortOrder(): string {
    return Constants.SEARCH_SORT_KEY[this.searchSortOrderIndex]["value"] as string
  }

  async loadDataSource(): Promise<void> {
    this.isLoading = true;
    if (this.searchKeyword && this.searchKeyword !== '') {
      try {
        let searchResult = await getSearch({
          message: this.searchKeyword,
          yearFrom: this.searchFilterOption.startYear,
          yearTo: this.searchFilterOption.endYear,
          languages: this.searchFilterOption.selectedLanguages.map((ele) => this._languageOptions[ele]),
          extensions: this.searchFilterOption.selectedExtensions,
          e: this.searchFilterOption.exactMatch ? 1 : 0,
          order: this.searchSortOrder
        });
        this.isLoadFailed = false;
        this.isLoading = false;
        if (searchResult !== null) {
          this.bookDataSource = searchResult.books.map(element => BookDataFactory.fromBookCommonDataSource(element))
          this.pagination = searchResult.pagination
        }
      } catch (e) {
        logger.error(e)
        this.isLoadFailed = true;
        this.isLoading = false;
      }
    }
  }

  async loadNewSearchData(): Promise<void> {
    if (this.pagination && this.searchKeyword && this.searchKeyword !== '') {
      try {
        let favorites = await getSearch({
          message: this.searchKeyword,
          yearFrom: this.searchFilterOption.startYear,
          yearTo: this.searchFilterOption.endYear,
          languages: this.searchFilterOption.selectedLanguages.map((ele) => this._languageOptions[ele]),
          extensions: this.searchFilterOption.selectedExtensions,
          e: this.searchFilterOption.exactMatch ? 1 : 0,
          page: this.pagination.current + 1,
          order: this.searchSortOrder
        });
        this.isLoadFailed = false;
        this.isLoading = false;
        if (favorites !== null) {
          this.bookDataSource.push(...favorites.books.map(element => new BookData(element as BookDataType)))
          this.pagination = favorites.pagination
        }
      } catch (e) {
        logger.error(e)
        this.isLoadFailed = false;
        this.isLoading = false;
      }
    }
  }

  async loadNewData(): Promise<void> {
    if (!this.isLoadingNew) {
      this.isLoadingNew = true
      await this.loadNewSearchData()
      this.isLoadingNew = false
    }
  }

  async onSubmitSearch(value: string) {
    if (!value) {
      ToastUtil.showToast($r("app.string.notif_search_empty_content"))
    } else {
      this.searchKeyword = value
      await this.loadDataSource()
    }
  }

  /**
   * Add a new search keyword to history with LRU logic
   * @param keyword - The search keyword to add
   */
  addSearchHistory(keyword: string): void {
    if (!keyword || keyword.trim() === '') return;

    try {
      const trimmedKeyword = keyword.trim();
      const maxHistoryItems = 30;

      // Remove if already exists (to move to front)
      const existingIndex = this.searchHistoryState.searchHistory.indexOf(trimmedKeyword);
      if (existingIndex > -1) {
        this.searchHistoryState.searchHistory.splice(existingIndex, 1);
      }

      // Add to front
      this.searchHistoryState.searchHistory.unshift(trimmedKeyword);

      // Limit to max items
      if (this.searchHistoryState.searchHistory.length > maxHistoryItems) {
        this.searchHistoryState.searchHistory = this.searchHistoryState.searchHistory.slice(0, maxHistoryItems);
      }
    } catch (e) {
      logger.error(`Error adding search history: ${JSON.stringify(e)}`);
      // Continue execution even if storage fails
    }
  }

  /**
   * Delete a search history item by index
   * @param index - The index of the item to delete
   */
  deleteSearchHistory(index: number): void {
    try {
      if (index >= 0 && index < this.searchHistoryState.searchHistory.length) {
        this.searchHistoryState.searchHistory.splice(index, 1);
      }
    } catch (e) {
      logger.error(`Error deleting search history: ${JSON.stringify(e)}`);
      // Continue execution even if storage fails
    }
  }

  /**
   * Clear all search history
   */
  clearSearchHistory(): void {
    try {
      this.searchHistoryState.searchHistory = [];
    } catch (e) {
      logger.error(`Error clearing search history: ${JSON.stringify(e)}`);
      // Continue execution even if storage fails
    }
  }
}