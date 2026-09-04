import { HdsNavigationTitleBarOptions, HdsNavigationMenuItemOptions,
  TitleBarStyleOptions, SystemMaterialParams, hdsMaterial } from '@kit.UIDesignKit';

// Let the system choose the light-sense material quality for this device.
export const NAVIGATION_MATERIAL: SystemMaterialParams = {
  materialType: hdsMaterial.MaterialType.ADAPTIVE,
  materialLevel: hdsMaterial.MaterialLevel.ADAPTIVE
};
export const NAVIGATION_STYLE: TitleBarStyleOptions = {
  systemMaterialEffect: NAVIGATION_MATERIAL
};
// Scroll content can pass behind the floating tabs, then clear them at the end.
export const FLOATING_TAB_BAR_INSET: number = 80;

/** Preserve existing labels, icons and actions when using native HDS menus. */
export function hdsMenus(items: NavigationMenuItem[]): HdsNavigationMenuItemOptions[] {
  return items.map((item: NavigationMenuItem): HdsNavigationMenuItemOptions => ({
    content: { label: item.value, icon: item.icon, action: item.action, isEnabled: item.isEnabled }
  }));
}

/** Share native light-sense navigation and keep page controls below the title bar. */
export function destinationTitle(title: ResourceStr = '',
  menus: NavigationMenuItem[] = []): HdsNavigationTitleBarOptions {
  return {
    enableComponentSafeArea: true,
    style: NAVIGATION_STYLE,
    content: { title: { mainTitle: title }, menu: { value: hdsMenus(menus) } }
  };
}
