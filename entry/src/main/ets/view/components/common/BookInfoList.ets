import { AppStorageV2 } from '@kit.ArkUI';
import { WidthBreakpointType } from '../../../common/system/BreakpointUtil';
import { WindowInfo } from '../../../common/system/WindowUtil';
import { PaginationDataSource } from '../../../common/types/ResponseTypes';
import { BookData, BookDetailParam } from '../../../model/entities/BookModel';
import { BookInfoListItem } from './BookInfoListItem';

@ComponentV2
export struct BookInfoList {
  @Param bookDataSource: BookData[] = []
  @Param pagination: PaginationDataSource | undefined = undefined;
  @Local windowInfo: WindowInfo = AppStorageV2.connect(WindowInfo, "mainWindowInfo", () => new WindowInfo())!
  @Event onLoadNewData: () => Promise<void> = async () => {
  }
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
        .key((item, index) => `${index}:${item.title}:${item._isFavorite}`)
    }
    .divider({
      color: Color.Gray,
      strokeWidth: "1px",
      // startMargin: 10,
      // endMargin: 10
    })
    .lanes(new WidthBreakpointType(1, 2, 3, 4).getValue(this.windowInfo.widthBp), 10)
    .width("100%")
    .height("100%")
    .onScrollIndex(async (start: number, end: number) => {
      // 当达到列表末尾时，触发新数据加载。
      await this.onEndOfList(end);
    })
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    .padding({ left: "10vp", right: "10vp" })
  }

  private async onEndOfList(end: number) {
    if (this.pagination && end >= this.bookDataSource.length - 1
      && this.pagination.current < this.pagination.total_pages) {
      await this.onLoadNewData();
    }
  }
}