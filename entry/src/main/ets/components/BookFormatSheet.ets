import { BookFormatType, FullBookDataType } from "../models/BookModel"
import { common } from "@kit.AbilityKit"
import { fileDownload } from "../common/request/FileDownload"
import { getBookDownloadUrl } from "../api/BookApi"
import { url } from "@kit.ArkTS"
import { ToastUtil } from "@pura/harmony-utils"

@ComponentV2
export struct BookFormatSheet {
  @Param @Require mainBookData: FullBookDataType
  @Param @Require formats: BookFormatType[]
  @Param @Require onClose: () => void;

  build() {
    Column() {
      this.BookFormatItem(this.mainBookData)
      Divider()
        .margin({top: 10, bottom: 10})
        .width("90%")
      Text("其他格式")
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({left: 20, top: 10, bottom: 10})
        .alignSelf(ItemAlign.Start)
      List({ space: '10vp' }) {
        Repeat(this.formats)
          .each((ri) => {
            ListItem() {
              this.BookFormatItem(ri.item)
            }
          })
      }
      .alignListItem(ListItemAlign.Center)
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  BookFormatItem(item: FullBookDataType | BookFormatType) {
    Row() {
      Text(item.extension).fontSize(16)
      Text(item.filesizeString).fontSize(16)
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
    .width("100%")
    .height('40vp')
    .padding({left: 20, right: 20})
    .onClick(async () => {
      // todo: bg color
      if (this.mainBookData) {
        const context = this.getUIContext().getHostContext() as common.UIAbilityContext;

        // query download url
        const downloadInfo = await getBookDownloadUrl(item.id, item.hash)
        if (!downloadInfo) {
          ToastUtil.showToast("下载失败：获取下载地址失败")
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
