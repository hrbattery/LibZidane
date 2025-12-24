import { DownloadedViewModel } from "../../../viewModel/mybook/DownloadedViewModel";
import { MyBookComponent } from "./MyBookComponent";

@Preview
@ComponentV2
export struct DownloadedBooks {
  @Local viewModel: DownloadedViewModel = new DownloadedViewModel()
  @Param @Require sortOrder: string

  @Event updateEntriesAmount: (amount: number) => void;

  aboutToAppear(): void {
    setInterval(() => {
      this.viewModel.currentTime = Date.now()
    }, 1000)
  }

  @Monitor("viewModel.appState.loginState")
  onUpdateLoginState() {
    this.viewModel.bookDataSource = []
    this.viewModel.pagination = undefined
  }

  @Monitor("viewModel.pagination")
  onUpdatePagination() {
    this.updateEntriesAmount(this.viewModel.pagination?.total_items ?? 0)
  }

  build() {
    Column() {
      Row({ space: 10 }) {
        Text(this.getUIContext().getHostContext()?.resourceManager.getStringSync(
          $r("app.string.ui_downloaded_download_limited").id,
          this.viewModel.timeToResetLimit[0],
          this.viewModel.timeToResetLimit[1]
        ))
          .fontSize(14)
          .layoutWeight(1)
          .textAlign(TextAlign.JUSTIFY)
        Column({ space: 4 }) {
          Text(`${this.viewModel.downloadToday} / ${this.viewModel.downloadLimit}`)
            .fontSize(14)
          Progress({
            value: this.viewModel.downloadToday,
            total: this.viewModel.downloadLimit,
            type: ProgressType.Linear
          })
        }
        .alignItems(HorizontalAlign.Center)
        .layoutWeight(1)
      }
      .padding({ left: 10, right: 10 })
      MyBookComponent({
        viewModel: this.viewModel,
        sortOrder: this.sortOrder
      })
    }
  }
}