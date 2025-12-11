import { Context } from '@kit.AbilityKit'
import { preferences } from '@kit.ArkData'
import { LogUtil as logger } from '@pura/harmony-utils'

class PreferencesUtils {
  private preferencesMap: Map<string, preferences.Preferences> = new Map()

  // 加载首选项表
  async loadPreference(context: Context, field: string) {
    try {
      const preference = await preferences.getPreferences(context, field)
      this.preferencesMap.set(field, preference)
    } catch (e) {
      logger.error(`Load Preference ${field} Failed: ${JSON.stringify(e)}`)
      throw new Error(`Load Preference ${field} Failed: ${JSON.stringify(e)}`)
    }
  }

  loadPreferenceSync(context: Context, field: string) {
    try {
      const preference = preferences.getPreferencesSync(context, {
        name: field
      })
      this.preferencesMap.set(field, preference)
    } catch (e) {
      logger.error(`Load Preference ${field} Failed: ${JSON.stringify(e)}`)
      throw new Error(`Load Preference ${field} Failed: ${JSON.stringify(e)}`)
    }
  }

  // 新增数据
  async put(field: string, key: string, value: preferences.ValueType) {
    if (!this.preferencesMap.has(field)) {
      logger.error(`Preference ${field} has not been initialized yet.`)
      return
    }
    try {
      const preference = this.preferencesMap.get(field)
      await preference?.put(key, value)
      await preference?.flush()
    } catch (e) {
      logger.error(`Put Preference ${field} failed: ${JSON.stringify(e)}`)
    }
  }

  putSync(field: string, key: string, value: preferences.ValueType) {
    if (!this.preferencesMap.has(field)) {
      logger.error(`Preference ${field} has not been initialized yet.`)
      return
    }
    try {
      const preference = this.preferencesMap.get(field)
      preference?.putSync(key, value)
      preference?.flushSync()
    } catch (e) {
      logger.error(`Put Preference ${field} failed: ${JSON.stringify(e)}`)
    }
  }

  // 读取数据
  async get<T extends preferences.ValueType>(field: string, key: string, defaultValue: T): Promise<T> {
    if (!this.preferencesMap.has(field)) {
      logger.error(`Preference ${field} has not been initialized yet.`)
      return defaultValue
    }
    try {
      const preference = this.preferencesMap.get(field)
      const value = await preference?.get(key, defaultValue)
      return value as T;
    } catch (e) {
      logger.error(`Get Preference ${field} failed: ${JSON.stringify(e)}`)
      throw new Error(`Can not get Preference ${field}.${key}`)
    }
  }

  getSync<T extends preferences.ValueType>(field: string, key: string, defaultValue: T): T {
    if (!this.preferencesMap.has(field)) {
      logger.error(`Preference ${field} has not been initialized yet.`)
      return defaultValue
    }
    try {
      const preference = this.preferencesMap.get(field)
      const value = preference?.getSync(key, defaultValue)
      return value as T;
    } catch (e) {
      logger.error(`Get Preference ${field} failed: ${JSON.stringify(e)}`)
      throw new Error(`Can not get Preference ${field}.${key}`)
    }
  }

  // 删除数据
  async delete(field: string, key: string) {
    if (!this.preferencesMap.has(field)) {
      logger.error(`Preference ${field} has not been initialized yet.`)
      return
    }
    try {
      const preference = this.preferencesMap.get(field)
      await preference?.delete(key)
      await preference?.flush()
    } catch (e) {
      logger.error(`Delete Preference ${field} Failed: ${JSON.stringify(e)}`)
    }
  }

  deleteSync(field: string, key: string) {
    if (!this.preferencesMap.has(field)) {
      logger.error(`Preference ${field} has not been initialized yet.`)
      return
    }
    try {
      const preference = this.preferencesMap.get(field)
      preference?.deleteSync(key)
      preference?.flushSync()
    } catch (e) {
      logger.error(`Delete Preference ${field} Failed: ${JSON.stringify(e)}`)
    }
  }

  // 判断 Preference 中是否存在指定的 key
  async has(field: string, key: string): Promise<boolean> {
    if (!this.preferencesMap.has(field)) {
      logger.error(`Preference ${field} has not been initialized yet.`)
      return false
    }
    try {
      const preference = this.preferencesMap.get(field)
      const value = await preference?.get(key, undefined)
      return value !== undefined
    } catch (e) {
      logger.error(`Determine whether Preference ${field} exists failed: ${JSON.stringify(e)}`)
      return false
    }
  }

  hasSync(field: string, key: string): boolean {
    if (!this.preferencesMap.has(field)) {
      logger.error(`Preference ${field} has not been initialized yet.`)
      return false
    }
    try {
      const preference = this.preferencesMap.get(field)
      const value = preference?.getSync(key, undefined)
      return value !== undefined
    } catch (e) {
      logger.error(`Determine whether Preference ${field} exists failed: ${JSON.stringify(e)}`)
      return false
    }
  }

  // 精确监听 Preference 中对应 field 和 key 的变动
  on(field: string, keys: string[], cbs: Callback<Record<string, preferences.ValueType>>) {
    if (!this.preferencesMap.has(field)) {
      logger.error(`Preference ${field} has not been initialized yet.`)
      return
    }
    try {
      const preference = this.preferencesMap.get(field)
      preference?.on('dataChange', keys, cbs)
    } catch (e) {
      logger.error(`Listening Preference ${field} failed: ${JSON.stringify(e)}`)
      return
    }
  }

  // 取消监听 Preference 中对应 field 和 key 的变动
  off(field: string, keys: string[], cbs?: Callback<Record<string, preferences.ValueType>>) {
    if (!this.preferencesMap.has(field)) {
      logger.error(`Preference ${field} has not been initialized yet.`)
      return
    }
    try {
      const preference = this.preferencesMap.get(field)
      preference?.off('dataChange', keys, cbs)
    } catch (e) {
      logger.error(`Cancel listening Preference ${field} failed: ${JSON.stringify(e)}`)
      return
    }
  }
}

export const preferencesUtils: PreferencesUtils = new PreferencesUtils()
