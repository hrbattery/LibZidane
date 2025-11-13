import { AppStorageV2, promptAction } from '@kit.ArkUI';
import { LogUtil as logger, ToastUtil } from '@pura/harmony-utils';
import { login } from '../../../api/LoginApi';
import { SettingsModel } from '../../../models/SettingsModel';

@Builder
export function SettingsLoginBuilder() {
  SettingsLogin()
}

@ComponentV2
export struct SettingsLogin {
  @Local username: string = '';
  @Local password: string = '';
  private pathStack: NavPathStack | undefined = undefined;

  private async onLogin() {
    if (!this.username || !this.password) {
      logger.error('login_failed: empty username or password')
      ToastUtil.showToast("请输入账号和密码", {
        duration: 2000,
        showMode: promptAction.ToastShowMode.DEFAULT,
        bottom: 80
      });
      return;
    }
    // 实际开发中应替换为真实接口调用
    logger.info('login_success.')
    let res = await login(this.username, this.password)
    AppStorageV2.connect(SettingsModel, "settingsModel", () => new SettingsModel())!.hasCookie = res
    if (res) {
      ToastUtil.showToast("登录成功", {
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

  build() {
    NavDestination() {
      Column() {
        TextInput({ placeholder: '请输入账号' })
          .width('90%')
          .height(45)
          .fontSize(16)
          .backgroundColor('#F0F2F4')
          .onChange(value => this.username = value)
          .margin({ top: 20, bottom: 20 })

        TextInput({ placeholder: '请输入密码' })
          .width('90%')
          .height(45)
          .type(InputType.Password)
          .backgroundColor('#F0F2F4')
          .onChange(value => this.password = value)
          .margin({ bottom: 20 })

        Flex({direction: FlexDirection.Row}) {
          // 登录按钮
          Button('登录')
            .loginButtonStyle()
            .margin({ right: 10 })
            .onClick(async () => await this.onLogin())

          Button('Cookie登录')
            .loginButtonStyle()
            .margin({ left: 10 })
            .onClick(() => this.onCookieLogin())
        }
        .width('90%')
        .margin({ bottom: 20 })
      }
      .height('100%')
      .width('100%')
      .backgroundColor(Color.White)
    }
    .title("登录")
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
    })
  }
}

@Extend(Button)
function loginButtonStyle() {
  // 登录按钮
  .width('100%')
  .height(45)
  .fontColor(Color.White)
}
