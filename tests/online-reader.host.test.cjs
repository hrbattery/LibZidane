const { test } = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const ts = require(process.env.ARKTS_TYPESCRIPT_PATH ||
  '/Applications/DevEco-Studio.app/Contents/sdk/default/openharmony/ets/build-tools/ets-loader/node_modules/typescript/lib/typescript.js');

/** Execute production session logic with controllable requests and no live account. */
function environment() {
  const requests = [];
  const source = fs.readFileSync(path.join(__dirname,
    '../entry/src/main/ets/model/entities/OnlineReaderState.ets'), 'utf8');
  const output = ts.transpileModule(source, {
    compilerOptions: { module: ts.ModuleKind.CommonJS, target: ts.ScriptTarget.ES2021, experimentalDecorators: true }
  }).outputText;
  const exports = {};
  new Function('require', 'exports', 'ObservedV2', 'Trace', output)(name => {
    if (name === '@kit.ArkTS') return { url: { URL: { parseURL: value => new URL(value) } } };
    if (name === '../api/BookApi') return {
      getBookInfo: (id, hash) => new Promise((resolve, reject) => requests.push({ id, hash, resolve, reject }))
    };
    throw new Error(`Unexpected import ${name}`);
  }, exports, value => value, () => {});
  return { state: new exports.OnlineReaderState(), library: new exports.OnlineReaderLibrary(),
    requests, valid: exports.isOnlineReaderUrl };
}

const book = (address = 'https://reader.example/read/book?signature=AbC%2F123') =>
  ({ readOnlineAvailable: true, readOnlineUrl: address });

test('resuming the same book retains its exact signed URL without a new request', async () => {
  const { state, requests } = environment();
  const opening = state.open(1, 'hash', 'Book');
  requests[0].resolve(book());
  await opening;
  await state.open(1, 'hash', 'Book');
  assert.equal(requests.length, 1);
  assert.equal(state.readerUrl, book().readOnlineUrl);
  assert.equal(state.failed, false);
});

test('switching books ignores a late response for the previous book', async () => {
  const { state, requests } = environment();
  const first = state.open(1, 'a', 'First');
  const second = state.open(2, 'b', 'Second');
  requests[1].resolve(book('https://reader.example/second'));
  await second;
  requests[0].resolve(book('https://reader.example/first'));
  await first;
  assert.equal(state.title, 'Second');
  assert.equal(state.readerUrl, 'https://reader.example/second');
});

test('close or logout invalidates an unfinished request', async () => {
  const { state, requests } = environment();
  const opening = state.open(1, 'a', 'Book');
  state.close();
  requests[0].resolve(book());
  await opening;
  assert.equal(state.bookId, 0);
  assert.equal(state.readerUrl, '');
  assert.equal(state.loading, false);
});

test('a late failure cannot stop the newer book from loading', async () => {
  const { state, requests } = environment();
  const first = state.open(1, 'a', 'First');
  const second = state.open(2, 'b', 'Second');
  requests[0].reject(new Error('Old failure'));
  await first;
  assert.equal(state.loading, true);
  assert.equal(state.failed, false);
  requests[1].resolve(book());
  await second;
});

test('retry fetches a new URL after failure, without keeping the old address', async () => {
  const { state, requests } = environment();
  const opening = state.open(1, 'a', 'Book');
  requests[0].reject(new Error('Network failure'));
  await opening;
  assert.equal(state.failed, true);
  const retry = state.reload();
  assert.equal(state.failed, false);
  assert.equal(state.readerUrl, '');
  requests[1].resolve(book());
  await retry;
  assert.equal(state.readerUrl, book().readOnlineUrl);
});

test('unavailable and unsafe reading addresses never reach the web component', async () => {
  for (const response of [
    { readOnlineAvailable: false, readOnlineUrl: 'https://reader.example/book' },
    { readOnlineAvailable: true, readOnlineUrl: '' },
    book('javascript:alert(1)'), book('file:///private/book'), book('http://reader.example/book'),
    book('https://user:password@reader.example/book')
  ]) {
    const { state, requests } = environment();
    const opening = state.open(1, 'a', 'Book');
    requests[0].resolve(response);
    await opening;
    assert.equal(state.readerUrl, '');
    assert.ok(state.failed || state.unavailable);
  }
});

test('multiple books retain independent sessions and resume in most-recent order', async () => {
  const { library, requests } = environment();
  const first = library.open(1, 'a', 'First', 'https://example.test/cover.jpg');
  requests[0].resolve(book('https://reader.example/first'));
  await first;
  const firstSession = library.current;
  const second = library.open(2, 'b', 'Second');
  requests[1].resolve(book('https://reader.example/second'));
  await second;
  const secondSession = library.current;
  await library.open(1, 'a', 'First');
  assert.equal(requests.length, 2);
  assert.equal(library.current, firstSession);
  assert.deepEqual(library.sessions, [firstSession, secondSession]);
  assert.equal(firstSession.cover, 'https://example.test/cover.jpg');
  assert.equal(firstSession.readerUrl, 'https://reader.example/first');
  assert.equal(secondSession.readerUrl, 'https://reader.example/second');
});

test('closing one listed book leaves other books and their links intact', async () => {
  const { library, requests } = environment();
  const first = library.open(1, 'a', 'First');
  requests[0].resolve(book('https://reader.example/first'));
  await first;
  const firstSession = library.current;
  const second = library.open(2, 'b', 'Second');
  requests[1].resolve(book('https://reader.example/second'));
  await second;
  const secondSession = library.current;
  library.close(firstSession);
  assert.deepEqual(library.sessions, [secondSession]);
  assert.equal(library.current, secondSession);
  assert.equal(secondSession.readerUrl, 'https://reader.example/second');
  library.resume(firstSession);
  assert.equal(library.current, secondSession);
});

test('closing a loading book cannot restore it when its request finishes', async () => {
  const { library, requests } = environment();
  const loading = library.open(1, 'a', 'Book');
  library.close(library.current);
  requests[0].resolve(book());
  await loading;
  assert.equal(library.sessions.length, 0);
  assert.equal(library.current.bookId, 0);
});

test('logout clears every session and invalidates all unfinished requests', async () => {
  const { library, requests } = environment();
  const first = library.open(1, 'a', 'First');
  const second = library.open(2, 'b', 'Second');
  const sessions = [...library.sessions];
  library.closeAll();
  requests.forEach(request => request.resolve(book()));
  await Promise.all([first, second]);
  assert.equal(library.sessions.length, 0);
  assert.ok(sessions.every(session => session.readerUrl === '' && !session.loading));
});
