import { AppStorageV2, UIContext, window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';

import { LogUtil as logger } from "@pura/harmony-utils"

const TAG = "[WindowInfo] "
export class WindowUtil {
  public uiContext?: UIContext;
  public mainWindow?: window.Window;
  // public mainWindowInfo: WindowInfo = new WindowInfo();
  public mainWindowInfo: WindowInfo = AppStorageV2.connect(WindowInfo, "mainWindowInfo", () => new WindowInfo())!

  init(mainWindow: window.Window) {
    this.mainWindow = mainWindow;
    try {
      this.uiContext = mainWindow.getUIContext();
    } catch (error) {
      let err = error as BusinessError;
      logger.error(TAG, `Failed to set UI context. Code: ${err.code}, message: ${err.message}`)
    }
    this.initWindowInfo();
    this.initWindowListeners();
  }

  /**
   * Register for window size change monitoring, update window size and width/height breakpoint.
   */
  private initWindowListeners(): void {
    try {
      this.mainWindow?.on('windowStatusChange', (statusType: window.WindowStatusType) => {
        this.mainWindowInfo.windowStatusType = statusType;
      });
      this.mainWindow?.on('windowSizeChange', (windowSize: window.Size) => {
        this.mainWindowInfo.windowSize = windowSize;
        this.mainWindowInfo.widthBp = this.uiContext!.getWindowWidthBreakpoint();
        this.mainWindowInfo.heightBp = this.uiContext!.getWindowHeightBreakpoint();
      });
    } catch (error) {
      let err = error as BusinessError;
      logger.error(TAG, `Failed to update window info. Code: ${err.code}, message: ${err.message}`);
    }
  }

  /**
   * Init necessary window infos.
   */
  private initWindowInfo() {
    try {
      this.mainWindowInfo.windowStatusType = this.mainWindow!.getWindowStatus();

      // First time get window size.
      this.mainWindowInfo.windowSize = {
        width: this.mainWindow!.getWindowProperties().windowRect.width,
        height: this.mainWindow!.getWindowProperties().windowRect.height
      };

      // First time get width/height breakpoint.
      this.mainWindowInfo.widthBp = this.uiContext!.getWindowWidthBreakpoint();
      this.mainWindowInfo.heightBp = this.uiContext!.getWindowHeightBreakpoint();
    } catch (error) {
      let err = error as BusinessError;
      logger.error(TAG, `Failed to update window info. Code: ${err.code}, message: ${err.message}`);
    }
  }

  cancelListeners(): void {
    try {
      this.mainWindow?.off('windowStatusChange');
      this.mainWindow?.off('windowSizeChange');
    } catch (error) {
      let err = error as BusinessError;
      logger.error(TAG, `Failed to off. Code: ${err.code}, message: ${err.message}`);
    }
  }
}

@ObservedV2
export class WindowInfo {
  // Window status.
  @Trace public windowStatusType: window.WindowStatusType = window.WindowStatusType.UNDEFINED;

  // Window orientation.
  @Trace public orientation: window.Orientation = window.Orientation.UNSPECIFIED;

  // Window size.
  @Trace public windowSize: window.Size = { width: 0, height: 0 };

  // Width/height breakpoint.
  @Trace public widthBp: WidthBreakpoint = WidthBreakpoint.WIDTH_XS;
  @Trace public heightBp: HeightBreakpoint = HeightBreakpoint.HEIGHT_SM;
}

export const windowUtil: WindowUtil = new WindowUtil()
