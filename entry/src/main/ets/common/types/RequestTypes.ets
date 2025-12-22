export interface ApiEndpoint {
  url: string;
  name: string;
  weight?: number;
  timeout?: number;
  retryCount?: number;
}

export interface ApiResponse<T> {
  data: T;
  endpoint: string;
  attempts: number;
  duration: number;
}

export interface ApiError extends Error {
  endpoint: string;
  attempts: number;
  statusCode?: number;
}