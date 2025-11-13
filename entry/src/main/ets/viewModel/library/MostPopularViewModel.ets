import { LogUtil as logger } from "@pura/harmony-utils"
import { getMostPopular } from "../../model/api/BookApi";

import { CoverData } from "../../model/entities/BookModel";
import { LibraryComponentViewModel } from "./LibraryComponentViewModel";

@ObservedV2
export class MostPopularViewModel extends LibraryComponentViewModel{
  private async loadMostPopularDataSource() {
    this.isLoading = true;
    try {
      let mostPopulars = await getMostPopular();
      this.isLoadFailed = false;
      this.isLoading = false;
      return mostPopulars.map(element => {
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
    this.coverDataSource = await this.loadMostPopularDataSource()
  }
}