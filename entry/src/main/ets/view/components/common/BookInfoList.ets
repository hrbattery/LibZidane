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
  @Event onLoadNewData: () => Promise<void> = async () => {}
  @Event onRemove?: (index: number) => Promise<void> = undefined

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
            BookInfoListItem({
              bookDataItem: ri,
              onRemove: this.onRemove === undefined ? undefined: async (index: number) => await this.onRemove!(index)
            })
              .onClick(() => {
                this.gotoBookDetail(ri.item.id, ri.item.hash)
              })
          }
        })
        .key((item, index) => `${index}:${item.title}:${item._isFavorite}`)
    }
    .divider({
      color: $r("sys.color.font_tertiary"),
      strokeWidth: "1px",
    })
    .lanes(new WidthBreakpointType(1, 2, 3, 4).getValue(this.windowInfo.widthBp), 10)
    .width("100%")
    .height("100%")
    .onScrollIndex(async (start: number, end: number) => {
      await this.onEndOfList(end);
    })
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    // .padding({ left: 10, right: 10 })
  }

  private async onEndOfList(end: number) {
    if (this.pagination && end >= this.bookDataSource.length - 1
      && this.pagination.current < this.pagination.total_pages) {
      await this.onLoadNewData();
    }
  }
}