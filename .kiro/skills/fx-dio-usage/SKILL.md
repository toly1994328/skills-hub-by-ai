---
name: "fx-dio-usage"
description: "使用 fx_dio 进行 Flutter HTTP 请求开发。基于实际项目实践的模式，包含 Host 定义、请求发起、返回值处理等核心流程。"
metadata:
  author: toly
  version: "3.0.0"
---

# fx_dio 使用指南

## 分层架构

fx_dio 的网络模块采用三层结构：

```
┌─────────────────────────────────────┐
│  Repository（仓储层）                │  ← 对外暴露业务方法，返回 ApiRet<T>
├─────────────────────────────────────┤
│  Model（模型层）                     │  ← 定义数据结构 + fromApi 工厂方法
├─────────────────────────────────────┤
│  Env / Host（环境层）                │  ← 定义服务地址、端口、环境切换
└─────────────────────────────────────┘
```

对应到文件结构：

```
lib/
├── articles.dart                    # 入口，统一 export
└── src/
    ├── env/
    │   └── env.dart                 # Host 定义 + HostMixin
    ├── model/
    │   ├── article_po.dart          # 数据模型
    │   └── query.dart               # 查询参数
    └── repository/
        └── article_repository.dart  # 请求仓储
```

---

## 流程概览

使用 fx_dio 开发一个网络模块，按以下顺序：

```
Step 1: 定义 Host（服务地址 + 环境）
Step 2: 定义 Model（数据模型 + fromApi）
Step 3: 编写 Repository（请求方法 + convertor）
Step 4: 注册 Host（App 启动时）
Step 5: 调用 Repository 获取数据
```

---

## Step 1：定义 Host

每个后端服务对应一个 Host 子类。按 dev/release 分地址，HostConfig 定义协议、端口、路径前缀：

```dart
---->[lib/src/env/env.dart]----
import 'package:fx_dio/fx_dio.dart';

class ArticleHost extends Host {
  const ArticleHost();

  @override
  Map<HostEnv, String> get value => {
    HostEnv.release: 'toly1994.com',
    HostEnv.dev: '127.0.0.1',
  };

  @override
  HostConfig get config => const HostConfig(
    scheme: 'http',
    port: 3000,
    apiNest: '/api/v1',
  );

  @override
  HostEnv get env => HostEnv.release;
}

mixin ArticleHostMixin {
  Host get host => FxDio()<ArticleHost>();
}
```

HostConfig 参数：
- `scheme`：协议（http/https）
- `port`：端口，null 则不拼接
- `apiNest`：路径前缀，拼在 baseUrl 末尾

最终 baseUrl = `{scheme}://{address}:{port}{apiNest}`

---

## Step 2：定义 Model

数据模型只关心字段映射，通过 `fromApi` 工厂方法从服务端 JSON 转换：

```dart
---->[lib/src/model/article_po.dart]----
class ArticlePo {
  final int articleId;
  final String title;
  final String subtitle;
  final String url;
  final String cover;
  final int type;
  final int status;
  final String createAt;
  final String updateAt;

  ArticlePo({
    required this.articleId,
    required this.title,
    this.subtitle = '',
    this.url = '',
    this.cover = '',
    this.type = 0,
    this.status = 0,
    this.createAt = '',
    this.updateAt = '',
  });

  factory ArticlePo.fromApi(dynamic map) => ArticlePo(
    articleId: map['article_id'] ?? 0,
    title: map['title'] ?? '',
    subtitle: map['subtitle'] ?? '',
    url: map['url'] ?? '',
    cover: map['cover'] ?? '',
    type: map['type'] ?? 0,
    status: map['status'] ?? 0,
    createAt: map['create_at'] ?? '',
    updateAt: map['update_at'] ?? '',
  );
}
```

查询参数单独成类：

```dart
---->[lib/src/model/query.dart]----
class SizeFilter {
  final int page;
  final int pageSize;

  const SizeFilter({
    this.page = 1,
    this.pageSize = 20,
  });
}
```

---

## Step 3：编写 Repository

Repository 是对外暴露的业务接口层。mixin HostMixin 获取 host，调用 host.get/post 发请求：

```dart
---->[lib/src/repository/article_repository.dart]----
import 'package:fx_dio/fx_dio.dart';
import '../env/env.dart';
import '../model/article_po.dart';
import '../model/query.dart';

class ArticleRepository with ArticleHostMixin {

  Future<ApiRet<List<ArticlePo>>> list({
    SizeFilter filter = const SizeFilter(),
  }) {
    return host.get<List<ArticlePo>>(
      '/article',
      queryParameters: {
        'page': filter.page,
        'page_size': filter.pageSize,
      },
      convertor: (data) {
        List list = data['data'] as List;
        return list.map<ArticlePo>(ArticlePo.fromApi).toList();
      },
    );
  }
}
```

convertor 接收的是 `response.data`（即 HTTP 响应体反序列化后的对象）。
如果服务端返回 `{ "data": [...], "total": 42 }`，则 convertor 的参数就是这整个 Map。

---

## Step 4：注册 Host

App 启动时统一注册：

```dart
---->[注册]----
import 'package:fx_dio/fx_dio.dart';

void registerHttpClient() {
  FxDio().register(const ArticleHost());
  // 如果需要认证
  // FxDio().auth<ArticleHost>(MyAuth());
}
```

自定义认证：

```dart
class MyAuth extends ApiAuth {
  final String token;
  MyAuth(this.token);

  @override
  Map<String, dynamic> get buildHeaders => {
    'Authorization': 'Bearer $token',
  };
}
```

---

## Step 5：调用

```dart
final repo = ArticleRepository();
ApiRet<List<ArticlePo>> ret = await repo.list(
  filter: const SizeFilter(page: 1, pageSize: 10),
);

if (ret.success) {
  List<ArticlePo> articles = ret.data;
  int? total = ret.paginate?.total;
} else {
  print('失败: ${ret.msg}');
}
```

---

## convertor 写法速查

```dart
// 服务端返回 { "data": [...] }，取 data 字段转列表
convertor: (data) {
  List list = data['data'] as List;
  return list.map<T>(T.fromApi).toList();
}

// 服务端返回直接是对象
convertor: (data) => User.fromApi(data)

// 服务端返回 { "status": true }，只关心布尔值
convertor: (data) => data['status'] == true

// 不需要转换
convertor: (data) => data
```

---

## 测试模式

单元测试中同样需要注册 Host：

```dart
void main() {
  setUpAll(() {
    FxDio().register(const ArticleHost());
  });

  test('获取文章列表', () async {
    final repo = ArticleRepository();
    ApiRet<List<ArticlePo>> ret = await repo.list(
      filter: const SizeFilter(page: 1, pageSize: 3),
    );
    expect(ret.success, isTrue);
    expect(ret.data.isNotEmpty, isTrue);
  });
}
```

---

## 关键语法

| 语法 | 作用 |
|------|------|
| `FxDio().register(host)` | 注册 Host |
| `FxDio()<T>()` | 通过泛型获取已注册的 Host |
| `FxDio().auth<T>(auth)` | 配置认证 |
| `host.get(path, convertor: ...)` | GET 请求 |
| `host.post(path, data: ..., convertor: ...)` | POST 请求 |
| `host.put` / `host.patch` / `host.delete` | 其他方法 |
| `ret.success` / `ret.failed` | 判断结果 |
| `ret.data` | 获取数据（success 时） |
| `ret.paginate?.total` | 获取分页总数 |
| `ret.msg` | 获取错误信息（failed 时） |
