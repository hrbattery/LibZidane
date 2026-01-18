import { DonationViewModel } from '../../../viewModel/settings/DonationsViewModel'
import { i18n } from '@kit.LocalizationKit'
import { common } from '@kit.AbilityKit'
import { ToastUtil } from '@pura/harmony-utils'
import { preferencesUtils } from '../../../model/storage/PreferencesUtils'
import { StorageConstants } from '../../../common/const/StorageConstants'
import { Constants } from '../../../common/const/Constants'

@Builder
export function DonationBuilder() {
  Donation()
}


@Preview
@ComponentV2
struct Donation {
  @Local viewModel: DonationViewModel = new DonationViewModel()

  @Computed
  get navMenu(): NavigationMenuItem[] {
    return [
      {
        'value': $r("app.string.ui_donation_menu_donate"),
        'icon': $r("app.media.donation"),
        'action': () => this.openDonationPage()
      }
    ]
  }

  async aboutToAppear(): Promise<void> {
    await Promise.all([
      this.viewModel.loadDonationRecords(),
      this.viewModel.loadDonationProfile()
    ])
  }

  openDonationPage() {
    const activeApi = preferencesUtils.getSync<string>(
      StorageConstants.DEFAULT_PREF,
      StorageConstants.PREFKEY_CURRENT_ACTIVE_API,
      Constants.DEFAULT_ZLIB_DOMAIN
    )
    const donationUrl = `${activeApi}/how-to-donate`
    const context = this.getUIContext().getHostContext() as common.UIAbilityContext
    context.openLink(donationUrl, { appLinkingOnly: false })
      .catch(() => {
        ToastUtil.showToast(
          this.getUIContext().getHostContext()!.resourceManager.getStringSync(
            $r("app.string.notif_open_link_failed").id,
            donationUrl
          ), { duration: 2000 });
      });
  }

  build() {
    NavDestination() {
      Column() {
        Column() {
          InfoCard({
            title: $r("app.string.ui_donation_active_donations"),
            content: this.viewModel.activeDonationString
          })
          Divider()
            .margin({ left: 8, right: 8 })
            .color(Color.Gray)
          InfoCard({
            title: $r("app.string.ui_donation_expiration_date"),
            content: this.viewModel.donationExpireDate
          })
        }
        .backgroundColor($r("sys.color.comp_background_primary"))
        .margin(16)
        .borderRadius(20)

        if (this.viewModel.donationRecords.length > 0) {
          Column() {
            List() {
              Repeat(this.viewModel.donationRecords)
                .each(ri => {
                  InfoCard({
                    title: `$${ri.item.amount}`,
                    content: new Date(ri.item.date).toLocaleDateString(i18n.System.getAppPreferredLanguage())
                  })
                })
            }
            .divider({
              strokeWidth: "1px",
              color: $r("sys.color.font_tertiary"),
              startMargin: 8,
              endMargin: 8
            })
            .width("100%")
          }
          .backgroundColor($r("sys.color.comp_background_primary"))
          .margin({ left: 16, right: 16 })
          .borderRadius(20)
        } else {
          Text($r("app.string.ui_donation_no_records"))
        }
      }
      .backgroundColor($r("sys.color.background_secondary"))
      .height("100%")
      .width("100%")
    }
    .title($r("app.string.ui_setting_account_donation"))
    .menus(this.navMenu)
  }
}

@ComponentV2
struct InfoCard {
  @Param @Require title: ResourceStr;
  @Param @Require content: ResourceStr

  build() {
    Row({ space: 10 }) {
      Text(this.title)
        .fontSize(16)
        .textAlign(TextAlign.Start)
        .fontWeight(FontWeight.Bold)
        .layoutWeight(1)
      Text(this.content)
        .fontSize(16)
        .textAlign(TextAlign.End)
        .fontWeight(FontWeight.Regular)
        .layoutWeight(1)
    }
    .backgroundColor(Color.Transparent)
    .width('100%')
    .padding({
      left: 10,
      right: 10,
      top: 15,
      bottom: 15
    })
  }
}