import { AppStorageV2, UIContext, window } from '@kit.ArkUI';
import { BusinessError, deviceInfo } from '@kit.BasicServicesKit';

import { LogUtil as logger } from "@pura/harmony-utils"

const TAG = "[WindowInfo] "
export class WindowUtil {
  public uiContext?: UIContext;
  public mainWindow?: window.Window;
  // public mainWindowInfo: WindowInfo = new WindowInfo();
  public mainWindowInfo: WindowInfo = AppStorageV2.connect(WindowInfo, "mainWindowInfo", () => new WindowInfo())!

  /** Initialize the window and keep system bars transparent over the page background. */
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
    this.updateSystemBars();
  }

  /** Match system-bar icons to the current app theme without moving controls into safe areas. */
  updateSystemBars(): void {
    const resources = this.uiContext?.getHostContext()?.resourceManager;
    if (!this.mainWindow || !resources || deviceInfo.deviceType === '2in1') {
      return;
    }
    try {
      const foreground = resources.getColorSync($r('sys.color.font_primary').id);
      const contentColor = '#' + (foreground >>> 0).toString(16).padStart(8, '0');
      // The window API accepts ARGB strings rather than ResourceColor values.
      const background = resources.getColorSync($r('app.color.system_bar_background').id);
      const backgroundColor = '#' + (background >>> 0).toString(16).padStart(8, '0');
      this.mainWindow.setWindowSystemBarProperties({
        statusBarColor: backgroundColor,
        navigationBarColor: backgroundColor,
        statusBarContentColor: contentColor,
        navigationBarContentColor: contentColor
      }).catch((error: BusinessError) => {
        logger.error(TAG, `Failed to update system bars. Code: ${error.code}, message: ${error.message}`);
      });
    } catch (error) {
      const err = error as BusinessError;
      logger.error(TAG, `Failed to read system-bar appearance. Code: ${err.code}, message: ${err.message}`);
    }
  }

  /**
   * Register for window size change monitoring, update window size and width/height breakpoint.
   */
  private initWindowListeners(): void {
    try {
      this.mainWindow?.on('avoidAreaChange', (options: window.AvoidAreaOptions) => {
        if (options.type === window.AvoidAreaType.TYPE_SYSTEM ||
          options.type === window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR) {
          this.updateBottomInset();
        }
      });
      this.mainWindow?.on('windowStatusChange', (statusType: window.WindowStatusType) => {
        this.mainWindowInfo.windowStatusType = statusType;
      });
      this.mainWindow?.on('windowSizeChange', (windowSize: window.Size) => {
        this.mainWindowInfo.windowSize = windowSize;
        this.mainWindowInfo.widthBp = this.uiContext!.getWindowWidthBreakpoint();
        this.mainWindowInfo.heightBp = this.uiContext!.getWindowHeightBreakpoint();
        this.updateBottomInset();
      });
    } catch (error) {
      let err = error as BusinessError;
      logger.error(TAG, `Failed to update window info. Code: ${err.code}, message: ${err.message}`);
    }
  }

  /** Reserve only the system gesture/bar height for floating controls, not for scroll content. */
  private updateBottomInset(): void {
    if (!this.mainWindow || !this.uiContext) {
      return;
    }
    try {
      const system = this.mainWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
      const indicator = this.mainWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
      this.mainWindowInfo.bottomInset = this.uiContext.px2vp(
        Math.max(system.bottomRect.height, indicator.bottomRect.height));
    } catch (error) {
      const err = error as BusinessError;
      logger.error(TAG, `Failed to read bottom safe area. Code: ${err.code}, message: ${err.message}`);
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
      this.updateBottomInset();
    } catch (error) {
      let err = error as BusinessError;
      logger.error(TAG, `Failed to update window info. Code: ${err.code}, message: ${err.message}`);
    }
  }

  cancelListeners(): void {
    try {
      this.mainWindow?.off('windowStatusChange');
      this.mainWindow?.off('windowSizeChange');
      this.mainWindow?.off('avoidAreaChange');
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

  // Bottom system bar or gesture area in vp; content can render beneath it.
  @Trace public bottomInset: number = 0;

  // Width/height breakpoint.
  @Trace public widthBp: WidthBreakpoint = WidthBreakpoint.WIDTH_XS;
  @Trace public heightBp: HeightBreakpoint = HeightBreakpoint.HEIGHT_SM;
}

export const windowUtil: WindowUtil = new WindowUtil()
