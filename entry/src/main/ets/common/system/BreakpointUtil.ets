export class WidthBreakpointType<T> {
  sm: T;
  md: T;
  lg: T;
  xl: T;

  constructor(sm: T, md: T, lg: T, xl: T) {
    this.sm = sm;
    this.md = md;
    this.lg = lg;
    this.xl = xl
  }

  getValue(widthBp: WidthBreakpoint): T {
    if (widthBp === WidthBreakpoint.WIDTH_XS || widthBp === WidthBreakpoint.WIDTH_SM) {
      return this.sm;
    }
    if (widthBp === WidthBreakpoint.WIDTH_MD) {
      return this.md;
    }
    if (widthBp === WidthBreakpoint.WIDTH_LG) {
      return this.lg;
    } else {
      return this.xl;
    }
  }
}