/*
 * Host checks execute the real ArkTS store/download code with native API adapters.
 * They do not prove device URI grants or UI behavior. Run with Node's test runner:
 * node --test tests/local-books.host.test.cjs
 * Set ARKTS_TYPESCRIPT_PATH to the SDK's typescript.js when DevEco is elsewhere.
 */
const { test } = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const ts = require(process.env.ARKTS_TYPESCRIPT_PATH ||
  '/Applications/DevEco-Studio.app/Contents/sdk/default/openharmony/ets/build-tools/ets-loader/node_modules/typescript/lib/typescript.js');
const project = path.resolve(__dirname, '..');
const main = path.join(project, 'entry/src/main/ets');

/** Isolate module state, disk fixtures, fault injection and simulated system download events. */
function environment() {
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), 'libzidane-test-'));
  const context = {
    filesDir: path.join(directory, 'files'), cacheDir: path.join(directory, 'cache'),
    resourceManager: { getStringSync: id => id }, startAbility: async want => { env.opened.push(want); }
  };
  fs.mkdirSync(context.filesDir);
  fs.mkdirSync(context.cacheDir);
  const env = {
    context, tasks: [], opened: [], dialogs: [], notices: [], toasts: [], urlCalls: [],
    fault: undefined, urlError: false, noticeError: false, pickerUris: [], openDescriptors: new Set(),
    dispose: () => fs.rmSync(directory, { recursive: true, force: true })
  };
  const io = {
    OpenMode: { CREATE: fs.constants.O_CREAT, WRITE_ONLY: fs.constants.O_WRONLY,
      READ_WRITE: fs.constants.O_RDWR, TRUNC: fs.constants.O_TRUNC },
    accessSync: fs.existsSync,
    mkdirSync: (p, recursive = false) => {
      // Do not let Node's recursive mkdir mask the native File-exists error on restart.
      if (fs.existsSync(p)) throw new Error('File exists');
      return fs.mkdirSync(p, { recursive });
    },
    rmdirSync: p => fs.rmSync(p, { recursive: true }),
    listFileSync: fs.readdirSync,
    statSync: fs.statSync,
    readTextSync: p => fs.readFileSync(p, 'utf8'),
    moveFileSync: fs.renameSync,
    renameSync: fs.renameSync,
    unlinkSync: fs.unlinkSync,
    fsyncSync: fs.fsyncSync,
    openSync: (p, flags) => {
      const fd = fs.openSync(p, flags);
      env.openDescriptors.add(fd);
      return { fd };
    },
    closeSync: file => {
      fs.closeSync(file.fd);
      env.openDescriptors.delete(file.fd);
    },
    writeSync: (fd, data) => fs.writeSync(fd, typeof data === 'string' ? data : Buffer.from(data)),
    copyFileSync: fs.copyFileSync,
    copyFile: async (src, dest) => {
      if (typeof dest === 'number') fs.writeFileSync(dest, fs.readFileSync(src));
      else fs.copyFileSync(src, dest);
    }
  };
  for (const [name, operation] of Object.entries(io)) {
    if (typeof operation !== 'function') continue;
    io[name] = (...args) => {
      if (env.fault?.operation === name && args.some(arg => String(arg).includes(env.fault.match))) {
        env.fault = undefined;
        throw new Error(`Injected ${name} failure`);
      }
      return operation(...args);
    };
  }
  io.open = async (...args) => io.openSync(...args);
  io.close = async (...args) => io.closeSync(...args);
  env.io = io;
  const nativeTests = [];
  let before = () => {}, after = () => {};
  const modules = {
    '@kit.CoreFileKit': {
      fileIo: io,
      fileUri: { getUriFromPath: p => `file://com.library.zidane${p}` },
      picker: { DocumentSaveOptions: class {}, DocumentViewPicker: class {
        async save() { return env.pickerUris; }
      } }
    },
    '@kit.AbilityKit': { wantConstant: { Flags: { FLAG_AUTH_READ_URI_PERMISSION: 1 } } },
    '@kit.ArkData': { uniformTypeDescriptor: {} },
    '@kit.ArkTS': { url: { URL: { parseURL: value => new URL(value) }, URLParams: URLSearchParams } },
    '@kit.TestKit': { abilityDelegatorRegistry: {
      getAbilityDelegator: () => ({ getAppContext: () => context })
    } },
    '@ohos/hypium': {
      describe: (_name, callback) => callback(),
      beforeEach: callback => { before = callback; }, afterEach: callback => { after = callback; },
      it: (name, _flags, callback) => nativeTests.push({ name, callback }),
      expect: value => ({ assertTrue: () => assert.equal(value, true),
        assertFalse: () => assert.equal(value, false), assertEqual: expected => assert.deepEqual(value, expected) })
    },
    '@kit.BasicServicesKit': { request: { downloadFile: async (_context, options) => {
      const listeners = new Map();
      const task = {
        on: (event, callback) => listeners.set(event, callback), off: event => listeners.delete(event),
        complete: (contents = 'download content') => {
          fs.writeFileSync(options.filePath, contents);
          listeners.get('complete')();
        },
        fail: () => { fs.writeFileSync(options.filePath, 'partial'); listeners.get('fail')(1); }
      };
      env.tasks.push(task);
      return task;
    } } },
    '@pura/harmony-utils': {
      LogUtil: { error() {}, warn() {} }, ToastUtil: { showToast: text => env.toasts.push(text) }
    },
    '@pura/harmony-dialog': {
      DialogAction: { TWO: 2 }, DialogHelper: { showAlertDialog: dialog => env.dialogs.push(dialog) }
    },
    '@ohos/axios': { __esModule: true, default: { get: async () => { throw new Error('cover unavailable'); } } }
  };
  const cache = new Map();
  env.load = file => {
    file = path.resolve(file);
    if (cache.has(file)) return cache.get(file).exports;
    const module = { exports: {} };
    cache.set(file, module);
    const source = fs.readFileSync(file, 'utf8');
    const code = ts.transpileModule(source, {
      fileName: file.replace(/\.ets$/, '.ts'),
      compilerOptions: { module: ts.ModuleKind.CommonJS, target: ts.ScriptTarget.ES2021 }
    }).outputText;
    const localRequire = name => {
      if (modules[name]) return modules[name];
      if (name.endsWith('/BookApi')) return { getBookDownloadUrl: async (id, hash) => {
        env.urlCalls.push({ id, hash });
        if (env.urlError) throw new Error('offline');
        return { downloadLink: 'https://example.invalid/book?filename=same.epub' };
      } };
      if (name.endsWith('/NotificationUtil')) return { notificationUtil: {
        publish: (_id, title) => {
          if (env.noticeError) throw new Error('Notifications unavailable');
          env.notices.push(title);
        }, download() {}
      } };
      if (name.endsWith('/filesize')) return { filesize: size => String(size) };
      if (name.startsWith('.')) return env.load(path.resolve(path.dirname(file), `${name}.ets`));
      throw new Error(`Unexpected import: ${name}`);
    };
    new Function('require', 'module', 'exports', '$r', code)(localRequire, module, module.exports, name => ({ id: name }));
    return module.exports;
  };
  env.nativeTests = nativeTests;
  env.runNativeTest = async fixture => { try { await before(); await fixture.callback(); } finally { await after(); } };
  return env;
}

