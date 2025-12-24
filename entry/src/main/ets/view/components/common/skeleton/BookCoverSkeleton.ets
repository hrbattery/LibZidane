import { AnimateType, SkeletonTheme, UISkeleton } from '@hw-agconnect/ui-skeleton'

@ComponentV2
export struct BookCoverSkeleton {
  build() {
    UISkeleton({
      options: [{ width: "100%", height: "100%s" }],
      /** 动画控制 **/
      animate: AnimateType.GRADIENT,
      duration: 1500,
      delay: 500,

      /** 内置样式 **/
      theme: SkeletonTheme.IMAGE,
    })
      .width("100%")
      .aspectRatio(3/4)
  }
}