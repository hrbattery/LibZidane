/**
 * API 域名验证和标准化工具
 */
import { url } from '@kit.ArkTS';

/**
 * 域名验证选项接口
 */
export interface DomainValidationOptions {
  /**
   * 是否允许 HTTP（不安全的协议）
   * @default false
   */
  allowHttp?: boolean;

  /**
   * 是否允许 IP 地址作为域名
   * @default true
   */
  allowIp?: boolean;

  /**
   * 是否允许本地主机（localhost、127.0.0.1等）
   * @default false
   */
  allowLocalhost?: boolean;

  /**
   * 是否允许端口号
   * @default true
   */
  allowPort?: boolean;

  /**
   * 是否允许路径
   * @default true
   */
  allowPath?: boolean;

  /**
   * 是否允许查询参数
   * @default false
   */
  allowQuery?: boolean;

  /**
   * 默认协议（当没有协议时自动添加）
   * @default 'https'
   */
  defaultProtocol?: 'http' | 'https';

  /**
   * 是否强制小写
   * @default true
   */
  forceLowercase?: boolean;

  /**
   * 是否移除尾部斜杠
   * @default true
   */
  removeTrailingSlash?: boolean;

  /**
   * 是否移除默认端口（如:443、:80）
   * @default true
   */
  removeDefaultPort?: boolean;

  /**
   * 允许的顶级域名列表（如 ['com', 'cn', 'net', 'org']）
   * 为空数组则不限制
   * @default []
   */
  allowedTlds?: string[];
}

/**
 * 验证结果接口
 */
export interface ValidationResult {
  isValid: boolean;
  normalizedUrl?: string;
  error?: string;
  protocol?: string;
  hostname?: string;
  port?: string;
  path?: string;
  query?: string;
  hash?: string;
}

/**
 * 默认验证选项
 */
const DEFAULT_OPTIONS: DomainValidationOptions = {
  allowHttp: true,
  allowIp: true,
  allowLocalhost: false,
  allowPort: true,
  allowPath: true,
  allowQuery: false,
  defaultProtocol: 'https',
  forceLowercase: true,
  removeTrailingSlash: true,
  removeDefaultPort: true,
  allowedTlds: []
};

/**
 * 检查 API 域名是否合法
 * @param _url 要检查的 URL 字符串
 * @param options 验证选项
 * @returns 验证结果
 */
