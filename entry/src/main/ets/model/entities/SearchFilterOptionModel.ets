import { Command } from "../../common/types/CommonTypes";

@ObservedV2
export class SearchFilterOptions {
  @Trace exactMatch: boolean = false;
  @Trace startYear: string | undefined = undefined;
  @Trace endYear: string | undefined = undefined;
  @Trace selectedLanguages: string[] = [];
  @Trace selectedExtensions: string[] = [];

  private commands = Array<Command>(5)

  setExactMatchCmd(value: boolean) {
    this.commands[0] = () => {
      this.exactMatch = value;
    }
  }

  setStartYearCmd(value: string | undefined) {
    this.commands[1] = () => {
      this.startYear = value;
    }
  }

  setEndYearCmd(value: string | undefined) {
    this.commands[2] = () => {
      this.endYear = value;
    }
  }

  setSelectedLanguagesCmd(value: string[]) {
    this.commands[3] = () => {
      this.selectedLanguages = Array.from(value);
    }
  }

  setSelectedExtensionsCmd(value: string[]) {
    this.commands[4] = () => {
      this.selectedExtensions = Array.from(value);
    }
  }

  apply() {
    for (const cmd of this.commands) {
      if (cmd) {
        cmd()
      }
    }
  }
}
