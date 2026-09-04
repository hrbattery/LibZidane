import { common } from '@kit.AbilityKit';

/** Year wheel with an explicit unlimited index, including after resetting an open form. */
@ComponentV2
export struct YearPicker {
  @Param @Require years: string[];
  @Param currentValue: string | undefined = undefined;
  @Event onValueChange: (year: string | undefined) => void;

  /** Bind the selected index so undefined never leaves the previous wheel value on screen. */
  build() {
    TextPicker({
      range: this.years,
      selected: Math.max(0, this.years.indexOf(this.currentValue ?? ''))
    })
      .onChange((value: string | string[], index: number | number[]) => {
        if (typeof index === 'number') {
          this.onValueChange(index === 0 ? undefined : this.years[index]);
        }
      })
      .canLoop(false)
      .width('100%')
      .height(144)
  }
}

/** Include an unlimited choice followed by every supported publication year. */
export function generateYearRange(context: common.UIAbilityContext): string[] {
  const years: string[] = [context.resourceManager.getStringSync($r('app.string.ui_yearpicker_unlimited').id)];
  const currentYear = new Date().getFullYear();
  for (let year = 1800; year <= currentYear; year++) {
    years.push(year.toString());
  }
  return years;
}

/** Reactive header shared by all three collapsible filter sections. */
@ComponentV2
export struct SearchFilterHeader {
  @Param @Require title: ResourceStr;
  @Param @Require summary: ResourceStr;
  @Param expanded: boolean = false;
  @Event onToggle: () => void;

  /** Component parameters keep the summary and arrow synchronized after each draft change. */
  build(): void {
    Button({ type: ButtonType.Normal }) {
      Row({ space: 12 }) {
        Column({ space: 4 }) {
          Text(this.title)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))
          Text(this.summary)
            .fontSize(12)
            .fontColor($r('sys.color.font_secondary'))
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        SymbolGlyph($r('sys.symbol.chevron_right'))
          .fontSize(16)
          .fontColor([$r('sys.color.icon_secondary')])
          .rotate({ angle: this.expanded ? 90 : 0 })
      }
      .width('100%')
      .padding(12)
    }
    .width('100%')
    .backgroundColor(Color.Transparent)
    .borderRadius(12)
    .onClick(() => {
      // Animate the section's layout change and arrow rotation in the same update.
      this.getUIContext().animateTo({ duration: 240, curve: Curve.EaseInOut }, () => this.onToggle());
    })
  }
}

/** A bounded multi-select list shared by the language and format sections. */
@ComponentV2
export struct SearchMultiSelect {
  @Param items: string[] = [];
  @Param @Require selectedItems: string[];
  @Event onToggle: (item: string, selected: boolean) => void;

  /** Short lists fit their contents; long lists scroll first and hand off at either boundary. */
  build(): void {
    Column() {
      if (this.items.length === 0) {
        Text($r('app.string.ui_search_options_unavailable'))
          .fontSize(14)
          .fontColor($r('sys.color.font_secondary'))
          .width('100%')
          .padding(12)
      } else {
        List() {
          ForEach(this.items, (item: string) => {
            ListItem() {
              Row({ space: 12 }) {
                Checkbox({ name: item })
                  .select(this.selectedItems.includes(item))
                  .onChange((selected: boolean) => this.onToggle(item, selected))
                  // Handle checkbox clicks here; selection changes are owned by onChange.
                  .onClick(() => {})
                  .size({ width: 22, height: 22 })
                  .margin(0)
                  .accessibilityText(item)
                Text(item)
                  .fontSize(16)
                  .fontColor($r('sys.color.font_primary'))
                  .layoutWeight(1)
                  .maxLines(2)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
              }
              .width('100%')
              .height(52)
              .padding({ left: 12, right: 16 })
              .onClick(() => this.onToggle(item, !this.selectedItems.includes(item)))
            }
          }, (item: string) => item)
        }
        .width('100%')
        .height(Math.min(this.items.length * 52, 208))
        .scrollBar(BarState.Auto)
        .nestedScroll({ scrollForward: NestedScrollMode.SELF_FIRST, scrollBackward: NestedScrollMode.SELF_FIRST })
        .edgeEffect(EdgeEffect.None)
      }
    }
    .width('100%')
    .padding({ right: 8, bottom: 8 })
    .transition(TransitionEffect.OPACITY)
  }
}
