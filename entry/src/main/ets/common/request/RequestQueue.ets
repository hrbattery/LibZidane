import { InternalAxiosRequestConfig } from '@ohos/axios'

interface qpsMapValue {
  count: number,
  ts: number
}

let qpsMap = new Map<string, qpsMapValue>()
export async function qpsController(config: InternalAxiosRequestConfig, QPS = 10, OFFSET = 500) {
  if (config.url) {
    const now = new Date().getTime()
    let qpsCacheValue = config.url && qpsMap.get(config.url) || {
      count: 1,
      ts: now
    }
    let count = qpsCacheValue.count;
    let ts = qpsCacheValue.ts;

    if (Math.floor(now / 1000) <= Math.floor(ts / 1000)) {
      if (count < QPS) {
        count++
      } else {
        ts = 1000 * (Math.floor(ts / 1000) + 1)
        count = 1
      }
    } else {
      ts = now
      count = 1
    }
    qpsMap.set(config.url, {
      count,
      ts
    })

    let sleep = ts - now
    sleep = sleep > 0 ? sleep + OFFSET : 0

    await new Promise<void>(resolve => setTimeout(() => resolve(), sleep))
  }
  return config
}