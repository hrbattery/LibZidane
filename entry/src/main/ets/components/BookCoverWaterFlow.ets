import { getBookInfo } from '../api/BookApi';
import { BookDetailParam, CoverData, FullBookDataType } from '../models/BookModel'
import { BookCover } from './BookCover'
import { LogUtil as logger } from "@pura/harmony-utils"
import { bookDataCache } from '../common/cache/BookDataCache';

/**
 * WaterFlow component showing book covers.
 * Receive an array of CoverData.
 */

@ComponentV2
export struct BookCoverWaterFlow {
  @Local coverDataSource: CoverData[] = []

  @Event onInitialData: () => Promise<CoverData[]> = async () => []

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

  // /**
  //  * Load book detail data, to accelerate loading procedure of book detail page.
  //  * @param bookId
  //  * @param hash
  //  */
  // async preloadBookDetail(bookId: number, hash: string) {
  //   if (!bookDataCache.getCache(`${bookId}_${hash}`)) {
  //     try {
  //       let bookData = await getBookInfo(bookId, hash) as FullBookDataType;
  //       bookDataCache.setCache(`${bookId}_${hash}`, bookData)
  //     } catch (e) {
  //       logger.error(e)
  //       // todo: toast error or use a 404 page
  //     }
  //   }
  // }

  async aboutToAppear(): Promise<void> {
    this.pathStack = this.queryNavigationInfo()?.pathStack;
    this.coverDataSource = await this.onInitialData()
  }

  build() {
    WaterFlow() {
      Repeat(this.coverDataSource)
        .each((ri) => {
          BookCover({coverData: ri.item})
            .border({
              width: 5,
              color: Color.Transparent
            })
            .onClick(() => {
              this.gotoBookDetail(ri.item.id, ri.item.hash)
            })
            // .onVisibleAreaChange([0.0, 1.0], (isExpanding: boolean, currentRatio: number) => {
            //   if (isExpanding && currentRatio >= 1.0) {
            //     this.preloadBookDetail(ri.item.id, ri.item.hash)
            //   }
            // })
        })
        .key((item, index) => `${index}:${item.name}`)
    }
    .columnsTemplate('1fr 1fr 1fr')
    // todo: 组件需要接收方法，描述在刷新或者请求新内容时调用的方法
    // .onScrollIndex((start, end) => {
    //   console.log('onScrollIndex', start, end);
    //   // 数据懒加载
    //   if (this.recommendedDataSource.length < 50) {
    //     for (let i = 0; i < 10; i++) {
    //       if (this.recommendedDataSource.length < 50) {
    //         this.recommendedDataSource.push(new CoverData(`Cover_loaded_${i}`, ""));
    //       }
    //     }
    //   }
    // })
  }
}