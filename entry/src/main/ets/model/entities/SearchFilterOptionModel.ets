/** Search values shared by the applied filters and each dialog's independent draft. */
@ObservedV2
export class SearchFilterOptions {
  @Trace exactMatch: boolean = false;
  @Trace startYear: string | undefined = undefined;
  @Trace endYear: string | undefined = undefined;
  @Trace selectedLanguages: string[] = [];
  @Trace selectedExtensions: string[] = [];

  /** Copy arrays as well as scalar values so dismissing a draft cannot change applied filters. */
  clone(): SearchFilterOptions {
    const copy = new SearchFilterOptions();
    copy.exactMatch = this.exactMatch;
    copy.startYear = this.startYear;
    copy.endYear = this.endYear;
    copy.selectedLanguages = Array.from(this.selectedLanguages);
    copy.selectedExtensions = Array.from(this.selectedExtensions);
    return copy;
  }

  /** Reset the current draft to an unrestricted search. */
  clear(): void {
    this.exactMatch = false;
    this.startYear = undefined;
    this.endYear = undefined;
    this.selectedLanguages = [];
    this.selectedExtensions = [];
  }

  /** Either endpoint may be unlimited; a bounded range must be chronological. */
  hasValidYearRange(): boolean {
    return this.startYear === undefined || this.endYear === undefined ||
      Number(this.startYear) <= Number(this.endYear);
  }
}
