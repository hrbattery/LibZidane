import { AppStorageV2 } from '@kit.ArkUI';
import { WidthBreakpointType } from '../../../common/system/BreakpointUtil';
import { WindowInfo } from '../../../common/system/WindowUtil';
import { PaginationDataSource } from '../../../common/types/ResponseTypes';
import { BookData, BookDetailParam } from '../../../model/entities/BookModel';
import { BookInfoListItem } from './BookInfoListItem';

@ComponentV2
export struct BookInfoList {
  @Consumer() floatingTabBarInset: number = 0;
  @Param bookDataSource: BookData[] = []
  @Param pagination: PaginationDataSource | undefined = undefined;
  @Local windowInfo: WindowInfo = AppStorageV2.connect(WindowInfo, "mainWindowInfo", () => new WindowInfo())!
  @Event onLoadNewData: () => Promise<void> = async () => {}
  @Consumer() showSkeleton: boolean = true;
  @Event onScrollOffsetChange: (offset: number) => void = () => {};
  private scroller: Scroller = new Scroller();
  pathStack: NavPathStack | undefined = undefined;

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

  aboutToAppear(): void {
    this.pathStack = this.queryNavigationInfo()?.pathStack;
  }

  build() {
    List({ scroller: this.scroller }) {
      Repeat(this.showSkeleton ? (Array(20).fill(null) as BookData[]) : this.bookDataSource)
        .each((ri) => {
          ListItem() {
            BookInfoListItem({
              bookDataItem: ri
            })
              .transition(TransitionEffect.OPACITY.animation({duration: 500}))
              .onClick(() => {
                if (ri.item !== null) {
                  this.gotoBookDetail(ri.item.id, ri.item.hash)
                }
              })
          }
        })
        .key((item, index) => item === null ? index.toString() : `${index}:${item.title}:${item._isFavorite}`)
    }
    .onDidScroll(() => this.onScrollOffsetChange(this.scroller.currentOffset().yOffset))
    .onAppear(() => this.onScrollOffsetChange(0))
    .onDisAppear(() => this.onScrollOffsetChange(0))
    .contentEndOffset(this.floatingTabBarInset > 0 ? this.floatingTabBarInset + this.windowInfo.bottomInset : 0)
    .divider({
      color: $r("sys.color.font_tertiary"),
      strokeWidth: "2px",
      startMargin: 10,
      endMargin: 10
    })
    .lanes(new WidthBreakpointType(1, 2, 3, 4).getValue(this.windowInfo.widthBp), 10)
    .width("100%")
    .height("100%")
    .onScrollIndex(async (start: number, end: number) => {
      await this.onEndOfList(end);
    })
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
  }

  private async onEndOfList(end: number) {
    if (this.pagination && end >= this.bookDataSource.length - 1
      && this.pagination.current < this.pagination.total_pages) {
      await this.onLoadNewData();
    }
  }
}
