export class Constants {
  /**
   * FAVORITES_SORT_KEY
   * 收藏页面排序的显示Key值
   */
  static readonly FAVORITES_SORT_KEY: Record<string, string>[] = [
    { "key": "收藏日期（降序）", "value": "saved_date" },
    { "key": "收藏日期（升序）", "value": "saved_dateA" }
  ]
  /**
   * DOWNLOADED_SORT_KEY
   * 已下载页面排序的显示Key值
   */
  static readonly DOWNLOADED_SORT_KEY: Record<string, string>[] = [
    { "key": "下载日期（降序）", "value": "downloaded_date" },
    { "key": "下载日期（升序）", "value": "downloaded_dateA" },
    { "key": "名称（A-Z）", "value": "titleA" },
    { "key": "名称（Z-A）", "value": "title" },
    { "key": "年份", "value": "year" },
    { "key": "文件大小（降序）", "value": "filesize" },
    { "key": "文件大小（升序）", "value": "filesizeA" }
  ]
  /**
   * SEARCH_SORT_KEY
   * 搜索页面排序的显示Key值
   */
  static readonly SEARCH_SORT_KEY: Record<string, string>[] = [
    { "key": "最受欢迎", "value": "popular" },
    { "key": "最佳匹配", "value": "bestmatch" },
    { "key": "最近添加", "value": "date" },
    { "key": "名称（A-Z）", "value": "titleA" },
    { "key": "名称（Z-A）", "value": "title" },
    { "key": "年份", "value": "year" },
    { "key": "文件大小（降序）", "value": "filesize" },
    { "key": "文件大小（升序）", "value": "filesizeA" }
  ]
}