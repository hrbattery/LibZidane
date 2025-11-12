import { BookDetailParam, CoverData } from '../models/BookModel'
import { BookCover } from './BookCover'

/**
 * WaterFlow component showing book covers.
 * Receive an array of CoverData.
 */

@ComponentV2
export struct BookCoverWaterFlow {
  @Local coverDataSource: CoverData[] = []

  @Local refreshing: boolean = false;
  @Local refreshOffset: number = 0;
  @Local refreshState: RefreshStatus = RefreshStatus.Inactive;

  @Event onInitialData: () => Promise<CoverData[]> = async () => []
  @Event onRefreshData: () => Promise<CoverData[]> = async () => []

  pathStack: NavPathStack | undefined = undefined;

  /**
   * Goto book detail page, according to the id and hash value of book.
   * @param bookId
   * @param hash
   */
  gotoBookDetail(bookId: number, hash: string) {
    this.pathStack?.pushPathByName("BookDetail", {
      bookId: bookId,
      hash: hash
    } as BookDetailParam)
  }

  async aboutToAppear(): Promise<void> {
    this.pathStack = this.queryNavigationInfo()?.pathStack;
    this.coverDataSource = await this.onInitialData()
  }

  build() {
    Refresh({ refreshing: $$this.refreshing, builder: this.refreshBuilder() }) {
      WaterFlow() {
        Repeat(this.coverDataSource)
          .each((ri) => {
            BookCover({ coverData: ri.item })
              .border({
                width: 5,
                color: Color.Transparent
              })
              .onClick(() => {
                this.gotoBookDetail(ri.item.id, ri.item.hash)
              })
          })
          .key((item, index) => `${index}:${item.name}`)
      }
      .columnsTemplate('1fr 1fr 1fr')
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    }
    .onOffsetChange((offset: number) => {
      this.refreshOffset = offset;
    })
    .onStateChange((state: RefreshStatus) => {
      this.refreshState = state;
    })
    .onRefreshing(async () => {
      this.coverDataSource = await this.onRefreshData()
      this.refreshing = false;
    })
  }

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
}