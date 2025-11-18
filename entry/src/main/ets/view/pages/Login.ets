import { AppStorageV2, PersistenceV2, prompt, promptAction, window } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { ToastUtil } from '@pura/harmony-utils';
import { StorageConstants } from '../../common/const/StorageConstants';
import { login } from '../../model/api/LoginApi';
import { AppState } from '../../model/entities/AppState';
import { preferencesUtils } from '../../model/storage/PreferencesUtils';

@Entry
@ComponentV2
struct Login {
  @Local username: string = '';
  @Local password: string = '';

  private async onLogin() {
    if (!this.username || !this.password) {
      hilog.info(0x000, 'libzidane', 'login_failed')
      ToastUtil.showToast("请输入账号和密码", {
        duration: 2000,
        showMode: promptAction.ToastShowMode.DEFAULT,
        bottom: 80
      });
      return;
    }
    // 实际开发中应替换为真实接口调用
    hilog.info(0x000, 'libzidane', 'login_go')
    let res = await login(this.username, this.password)
    PersistenceV2.connect(AppState, 'appState', () => new AppState())!.loginState = res
    //
    // preferencesUtils.put(StorageConstants.DEFAULT_PREF, "loginState", res)
    if (res) {
      this.getUIContext().getRouter().replaceUrl({ url: 'view/pages/Home' });
    }
  }

  build() {
    Column() {
      // 顶部LOGO区域
      Image($r('app.media.startIcon'))
        .width(120)
        .height(120)
        .margin({ top: 150, bottom: 30 })

      // 标题区域
      Text('用户登录')
        .fontSize(24)
        .fontColor('#182431')
        .margin({ bottom: 8 })

      // 输入区域
      TextInput({ placeholder: '请输入账号' })
        .width('90%')
        .height(45)
        .fontSize(16)
        .backgroundColor('#F0F2F4')
        .onChange(value => this.username = value)
        .margin({ bottom: 15 })

      TextInput({ placeholder: '请输入密码' })
        .width('90%')
        .height(45)
        .type(InputType.Password)
        .backgroundColor('#F0F2F4')
        .onChange(value => this.password = value)
        .margin({ bottom: 30 })

      // 登录按钮
      Button('立即登录')
        .width('90%')
        .height(45)
        .backgroundColor('#007DFF')
        .fontColor('#FFFFFF')
        .onClick(async () => await this.onLogin())
        .margin({ bottom: 20 })
    }
    .height('100%')
    .width('100%')
    .backgroundColor('#FFFFFF')
  }
}