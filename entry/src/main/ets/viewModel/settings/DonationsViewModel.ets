import { LogUtil as logger } from '@pura/harmony-utils';

import { DonationDataSource } from "../../common/types/ResponseTypes";
import { getDonations, getProfile } from "../../model/api/UserApi";
import { NetworkRequestViewModel } from '../common/NetworkRequestViewModel';

@ObservedV2
export class DonationViewModel extends NetworkRequestViewModel {
  /**
   * history donation records
   */
  @Trace donationRecords: DonationDataSource[] = [];
  /**
   * current active donation amount
   */
  @Trace activeDonation: number | null = null;
  /**
   * donation expire time
   */
  @Trace donationExpire: string | null = null

  @Computed
  get activeDonationString() {
    if (this.activeDonation === null) {
      return "$0"
    } else {
      return `$${this.activeDonation}`
    }
  }

  @Computed
  get donationExpireDate() {
    if (this.donationExpire === null) {
      return "不存在"
    } else {
      return new Date(this.donationExpire).toLocaleDateString()
    }
  }

  async loadDonationRecords() {
    this.isLoading = true;
    try {
      let donations = await getDonations();
      this.isLoadFailed = false;
      this.isLoading = false;
      if (donations !== null) {
        this.donationRecords = donations;
      }
    } catch (e) {
      logger.error(e)
      this.isLoadFailed = true;
      this.isLoading = false;
    }
  }

  async loadDonationProfile() {
    this.isLoading = true;
    try {
      let profile = await getProfile();
      this.isLoadFailed = false;
      this.isLoading = false;
      if (profile !== null) {
        this.activeDonation = profile.donations_active;
        this.donationExpire = profile.donations_expire;
      }
    } catch (e) {
      logger.error(e)
      this.isLoadFailed = true;
      this.isLoading = false;
    }
  }
}