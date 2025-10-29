import { Any } from "@pura/harmony-utils";

interface CacheItem<T> {
  data: T;
  expireTime: number;
}

export class CacheManager<T> {
  private cacheName: string
  private cacheMap: SubscribedAbstractProperty<Map<string, CacheItem<T>>>;
  
  constructor(cacheName: string) {
    this.cacheName = `_${cacheName}_cacheMap`
    // 初始化缓存容器
    this.cacheMap = AppStorage.setAndLink(this.cacheName, new Map());
  }


  // 设置缓存（带过期时间）
  setCache(key: string, value: T, expireSeconds: number = 300) {
    const expireTime = Date.now() + expireSeconds * 1000;
    this.cacheMap.get().set(key, { data: value, expireTime })
  }

  // 获取有效缓存
  getCache(key: string): T | null {
    const item = this.cacheMap.get().get(key);

    if (!item || Date.now() > item.expireTime) {
      this.cacheMap.get().delete(key);
      return null;
    }
    return item.data;
  }

  // 清理过期缓存
  clearExpired() {
    const now = Date.now();

    this.cacheMap.get().forEach((value, key) => {
      if (now > value.expireTime) {
        this.cacheMap.get().delete(key);
      }
    });
  }
}