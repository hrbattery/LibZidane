import { LogUtil as logger } from '@pura/harmony-utils';

import { DonationDataSource } from "../../common/types/ResponseTypes";
import { getDonations, getProfile } from "../../model/api/UserApi";

@ObservedV2
export class DonationViewModel {
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
  /**
   * state to determine show skeleton or not
   */
  @Trace isLoading: boolean = true
  /**
   * state to determine show error placeholder or empty placeholder
   */
  @Trace isLoadFailed: boolean = false

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