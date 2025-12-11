export class SettingsConstants {
  /**
   * DARK_MODE
   * 深色模式设置项
   */
  static readonly DARK_MODE: ResourceStr[] = [
    $r("app.string.ui_setting_general_dark_mode_light"),
    $r("app.string.ui_setting_general_dark_mode_dark"),
    $r("app.string.ui_setting_general_dark_mode_auto")]
  /**
   * LANGUAGE
   * 语言设置项
   */
  static readonly LANGUAGE: string[] = ["中文", "English"]
}

export enum DarkModeEnum {
  LIGHT = 0,
  DARK = 1,
  AUTO = 2
}