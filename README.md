# LibZidane: A third-party Z-Library app for HarmonyOS
<p align="center">
    <img alt="lz_icon.png" height="240" src="AppScope/resources/base/media/lz_icon.png" width="240"/>
</p>

## 📖 Software Features

A simple replacement of Z-Library Android App for HarmonyOS. 

- [x] Login to Z-Library (Account / Cookie)
- [x] Recommended / Most Popular
- [x] My favorite books / downloaded books
- [x] Book details (Multi formats)
- [x] Search books with history, sorting, exact matching, publication years, languages, and file formats
- [x] Search filters with animated sections, selection summaries, independent option scrolling, and confirm/cancel editing
- [x] Read supported books online and switch between books from the Recent reads sidebar
- [x] Restore the recent reading list after restarting the app
- [x] Download books
- [x] Local bookshelf for new downloads (available offline and after logout)
- [x] Open local books in an external reader, export copies, and delete managed files
- [x] i18n (zh-hans & en-us)
- [x] Dark mode
- [x] Custom Api
- [x] Donation page to original Z-Library (not to me)
- [x] Multi-device adaption (Tablet, 2in1, PC)

## 🆕 What's new in 1.0.0

- Added an online reader and a Recent reads sidebar for switching between books. The recent list survives app restarts; restoring the reading position after a restart depends on the reader website.
- Rebuilt Search options with animated expansion, rotating arrows, selection summaries, and separate scrolling for long language and format lists. Clear filters stays accessible above the form.
- Fixed cancellation and dismissed drafts leaking into later searches. Invalid year ranges now keep the dialog open and explain the problem.
- Fixed loading placeholders appearing when an empty search field loses focus or filters are confirmed without a keyword.
- Refreshed navigation, bottom-tab symbols, safe-area handling, and list appearance, with system color resources and Chinese/English UI text.
- Raised the minimum supported API level to 24.

## 🛠️ System Requirements

HarmonyOS API 24 or newer. The project targets SDK 6.1.1 (API 24).

⚠️ Untested on OpenHarmony.

## 📦 How to use

Only building from source is available now.

```bash
git clone https://github.com/hrbattery/LibZidane
```

Then open the project in DevEco Studio, install the configured SDK, and configure your own signing material before building.

Host regression checks and device verification instructions are documented in [tests/README.md](tests/README.md).

## ⚽ Are you a Juventino / Madridista?

No, I'm a Kop. The name of app is just a meme about an alias of early version of HarmonyOS.

## ⚠️ Disclaimer

See [DISCLAIMER.md](DISCLAIMER.md).

## 🤝 Credits

- [zlibrary-eapi-documentation](https://github.com/baroxyton/zlibrary-eapi-documentation) by baroxyton for providing endpoints of the Z-Library android app API.
- [filesize.js](https://github.com/avoidwork/filesize.js)

