/* Execute the real filter model and dialog action handler with native UI adapters.
 * These checks cover commit/dismissal semantics, not ArkUI rendering or gestures.
 * Run: node --test tests/search-filters.host.test.cjs
 */
const { test } = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const ts = require(process.env.ARKTS_TYPESCRIPT_PATH ||
  '/Applications/DevEco-Studio.app/Contents/sdk/default/openharmony/ets/build-tools/ets-loader/node_modules/typescript/lib/typescript.js');
const main = path.resolve(__dirname, '../entry/src/main/ets');

/** Transpile production logic while leaving native rendering and observation to device checks. */
function compile(source, bindings = {}) {
  const code = ts.transpileModule(source.replace(/@ObservedV2\s*/g, '').replace(/@Trace\s*/g, ''), {
    compilerOptions: { module: ts.ModuleKind.CommonJS, target: ts.ScriptTarget.ES2021 }
  }).outputText;
  const module = { exports: {} };
  new Function('module', 'exports', ...Object.keys(bindings), code)(module, module.exports, ...Object.values(bindings));
  return module.exports;
}
const { SearchFilterOptions } = compile(fs.readFileSync(path.join(main, 'model/entities/SearchFilterOptionModel.ets'), 'utf8'));
const page = fs.readFileSync(path.join(main, 'view/pages/Search.ets'), 'utf8');
const handler = page.match(/  private handleSearchOptionsClick\(\) \{[\s\S]*?\n  \}/)[0];

/** Capture each real dialog opening and invoke its actual button callbacks against a page adapter. */
function environment() {
  const env = { dialogs: [], closed: [], toasts: [], drafts: [], commits: 0 };
  let applied = new SearchFilterOptions();
  const viewModel = {};
  Object.defineProperty(viewModel, 'searchFilterOption', {
    get: () => applied,
    set: value => { applied = value; env.commits++; }
  });
  const { SearchActions } = compile(`export class SearchActions { ${handler} }`, {
    DialogAction: { ONE: 1, TWO: 2 },
    DialogHelper: {
      showCustomContentDialog: options => { env.dialogs.push(options); options.contentBuilder(); },
      closeDialog: id => env.closed.push(id)
    },
    ToastUtil: { showToast: message => env.toasts.push(message) },
    $r: name => name
  });
  const owner = { viewModel, getUIContext: () => ({}), SearchOptionDialogBuilder: draft => env.drafts.push(draft) };
  env.open = () => {
    SearchActions.prototype.handleSearchOptionsClick.call(owner);
    return { draft: env.drafts.at(-1), options: env.dialogs.at(-1) };
  };
  env.applied = () => applied;
  return env;
}

/** Edit all filter types to detect both scalar leaks and shared array references. */
function selectFilters(draft) {
  draft.exactMatch = true;
  draft.startYear = '2000';
  draft.endYear = '2024';
  draft.selectedLanguages.push('English');
  draft.selectedExtensions.push('epub');
}

test('cancel discards every draft field, and reopening cannot resurrect those edits', () => {
  const env = environment();
  const first = env.open();
  selectFilters(first.draft);
  assert.deepEqual(env.applied(), new SearchFilterOptions());
  first.options.onAction(1, 'cancelled');
  assert.equal(env.commits, 0);
  assert.deepEqual(env.closed, ['cancelled']);
  const second = env.open();
  assert.deepEqual(second.draft, new SearchFilterOptions());
  second.options.onAction(2, 'confirmed');
  assert.deepEqual(env.applied(), new SearchFilterOptions());
});

test('mask/back dismissal followed by confirmation cannot apply the abandoned draft', () => {
  const env = environment();
  selectFilters(env.open().draft);
  // System dismissal does not invoke a button action; the next opening creates a fresh draft.
  const next = env.open();
  assert.deepEqual(next.draft, new SearchFilterOptions());
  next.options.onAction(2, 'next');
  assert.deepEqual(env.applied(), new SearchFilterOptions());
});

