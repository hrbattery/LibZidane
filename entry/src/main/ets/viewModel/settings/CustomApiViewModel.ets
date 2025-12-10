@ObservedV2
export class CustomApiViewModel {
  /**
   * Current used custom API list
   */
  @Trace customApis: string[] = ["test", "test2"]

  /**
   * keyword used to add to custom API list
   */
  @Trace newApi: string = ""

  removeApi(index: number) {
    this.customApis.splice(index, 1);
  }

  addApi() {
    this.customApis.push(this.newApi);
    this.newApi = "";
  }
}