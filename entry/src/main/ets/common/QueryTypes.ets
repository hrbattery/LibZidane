export interface SearchQueryType {
  message: string,
  yearFrom?: number,
  yearTo?: number,
  languages?: string[],
  extensions?: string[],
  e: number, // exactly: 完全匹配
  page?: number,
  limit?: number,
  order: string
}

export interface DownloadedQueryType {
  page?: number,
  limit?: number,
  order?: string
}

export interface FavoriteQueryType {
  page?: number,
  limit?: number,
  order?: string
}