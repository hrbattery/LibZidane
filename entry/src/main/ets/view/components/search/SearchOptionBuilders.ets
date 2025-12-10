/**
 * 年份选择器组件
 */
@ComponentV2
export struct YearPicker {
  @Param @Require years: string[]
  @Param @Require currentValue: string;
  @Event onValueChange: (year: string) => void;

  // 只显示非空标签
  build() {
    TextPicker({
      range: this.years,
      value: this.currentValue
    })
      .onChange((value: string | string[], index: number | number[]) => {
        if (typeof index === 'number') {
          this.onValueChange(this.years[index]);
        }
      })
      .width('100%')
      .height(100) // 降低高度使界面更紧凑
      // .backgroundColor('#FFFFFF') // 设置为白色背景
      .borderRadius(10) // 保持圆角设计
      .padding({ top: 5, bottom: 5 }); // 保持内边距
  }

}

/**
 * 生成年份范围数组
 * @returns 年份数组，包含"不限"选项
 */
export function generateYearRange(): string[] {
  const years: string[] = ['不限'];
  const currentYear = new Date().getFullYear();
  for (let year = 1800; year <= currentYear; year++) {
    years.push(year.toString());
  }
  return years;
}

/**
 * 多选组件
 */
@Builder
function MultiSelect(items: string[], selectedItems: string[], onToggle: (item: string, value: boolean) => void) {
  List({
    initialIndex: 0,
    space: 4, // 增加列表项间距
  }) {
    ForEach(items, (item: string) => {
      ListItem() {
        Row() {
          Checkbox({
            name: item
          })
            .select(selectedItems.includes(item))
            .onChange((value: boolean) => onToggle(item, value))
            .size({ width: 22, height: 22 }) // 增大复选框尺寸
            .margin({ right: 15 }); // 增加右侧间距
          Text(item)
            .fontSize(16)
            .flexGrow(1)
            .fontWeight(FontWeight.Medium); // 略微加粗文本
        }
        .alignItems(VerticalAlign.Center)
        .width('100%')
        .padding({ top: 12, bottom: 12, left: 16, right: 16 }) // 增加内边距
        // .backgroundColor() // 设置为白色背景
        .borderRadius(10) // 保持圆角设计
        .onClick(() => {
          // 点击整行时切换选中状态
          const isSelected = selectedItems.includes(item);
          onToggle(item, !isSelected);
        })
      }
    });
  }
  .height(190) // 略微增加高度
  .width('100%')
  // .divider({
  //   strokeWidth: 1,
  //   color: $r("sys.color.font_tertiary"),
  //   startMargin: 16,
  //   endMargin: 16
  // }) // 恢复分隔线
  .scrollBar(BarState.Off)
}

/**
 * 语言选择组件
 */
@ComponentV2
export struct LanguageSelector {
  /**
   * 已选择的语言
   */
  @Param @Require selectedLanguages: string[];
  
  /**
   * 语言变更回调函数
   */
  @Event onToggleLanguage: (language: string, value: boolean) => void;
  
  /**
   * 语言选项列表
   */
  @Param languages: string[] = [];

  build(): void {
    Column() {
      // 直接使用MultiSelect组件，标题已在父组件中设置
      MultiSelect(this.languages, this.selectedLanguages, (item: string, value: boolean) => this.onToggleLanguage(item, value));
    }
  }
}

/**
 * 扩展名选择组件
 */
@ComponentV2
export struct ExtensionSelector {
  /**
   * 已选择的扩展名
   */
  @Param @Require selectedExtensions: string[];
  
  /**
   * 扩展名变更回调函数
   */
  @Event onToggleExtension: (extension: string, value: boolean) => void;
  
  /**
   * 扩展名选项列表
   */
  @Param extensions: string[] = [];

  build(): void {
    Column() {
      // 直接使用MultiSelect组件，标题已在父组件中设置
      MultiSelect(this.extensions, this.selectedExtensions, (item: string, value: boolean) => this.onToggleExtension(item, value));
    }
  }
}