import { LogUtil as logger } from "@pura/harmony-utils"

import { getRecommended } from "../../model/api/UserApi";
import { CoverData } from "../../model/entities/BookModel";
import { LibraryComponentViewModel } from "./LibraryComponentViewModel";

@ObservedV2
export class RecommendedViewModel extends LibraryComponentViewModel{
  private async loadRecommendedDataSource() {
    this.isLoading = true;
    try {
      let recommends = await getRecommended();
      this.isLoadFailed = false;
      this.isLoading = false;
      return recommends.map(element => {
        return new CoverData(
          element.id,
          element.hash,
          element.title,
          element.author,
          element.cover
        )
      })
    } catch (e) {
      logger.error(e)
      this.isLoadFailed = true;
      this.isLoading = false;
    }
    return []
  }

  async loadDataSource(): Promise<void> {
    this.coverDataSource = await this.loadRecommendedDataSource()
  }
}