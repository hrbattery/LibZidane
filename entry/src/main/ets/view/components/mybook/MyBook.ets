import { Constants } from '../../../common/const/Constants'
import { DownloadedBooks } from './DownloadedBooks'
import { FavoriteBooks } from './FavoriteBooks'

@ComponentV2
export struct MyBook {
  @Local tabCurrentIndex: number = 0
  @Local favoritesEntriesAmount: number = 0;
  @Local downloadedEntriesAmount: number = 0;

  @Param favoriteOrder: number = 0;
  @Param downloadedOrder: number = 0;

  @Event onMyBookTabIndexChange?: (index: number) => void;

  @Monitor('tabCurrentIndex')
  onTabIndexChange(): void {
    if (this.onMyBookTabIndexChange) {
      this.onMyBookTabIndexChange(this.tabCurrentIndex);
    }
  }

  @Computed
  get favoriteOrderStr(): string {
    return Constants.FAVORITES_SORT_KEY[this.favoriteOrder]['value']
  }

  @Computed
  get downloadedOrderStr(): string {
    return Constants.DOWNLOADED_SORT_KEY[this.downloadedOrder]['value']
  }

  build() {
    Column() {
      Tabs({ index: this.tabCurrentIndex!! }) {
        TabContent() {
          FavoriteBooks({
            sortOrder: this.favoriteOrderStr,
            updateEntriesAmount: (amount: number) => this.favoritesEntriesAmount = amount
          })
        }
        .tabBar('选集' + (this.favoritesEntriesAmount > 0 ? ` ( ${this.favoritesEntriesAmount} )` : ''))

        TabContent() {
          DownloadedBooks({
            sortOrder: this.downloadedOrderStr,
            updateEntriesAmount: (amount: number) => this.downloadedEntriesAmount = amount
          })
        }
        .tabBar('已下载' + (this.downloadedEntriesAmount > 0 ? ` ( ${this.downloadedEntriesAmount} )` : ''))
      }
      .barMode(BarMode.Fixed)
      // .onChange((index: number) => {
      //   this.tabCurrentIndex = index;
      // })
    }
  }
}