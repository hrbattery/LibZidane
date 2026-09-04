import { HdsNavDestination } from '@kit.UIDesignKit';
import { NAVIGATION_STYLE, hdsMenus } from '../components/common/NavigationStyle';
import { DialogAction, DialogHelper } from '@pura/harmony-dialog'
import { LogUtil as logger, ToastUtil } from '@pura/harmony-utils'
import { Constants } from '../../common/const/Constants'
import { SearchViewModel } from '../../viewModel/search/SearchResultViewModel'
import { SearchHistory } from '../components/search/SearchHistory'
import { SearchOptionDialog } from '../components/search/SearchOptionDialog'
import { SearchResults } from '../components/search/SearchResults'
import { SearchFilterOptions } from '../../model/entities/SearchFilterOptionModel'

@Builder
export function SearchPageBuilder() {
  SearchPage()
}

@ComponentV2
struct SearchPage {
  @Local viewModel: SearchViewModel = new SearchViewModel()
  @Local isSearchFocused: boolean = false

  getSortMenuItems(): SheetInfo[] {
    return Constants.SEARCH_SORT_KEY.map((value, index) => {
      return {
        title: value["key"],
        action: () => this.viewModel.searchSortOrderIndex = index
      } as SheetInfo
    })
  }

  handleSortClick(): void {
    const dialogId = DialogHelper.showSelectDialog({
      selectedIndex: this.viewModel.searchSortOrderIndex,
      title: $r("app.string.ui_search_menu_sort_by"),
      radioContent: this.getSortMenuItems(),
      confirm: $r("app.string.ui_common_cancel_btn"),
      onCheckedChanged: (index: number): void => {
        closeDialog()
        logger.debug(`onCheckedChanged: index=${index}`)
      },
      onAction: (action: number, dialogId: string, value: string): void => {
        logger.debug(`onAction: action=${action}, dialogId=${dialogId}, value=${value}`)
      }
    })

    const closeDialog: () => void = () => {
      DialogHelper.closeDialog(dialogId);
    }
  }

  /** Edit a fresh draft; only a valid confirmation replaces the applied search parameters. */
  private handleSearchOptionsClick() {
    const draft = this.viewModel.searchFilterOption.clone()
    DialogHelper.showCustomContentDialog({
      contentBuilder: () => this.SearchOptionDialogBuilder(draft),
      actionCancel: false,
      onAction: (action: DialogAction, dialogId: string) => {
        if (action === DialogAction.TWO) {
          if (!draft.hasValidYearRange()) {
            ToastUtil.showToast($r('app.string.ui_search_invalid_year_range'))
            return
          }
          this.viewModel.searchFilterOption = draft.clone()
        }
        DialogHelper.closeDialog(dialogId)
      },
      uiContext: this.getUIContext(),
      maxWidth: 420,
      maxHeight: '85%',
      contentAreaPadding: { top: 0, bottom: 0, left: 16, right: 16 },
      title: $r("app.string.ui_search_menu_filter"),
      buttons: [$r("app.string.ui_common_cancel_btn"), $r("app.string.ui_common_confirm_btn")]
    })
  }

  /** Let the content own its single outer scroll area without a percentage-height wrapper. */
  @Builder
  SearchOptionDialogBuilder(draft: SearchFilterOptions) {
    SearchOptionDialog({ options: draft })
  }

  /** Keep the search field clear of the native back button and two menu buttons. */
  @Builder
  SearchInput() {
    Column() {
      Search({
        placeholder: $r("app.string.ui_search_placeholder"),
        value: this.viewModel.searchKeyword
      })
        .defaultFocus(true)
        .height(40)
        .searchButton($r("app.string.ui_search_btn"))
        .onChange((value) => {
          if (!value) {
            this.viewModel.searchKeyword = ''
          }
        })
        .onSubmit(async (value) => {
          await this.viewModel.onSubmitSearch(value)
          this.viewModel.addSearchHistory(value)
        })
        .onFocus(() => {
          this.isSearchFocused = true
        })
        .onBlur(() => {
          this.isSearchFocused = false
        })
    }
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .padding({ left: 80, right: 136 })
    .hitTestBehavior(HitTestMode.Transparent)
  }

  @Builder
  SearchResultAmount() {
    if (this.viewModel.pagination) {
      Text(this.getUIContext().getHostContext()!.resourceManager.getPluralStringValueSync(
        $r("app.plural.ui_search_results"),
        this.viewModel.pagination?.total_items
      ))
        .alignSelf(ItemAlign.Start)
        .textAlign(TextAlign.Center)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 4, left: 10, bottom: 4 })
    }
  }

  build() {
    HdsNavDestination() {
      Column() {
        if (this.isSearchFocused) {
          SearchHistory({
            viewModel: this.viewModel,
            onHistoryItemClick: async (keyword: string) => {
              this.getUIContext().getFocusController().clearFocus();
              await this.viewModel.onSubmitSearch(keyword)
            }
          })
        } else if (this.viewModel.searchKeyword.length > 0) {
          // Search results section
          Column() {
            this.SearchResultAmount()
            SearchResults({
              viewModel: this.viewModel
            })
          }
          .width("100%")
          .margin({ top: 10 })
        }
      }
      .width("100%")
    }
    .titleBar({
      enableComponentSafeArea: true,
      style: NAVIGATION_STYLE,
      content: {
        title: { mainTitle: '' },
        stackBuilder: () => this.SearchInput(),
        menu: { value: hdsMenus([
          {
            value: $r("app.string.ui_search_menu_sort"),
            icon: $r("app.media.sort"),
            action: () => this.handleSortClick()
          },
          {
            value: $r("app.string.ui_search_menu_filter"),
            icon: $r("app.media.slider_vertical_3"),
            action: () => this.handleSearchOptionsClick()
          }
        ]) }
      }
    })
    .onReady((context: NavDestinationContext) => {
      let param = context.pathInfo.param as string;
      if (param && param !== "") {
        this.viewModel.searchKeyword = param;
      }
    })
  }
}