export function validateApiDomain(
  _url: string,
  options: DomainValidationOptions = {}
): ValidationResult {
  const opts: DomainValidationOptions = {
    allowHttp: options.allowHttp ?? DEFAULT_OPTIONS.allowHttp,
    allowIp: options.allowIp ?? DEFAULT_OPTIONS.allowIp,
    allowLocalhost: options.allowLocalhost ?? DEFAULT_OPTIONS.allowLocalhost,
    allowPort: options.allowPort ?? DEFAULT_OPTIONS.allowPort,
    allowPath: options.allowPath ?? DEFAULT_OPTIONS.allowPath,
    allowQuery: options.allowQuery ?? DEFAULT_OPTIONS.allowQuery,
    defaultProtocol: options.defaultProtocol ?? DEFAULT_OPTIONS.defaultProtocol,
    forceLowercase: options.forceLowercase ?? DEFAULT_OPTIONS.forceLowercase,
    removeTrailingSlash: options.removeTrailingSlash ?? DEFAULT_OPTIONS.removeTrailingSlash,
    removeDefaultPort: options.removeDefaultPort ?? DEFAULT_OPTIONS.removeDefaultPort,
    allowedTlds: options.allowedTlds ?? DEFAULT_OPTIONS.allowedTlds,
  };

  // 基本检查
  if (!_url || typeof _url !== 'string') {
    return {
      isValid: false,
      error: 'URL 必须是字符串'
    };
  }

  _url = _url.trim();
  if (!_url) {
    return {
      isValid: false,
      error: 'URL 不能为空'
    };
  }

  let normalizedUrl = _url;

  // 1. 处理协议
  if (!/^https?:\/\//i.test(normalizedUrl)) {
    normalizedUrl = `${opts.defaultProtocol}://${normalizedUrl}`;
  }

  // 2. 尝试解析 URL
  let parsedUrl: url.URL;
  try {
    parsedUrl = url.URL.parseURL(normalizedUrl)
  } catch (error) {
    return {
      isValid: false,
      error: `无效的 URL 格式: ${error instanceof Error ? error.message : String(error)}`
    };
  }

  // 3. 协议验证
  const protocol = parsedUrl.protocol.replace(':', '');
  if (protocol !== 'http' && protocol !== 'https') {
    return {
      isValid: false,
      error: `不支持的协议: ${protocol}`
    };
  }

  if (!opts.allowHttp && protocol === 'http') {
    return {
      isValid: false,
      error: 'HTTP 协议不安全，请使用 HTTPS'
    };
  }

  // 4. 主机名验证
  const hostname = parsedUrl.hostname;

  // 检查是否为空
  if (!hostname) {
    return {
      isValid: false,
      error: '域名不能为空'
    };
  }

  // 检查 localhost
  if (!opts.allowLocalhost) {
    const localhostPatterns = [
      'localhost',
      '127.0.0.1',
      '::1',
      '0.0.0.0',
      '[::]'
    ];
    if (localhostPatterns.includes(hostname.toLowerCase())) {
      return {
        isValid: false,
        error: '不允许使用本地主机地址'
      };
    }
  }

  // 检查 IP 地址
  if (!opts.allowIp) {
    const ipv4Pattern = /^(\d{1,3}\.){3}\d{1,3}$/;
    const ipv6Pattern = /^\[.*\]$/;
    if (ipv4Pattern.test(hostname) || ipv6Pattern.test(hostname)) {
      return {
        isValid: false,
        error: '不允许使用 IP 地址作为域名'
      };
    }
  }

  // 5. 域名格式验证
  if (!opts.allowIp) {
    // 验证域名格式（非IP地址）
    const domainPattern = /^(?!:\/\/)([a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}$/i;
    if (!domainPattern.test(hostname)) {
      return {
        isValid: false,
        error: '无效的域名格式'
      };
    }
  }

  // 6. 顶级域名验证
  if (opts.allowedTlds && opts.allowedTlds.length > 0) {
    const tld = hostname.split('.').pop()?.toLowerCase();
    if (tld && !opts.allowedTlds.map(t => t.toLowerCase()).includes(tld)) {
      return {
        isValid: false,
        error: `不允许的顶级域名: ${tld}。允许的顶级域名: ${opts.allowedTlds.join(', ')}`
      };
    }
  }

  // 7. 端口验证
  const port = parsedUrl.port;
  if (!opts.allowPort && port) {
    return {
      isValid: false,
      error: '不允许指定端口号'
    };
  }

  // 验证端口范围
  if (port) {
    const portNum = parseInt(port, 10);
    if (isNaN(portNum) || portNum < 1 || portNum > 65535) {
      return {
        isValid: false,
        error: `无效的端口号: ${port}`
      };
    }
  }

  // 8. 路径验证
  const path = parsedUrl.pathname;
  if (!opts.allowPath && path !== '/') {
    return {
      isValid: false,
      error: '不允许指定路径'
    };
  }

  // 9. 查询参数验证
  const query = parsedUrl.search;
  if (!opts.allowQuery && query) {
    return {
      isValid: false,
      error: '不允许查询参数'
    };
  }

  // 10. 标准化处理
  let finalUrl = normalizedUrl;

  // 强制小写
  if (opts.forceLowercase) {
    finalUrl = finalUrl.toLowerCase();
    parsedUrl = url.URL.parseURL(finalUrl);
  }

  // 移除默认端口
  if (opts.removeDefaultPort) {
    if ((protocol === 'https' && port === '443') ||
      (protocol === 'http' && port === '80')) {
      parsedUrl.port = '';
    }
  }

  // 构建最终 URL
  finalUrl = parsedUrl.toString();

  // 如果路径为空，确保至少有一个斜杠
  if (parsedUrl.pathname === '') {
    finalUrl += '/';
  }

  // 移除尾部斜杠
  if (opts.removeTrailingSlash) {
    if (finalUrl.endsWith('/')) {
      finalUrl = finalUrl.slice(0, -1);
    }
  } else {
    if (!finalUrl.endsWith('/')) {
      finalUrl += '/';
    }
  }

  // 返回结果
  return {
    isValid: true,
    normalizedUrl: finalUrl,
    protocol,
    hostname: parsedUrl.hostname,
    port: parsedUrl.port || '',
    path: parsedUrl.pathname,
    query: parsedUrl.search,
    hash: parsedUrl.hash
  };
}

/**
 * 仅验证 API 域名是否合法（不返回标准化结果）
 * @param url 要检查的 URL 字符串
 * @param options 验证选项
 * @returns 是否合法
 */
export function isValidApiDomain(
  url: string,
  options: DomainValidationOptions = {}
): boolean {
  return validateApiDomain(url, options).isValid;
}

/**
 * 标准化 API 域名
 * @param url 要标准化的 URL 字符串
 * @param options 标准化选项
 * @returns 标准化后的 URL，如果无效则抛出错误
 */
export function normalizeApiDomain(
  url: string,
  options: DomainValidationOptions = {}
): string {
  const result = validateApiDomain(url, options);
  if (!result.isValid) {
    throw new Error(`无效的 API 域名: ${result.error}`);
  }
  return result.normalizedUrl!;
}

/**
 * 批量验证 API 域名
 * @param urls URL 字符串数组
 * @param options 验证选项
 * @returns 验证结果数组
 */
export function validateApiDomains(
  urls: string[],
  options: DomainValidationOptions = {}
): ValidationResult[] {
  return urls.map(url => validateApiDomain(url, options));
}

/**
 * 从字符串中提取所有 API 域名
 * @param text 文本内容
 * @param options 验证选项
 * @returns 提取到的合法 API 域名数组
 */
export function extractApiDomains(
  text: string,
  options: DomainValidationOptions = {}
): string[] {
  const urlPattern =
    /(https?:\/\/[^\s"'<>()]+|(?:www\.)?[a-zA-Z0-9][a-zA-Z0-9-]{0,61}[a-zA-Z0-9](?:\.[a-zA-Z]{2,})+)/gi;
  const matches: RegExpMatchArray | string[] = text.match(urlPattern) || [];

  return matches
    .map(url => {
      const result = validateApiDomain(url, options);
      return result.isValid ? result.normalizedUrl : null;
    })
    .filter((url) => url !== null && url !== undefined) as string[];
}

/**
 * 使用示例
 */
export function exampleUsage(): void {
  const testUrls = [
    'https://api.example.com',
    'http://api.example.com',
    'api.example.com',
    'example.com:8080/api/v1',
    'https://192.168.1.1/api',
    'localhost:3000',
    'https://api.example.com/users?page=1',
    'https://api.example.com/#section',
    'https://example.co.uk/api',
    'https://test-api.example.com:8443/',
    'https://api.example.com/path/to/resource/'
  ];

  console.log('=== API 域名验证示例 ===\n');

  // 1. 严格验证（生产环境推荐）
  const strictOptions: DomainValidationOptions = {
    allowHttp: false,
    allowLocalhost: false,
    allowIp: false,
    allowQuery: false,
    removeDefaultPort: true,
    removeTrailingSlash: true
  };

  console.log('严格验证模式:');
  testUrls.forEach(url => {
    const result = validateApiDomain(url, strictOptions);
    console.log(`${url.padEnd(40)} => ${result.isValid ? '✓' : '✗'} ${result.error || ''}`);
  });

  console.log('\n=== 标准化示例 ===\n');

  // 2. 标准化示例
  const urlsToNormalize = [
    'API.EXAMPLE.COM',
    'http://api.example.com:80/api/',
    'https://api.example.com:443/',
    'api.example.com/v1/users/'
  ];

  urlsToNormalize.forEach(url => {
    try {
      const normalized = normalizeApiDomain(url);
      console.log(`${url.padEnd(40)} => ${normalized}`);
    } catch (error) {
      console.log(`${url.padEnd(40)} => 错误: ${(error as Error).message}`);
    }
  });

  console.log('\n=== 提取示例 ===\n');

  // 3. 从文本中提取
  const text = `
    我们的服务使用以下API端点：
    - 生产环境: https://api.company.com/v1
    - 测试环境: http://test-api.company.com:3000
    - 本地开发: http://localhost:8080
    其他无效地址: ftp://old-server.com, ws://websocket.example.com
  `;

  const extracted = extractApiDomains(text);
  console.log('提取到的合法API域名:');
  extracted.forEach(url => console.log(`  - ${url}`));
}