const selection = { id: 101, hash: 'epubhash', title: 'A book', author: 'Author', extension: 'epub', cover: '' };

/** Let the mocked URL/task promises settle without depending on arbitrary timers. */
async function flush() { await new Promise(resolve => setImmediate(resolve)); }

test('native storage scenarios using host filesystem adapter', async t => {
  const env = environment();
  try {
    env.load(path.join(project, 'entry/src/ohosTest/ets/test/LocalBookStore.test.ets')).default();
    for (const fixture of env.nativeTests) await t.test(fixture.name, () => env.runNativeTest(fixture));
  } finally { env.dispose(); }
});

test('download reservation precedes URL request, selected version commits, duplicate opens locally', async () => {
  const env = environment();
  try {
    const { fileDownload } = env.load(path.join(main, 'common/request/FileDownload.ets'));
    const download = fileDownload.downloadBook(env.context, selection);
    await flush();
    await fileDownload.downloadBook(env.context, selection);
    assert.equal(env.urlCalls.length, 1);
    assert.equal(env.tasks.length, 1);
    env.tasks[0].complete();
    await download;
    await fileDownload.downloadBook(env.context, selection);
    assert.equal(env.urlCalls.length, 1);
    assert.equal(env.opened.length, 1);
    assert.equal(env.opened[0].flags, 1);
    assert.equal(env.opened[0].type, 'application/epub+zip');
    const store = env.load(path.join(main, 'model/storage/LocalBookStore.ets')).getLocalBookStore(env.context);
    assert.equal(store.list()[0].record.id, selection.id);
    assert.equal(store.list()[0].record.hash, selection.hash);
    assert.equal(env.notices.filter(n => n.endsWith('download_complete')).length, 1);
  } finally { env.dispose(); }
});

for (const failure of ['url', 'transfer', 'empty', 'metadata', 'write']) {
  test(`${failure} failure publishes no success and releases reservation for retry`, async () => {
    const env = environment();
    try {
      const { fileDownload } = env.load(path.join(main, 'common/request/FileDownload.ets'));
      env.urlError = failure === 'url';
      const attempt = fileDownload.downloadBook(env.context, selection);
      await flush();
      if (failure === 'transfer') env.tasks[0].fail();
      if (failure === 'metadata') {
        env.fault = { operation: 'renameSync', match: 'record.json' };
        env.tasks[0].complete();
      }
      if (failure === 'write') {
        env.fault = { operation: 'openSync', match: 'record.tmp' };
        env.tasks[0].complete();
      }
      if (failure === 'empty') env.tasks[0].complete('');
      await attempt;
      const store = env.load(path.join(main, 'model/storage/LocalBookStore.ets')).getLocalBookStore(env.context);
      assert.equal(store.list().length, 0);
      assert.equal(env.notices.some(n => n.endsWith('download_complete')), false);
      assert.equal(fs.readdirSync(path.join(env.context.cacheDir, 'local-books-downloads')).length, 0);
      env.urlError = false;
      const retry = fileDownload.downloadBook(env.context, selection);
      await flush();
      env.tasks.at(-1).complete();
      await retry;
      assert.equal(env.urlCalls.length, 2);
      assert.equal(store.list().length, 1);
      assert.equal(env.openDescriptors.size, 0);
    } finally { env.dispose(); }
  });
}

