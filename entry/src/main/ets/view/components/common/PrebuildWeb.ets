import { BuilderNode, FrameNode, NodeController, Size, UIContext } from '@kit.ArkUI';
import { webview } from '@kit.ArkWeb';

// Data为入参封装类。
export class PrebuildWebCompData {
  url: string = '';
  controller: WebviewController = new webview.WebviewController();
  shouldInactive: boolean = true;
}

// 用于控制和反馈对应的NodeContainer上的节点的行为，需要与NodeContainer一起使用。
export class prebuildWebCompController extends NodeController {
  private shouldInactive: boolean = true; // 通过布尔变量shouldInactive控制网页在后台完成预渲染后停止渲染。
  private rootnode: BuilderNode<PrebuildWebCompData[]> | null = null;

  // 必须要重写的方法，用于构建节点数、返回节点挂载在对应NodeContainer中。
  // 在对应NodeContainer创建的时候调用、或者通过rebuild方法调用刷新。
  makeNode(uiContext: UIContext): FrameNode | null {
    // 返回null控制动态组件脱离绑定节点。
    return this.rootnode != null ? this.rootnode.getFrameNode() :null;
  }

  // 当controller对应的NodeContainer在Appear的时候进行回调。
  aboutToAppear() {
    this.shouldInactive = false;
  }

  dispose() {
    if (this.rootnode != null) {
      this.rootnode.dispose();
    }
  }

  // 此函数为自定义函数，可作为初始化函数使用。
  // 通过UIContext初始化BuilderNode，再通过BuilderNode中的build接口初始化@Builder中的内容。
  initWeb(wrap: WrappedBuilder<PrebuildWebCompData[]>, url: string, uiContext: UIContext, control: WebviewController) {
    if (this.rootnode != null) {
      return;
    }
    // 创建节点，需要uiContext。
    this.rootnode = new BuilderNode(uiContext);
    // 创建动态Web组件。
    this.rootnode.build(wrap, { url: url, controller: control, shouldInactive: this.shouldInactive });
  }
}

let NodeMap: Map<string, prebuildWebCompController | undefined> = new Map();
let controllerMap: Map<string, WebviewController | undefined> = new Map();

// 初始化需要UIContext 需在Ability获取。
export function createNWeb(builder: WrappedBuilder<PrebuildWebCompData[]>, url: string, uiContext: UIContext) {
  // 创建NodeController。
  let baseNode = new prebuildWebCompController();
  let controller = new webview.WebviewController();

  // 初始化自定义Web组件。
  baseNode.initWeb(builder, url, uiContext, controller);
  controllerMap.set(url, controller);
  NodeMap.set(url, baseNode);
}

// 自定义获取NodeController接口。
export function getNWeb(url: string): prebuildWebCompController | undefined {
  return NodeMap.get(url);
}

export function getNWebController(url: string): webview.WebviewController | undefined {
  return controllerMap.get(url);
}

export function disposeNWeb(url: string) {
  NodeMap.get(url)?.dispose();
  NodeMap.delete(url);
  controllerMap.delete(url);
}