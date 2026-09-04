import { SearchFilterOptions } from '../../../model/entities/SearchFilterOptionModel';
import { generateYearRange, SearchFilterHeader, SearchMultiSelect, YearPicker } from './SearchOptionBuilders';
import { common } from '@kit.AbilityKit';

/** Search filter form. The owner supplies an isolated draft and decides whether to commit it. */
@ComponentV2
export struct SearchOptionDialog {
  @Param @Require options: SearchFilterOptions;
  @Local isYearExpanded: boolean = false;
  @Local isLanguageExpanded: boolean = false;
  @Local isExtensionExpanded: boolean = false;
  @Local years: string[] = [];

  /** Generate the picker labels once per opening, including the localized unlimited entry. */
  aboutToAppear(): void {
    this.years = generateYearRange(this.getUIContext().getHostContext() as common.UIAbilityContext);
  }

  /** Describe the selected range even while its controls are collapsed. */
  private yearSummary(): ResourceStr {
    if (!this.options.startYear && !this.options.endYear) {
      return $r('app.string.ui_yearpicker_unlimited');
    }
    return `${this.options.startYear ?? this.years[0]} – ${this.options.endYear ?? this.years[0]}`;
  }

  /** Show a single selection by name and summarize multiple selections without widening the dialog. */
  private selectionSummary(items: string[]): ResourceStr {
    if (items.length === 0) {
      return $r('app.string.ui_yearpicker_unlimited');
    }
    return items.length === 1 ? items[0] : $r('app.string.ui_search_selected_count', items.length);
  }

  /** Read localized language names from the current app option cache. */
  private getLanguageOptions(): string[] {
    const languages: Record<string, string> = AppStorage.get<Record<string, string>>('language_options') ?? {};
    return Object.keys(languages);
  }

  /** Update only the draft; list rows and checkboxes use the same selection path. */
  private toggleSelection(items: string[], item: string, selected: boolean): void {
    const index = items.indexOf(item);
    if (selected && index === -1) {
      items.push(item);
    } else if (!selected && index !== -1) {
      items.splice(index, 1);
    }
  }

  /** Equal-width year wheels leave room for localized labels and report invalid ranges inline. */
  @Builder
  YearRange() {
    Column({ space: 8 }) {
      Row({ space: 12 }) {
        Column({ space: 4 }) {
          Text($r('app.string.ui_search_published_year_from'))
            .fontSize(14)
            .fontColor($r('sys.color.font_secondary'))
          YearPicker({
            years: this.years,
            currentValue: this.options.startYear,
            onValueChange: (year: string | undefined) => this.options.startYear = year
          })
        }.layoutWeight(1)
        Column({ space: 4 }) {
          Text($r('app.string.ui_search_published_year_to'))
            .fontSize(14)
            .fontColor($r('sys.color.font_secondary'))
          YearPicker({
            years: this.years,
            currentValue: this.options.endYear,
            onValueChange: (year: string | undefined) => this.options.endYear = year
          })
        }.layoutWeight(1)
      }.width('100%')
      if (!this.options.hasValidYearRange()) {
        Text($r('app.string.ui_search_invalid_year_range'))
          .fontSize(12)
          .fontColor($r('sys.color.font_emphasize'))
          .width('100%')
      }
    }
    .padding({ left: 12, right: 12, bottom: 12 })
    .transition(TransitionEffect.OPACITY)
  }

  /** Keep the reset action visible; only the form body and the two long option lists scroll. */
  build(): void {
    Column({ space: 8 }) {
      Button($r('app.string.ui_search_clear_filter'))
        .buttonStyle(ButtonStyleMode.TEXTUAL)
        .fontSize(14)
        .height(32)
        .alignSelf(ItemAlign.End)
        .onClick(() => this.options.clear())
      Scroll() {
        Column({ space: 8 }) {
          Row({ space: 12 }) {
            Text($r('app.string.ui_search_exact_match'))
              .fontWeight(FontWeight.Medium)
              .fontSize(16)
              .fontColor($r('sys.color.font_primary'))
              .layoutWeight(1)
            Toggle({ type: ToggleType.Switch, isOn: this.options.exactMatch })
              .onChange((isOn: boolean) => this.options.exactMatch = isOn)
          }
          .width('100%')
          .padding(12)
          .borderRadius(12)
          .backgroundColor($r('sys.color.comp_background_primary'))

          Column() {
            SearchFilterHeader({
              title: $r('app.string.ui_search_published_year'),
              summary: this.yearSummary(),
              expanded: this.isYearExpanded,
              onToggle: () => this.isYearExpanded = !this.isYearExpanded
            })
            if (this.isYearExpanded) {
              this.YearRange()
            }
          }
          .width('100%')
          .borderRadius(12)
          .backgroundColor($r('sys.color.comp_background_primary'))

          Column() {
            SearchFilterHeader({
              title: $r('app.string.ui_search_language'),
              summary: this.selectionSummary(this.options.selectedLanguages),
              expanded: this.isLanguageExpanded,
              onToggle: () => this.isLanguageExpanded = !this.isLanguageExpanded
            })
            if (this.isLanguageExpanded) {
              SearchMultiSelect({
                items: this.getLanguageOptions(),
                selectedItems: this.options.selectedLanguages,
                onToggle: (item: string, selected: boolean) =>
                  this.toggleSelection(this.options.selectedLanguages, item, selected)
              })
            }
          }
          .width('100%')
          .borderRadius(12)
          .backgroundColor($r('sys.color.comp_background_primary'))

          Column() {
            SearchFilterHeader({
              title: $r('app.string.ui_search_extension'),
              summary: this.selectionSummary(this.options.selectedExtensions),
              expanded: this.isExtensionExpanded,
              onToggle: () => this.isExtensionExpanded = !this.isExtensionExpanded
            })
            if (this.isExtensionExpanded) {
              SearchMultiSelect({
                items: AppStorage.get<string[]>('extension_options') ?? [],
                selectedItems: this.options.selectedExtensions,
                onToggle: (item: string, selected: boolean) =>
                  this.toggleSelection(this.options.selectedExtensions, item, selected)
              })
            }
          }
          .width('100%')
          .borderRadius(12)
          .backgroundColor($r('sys.color.comp_background_primary'))
        }
        .width('100%')
        .padding({ bottom: 8 })
      }
      .width('100%')
      .constraintSize({ maxHeight: 440 })
      .scrollBar(BarState.Off)
      .nestedScroll({ scrollForward: NestedScrollMode.SELF_FIRST, scrollBackward: NestedScrollMode.SELF_FIRST })
      .edgeEffect(EdgeEffect.None)
      .flexShrink(1)
    }
    .width('100%')
  }
}
