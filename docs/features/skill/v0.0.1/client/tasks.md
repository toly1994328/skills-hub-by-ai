# 技能管理 — 前端任务清单

基于 client/design.md 设计，列出需要创建/修改的具体细节。

全局约束：
- 状态管理使用 Cubit 模式，不使用 Event 模式
- 网络请求使用 fx_dio（Host + Repository + convertor）
- Model 使用 fromApi 工厂方法
- 组件只管渲染，Cubit 只管状态，Repository 只管数据

---

## 执行顺序

1. ✅ 任务 1 — 添加依赖（无依赖）
2. ✅ 任务 2 — SkillHost 环境定义（无依赖）
3. ✅ 任务 3 — SkillSummary 模型（无依赖）
4. ✅ 任务 4 — SkillDetail 模型（无依赖）
5. ✅ 任务 5 — SkillRepository（依赖任务 2、3、4）
6. ✅ 任务 6 — SkillListCubit + State（依赖任务 5）
7. ✅ 任务 7 — SkillDetailCubit + State（依赖任务 5）
8. ✅ 任务 8 — SkillCard 卡片组件（依赖任务 3）
9. ✅ 任务 9 — SkillListPage 列表页（依赖任务 6、8）
10. ✅ 任务 10 — SkillDetailPage 详情页（依赖任务 7）
11. ✅ 任务 11 — main.dart 入口改造（依赖任务 2、9）
12. ✅ 任务 12 — 编译验证

---

## 任务 1：pubspec.yaml — 添加依赖 `⬜ 待处理`

文件：`client/pubspec.yaml`（修改）

### 1.1 添加依赖 `⬜`

```yaml
dependencies:
  fx_dio:
    hosted: # 按项目私服地址填写
  flutter_bloc: ^9.1.1
  flutter_markdown_plus: ^0.7.1
  cached_network_image: ^3.3.1
  url_launcher: ^6.2.5
```

### 1.2 执行 flutter pub get `⬜`

```bash
flutter pub get
```

---

## 任务 2：skill_host.dart — Host 定义 `⬜ 待处理`

文件：`client/lib/skill/env/skill_host.dart`（新建）

### 2.1 定义 SkillHost `⬜`

```dart
import 'package:fx_dio/fx_dio.dart';

class SkillHost extends Host {
  const SkillHost();

  @override
  Map<HostEnv, String> get value => {
    HostEnv.release: 'toly1994.com',  // 生产地址，后续替换
    HostEnv.dev: '10.0.2.2',          // Android 模拟器访问宿主机
  };

  @override
  HostConfig get config => const HostConfig(
    scheme: 'http',
    port: 3000,
    apiNest: '/api',
  );

  @override
  HostEnv get env => HostEnv.dev;
}

mixin SkillHostMixin {
  Host get host => FxDio()<SkillHost>();
}
```

---

## 任务 3：skill_summary.dart — 列表数据模型 `⬜ 待处理`

文件：`client/lib/skill/model/skill_summary.dart`（新建）

### 3.1 定义 SkillSummary `⬜`

```dart
class SkillSummary {
  final int id;
  final String name;
  final String description;
  final String author;
  final String tags;
  final String iconUrl;
  final String sourceUrl;
  final String version;
  final String downloadUrl;
  final String createdAt;
  final String updatedAt;

  SkillSummary({
    required this.id,
    required this.name,
    this.description = '',
    this.author = '',
    this.tags = '',
    this.iconUrl = '',
    this.sourceUrl = '',
    this.version = '',
    this.downloadUrl = '',
    this.createdAt = '',
    this.updatedAt = '',
  });

  factory SkillSummary.fromApi(dynamic map) => SkillSummary(
    id: map['id'] ?? 0,
    name: map['name'] ?? '',
    description: map['description'] ?? '',
    author: map['author'] ?? '',
    tags: map['tags'] ?? '',
    iconUrl: map['icon_url'] ?? '',
    sourceUrl: map['source_url'] ?? '',
    version: map['version'] ?? '',
    downloadUrl: map['download_url'] ?? '',
    createdAt: map['created_at'] ?? '',
    updatedAt: map['updated_at'] ?? '',
  );

  /// 标签列表（逗号分隔转 List）
  List<String> get tagList => tags.isEmpty ? [] : tags.split(',');
}
```

---

## 任务 4：skill_detail.dart — 详情数据模型 `⬜ 待处理`

文件：`client/lib/skill/model/skill_detail.dart`（新建）

### 4.1 定义 SkillDetail `⬜`

