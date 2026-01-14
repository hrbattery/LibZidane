import { DialogHelper } from '@pura/harmony-dialog';
import { SearchViewModel } from '../../../viewModel/search/SearchResultViewModel';
import { Chip, ChipSize, ChipGroup } from '@kit.ArkUI';

@ComponentV2
export struct SearchHistory {
  @Param @Require viewModel: SearchViewModel;
  @Event onHistoryItemClick: (keyword: string) => void;

  private get displayHistory() {
    return this.viewModel.searchHistoryState.searchHistory;
  }

  private handleDeleteItem(index: number) {
    this.getUIContext()?.animateTo({
      duration: 200,
      curve: "ease-out"
    }, () => {
      this.viewModel.deleteSearchHistory(index);
    });
  }

  private handleClearAll() {
    DialogHelper.showAlertDialog({
      title: $r("app.string.ui_search_history_clear_title"),
      content: $r("app.string.ui_search_history_clear_message"),
      primaryButton: $r("app.string.ui_common_confirm_btn"),
      secondaryButton: $r("app.string.ui_common_cancel_btn"),
      onAction: (action: number) => {
        if (action === 0) {
          // User confirmed, clear all history
          this.viewModel.clearSearchHistory();
        }
      },
    });
  }

  build() {
    Column() {
      if (this.viewModel.searchHistoryState.searchHistory.length > 0) {
        Row() {
          Text($r("app.string.ui_search_history_title"))
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
          Text($r("app.string.ui_search_history_clear_all"))
            .fontSize(14)
            .onClick(() => this.handleClearAll())
            // .layoutWeight(1)
        }
        .width("100%")
        .height(40)
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.SpaceBetween)

        // 使用 ChipGroup 和 Chip 组件
        Scroll() {
          Row() {
            ForEach(this.displayHistory, (item: string, index: number) => {
              Row() {
                Chip({
                  size: ChipSize.SMALL,
                  label: {
                    text: item,
                  },
                  allowClose: true,
                  onClose: (): void => this.handleDeleteItem(index),
                  onClicked: () => this.onHistoryItemClick(item),
                })
              }
              .margin({
                left: 4,
                right: 4
              })
            })
          }
          .justifyContent(FlexAlign.Start)
          .alignSelf(ItemAlign.Start)
          .width("100%")
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .width("100%")
      }
    }
    .width("100%")
    .padding({ left: 10, right: 10 })
  }
}