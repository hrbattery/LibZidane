import { common } from '@kit.AbilityKit'
import { url } from '@kit.ArkTS'
import { ToastUtil } from '@pura/harmony-utils'
import { fileDownload } from '../../../common/request/FileDownload'
import { getBookDownloadUrl } from '../../../model/api/BookApi'
import { BookFormatType, FullBookData } from '../../../model/entities/BookModel'

@ComponentV2
export struct BookFormatSheet {
  @Param @Require mainBookData: FullBookData
  @Param @Require formats: BookFormatType[]
  @Param @Require onClose: () => void;

  build() {
    Column({ space: 10 }) {
      this.BookFormatItem(this.mainBookData)
      Divider().width("100%")
        // .margin({ top: 10, bottom: 10 })
      Text($r("app.string.ui_bookdetail_downloadsheet_other_format"))
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 10 })
        .alignSelf(ItemAlign.Start)
      List({ space: 10 }) {
        Repeat(this.formats)
          .each((ri) => {
            ListItem() {
              this.BookFormatItem(ri.item)
            }
          })
      }
      .edgeEffect(EdgeEffect.None) // 禁用默认边缘效果
      .nestedScroll({
        scrollForward: NestedScrollMode.PARENT_FIRST,
        scrollBackward: NestedScrollMode.SELF_FIRST
      })
      .alignListItem(ListItemAlign.Center)
      .width('100%')
    }
    .padding({ left: 16, right: 16 })
    .width('100%')
    .height('100%')
  }

  @Builder
  BookFormatItem(item: FullBookData | BookFormatType) {
    Button({ type: ButtonType.Normal }) {
      Row({ space: 10 }) {
        Text(item.extension).fontSize(16).layoutWeight(1)
        Text(item.filesizeString).fontSize(16)
      }
      .alignItems(VerticalAlign.Center)
    }
    .backgroundColor(Color.Transparent)
    .width("100%")
    .height('40vp')
    .borderRadius(10)
    .onClick(async () => {
      // todo: bg color
      if (this.mainBookData) {
        const context = this.getUIContext().getHostContext() as common.UIAbilityContext;

        // query download url
        const downloadInfo = await getBookDownloadUrl(item.id, item.hash)
        if (!downloadInfo) {
          ToastUtil.showToast($r("app.string.notif_download_get_url_failed"))
          return
        } else {
          const decodedUrl = decodeURI(downloadInfo.downloadLink);
          let searchParams = new url.URLParams(url.URL.parseURL(decodedUrl).search)
          let fileName: string = searchParams.get("filename") ??
            `${downloadInfo.description}.${downloadInfo.extension}`

          this.onClose()
          await fileDownload.downloadBook(context, {
            downloadLink: downloadInfo.downloadLink,
            fileName: fileName
          }, this.mainBookData)
        }
      }
    })
  }
}