```dart
class SkillDetail {
  final int id;
  final String name;
  final String description;
  final String author;
  final String tags;
  final String iconUrl;
  final String sourceUrl;
  final String version;
  final String downloadUrl;
  final String content;
  final String status;
  final String createdAt;
  final String updatedAt;

  SkillDetail({
    required this.id,
    required this.name,
    this.description = '',
    this.author = '',
    this.tags = '',
    this.iconUrl = '',
    this.sourceUrl = '',
    this.version = '',
    this.downloadUrl = '',
    this.content = '',
    this.status = '',
    this.createdAt = '',
    this.updatedAt = '',
  });

  factory SkillDetail.fromApi(dynamic map) => SkillDetail(
    id: map['id'] ?? 0,
    name: map['name'] ?? '',
    description: map['description'] ?? '',
    author: map['author'] ?? '',
    tags: map['tags'] ?? '',
    iconUrl: map['icon_url'] ?? '',
    sourceUrl: map['source_url'] ?? '',
    version: map['version'] ?? '',
    downloadUrl: map['download_url'] ?? '',
    content: map['content'] ?? '',
    status: map['status'] ?? '',
    createdAt: map['created_at'] ?? '',
    updatedAt: map['updated_at'] ?? '',
  );

  List<String> get tagList => tags.isEmpty ? [] : tags.split(',');
}
```

---

## 任务 5：skill_repository.dart — API 调用 `⬜ 待处理`

文件：`client/lib/skill/repository/skill_repository.dart`（新建）

### 5.1 列表查询方法 `⬜`

```dart
import 'package:fx_dio/fx_dio.dart';
import '../env/skill_host.dart';
import '../model/skill_summary.dart';
import '../model/skill_detail.dart';

class SkillRepository with SkillHostMixin {

  Future<ApiRet<List<SkillSummary>>> list({
    int page = 1,
    int pageSize = 20,
  }) {
    return host.get<List<SkillSummary>>(
      '/skills',
      queryParameters: {
        'page': page,
        'page_size': pageSize,
      },
      convertor: (data) {
        List list = data['data']['list'] as List;
        return list.map<SkillSummary>(SkillSummary.fromApi).toList();
      },
    );
  }
```

逻辑：
1. 调用 host.get，path 为 `/skills`（apiNest 已含 `/api`）
2. convertor 从 `data['data']['list']` 提取列表
3. 返回 `ApiRet<List<SkillSummary>>`

### 5.2 详情查询方法 `⬜`

```dart
  Future<ApiRet<SkillDetail>> detail(int id) {
    return host.get<SkillDetail>(
      '/skills/$id',
      convertor: (data) => SkillDetail.fromApi(data['data']),
    );
  }
}
```

---

## 任务 6：SkillListCubit + State — 列表状态管理 `⬜ 待处理`

文件：`client/lib/skill/cubit/skill_list_state.dart`（新建）+ `client/lib/skill/cubit/skill_list_cubit.dart`（新建）

### 6.1 定义 SkillListState `⬜`

```dart
import '../model/skill_summary.dart';

enum SkillListStatus { initial, loading, loaded, error }

class SkillListState {
  final SkillListStatus status;
  final List<SkillSummary> skills;
  final int page;
  final int total;
  final bool hasMore;
  final String errorMsg;

  const SkillListState({
    this.status = SkillListStatus.initial,
    this.skills = const [],
    this.page = 1,
    this.total = 0,
    this.hasMore = true,
    this.errorMsg = '',
  });

  SkillListState copyWith({...});
}
```

### 6.2 定义 SkillListCubit `⬜`

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/skill_repository.dart';
import 'skill_list_state.dart';

class SkillListCubit extends Cubit<SkillListState> {
  final SkillRepository _repo = SkillRepository();

  SkillListCubit() : super(const SkillListState());

  /// 加载第一页
  Future<void> loadSkills() async { ... }

  /// 加载更多（下一页，追加数据）
  Future<void> loadMore() async { ... }
}
```

loadSkills 逻辑：
1. emit loading
2. 调用 `_repo.list(page: 1)`
3. 成功：emit loaded + skills + total + hasMore
4. 失败：emit error + errorMsg

loadMore 逻辑：
1. 如果 !hasMore 或正在 loading，return
2. page + 1，调用 `_repo.list(page: nextPage)`
3. 成功：追加到 skills，更新 hasMore
4. 失败：emit error

---

## 任务 7：SkillDetailCubit + State — 详情状态管理 `⬜ 待处理`

文件：`client/lib/skill/cubit/skill_detail_state.dart`（新建）+ `client/lib/skill/cubit/skill_detail_cubit.dart`（新建）

### 7.1 定义 SkillDetailState `⬜`

```dart
import '../model/skill_detail.dart';

