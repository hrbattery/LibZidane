export class Constants {
  /**
   * FAVORITES_SORT_KEY
   * 收藏页面排序的显示Key值
   */
  static readonly FAVORITES_SORT_KEY: Record<string, ResourceStr>[] = [
    { "key": $r("app.string.ui_favorite_sort_key_saved_date"), "value": "saved_date" },
    { "key": $r("app.string.ui_favorite_sort_key_saved_date_A"), "value": "saved_dateA" }
  ]
  /**
   * DOWNLOADED_SORT_KEY
   * 已下载页面排序的显示Key值
   */
  static readonly DOWNLOADED_SORT_KEY: Record<string, ResourceStr>[] = [
    { "key": $r("app.string.ui_downloaded_sort_key_downloaded_date"), "value": "downloaded_date" },
    { "key": $r("app.string.ui_downloaded_sort_key_downloaded_date_A"), "value": "downloaded_dateA" },
    { "key": $r("app.string.ui_downloaded_sort_key_title_A"), "value": "titleA" },
    { "key": $r("app.string.ui_downloaded_sort_key_title"), "value": "title" },
    { "key": $r("app.string.ui_downloaded_sort_key_year"), "value": "year" },
    { "key": $r("app.string.ui_downloaded_sort_key_filesize"), "value": "filesize" },
    { "key": $r("app.string.ui_downloaded_sort_key_filesize_A"), "value": "filesizeA" }
  ]
  /**
   * SEARCH_SORT_KEY
   * 搜索页面排序的显示Key值
   */
  static readonly SEARCH_SORT_KEY: Record<string, ResourceStr>[] = [
    { "key": $r("app.string.ui_search_sort_key_popular"), "value": "popular" },
    { "key": $r("app.string.ui_search_sort_key_best_match"), "value": "bestmatch" },
    { "key": $r("app.string.ui_search_sort_key_recently_added"), "value": "date" },
    { "key": $r("app.string.ui_search_sort_key_title_A"), "value": "titleA" },
    { "key": $r("app.string.ui_search_sort_key_title"), "value": "title" },
    { "key": $r("app.string.ui_search_sort_key_year"), "value": "year" },
    { "key": $r("app.string.ui_search_sort_key_filesize"), "value": "filesize" },
    { "key": $r("app.string.ui_search_sort_key_filesize_A"), "value": "filesizeA" }
  ]
}