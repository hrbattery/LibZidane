# Local bookshelf checks

## Online reader checks

Run `node --test tests/online-reader.host.test.cjs` for signed-link validation,
same-book resume, fresh-link retry, independent books, closing one book and late responses after close.
These checks do not load the remote web reader.

On a device, open two available books from their detail pages, then return home. Open
Reading from the button before the home title. Edge swipes remain system Back gestures.
Check both books are listed, resume each, and confirm closing one preserves the other.
Also check tapping outside, swiping left and system Back dismiss the sidebar, while
detail pages retain their normal back button. Tablets use approximately one third of
the window width and wide windows one quarter; phones use a wider drawer.
Verify the same web page and reading position remain after resume. Logging out ends
all sessions. Reading state is retained only during the current app process;
restoration after restarting depends on the website.

Run the host regression suite with Node.js 18 or newer:

```sh
node --test tests/local-books.host.test.cjs
```

The runner uses the TypeScript compiler bundled with DevEco Studio. On installations
outside the default macOS location, set `ARKTS_TYPESCRIPT_PATH` to the SDK's
`ets/build-tools/ets-loader/node_modules/typescript/lib/typescript.js`.

The host runner executes the production store, download flow and file actions,
using real temporary files plus adapters for HarmonyOS APIs. It also runs the
same storage cases registered in `entry/src/ohosTest/ets/test/LocalBookStore.test.ets`.
URL, transfer, metadata write, deletion and export failures are injected on the host.
No account or live book endpoint is used.

## Device checks

With a valid local signing configuration, run the `ohosTest` target in DevEco Studio
to execute the storage cases using native file APIs. The tests use a dedicated
cache subdirectory and do not modify the user's bookshelf.

The host suite does **not** validate UI rendering, actual downloads, or URI grants.
On a device, also verify:

- Download an EPUB and PDF: the selected version appears under My books → Local books.
- Relaunch, go offline, and log out: the local shelf remains usable.
- Tap each file: a compatible installed reader can read it with read-only access.
- With no compatible reader, opening reports the problem and offers export.
- Export, cancel export, and delete: exported copies and server download history remain independent.
- Check refresh, returning from a reader, empty/error states, Chinese/English, dark/light mode and narrow screens.

Only new downloads are collected. Old files are not imported, and managed books
are deleted when the application is uninstalled; users can export copies first.
