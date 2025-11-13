import { PaginationDataSource } from '../../common/types/ResponseTypes';
import { BookData, BookDetailParam } from '../../models/BookModel';
import { BookInfoListItem } from './BookInfoListItem';

@ComponentV2
export struct BookInfoList {
  @Param bookDataSource: Array<BookData> = []
  @Param pagination: PaginationDataSource | undefined = undefined;

  @Event onLoadNewData: () => Promise<void> = async () => {}

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
    .width("100%")
    .height("100%")
    .onScrollIndex(async (start: number, end: number) => {
      // 当达到列表末尾时，触发新数据加载。
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