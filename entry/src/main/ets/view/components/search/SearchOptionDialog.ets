import { SearchFilterOptions } from '../../../model/entities/SearchFilterOptionModel';
import { ExtensionSelector, generateYearRange, LanguageSelector, YearPicker } from './SearchOptionBuilders';

/**
 * 搜索选项对话框组件
 * 提供多种搜索筛选条件的自定义对话框
 */
@ComponentV2
export struct SearchOptionDialog {
  /**
   * 当前筛选条件
   */
  @Param @Require options: SearchFilterOptions
  @Local exactMatch: boolean = this.options.exactMatch;
  @Local startYear: string = this.options.startYear;
  @Local endYear: string = this.options.endYear;
  @Local selectedLanguages: string[] = Array.from(this.options.selectedLanguages);
  @Local selectedExtensions: string[] = Array.from(this.options.selectedExtensions);
  // 展开/收起状态变量 - 默认收起
  @Local isYearExpanded: boolean = false;
  @Local isLanguageExpanded: boolean = false;
  @Local isExtensionExpanded: boolean = false;

  @Monitor('exactMatch')
  syncExactMatch() {
    this.options.setExactMatchCmd(this.exactMatch)
  }

  @Monitor('startYear')
  syncStartYear() {
    this.options.setStartYearCmd(this.startYear)
  }

  @Monitor('endYear')
  syncEndYear() {
    this.options.setEndYearCmd(this.endYear)
  }

  @Monitor('selectedLanguages.length')
  syncSelectedLanguages() {
    this.options.setSelectedLanguagesCmd(this.selectedLanguages)
  }

  @Monitor('selectedExtensions.length')
  syncSelectedExtensions() {
    this.options.setSelectedExtensionsCmd(this.selectedExtensions)
  }

  /**
   * 切换语言选择
   * @param language 语言名称
   */
  private toggleLanguage(language: string, value: boolean): void {
    const index = this.selectedLanguages.indexOf(language);
    if (index > -1 && value === false) {
      this.selectedLanguages.splice(index, 1);
    } else if (index === -1 && value === true) {
      this.selectedLanguages.push(language);
    }
  }

  /**
   * 切换扩展名选择
   * @param extension 扩展名
   */
  private toggleExtension(extension: string, value: boolean): void {
    const index = this.selectedExtensions.indexOf(extension);
    if (index > -1 && value === false) {
      this.selectedExtensions.splice(index, 1);
    } else if (index === -1 && value === true) {
      this.selectedExtensions.push(extension);
    }
  }

  /**
   * 清空所有筛选条件
   */
  private clearAllFilters(): void {
    this.exactMatch = false;
    this.startYear = '不限';
    this.endYear = '不限';
    this.selectedLanguages.splice(0, this.selectedLanguages.length);
    this.selectedExtensions.splice(0, this.selectedExtensions.length);
  }

  private getLanguageOptions() {
    const languageOptions: Record<string, string> = AppStorage.get<Record<string, string>>("language_options") ?? {};
    return Object.keys(languageOptions);
  }

  private getExtensionOptions() {
    return AppStorage.get<string[]>("extension_options") ?? []
  }

  build(): void {
    Scroll() {
      Column({ space: 18 }) {
        // 完全匹配选项
        Row() {
          Text('完全匹配')
            .fontWeight(FontWeight.Medium)
            .fontSize(16)
            .flexGrow(1)
          Toggle({
            type: ToggleType.Switch,
            isOn: this.exactMatch
          })
            .onChange((isOn: boolean) => {
              this.exactMatch = isOn;
            })
        }
        .width('100%')
        .padding({
          top: 12,
          bottom: 12,
          left: 16,
          right: 16
        })
        .borderRadius(10)

        // 年份范围选择
        // 出版年份标题 - 可点击展开/收起
        Column({ space: 18 }) {
          Row() {
            Text('出版年份')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .flexGrow(1)
              .textAlign(TextAlign.Start);
            // 展开/收起图标
            Text(this.isYearExpanded ? '▼' : '▶')
              .fontSize(16)
          }
          .width('100%')
          .padding({
            top: 12,
            bottom: 12,
            left: 16,
            right: 16
          })
          .borderRadius(10)
          .onClick(() => {
            this.isYearExpanded = !this.isYearExpanded;
          });

          // 年份范围选择器 - 条件显示
          if (this.isYearExpanded) {
            Row() {
              // 开始年份选择
              Column() {
                Text('开始年份')
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .margin({ bottom: 8 });
                YearPicker({
                  years: generateYearRange(),
                  currentValue: this.startYear,
                  onValueChange: (year: string) => {
                    this.startYear = year;
                  }
                });
              }
              .flexShrink(1)
              .width('40%');

              Text('-')
                .fontSize(18)
                .margin({ left: 10, right: 10 })
                .alignSelf(ItemAlign.Center)
                .fontWeight(FontWeight.Medium)
                .flexShrink(1)

              // 结束年份选择
              Column() {
                Text('结束年份')
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .margin({ bottom: 8 });
                YearPicker({
                  years: generateYearRange(),
                  currentValue: this.endYear,
                  onValueChange: (year: string) => {
                    this.endYear = year;
                  }
                });
              }
              .flexShrink(1)
              .width('40%');
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
          }
        }

        // 语言选择
        Column({ space: 18 }) {
          // 语言标题 - 可点击展开/收起
          Row() {
            Text('语言')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .flexGrow(1)
              .textAlign(TextAlign.Start);
            // 展开/收起图标
            Text(this.isLanguageExpanded ? '▼' : '▶')
              .fontSize(14)
          }
          .width('100%')
          .padding({
            top: 12,
            bottom: 12,
            left: 16,
            right: 16
          })
          .borderRadius(10)
          .onClick(() => {
            this.isLanguageExpanded = !this.isLanguageExpanded;
          });

          // 语言选择器 - 条件显示
          if (this.isLanguageExpanded) {
            LanguageSelector({
              selectedLanguages: this.selectedLanguages,
              onToggleLanguage: (lang, value) => this.toggleLanguage(lang, value),
              languages: this.getLanguageOptions()
            });
          }
        }

        Column({ space: 18 }) {
          // 文件格式标题 - 可点击展开/收起
          Row() {
            Text('文件格式')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .flexGrow(1)
              .textAlign(TextAlign.Start);
            // 展开/收起图标
            Text(this.isExtensionExpanded ? '▼' : '▶')
              .fontSize(14)
          }
          .width('100%')
          .padding({
            top: 12,
            bottom: 12,
            left: 16,
            right: 16
          })
          .borderRadius(10)
          .onClick(() => {
            this.isExtensionExpanded = !this.isExtensionExpanded;
          });

          // 文件格式选择器 - 条件显示
          if (this.isExtensionExpanded) {
            ExtensionSelector({
              selectedExtensions: this.selectedExtensions,
              onToggleExtension: (ext, value) => this.toggleExtension(ext, value),
              extensions: this.getExtensionOptions()
            })
              .width('100%')
          }
        }

        Button('清空条件')
          .onClick(() => this.clearAllFilters())
      }
      .width('100%')
      .padding({
        top: 20,
        bottom: 20,
        left: 24,
        right: 24
      })
      .width('100%')
      .borderRadius(20)
    }
  }
}