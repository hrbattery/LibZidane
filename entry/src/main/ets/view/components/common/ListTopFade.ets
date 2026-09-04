/** A fixed, theme-aware top fade that lets list taps and scroll gestures pass through. */
@Builder
export function ListTopFade(scrollOffset: number) {
  Row() {}
    .width('100%')
    .height(32)
    .linearGradient({
      direction: GradientDirection.Bottom,
      // Keep RGB identical at both stops so fading alpha never introduces a dark band.
      colors: [[$r('app.color.book_list_top_fade'), 0], [$r('app.color.book_list_top_fade_transparent'), 1]]
    })
    // Fade in linearly over the first 32vp; top overscroll stays transparent.
    .opacity(Math.min(1, Math.max(0, scrollOffset / 32)))
    .hitTestBehavior(HitTestMode.None)
}
