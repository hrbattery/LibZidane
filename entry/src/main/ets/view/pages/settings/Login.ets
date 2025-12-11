import { PersistenceV2, promptAction } from '@kit.ArkUI';
import { LogUtil as logger, ToastUtil } from '@pura/harmony-utils';
import { login } from '../../../model/api/LoginApi';
import { AppState } from '../../../model/entities/AppState';

@Builder
export function SettingsLoginBuilder() {
  SettingLoginNav()
}

@Builder
function SettingLoginNav() {
  NavDestination() {
    SettingsLogin()
  }
  .title($r("app.string.ui_login_title"))
}

@ComponentV2
export struct SettingsLogin {
  @Local username: string = '';
  @Local password: string = '';
  private pathStack: NavPathStack | undefined = undefined;

  private async onLogin() {
    if (!this.username || !this.password) {
      logger.error('login_failed: empty username or password')
      ToastUtil.showToast($r("app.string.notif_login_empty_input"), {
        duration: 2000,
        showMode: promptAction.ToastShowMode.DEFAULT,
        bottom: 80
      });
      return;
    }
    // 实际开发中应替换为真实接口调用
    let res = await login(this.username, this.password)
    PersistenceV2.connect(AppState, "appState", () => new AppState())!.loginState = res
    if (res) {
      ToastUtil.showToast($r("app.string.notif_login_success"), {
        duration: 2000,
        showMode: promptAction.ToastShowMode.DEFAULT,
        bottom: 80
      });
      this.pathStack?.pop(true)
    }
  }

  private onCookieLogin() {
    this.pathStack?.pushPathByName("Settings_CookieLogin", null)
  }

  aboutToAppear(): void {
    this.pathStack = this.queryNavigationInfo()?.pathStack;
  }

  build() {
    Column() {
      TextInput({ placeholder: $r("app.string.ui_login_account_placeholder") })
        .width('90%')
        .height(45)
        .fontSize(16)
        .onChange(value => this.username = value)
        .margin({ top: 20, bottom: 20 })

      TextInput({ placeholder: $r("app.string.ui_login_password_placeholder") })
        .width('90%')
        .height(45)
        .type(InputType.Password)
        .onChange(value => this.password = value)
        .margin({ bottom: 20 })

      Flex({ direction: FlexDirection.Row }) {
        // 登录按钮
        Button($r("app.string.ui_login_btn"))
          .loginButtonStyle()
          .margin({ right: 10 })
          .onClick(async () => await this.onLogin())

        Button($r("app.string.ui_cookie_login"))
          .loginButtonStyle()
          .margin({ left: 10 })
          .onClick(() => this.onCookieLogin())
      }
      .width('90%')
      .margin({ bottom: 20 })
    }
    .height('100%')
    .width('100%')
  }
}

@Extend(Button)
function loginButtonStyle() {
  .width('100%')
  .height(45)
}
