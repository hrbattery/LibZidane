import { LogUtil as logger } from '@pura/harmony-utils';

import { Constants } from '../../common/const/Constants';
import { PaginationDataSource } from '../../common/types/ResponseTypes';
import { getSearch } from '../../model/api/BookApi';
import { BookData, BookDataType } from '../../model/entities/BookModel';
import { SearchFilterOptions } from '../../model/entities/SearchFilterOptionModel';
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

  private _languageOptions: Record<string, string> = AppStorage.get("language_options") ?? {}

  @Monitor('searchSortOrderIndex','searchFilterOption.exactMatch','searchFilterOption.startYear','searchFilterOption.endYear','searchFilterOption.selectedLanguages','searchFilterOption.selectedExtensions')
  async onSearchParamChange(): Promise<void> {
    await this.loadDataSource();
  }

  @Computed
  get searchSortOrder(): string {
    return Constants.SEARCH_SORT_KEY[this.searchSortOrderIndex]["value"];
  }

  async loadDataSource(): Promise<void> {
    this.isLoading = true;
    if (this.searchKeyword && this.searchKeyword !== '') {
      try {
        let searchResult = await getSearch({
          message: this.searchKeyword,
          yearFrom: this.searchFilterOption.startYear === '不限' ? undefined : this.searchFilterOption.startYear,
          yearTo: this.searchFilterOption.endYear === '不限' ? undefined : this.searchFilterOption.endYear,
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
          yearFrom: this.searchFilterOption.startYear === '不限' ? undefined : this.searchFilterOption.startYear,
          yearTo: this.searchFilterOption.endYear === '不限' ? undefined : this.searchFilterOption.endYear,
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
}