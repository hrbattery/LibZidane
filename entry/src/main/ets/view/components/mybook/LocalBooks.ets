import { ListTopFade } from '../common/ListTopFade';
import { common } from '@kit.AbilityKit';
import { fileUri } from '@kit.CoreFileKit';
import { i18n } from '@kit.LocalizationKit';
import { WidthBreakpointType } from '../../../common/system/BreakpointUtil';
import { windowUtil } from '../../../common/system/WindowUtil';
import { filesize } from '../../../common/thirdparty/filesize/filesize';
import { LocalBookEntry, localBookKey } from '../../../model/entities/LocalBookRecord';
import { CoverData } from '../../../model/entities/BookModel';
import { LocalBooksViewModel } from '../../../viewModel/mybook/LocalBooksViewModel';
import { BookCover } from '../common/BookCover';

@ComponentV2
export struct LocalBooks {
  @Consumer() floatingTabBarInset: number = 0;
  @Param active: boolean = false;
  @Local viewModel: LocalBooksViewModel = new LocalBooksViewModel();
  @Local menuBookKey: string = '';
  @Provider() showSkeleton: boolean = false;

  /** Attach local storage without requesting any account data. */
  aboutToAppear(): void {
    this.viewModel.attach(this.getUIContext().getHostContext() as common.UIAbilityContext);
  }

  /** Avoid retaining component listeners after navigation destroys this component. */
  aboutToDisappear(): void {
    this.menuBookKey = '';
    this.viewModel.detach();
  }

  /** Refresh when switching back to this tab, even if Tabs kept its component alive. */
  @Monitor('active')
  onActiveChange(): void {
    if (this.active) {
      this.viewModel.refresh();
    } else {
      this.menuBookKey = '';
    }
  }

  /** Reuse the existing cover placeholder with a local-only image source. */
  private coverData(entry: LocalBookEntry): CoverData {
    return new CoverData({ id: entry.record.id, hash: entry.record.hash, title: entry.record.title,
      author: entry.record.author, cover: entry.coverPath ? fileUri.getUriFromPath(entry.coverPath) : '' });
  }

  /** Local cards open files rather than navigating to a network-dependent detail page. */
  @Builder
  BookItem(entry: LocalBookEntry) {
    Column({ space: 8 }) {
      Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.Start }) {
        BookCover({ coverData: this.coverData(entry), altHeight: 120 })
          .width('35.4%')
          .alignSelf(ItemAlign.Center)
          .constraintSize({ maxHeight: 120 })
        Column() {
          Column({ space: 2 }) {
            Text(entry.record.title)
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .maxLines(2)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .wordBreak(WordBreak.BREAK_ALL)
            Text(entry.record.author)
              .fontSize(14)
              .fontColor($r('sys.color.font_emphasize'))
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .wordBreak(WordBreak.BREAK_ALL)
          }
          .alignItems(HorizontalAlign.Start)
          Text() {
            Span($r('app.string.ui_bookinfo_downloaded'))
            Span(` ${new Date(entry.record.downloadedAt).toLocaleDateString(i18n.System.getAppPreferredLanguage())}`)
          }
            .fontSize(12)
            .fontColor($r('sys.color.font_secondary'))
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(HorizontalAlign.Start)
        .padding({ left: 10, right: 10 })
      }
      .height(120)
      .width('100%')
      Row({ space: 8 }) {
        Text() {
          SymbolSpan($r('sys.symbol.doc_text'))
        }.fontSize(12).fontColor($r('sys.color.font_secondary'))
        Text(`${entry.record.extension}, ${filesize(entry.record.size)}`)
          .fontSize(12)
          .fontColor($r('sys.color.font_secondary'))
        if (!entry.available) {
          Text($r('app.string.local_books_unavailable'))
            .fontSize(12)
            .fontColor($r('sys.color.font_secondary'))
        }
      }
      .height(12)
      .width('100%')
    }
    .padding({ top: 8, bottom: 8, left: 10, right: 10 })
    .width('100%')
    .backgroundColor($r('sys.color.background_primary'))
    .bindContextMenu(this.menuBookKey === localBookKey(entry.record.id, entry.record.hash), this.BookMenu(entry), {
      preview: MenuPreviewMode.IMAGE,
      previewAnimationOptions: {
        hoverScale: [0.9, 1.2]
      },
      aboutToDisappear: () => {
        if (this.menuBookKey === localBookKey(entry.record.id, entry.record.hash)) {
          this.menuBookKey = '';
        }
      }
    })
    .gesture(
      LongPressGesture({ repeat: false })
        .onAction(() => {
          if (!this.viewModel.isBusy) {
            this.menuBookKey = localBookKey(entry.record.id, entry.record.hash);
          }
        }),
      GestureMask.IgnoreInternal
    )
  }

  /** Match the download-history long-press menu while preserving file and operation guards. */
  @Builder
  BookMenu(entry: LocalBookEntry) {
    Menu() {
      MenuItem({ content: $r('app.string.local_books_export') })
        .enabled(entry.available && !this.viewModel.isBusy)
        .onClick(() => {
          if (entry.available && !this.viewModel.isBusy) {
            this.viewModel.export(entry.record);
          }
        })
      MenuItem({ content: $r('app.string.local_books_delete') })
        .enabled(!this.viewModel.isBusy)
        .onClick(() => {
          if (!this.viewModel.isBusy) {
            this.viewModel.confirmDelete(entry.record);
          }
        })
    }
  }

  /** Allow pull-to-refresh alongside automatic shelf updates, including empty and failed states. */
  build() {
    Column({ space: 8 }) {
      Text($r('app.string.local_books_storage_hint'))
        .fontSize(12)
        .fontColor($r('sys.color.font_secondary'))
        .width('100%')
        .textAlign(TextAlign.Start)
        .padding({ left: 12, right: 12, top: 8 })
      if (this.viewModel.isLoadFailed) {
        Text($r('app.string.local_books_load_failed'))
          .fontSize(14)
          .padding(12)
      }
      Refresh({ refreshing: $$this.viewModel.isRefreshing }) {
        List() {
          if (this.viewModel.entries.length === 0 && !this.viewModel.isLoadFailed) {
            ListItem() {
              Text($r('app.string.local_books_empty'))
                .width('100%')
                .padding(24)
                .textAlign(TextAlign.Center)
            }
          }
          Repeat(this.viewModel.entries)
            .each(ri => {
              ListItem() {
                this.BookItem(ri.item)
              }
              // Keep tap outside the card's IgnoreInternal long-press gesture, as in download history.
              .onClick(() => {
                if (ri.item.available && !this.viewModel.isBusy) {
                  this.viewModel.open(ri.item.record);
                }
              })
            })
            .key(entry => localBookKey(entry.record.id, entry.record.hash))
        }
        .divider({
          color: $r('sys.color.font_tertiary'),
          strokeWidth: '2px',
          startMargin: 10,
          endMargin: 10
        })
        .contentEndOffset(this.floatingTabBarInset + windowUtil.mainWindowInfo.bottomInset)
        .lanes(new WidthBreakpointType(1, 2, 3, 4).getValue(windowUtil.mainWindowInfo.widthBp), 10)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
        .width('100%')
        .height('100%')
      }
      // Keep the fade fixed while the list moves during pull-to-refresh.
      .overlay(ListTopFade(), { align: Alignment.Top })
      .onRefreshing(() => this.viewModel.refresh())
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .onVisibleAreaChange([0, 1], (visible: boolean) => {
      if (visible && this.active) {
        this.viewModel.refresh();
      }
    })
  }
}
