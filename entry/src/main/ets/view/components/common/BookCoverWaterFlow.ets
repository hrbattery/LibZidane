import { AppStorageV2 } from '@kit.ArkUI';
import { WidthBreakpointType } from '../../../common/system/BreakpointUtil';
import { WindowInfo } from '../../../common/system/WindowUtil';
import { BookDetailParam, CoverData } from '../../../model/entities/BookModel';
import { BookCover } from './BookCover';

/**
 * WaterFlow component showing book covers.
 * Receive an array of CoverData.
 */

@Preview
@ComponentV2
export struct BookCoverWaterFlow {
  @Param coverDataSource: CoverData[] = []
  @Consumer() showSkeleton: boolean = true;
  @Local windowInfo: WindowInfo = AppStorageV2.connect(WindowInfo, "mainWindowInfo", () => new WindowInfo())!
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

  aboutToAppear(): void {
    this.pathStack = this.queryNavigationInfo()?.pathStack;
  }

  build() {
    WaterFlow() {
      Repeat(this.showSkeleton ? (Array(20).fill(0) as CoverData[]) : this.coverDataSource)
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
        .key((item, index) => `${index}:${item.title}`)
    }
    .columnsTemplate(`repeat(${new WidthBreakpointType(3, 4, 6, 8).getValue(this.windowInfo.widthBp)}, 1fr)`)
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    .nestedScroll({
      scrollForward: NestedScrollMode.PARENT_FIRST,
      scrollBackward: NestedScrollMode.PARENT_FIRST
    })
  }
}