test('export cancellation, copy failure and success preserve the source and close descriptors', async () => {
  const env = environment();
  try {
    const store = env.load(path.join(main, 'model/storage/LocalBookStore.ets')).getLocalBookStore(env.context);
    const temp = path.join(env.context.cacheDir, 'book.part');
    fs.writeFileSync(temp, 'content');
    const record = store.commit(selection, temp, 'book.epub');
    const { exportLocalBook } = env.load(path.join(main, 'common/system/LocalBookFileActions.ets'));
    assert.equal(await exportLocalBook(env.context, record), false);
    const output = path.join(env.context.cacheDir, 'export.epub');
    fs.writeFileSync(output, '');
    env.pickerUris = [output];
    env.fault = { operation: 'copyFile', match: 'book.epub' };
    await assert.rejects(exportLocalBook(env.context, record));
    assert.equal(store.isAvailable(record), true);
    assert.equal(env.openDescriptors.size, 0);
    assert.equal(await exportLocalBook(env.context, record), true);
    assert.equal(fs.readFileSync(output, 'utf8'), 'content');
    assert.equal(env.openDescriptors.size, 0);
  } finally { env.dispose(); }
});

test('failed deletion retains metadata, and failed metadata reads never trigger cleanup', () => {
  const env = environment();
  try {
    const { getLocalBookStore, LocalBookStore } = env.load(path.join(main, 'model/storage/LocalBookStore.ets'));
    const store = getLocalBookStore(env.context);
    const temp = path.join(env.context.cacheDir, 'book.part');
    fs.writeFileSync(temp, 'content');
    const record = store.commit(selection, temp, 'book.epub');
    env.fault = { operation: 'unlinkSync', match: 'book.epub' };
    assert.throws(() => store.remove(record));
    assert.equal(store.list().length, 1);
    assert.equal(store.isAvailable(record), true);
    env.fault = { operation: 'readTextSync', match: 'record.json' };
    assert.throws(() => new LocalBookStore(path.join(env.context.filesDir, 'local-books')));
    assert.equal(store.isAvailable(record), true);
  } finally { env.dispose(); }
});

test('reader launch failure offers export without a new URL request', async () => {
  const env = environment();
  try {
    const store = env.load(path.join(main, 'model/storage/LocalBookStore.ets')).getLocalBookStore(env.context);
    const temp = path.join(env.context.cacheDir, 'book.part');
    fs.writeFileSync(temp, 'content');
    store.commit(selection, temp, 'book.epub');
    env.context.startAbility = async () => { throw new Error('No matching application'); };
    const { fileDownload } = env.load(path.join(main, 'common/request/FileDownload.ets'));
    await fileDownload.downloadBook(env.context, selection);
    assert.equal(env.urlCalls.length, 0);
    assert.equal(env.dialogs.length, 1);
    assert.equal(env.dialogs[0].secondaryButton.id, 'app.string.local_books_export');
    assert.equal(store.list()[0].available, true);
  } finally { env.dispose(); }
});

test('completion notification failure does not mark a committed book as failed', async () => {
  const env = environment();
  try {
    const { fileDownload } = env.load(path.join(main, 'common/request/FileDownload.ets'));
    const pending = fileDownload.downloadBook(env.context, selection);
    await flush();
    env.noticeError = true;
    env.tasks[0].complete();
    await pending;
    const store = env.load(path.join(main, 'model/storage/LocalBookStore.ets')).getLocalBookStore(env.context);
    assert.equal(store.list()[0].available, true);
    assert.equal(env.toasts.some(item => item.id?.endsWith('save_failed')), false);
    assert.equal(store.beginDownload(selection.id, selection.hash), true);
  } finally { env.dispose(); }
});

test('simultaneous formats retain separate files even when completed out of order', async () => {
  const env = environment();
  try {
    const { fileDownload } = env.load(path.join(main, 'common/request/FileDownload.ets'));
    const epub = fileDownload.downloadBook(env.context, selection);
    const pdf = fileDownload.downloadBook(env.context, { ...selection, id: 102, hash: 'pdfhash', extension: 'pdf' });
    await flush();
    assert.equal(env.tasks.length, 2);
    env.tasks[1].complete('PDF data');
    await pdf;
    env.tasks[0].complete('EPUB data');
    await epub;
    const store = env.load(path.join(main, 'model/storage/LocalBookStore.ets')).getLocalBookStore(env.context);
    const records = store.list().map(item => item.record);
    assert.equal(records.length, 2);
    for (const record of records) {
      assert.equal(fs.readFileSync(store.filePath(record), 'utf8'), `${record.extension.toUpperCase()} data`);
    }
  } finally { env.dispose(); }
});
