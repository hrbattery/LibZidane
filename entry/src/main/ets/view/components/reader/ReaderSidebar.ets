import { CoverData } from '../../../model/entities/BookModel';
import { BookCover } from '../common/BookCover';
import { OnlineReaderLibrary, OnlineReaderState } from '../../../model/entities/OnlineReaderState';

/** Unfinished online books; returning from the reader keeps each book in this list. */
@ComponentV2
export struct ReaderSidebar {
  @Param @Require library: OnlineReaderLibrary;
  @Event onResume: (session: OnlineReaderState) => void;
  @Event onCloseBook: (session: OnlineReaderState) => void;
  @Event onDismiss: () => void;

  /** Give the drawer a quiet surface and keep the header outside the scrolling books. */
  build() {
    Column() {
      this.Header()
      if (this.library.sessions.length === 0) {
        this.EmptyState()
      } else {
        List({ space: 24 }) {
          ForEach(this.library.sessions, (session: OnlineReaderState) => {
            ListItem() {
              this.BookCard(session)
            }
          }, (session: OnlineReaderState) => `${session.bookId}:${session.hash}`)
        }
        .padding({ left: 16, right: 16, top: 12, bottom: 24 })
        // Include the padding so floating close buttons and cover shadows are not cropped.
        .clipContent(ContentClipMode.BOUNDARY)
        .scrollBar(BarState.Off)
        .layoutWeight(1)
      }
    }
    .height('100%')
    .backgroundColor($r('sys.color.background_secondary'))
    .borderRadius({ topRight: 24, bottomRight: 24 })
    .clip(true)
    .shadow({ radius: 24, color: '#18000000', offsetX: 6, offsetY: 0 })
  }

  /** Keep the title, book count and dismiss control on one compact header. */
  @Builder
  Header() {
    Row({ space: 6 }) {
      Text($r('app.string.ui_reader_sidebar_title'))
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('sys.color.font_primary'))
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .layoutWeight(1)
      if (this.library.sessions.length > 0) {
        Text(`${this.library.sessions.length}`)
          .fontSize(12)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_secondary'))
          .padding({ left: 7, right: 7, top: 3, bottom: 3 })
          .backgroundColor($r('sys.color.comp_background_primary'))
          .borderRadius(8)
      }
      Button() {
        Image($r('app.media.back')).width(16).height(16)
          .fillColor($r('sys.color.icon_secondary'))
      }
      .width(36).height(36)
      .backgroundColor($r('sys.color.comp_background_primary'))
      .accessibilityText($r('app.string.ui_reader_sidebar_hide'))
      .onClick(() => this.onDismiss())
    }
    .padding({ left: 16, right: 16, top: 16, bottom: 24 })
    .width('100%')
  }

  /** Center a quiet book illustration with a single empty-state label. */
  @Builder
  EmptyState() {
    Column() {
      Blank().layoutWeight(2)
      Stack() {
        Image($r('app.media.reader_book')).width(36).height(36)
          .fillColor($r('sys.color.icon_emphasize'))
      }
      .width(80).height(80)
      .backgroundColor($r('sys.color.comp_background_primary'))
      .borderRadius(28)
      Text($r('app.string.ui_reader_sidebar_empty'))
        .fontSize(14)
        .margin({ top: 24 })
        .fontColor($r('sys.color.font_secondary'))
        .textAlign(TextAlign.Center)
      Blank().layoutWeight(3)
    }
    .padding({ left: 24, right: 24 })
    .width('100%')
    .layoutWeight(1)
  }

  /** Reuse the full-width cover, with its title below and a separate close target above it. */
  @Builder
  BookCard(session: OnlineReaderState) {
    Stack({ alignContent: Alignment.TopEnd }) {
      Button({ type: ButtonType.Normal }) {
        Column({ space: 12 }) {
          BookCover({
            coverData: new CoverData({
              id: session.bookId, hash: session.hash, title: session.title,
              author: '', cover: session.cover
            })
          })
            .width('100%')
            .borderRadius(10)
            .clip(true)
            .shadow({ radius: 10, color: '#20000000', offsetX: 0, offsetY: 4 })
          Text(session.title)
            .width('100%')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .width('100%')
      }
      .width('100%')
      .padding(0)
      .borderRadius(0)
      .backgroundColor(Color.Transparent)
      .clip(false)
      .onClick(() => this.onResume(session))
      Button() {
        Stack() {
          Image($r('app.media.reader_close')).width(14).height(14)
            .fillColor('#99000000')
        }
        .width(28).height(28)
        .backgroundColor(Color.White)
        .borderRadius(14)
        .shadow({ radius: 6, color: '#33000000', offsetX: 0, offsetY: 2 })
      }
      .width(40).height(40)
      // The 28vp circle protrudes 6vp; its 40vp touch target stays easy to hit.
      .offset({ x: 12, y: -12 })
      .backgroundColor(Color.Transparent)
      .clip(false)
      .accessibilityText($r('app.string.ui_reader_close'))
      .onClick(() => this.onCloseBook(session))
    }
    .width('100%')
  }
}
