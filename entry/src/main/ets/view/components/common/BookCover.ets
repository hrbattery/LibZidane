import { CoverData } from "../../../models/BookModel";

@ComponentV2
export struct BookCover {
  @Param @Require coverData: CoverData;
  @Param altHeight: number | undefined = undefined;
  @Local isLoaded: boolean = false
  @Local loadError: boolean = false
  @Local imgRatio: number = 0.75;

  build() {
    Column() {
      if (!this.isLoaded || this.loadError) {
        Text(this.coverData.name ?? '加载中...')
          .fontSize("14vp")
          .width("100%")
          .height(this.altHeight ?? 200)
          .textAlign(TextAlign.Center)
          .backgroundColor("#ffaaaaaa")
      }

      Image(this.coverData.img)
        .objectFit(ImageFit.Contain)
        .visibility(this.isLoaded && !this.loadError ? Visibility.Visible : Visibility.None)
        .onComplete(event => {
          this.isLoaded = true
          this.loadError = false
          if (event) {
            this.imgRatio = event?.width / event?.height
          }
        })
        .onError(() => {
          this.loadError = true
        })
        .aspectRatio(this.imgRatio)
    }
    .height("auto")
    .width("auto")
  }
}