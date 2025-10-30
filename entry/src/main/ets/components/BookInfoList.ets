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
  @Param bookDataSource: Array<BookData> = []
  @Param pagination: PaginationDataSource | undefined = undefined;

  @Local refreshing: boolean = false;
  @Local refreshOffset: number = 0;
  @Local refreshState: RefreshStatus = RefreshStatus.Inactive;
  @Local isLoading: boolean = false;

  @Event onInitialData: () => Promise<void> = async () => {}
  @Event onRefreshData: () => Promise<void> = async () => {}
  @Event onLoadNewData: () => Promise<void> = async () => {}

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
    await this.onInitialData()
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
          await this.onLoadNewData();
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
      await this.onRefreshData()
      this.refreshing = false;
    })
  }
}