import { CoverData } from '../../../model/entities/BookModel';

@ComponentV2
export struct BookCover {
  @Param @Require coverData: CoverData;
  @Param altHeight: number | undefined = undefined;
  @Local isLoaded: boolean = false
  @Local loadError: boolean = false
  @Local imgRatio: number = 0.75;

  build() {
    Row() {
      if (!this.isLoaded || this.loadError) {
        Text(this.coverData.title ?? '加载中...')
          .fontSize("14vp")
          .width("100%")
          .constraintSize({
            maxHeight: this.altHeight ?? Infinity
          })
          .aspectRatio(this.imgRatio)
          .textAlign(TextAlign.Center)
          .backgroundColor($r("sys.color.background_fourth"))
          .maxLines(6)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .wordBreak(WordBreak.BREAK_ALL)
      }

      Image(this.coverData.cover)
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
        .constraintSize({
          maxHeight: this.altHeight ?? Infinity
        })
        .width("100%")

    }
    .justifyContent(FlexAlign.Center)
    .width("100%")
  }
}