test('confirm publishes all fields in one replacement and keeps its arrays independent', () => {
  const env = environment();
  const { draft, options } = env.open();
  selectFilters(draft);
  options.onAction(2, 'confirmed');
  assert.equal(env.commits, 1);
  assert.deepEqual(env.applied(), draft);
  assert.notEqual(env.applied(), draft);
  draft.selectedLanguages.push('French');
  draft.selectedExtensions.length = 0;
  assert.deepEqual(env.applied().selectedLanguages, ['English']);
  assert.deepEqual(env.applied().selectedExtensions, ['epub']);
});

test('invalid years keep the dialog open and applied values intact until corrected', () => {
  const env = environment();
  const { draft, options } = env.open();
  draft.startYear = '2025';
  draft.endYear = '2000';
  assert.equal(options.actionCancel, false);
  options.onAction(2, 'invalid');
  assert.equal(env.commits, 0);
  assert.deepEqual(env.closed, []);
  assert.deepEqual(env.toasts, ['app.string.ui_search_invalid_year_range']);
  draft.endYear = '2025';
  options.onAction(2, 'corrected');
  assert.equal(env.commits, 1);
  assert.deepEqual(env.closed, ['corrected']);
});

test('unlimited endpoints and a single publication year are valid', () => {
  const values = new SearchFilterOptions();
  assert.equal(values.hasValidYearRange(), true);
  values.startYear = '2025';
  assert.equal(values.hasValidYearRange(), true);
  values.endYear = '2025';
  assert.equal(values.hasValidYearRange(), true);
  values.startYear = undefined;
  assert.equal(values.hasValidYearRange(), true);
});

test('clear only affects the draft until confirmed; cancelling clear preserves applied filters', () => {
  const env = environment();
  const initial = env.open();
  selectFilters(initial.draft);
  initial.options.onAction(2, 'initial');
  const expected = env.applied().clone();
  const cancelled = env.open();
  cancelled.draft.clear();
  assert.deepEqual(cancelled.draft, new SearchFilterOptions());
  cancelled.options.onAction(1, 'cancelled');
  assert.deepEqual(env.applied(), expected);
  const confirmed = env.open();
  confirmed.draft.clear();
  confirmed.options.onAction(2, 'cleared');
  assert.deepEqual(env.applied(), new SearchFilterOptions());
});

const searchModel = fs.readFileSync(path.join(main, 'viewModel/search/SearchResultViewModel.ets'), 'utf8');
const loadMethod = searchModel.match(/  async loadDataSource\(\): Promise<void> \{[\s\S]*?\n  \}/)[0];

/** Exercise the production loading method independently from native state observation. */
function searchLoader(keyword, initiallyLoading = false) {
  const requests = [];
  const { SearchLoader } = compile(`export class SearchLoader { ${loadMethod} }`, {
    getSearch: async params => { requests.push(params); return null; },
    logger: { error: error => { throw error; } }
  });
  const loader = new SearchLoader();
  Object.assign(loader, {
    searchKeyword: keyword, isLoading: initiallyLoading, searchFilterOption: new SearchFilterOptions(),
    _languageOptions: {}, searchSortOrder: 'default'
  });
  return { loader, requests };
}

test('applying filters without a keyword never starts a request or leaves a loading placeholder', async () => {
  for (const initiallyLoading of [false, true]) {
    const { loader, requests } = searchLoader('', initiallyLoading);
    await loader.loadDataSource();
    assert.equal(loader.isLoading, false);
    assert.deepEqual(requests, []);
  }
});

test('a nonempty keyword still loads with the selected filter parameters', async () => {
  const { loader, requests } = searchLoader('test book');
  selectFilters(loader.searchFilterOption);
  loader._languageOptions = { English: 'en' };
  const pending = loader.loadDataSource();
  assert.equal(loader.isLoading, true);
  await pending;
  assert.equal(loader.isLoading, false);
  assert.deepEqual(requests, [{
    message: 'test book', yearFrom: '2000', yearTo: '2024', languages: ['en'],
    extensions: ['epub'], e: 1, order: 'default'
  }]);
});
