import { common } from '@kit.AbilityKit';
import { uniformTypeDescriptor as utd } from '@kit.ArkData';

import { BusinessError } from '@kit.BasicServicesKit';
import { systemShare } from '@kit.ShareKit';

import { LogUtil as logger } from '@pura/harmony-utils';
import { bookDataCache } from '../../common/cache/BookDataCache';
import { Constants } from '../../common/const/Constants';
import { StorageConstants } from '../../common/const/StorageConstants';
import { getBookFormat, getBookInfo, getSimilar } from '../../model/api/BookApi';
import { saveBook, unsaveBook } from '../../model/api/UserApi';
import { BookFormatType, CoverData, FullBookData } from '../../model/entities/BookModel';
import { CoverDataFactory, FullBookDataFactory } from '../../model/factory/BookModelFactory';
import { preferencesUtils } from '../../model/storage/PreferencesUtils';
import { NetworkRequestViewModel } from '../common/NetworkRequestViewModel';


@ObservedV2
export class BookDetailViewModel extends NetworkRequestViewModel {
  /**
   * book id
   */
  @Trace bookId: number = 0;
  /**
   * book hash
   */
  @Trace hash: string = ""
  /**
   * full book data
   */
  @Trace bookData: FullBookData | undefined
  /**
   * showing book favourite status
   */
  @Trace isUserFavorite: boolean = false
  /**
   * available book formats
   */
  @Trace bookFormats: BookFormatType[] = []
  /**
   * similar books osusume
   */
  @Trace similarBookCoverDataSource: CoverData[] = []

  async loadBookData() {
    const cache = bookDataCache.getCache(`${this.bookId}_${this.hash}`);
    if (!cache) {
      try {
        this.isLoading = true;
        let bookData = await getBookInfo(this.bookId, this.hash);
        if (bookData) {
          this.isLoadFailed = false;
          this.isLoading = false;
          this.bookData = FullBookDataFactory.fromBookCommonDataSource(bookData);
          bookDataCache.setCache(`${this.bookId}_${this.hash}`, this.bookData)
        }
      } catch (e) {
        logger.error(e)
        this.isLoadFailed = true;
        this.isLoading = false;
        // todo: toast error or use a 404 page
      }
    } else {
      this.bookData = cache
    }
    this.isUserFavorite = !!this.bookData?._isFavorite
  }

  async loadDownloadFormats() {
    this.bookFormats = await getBookFormat(this.bookId, this.hash) as BookFormatType[];
  }

  async loadSimilar() {
    try {
      let similar = await getSimilar(this.bookId, this.hash);

      this.similarBookCoverDataSource = similar.map(element => {
        return CoverDataFactory.fromCoverDataSource(element)
      })
      return;
    } catch (e) {
      logger.error(e)
    }
    this.similarBookCoverDataSource = []
  }

  async loadPageData() {
    await Promise.all([
      this.loadBookData(),
      this.loadDownloadFormats(),
      this.loadSimilar()
    ])
  }

  shareBook(context: common.UIAbilityContext) {
    const baseUrl = preferencesUtils.getSync<string>(
      StorageConstants.DEFAULT_PREF,
      StorageConstants.PREFKEY_CURRENT_ACTIVE_API,
      Constants.DEFAULT_ZLIB_DOMAIN
    );

    if (this.bookData) {
      let shareData: systemShare.SharedData = new systemShare.SharedData({
        utd: utd.UniformDataType.HYPERLINK,
        content: baseUrl + this.bookData.href,
        title: this.bookData.title,
        description: baseUrl + this.bookData.href
      });

      let controller: systemShare.ShareController = new systemShare.ShareController(shareData);
      // let context = this.getUIContext().getHostContext() as common.UIAbilityContext;
      controller.show(context, {
        selectionMode: systemShare.SelectionMode.SINGLE,
        previewMode: systemShare.SharePreviewMode.DEFAULT,
      }).then(() => {
        logger.info('ShareController show success.');
      }).catch((error: BusinessError) => {
        logger.error(`ShareController show error. code: ${error.code}, message: ${error.message}`);
      });
    }
  }

  async onClickStar(): Promise<void> {
    try {
      this.isUserFavorite = !this.isUserFavorite
      !this.isUserFavorite ? await unsaveBook(this.bookId) : await saveBook(this.bookId);
      bookDataCache.clearCache(`${this.bookId}_${this.hash}`);
    } catch (e) {
      logger.error(e)
      this.isUserFavorite = !this.isUserFavorite
      // todo: toast error or use a 404 page
    }
  }
}