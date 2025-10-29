import { PaginationDataSource } from "../common/DataSourceTypes";
import { BookData, BookDetailParam } from "../models/BookModel";
import { BookInfoListItem } from "./BookInfoListItem";

export interface BookInfoListParam {
  books: Array<BookData>,
  pagination: PaginationDataSource | undefined;
}

const defaultSourceData: () => BookInfoListParam = () => {
  return {
    books: [],
    pagination: undefined
  }
}

@ComponentV2
export struct BookInfoList {
  // @Local dataSource: BookInfoListParam = {
  //   books: [],
  //   pagination: undefined
  // }
  @Local bookDataSource: Array<BookData> = []
  @Local pagination: PaginationDataSource | undefined;

  @Local refreshing: boolean = false;
  @Local refreshOffset: number = 0;
  @Local refreshState: RefreshStatus = RefreshStatus.Inactive;
  @Local isLoading: boolean = false;

  @Event onInitialData: (order?: string, page?: number, limit?: number) => Promise<BookInfoListParam> = async () => await defaultSourceData()
  @Event onRefreshData: (order?: string, page?: number, limit?: number) => Promise<BookInfoListParam> = async () => await defaultSourceData()
  @Event onLoadNewData: (order?: string, page?: number, limit?: number) => Promise<BookInfoListParam> = async () => await defaultSourceData()
  @Event updateAmount: (amount: number | undefined) => void;

  pathStack: NavPathStack | undefined = undefined;

  @Builder
  refreshBuilder() {
    Stack({ alignContent: Alignment.Bottom }) {
      // 可以通过刷新状态控制是否存在Progress组件。
      // 当刷新状态处于下拉中或刷新中状态时Progress组件才存在。
      if (this.refreshState != RefreshStatus.Inactive && this.refreshState != RefreshStatus.Done) {
        LoadingProgress()
          .width(32).height(32)
          .margin(10)
      }
    }
    .clip(true)
    .height("100%")
    .width("100%")
  }

  @Builder
  footer() {
    Row() {
      LoadingProgress().height(32).width(48)
      Text("加载中")
    }.width("100%")
    .height(64)
    .justifyContent(FlexAlign.Center)
    // 当不处于加载中状态时隐藏组件。
    .visibility(this.isLoading ? Visibility.Visible : Visibility.Hidden)
  }

  /**
   * Goto book detail page, according to the id and hash value of book.
   * @param bookId
   * @param hash
   */
  gotoBookDetail(bookId: number, hash: string) {
    if (this.pathStack) {
      this.pathStack.pushPathByName("BookDetail", {
        bookId: bookId,
        hash: hash
      } as BookDetailParam)
    }
  }

  async aboutToAppear(): Promise<void> {
    this.pathStack = this.queryNavigationInfo()?.pathStack;
    const dataSource = await this.onInitialData()
    this.bookDataSource = dataSource.books;
    this.pagination = dataSource.pagination;
    this.updateAmount(this.pagination?.total_items);
  }

  build() {
    Refresh({ refreshing: $$this.refreshing, builder: this.refreshBuilder() }) {
      List() {
        Repeat(this.bookDataSource)
          .each((ri) => {
            ListItem() {
              BookInfoListItem({ bookData: ri.item })
                .onClick(() => {
                  this.gotoBookDetail(ri.item.id, ri.item.hash)
                })
            }
          })
          .key((item, index) => `${index}:${item.title}`)
      }
      .width("100%")
      .height("100%")
      .onScrollIndex(async (start: number, end: number) => {
        // 当达到列表末尾时，触发新数据加载。
        if (!this.isLoading && this.pagination && end >= this.bookDataSource.length - 1
          && this.pagination.current < this.pagination.total_pages) {
          this.isLoading = true;
          const updateData = await this.onLoadNewData(undefined, this.pagination.current + 1);
          this.bookDataSource.push(...updateData.books)
          this.pagination = updateData.pagination;
          this.isLoading = false;
        }
      })
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    }
    .onOffsetChange((offset: number) => {
      this.refreshOffset = offset;
    })
    .onStateChange((state: RefreshStatus) => {
      this.refreshState = state;
    })
    .onRefreshing(async () => {
      const dataSource = await this.onRefreshData()
      this.bookDataSource = dataSource.books;
      this.pagination = dataSource.pagination;
      this.refreshing = false;
    })
  }
}