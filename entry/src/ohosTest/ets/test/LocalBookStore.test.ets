import { describe, it, expect, beforeEach, afterEach } from '@ohos/hypium';
import { abilityDelegatorRegistry } from '@kit.TestKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import { LocalBookStore } from '../../../main/ets/model/storage/LocalBookStore';
import { LocalBookSelection, localBookKey } from '../../../main/ets/model/entities/LocalBookRecord';

/** Write isolated fixtures with the same native file APIs used by the store. */
function writeFixture(path: string, text: string): void {
  const file = fs.openSync(path, fs.OpenMode.CREATE | fs.OpenMode.WRITE_ONLY | fs.OpenMode.TRUNC);
  try {
    fs.writeSync(file.fd, text);
  } finally {
    fs.closeSync(file);
  }
}

/** Assert an I/O failure without relying on platform-specific error messages. */
function expectFailure(action: () => void): void {
  let failed = false;
  try {
    action();
  } catch {
    failed = true;
  }
  expect(failed).assertTrue();
}

/** Persistence and failure tests run against a dedicated directory, never the user's shelf. */
export default function localBookStoreTest(): void {
  describe('LocalBookStore', () => {
    let directory = '';
    let store: LocalBookStore;
    const epub: LocalBookSelection = {
      id: 101, hash: 'epubhash', title: '测试书籍', author: 'Author', extension: 'EPUB', cover: ''
    };
    const pdf: LocalBookSelection = {
      id: 102, hash: 'pdfhash', title: '测试书籍', author: 'Author', extension: 'PDF', cover: ''
    };

    beforeEach(() => {
      directory = `${abilityDelegatorRegistry.getAbilityDelegator().getAppContext().cacheDir}/local-books-store-test`;
      if (fs.accessSync(directory)) {
        fs.rmdirSync(directory);
      }
      fs.mkdirSync(directory);
      store = new LocalBookStore(`${directory}/books`);
      writeFixture(`${directory}/download.part`, 'book content');
    });
    afterEach(() => {
      fs.rmdirSync(directory);
    });

    it('committed_book_survives_restart_and_uses_selected_format', 0, () => {
      const record = store.commit(epub, `${directory}/download.part`, 'book.epub');
      const restored = new LocalBookStore(`${directory}/books`).list();
      expect(restored.length).assertEqual(1);
      expect(restored[0].available).assertTrue();
      expect(restored[0].record.title).assertEqual(epub.title);
      expect(restored[0].record.extension).assertEqual('epub');
      expect(restored[0].record.size).assertEqual(12);
      expect(fs.readTextSync(store.filePath(record))).assertEqual('book content');
      expect(fs.accessSync(`${directory}/download.part`)).assertFalse();
    });

    it('different_versions_and_same_filenames_do_not_overwrite_each_other', 0, () => {
      const first = store.commit(epub, `${directory}/download.part`, 'same.file');
      writeFixture(`${directory}/download.part`, 'pdf content');
      const second = store.commit(pdf, `${directory}/download.part`, 'same.file');
      expect(store.list().length).assertEqual(2);
      expect(fs.readTextSync(store.filePath(first))).assertEqual('book content');
      expect(fs.readTextSync(store.filePath(second))).assertEqual('pdf content');
      expect(first.filePath === second.filePath).assertFalse();
    });

    it('reservation_rejects_duplicates_but_allows_other_versions_and_retry', 0, () => {
      expect(store.beginDownload(epub.id, epub.hash)).assertTrue();
      expect(store.beginDownload(epub.id, epub.hash)).assertFalse();
      expect(store.beginDownload(pdf.id, pdf.hash)).assertTrue();
      store.endDownload(epub.id, epub.hash);
      expect(store.beginDownload(epub.id, epub.hash)).assertTrue();
    });

    it('duplicate_commit_cannot_overwrite_a_valid_book', 0, () => {
      const first = store.commit(epub, `${directory}/download.part`, 'book.epub');
      writeFixture(`${directory}/download.part`, 'replacement');
      expectFailure(() => store.commit(epub, `${directory}/download.part`, 'other.epub'));
      expect(fs.readTextSync(store.filePath(first))).assertEqual('book content');
      expect(store.list().length).assertEqual(1);
    });

    it('missing_file_keeps_metadata_and_can_be_removed', 0, () => {
      const record = store.commit(epub, `${directory}/download.part`, 'book.epub');
      fs.unlinkSync(store.filePath(record));
      const restored = new LocalBookStore(`${directory}/books`);
      expect(restored.list().length).assertEqual(1);
      expect(restored.list()[0].available).assertFalse();
      restored.remove(record);
      expect(restored.list().length).assertEqual(0);
    });

    it('truncated_file_is_unavailable_and_can_be_downloaded_again', 0, () => {
      const old = store.commit(epub, `${directory}/download.part`, 'book.epub');
      writeFixture(store.filePath(old), 'x');
      expect(store.isAvailable(old)).assertFalse();
      writeFixture(`${directory}/download.part`, 'new complete book');
      const replacement = store.commit(epub, `${directory}/download.part`, 'book.epub');
      expect(store.isAvailable(replacement)).assertTrue();
      expect(store.list().length).assertEqual(1);
    });

    it('empty_or_missing_download_does_not_publish_a_record', 0, () => {
      writeFixture(`${directory}/download.part`, '');
      expectFailure(() => store.commit(epub, `${directory}/download.part`, 'book.epub'));
      expectFailure(() => store.commit(pdf, `${directory}/absent.part`, 'book.pdf'));
      expect(store.list().length).assertEqual(0);
    });

    it('restart_cleans_uncommitted_and_malformed_directories_only_inside_store', 0, () => {
      const orphan = `${directory}/books/orphan`;
      fs.mkdirSync(orphan);
      writeFixture(`${orphan}/record.tmp`, '{');
      const invalid = `${directory}/books/invalid`;
      fs.mkdirSync(invalid);
      writeFixture(`${invalid}/record.json`, '{}');
      const restored = new LocalBookStore(`${directory}/books`);
      expect(restored.list().length).assertEqual(0);
      expect(fs.accessSync(orphan)).assertFalse();
      expect(fs.accessSync(invalid)).assertFalse();
      expect(fs.accessSync(`${directory}/download.part`)).assertTrue();
    });

    it('untrusted_filename_never_controls_storage_path', 0, () => {
      const record = store.commit(epub, `${directory}/download.part`, '../../outside.epub');
      expect(record.filePath).assertEqual(`${localBookKey(epub.id, epub.hash)}/book.epub`);
      expect(record.fileName.includes('/')).assertFalse();
      expect(fs.accessSync(`${directory}/outside.epub`)).assertFalse();
    });

    it('subscribers_observe_only_complete_commits_and_deletions', 0, () => {
      let notifications = 0;
      let observedIncompleteBook = false;
      const listener = (): void => {
        notifications++;
        const books = store.list();
        if (books.length > 0) {
          observedIncompleteBook = observedIncompleteBook || !books[0].available;
        }
      };
      store.subscribe(listener);
      const record = store.commit(epub, `${directory}/download.part`, 'book.epub');
      store.remove(record);
      expect(notifications).assertEqual(2);
      expect(observedIncompleteBook).assertFalse();
      store.unsubscribe(listener);
      store.notifyChanged();
      expect(notifications).assertEqual(2);
    });

    it('deleting_local_book_does_not_remove_export_and_late_cover_cannot_recreate_it', 0, () => {
      const record = store.commit(epub, `${directory}/download.part`, 'book.epub');
      fs.copyFileSync(store.filePath(record), `${directory}/export.epub`);
      store.remove(record);
      store.saveCover(record, new ArrayBuffer(1));
      expect(store.list().length).assertEqual(0);
      expect(fs.readTextSync(`${directory}/export.epub`)).assertEqual('book content');
    });
  });
}
