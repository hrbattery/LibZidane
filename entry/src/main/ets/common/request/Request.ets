import axios, { AxiosError, AxiosRequestConfig, AxiosResponse, InternalAxiosRequestConfig } from '@ohos/axios'
import { LogUtil as logger } from '@pura/harmony-utils'
import { preferencesUtils } from '../../model/storage/PreferencesUtils'
import { deepCopy } from '../CommonUtils'
import { Constants } from '../const/Constants'
import { StorageConstants } from '../const/StorageConstants'
import { qpsController } from './RequestQueue'

const TAG = '[Request] '

let reqInst = axios.create({
  timeout: 15000
})

AppStorage.setOrCreate('cookie', {})

reqInst.interceptors.request.use(async (request: InternalAxiosRequestConfig) => {
  if (request.baseURL === undefined) {
    request.baseURL = preferencesUtils.getSync(
      StorageConstants.DEFAULT_PREF,
      StorageConstants.PREFKEY_CURRENT_ACTIVE_API,
      Constants.DEFAULT_ZLIB_DOMAIN
    );
  }
  // post请求需要执行contentType
  if (request.method === 'post' || request.method === 'POST') {
    request.headers.setContentType("application/x-www-form-urlencoded");
  }
  const cookies = await getCookie()
  if (cookies !== "") {
    request.headers['Cookie'] = cookies;
  }
  return qpsController(request);
}, (err: AxiosError) => {
  logger.error(TAG, 'request error: ' + err)
  return Promise.reject()
})

reqInst.interceptors.response.use((response: AxiosResponse) => {
  const setCookieHeader: string[] | undefined = response.headers['set-cookie'];
  if (setCookieHeader) {
    setCookie(setCookieHeader);
  }
  return response
}, (err: AxiosError) => {
  logger.error(TAG, `error: ${err?.status} + ${err.message}`)
  return Promise.reject(err)
})

interface ApiResponse<T> {
  data: T
}

class Request {
  public async request<R>(config: AxiosRequestConfig): Promise<R> {
    const response = await reqInst.request<R>(config) as ApiResponse<R>
    return response.data
  }

  public async get<R>(url: string, config?: AxiosRequestConfig): Promise<R> {
    // const response = await reqInst.get(url, config) as ApiResponse<R>
    const _config: AxiosRequestConfig = deepCopy(config ?? {} as AxiosRequestConfig);
    _config.method = "get";
    _config.url = url;
    const response = await this.requestWithFallback<R>(_config);
    return response
  }

  public async post<R, D>(url: string, data?: D, config?: AxiosRequestConfig): Promise<R> {
    // const response = await reqInst.post(url, data, config) as ApiResponse<R>
    const _config: AxiosRequestConfig = deepCopy(config ?? {} as AxiosRequestConfig);
    _config.method = "post";
    _config.data = data;
    _config.url = url;
    const response = await this.requestWithFallback<R>(_config);
    return response
  }

  public async requestWithFallback<R>(
    config: AxiosRequestConfig,
    maxAttempts?: number,
    onError?: (endpoint: string, error: Error) => void
  ): Promise<R> {
    const customApis: string[] =
      preferencesUtils.getSync(StorageConstants.DEFAULT_PREF, StorageConstants.PREFKEY_CUSTOM_APIS, []);
    const officialApis: string[] =
      preferencesUtils.getSync(StorageConstants.DEFAULT_PREF, StorageConstants.PREFKEY_OFFICIAL_APIS, []);
    const curActiveApi: string =
      preferencesUtils.getSync(StorageConstants.DEFAULT_PREF, StorageConstants.PREFKEY_CURRENT_ACTIVE_API,
        Constants.DEFAULT_ZLIB_DOMAIN);
    const endpoints: string[] = Array.from(new Set([
      curActiveApi,
      ...customApis,
      ...officialApis
    ]));

    const _maxAttempts = maxAttempts ?? endpoints.length
    let _config: AxiosRequestConfig = deepCopy(config);
    let attempts = 0;
    let lastError: Error | null = null;

    for (let i = 0; i < Math.min(_maxAttempts, endpoints.length); i++) {
      attempts++;
      const endpoint = endpoints[i];
      if (config.baseURL === undefined) {
        _config.baseURL = endpoint;
      }

      try {
        const data = await this.request<R>(_config);
        if (endpoint != curActiveApi) {
          preferencesUtils.putSync(StorageConstants.DEFAULT_PREF, StorageConstants.PREFKEY_CURRENT_ACTIVE_API, endpoint)
        }
        return data;
      } catch (error) {
        lastError = error as Error;
        onError?.(endpoint, error as Error);

        if (config.baseURL === undefined) {
          break;
        }

        // 如果不是最后一次尝试，继续下一个
        if (i < _maxAttempts - 1) {
          logger.debug(`Try next endpoint: ${endpoints[i + 1]}`);
          continue;
        }
      }
    }

    throw new Error(`所有端点都失败 (尝试了 ${attempts} 次): ${lastError?.message}`);
  }
}

const commonRequest = async<T>(config: AxiosRequestConfig): Promise<T> => {
  const response = await reqInst.request(config) as ApiResponse<T>
  return response.data
}

let ReqInst: Request = new Request()

export default ReqInst

export async function getCookie() {
  let curCookie = await preferencesUtils.get<Record<string, string>>(StorageConstants.DEFAULT_PREF, 'cookie', {})
  let cookies: string[] = []

  for (const key of Object.keys(curCookie)) {
    const value = curCookie[key];
    cookies.push(`${key}=${value}`);
  }

  return cookies.join("; ");
}

export async function setCookie(cookies: string[]) {
  let curCookie = await preferencesUtils.get<Record<string, string>>(StorageConstants.DEFAULT_PREF, 'cookie', {})
  cookies.forEach(cookie => {
    let keyValue = cookie.split(';')[0]; // 提取键值部分（忽略过期时间等属性）

    let GeneratedDestructArray_2 = keyValue.split('=');
    let key = GeneratedDestructArray_2[0];
    let value = GeneratedDestructArray_2[1];

    curCookie[key.trim()] = value.trim()
  });

  await preferencesUtils.put(StorageConstants.DEFAULT_PREF, 'cookie', curCookie)
}