enum SkillDetailStatus { initial, loading, loaded, error }

class SkillDetailState {
  final SkillDetailStatus status;
  final SkillDetail? skill;
  final String errorMsg;

  const SkillDetailState({
    this.status = SkillDetailStatus.initial,
    this.skill,
    this.errorMsg = '',
  });

  SkillDetailState copyWith({...});
}
```

### 7.2 定义 SkillDetailCubit `⬜`

```dart
class SkillDetailCubit extends Cubit<SkillDetailState> {
  final SkillRepository _repo = SkillRepository();

  SkillDetailCubit() : super(const SkillDetailState());

  Future<void> loadDetail(int id) async { ... }
}
```

loadDetail 逻辑：
1. emit loading
2. 调用 `_repo.detail(id)`
3. 成功：emit loaded + skill
4. 失败：emit error + errorMsg

---

## 任务 8：skill_card.dart — 技能卡片组件 `⬜ 待处理`

文件：`client/lib/skill/view/skill_card.dart`（新建）

### 8.1 定义 SkillCard Widget `⬜`

```dart
class SkillCard extends StatelessWidget {
  final SkillSummary skill;
  final VoidCallback? onTap;
}
```

Widget 树结构：
- Card
  - InkWell（onTap 回调）
    - Row
      - CachedNetworkImage（图标，48x48）
      - Expanded Column
        - Row: name + version（Chip）
        - Text: description（maxLines: 2）
        - Row: author + tags（Chip 列表）

---

## 任务 9：skill_list_page.dart — 列表页 `⬜ 待处理`

文件：`client/lib/skill/view/skill_list_page.dart`（新建）

### 9.1 定义 SkillListPage `⬜`

```dart
class SkillListPage extends StatelessWidget {
  // 使用 BlocProvider 包裹 SkillListCubit
  // initState 时调用 cubit.loadSkills()
}
```

Widget 树结构：
- Scaffold
  - AppBar: title "Skills"
  - body: BlocBuilder<SkillListCubit, SkillListState>
    - initial/loading: CircularProgressIndicator
    - loaded: ListView.builder
      - itemBuilder: SkillCard（onTap 跳转详情）
      - 滚动监听：到底部触发 cubit.loadMore()
    - error: 错误提示 + 重试按钮

### 9.2 滚动加载更多逻辑 `⬜`

使用 NotificationListener<ScrollNotification> 监听滚动位置，当 `pixels >= maxScrollExtent - 200` 时触发加载。

---

## 任务 10：skill_detail_page.dart — 详情页 `⬜ 待处理`

文件：`client/lib/skill/view/skill_detail_page.dart`（新建）

### 10.1 定义 SkillDetailPage `⬜`

```dart
class SkillDetailPage extends StatelessWidget {
  final int skillId;
  // 使用 BlocProvider 包裹 SkillDetailCubit
  // initState 时调用 cubit.loadDetail(skillId)
}
```

Widget 树结构：
- Scaffold
  - AppBar: title = skill.name
  - body: BlocBuilder<SkillDetailCubit, SkillDetailState>
    - loading: CircularProgressIndicator
    - loaded: SingleChildScrollView
      - Column
        - 头部信息区：图标 + 名称 + 版本 + 作者
        - 标签区：Wrap + Chip
        - 链接区：来源链接按钮 + 下载链接按钮（url_launcher 打开）
        - 分割线
        - Markdown 内容区：MarkdownBody(data: skill.content)
    - error: 错误提示

### 10.2 外部链接跳转 `⬜`

使用 url_launcher 的 `launchUrl` 打开 sourceUrl 和 downloadUrl。

---

## 任务 11：main.dart — 入口改造 `⬜ 待处理`

文件：`client/lib/main.dart`（修改）

### 11.1 注册 fx_dio Host `⬜`

```dart
import 'package:fx_dio/fx_dio.dart';
import 'skill/env/skill_host.dart';

void main() {
  FxDio().register(const SkillHost());
  runApp(const MyApp());
}
```

### 11.2 替换首页为 SkillListPage `⬜`

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Skills Share',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue)),
      home: const SkillListPage(),
    );
  }
}
```

删除原有的 Counter 相关代码。

---

## 任务 12：编译验证 `⬜ 待处理`

### 12.1 flutter analyze `⬜`

```bash
flutter analyze
```

确保零错误。

### 12.2 flutter build（可选） `⬜`

```bash
flutter build apk --debug
```

确保能正常构建。
