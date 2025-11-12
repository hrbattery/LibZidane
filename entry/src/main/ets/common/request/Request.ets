import axios, { AxiosError, AxiosRequestConfig, AxiosResponse, InternalAxiosRequestConfig } from "@ohos/axios"
import { LogUtil as logger } from "@pura/harmony-utils"
import { StorageConstants } from "../const/StorageConstants"
import { preferencesUtils } from "../data/PreferencesUtils"
import { qpsController } from "./RequestQueue"

const TAG = '[Request]'
const baseUrl = AppStorage.get("base_url") as string ?? "https://1lib.sk"

let reqInst = axios.create({
  timeout: 15000
})

AppStorage.setOrCreate('cookie', {})

reqInst.interceptors.request.use(async (request: InternalAxiosRequestConfig) => {
  request.baseURL = baseUrl;
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
    const response = await reqInst.request(config) as ApiResponse<R>
    return response.data
  }
  
  public async get<R>(url: string, config?: AxiosRequestConfig): Promise<R> {
    const response = await reqInst.get(url, config) as ApiResponse<R>
    return response.data
  }

  public async post<R, D>(url: string, data?: D, config?: AxiosRequestConfig): Promise<R> {
    const response = await reqInst.post(url, data, config) as ApiResponse<R>
    return response.data
  }
}

const commonRequest = async<T>(config: AxiosRequestConfig): Promise<T> => {
  const response = await reqInst.request(config) as ApiResponse<T>
  return response.data
}

let ReqInst: Request = new Request()
export default ReqInst

export async function getCookie() {
  // todo: use cacheManager without expired time
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
    let GeneratedDestructArray_1 = cookie.split(';');
    let keyValue = GeneratedDestructArray_1[0]; // 提取键值部分（忽略过期时间等属性）

    let GeneratedDestructArray_2 = keyValue.split('=');
    let key = GeneratedDestructArray_2[0];
    let value = GeneratedDestructArray_2[1];

    curCookie[key.trim()] = value.trim()
  });

  await preferencesUtils.put(StorageConstants.DEFAULT_PREF, 'cookie', curCookie)
}