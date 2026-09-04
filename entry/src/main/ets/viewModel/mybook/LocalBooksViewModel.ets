import { common } from '@kit.AbilityKit';
import { DialogAction, DialogHelper } from '@pura/harmony-dialog';
import { LogUtil, ToastUtil } from '@pura/harmony-utils';
import { LocalBookEntry, LocalBookRecord } from '../../model/entities/LocalBookRecord';
import { getLocalBookStore, LocalBookStore } from '../../model/storage/LocalBookStore';
import { exportLocalBook, openLocalBook } from '../../common/system/LocalBookFileActions';

/** Local shelf state deliberately has no dependency on login or online book APIs. */
@ObservedV2
export class LocalBooksViewModel {
  @Trace entries: LocalBookEntry[] = [];
  @Trace isRefreshing: boolean = false;
  @Trace isLoadFailed: boolean = false;
  @Trace isBusy: boolean = false;
  private store?: LocalBookStore;
  private context?: common.UIAbilityContext;
  private onStoreChanged: () => void = () => this.refresh();

  /** Attach once for immediate updates after download completion. */
  public attach(context: common.UIAbilityContext): void {
    this.context = context;
    this.refresh();
  }

  /** Release listeners when the shelf component leaves the component tree. */
  public detach(): void {
    this.store?.unsubscribe(this.onStoreChanged);
    this.store = undefined;
    this.context = undefined;
  }

  /** Re-read metadata and file availability, including after returning from a reader. */
  public refresh(): void {
    if (!this.context) {
      return;
    }
    this.isRefreshing = true;
    try {
      if (!this.store) {
        this.store = getLocalBookStore(this.context);
        this.store.subscribe(this.onStoreChanged);
      }
      this.entries = this.store.list();
      this.isLoadFailed = false;
    } catch (error) {
      LogUtil.error(`Read local shelf failed: ${error}`);
      this.isLoadFailed = true;
    } finally {
      this.isRefreshing = false;
    }
  }

  /** Validate on action as well as refresh; files can disappear while the shelf is visible. */
  private canUse(record: LocalBookRecord): boolean {
    try {
      if (this.store?.isAvailable(record)) {
        return true;
      }
      ToastUtil.showToast($r('app.string.local_books_unavailable'));
    } catch (error) {
      LogUtil.error(`Check local file failed: ${error}`);
      ToastUtil.showToast($r('app.string.local_books_load_failed'));
    }
    this.refresh();
    return false;
  }

  /** Open with read-only access and offer export if the system cannot launch a reader. */
  public async open(record: LocalBookRecord): Promise<void> {
    if (this.isBusy || !this.context || !this.canUse(record)) {
      return;
    }
    this.isBusy = true;
    try {
      await openLocalBook(this.context, record);
    } catch (error) {
      LogUtil.error(`Open local book failed: ${error}`);
      DialogHelper.showAlertDialog({
        title: $r('app.string.local_books_open_failed'),
        content: $r('app.string.local_books_reader_hint'),
        primaryButton: $r('app.string.ui_common_cancel_btn'),
        secondaryButton: $r('app.string.local_books_export'),
        onAction: (action: DialogAction) => {
          if (action === DialogAction.TWO) {
            this.export(record);
          }
        }
      });
    } finally {
      this.isBusy = false;
    }
  }

  /** Export is a copy: cancellation or failure leaves the managed book untouched. */
  public async export(record: LocalBookRecord): Promise<void> {
    if (this.isBusy || !this.context || !this.canUse(record)) {
      return;
    }
    this.isBusy = true;
    try {
      if (await exportLocalBook(this.context, record)) {
        ToastUtil.showToast($r('app.string.local_books_exported'));
      }
    } catch (error) {
      LogUtil.error(`Export local book failed: ${error}`);
      ToastUtil.showToast($r('app.string.local_books_export_failed'));
    } finally {
      this.isBusy = false;
      this.refresh();
    }
  }

  /** Require confirmation before deleting the application's only managed copy. */
  public confirmDelete(record: LocalBookRecord): void {
    if (this.isBusy) {
      return;
    }
    DialogHelper.showAlertDialog({
      title: $r('app.string.local_books_delete_title'),
      content: $r('app.string.local_books_delete_message'),
      primaryButton: $r('app.string.ui_common_cancel_btn'),
      secondaryButton: $r('app.string.local_books_delete'),
      onAction: (action: DialogAction) => {
        if (action === DialogAction.TWO) {
          this.remove(record);
        }
      }
    });
  }

  /** Keep failed deletions visible and report their outcome rather than swallowing I/O errors. */
  private remove(record: LocalBookRecord): void {
    if (this.isBusy || !this.store) {
      return;
    }
    this.isBusy = true;
    try {
      this.store.remove(record);
      ToastUtil.showToast($r('app.string.local_books_deleted'));
    } catch (error) {
      LogUtil.error(`Delete local book failed: ${error}`);
      ToastUtil.showToast($r('app.string.local_books_delete_failed'));
    } finally {
      this.isBusy = false;
      this.refresh();
    }
  }
}
