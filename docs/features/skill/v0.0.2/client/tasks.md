# 技能管理 v0.0.2 — 前端任务清单

基于 client/design.md 设计，列出需要创建/修改的具体细节。

全局约束：
- 状态管理使用 Cubit 模式
- 网络请求使用 fx_dio
- UI 遵循微信简洁风规范（.kiro/steering/ui-style.md）

---

## 执行顺序

1. ⬜ 任务 1 — 添加 file_picker 依赖
2. ⬜ 任务 2 — CreateSkillRequest 模型
3. ⬜ 任务 3 — SkillRepository 新增 create 方法
4. ⬜ 任务 4 — SkillPublishState 状态定义
5. ⬜ 任务 5 — SkillPublishCubit 逻辑
6. ⬜ 任务 6 — SkillPublishPage 表单页
7. ⬜ 任务 7 — SkillListPage 加发布按钮
8. ⬜ 任务 8 — 编译验证

---

## 任务 1：pubspec.yaml — 添加依赖 `⬜ 待处理`

文件：`client/pubspec.yaml`（修改）

### 1.1 添加 file_picker `⬜`

```yaml
  file_picker: ^8.0.0
```

---

## 任务 2：create_skill_request.dart — 请求模型 `⬜ 待处理`

文件：`client/lib/skill/model/create_skill_request.dart`（新建）

### 2.1 定义 CreateSkillRequest `⬜`

```dart
class CreateSkillRequest {
  final String name;
  final String description;
  final String author;
  final String tags;
  final String iconUrl;
  final String sourceUrl;
  final String version;
  final String downloadUrl;
  final String content;

  const CreateSkillRequest({
    required this.name,
    required this.content,
    this.description = '',
    this.author = '',
    this.tags = '',
    this.iconUrl = '',
    this.sourceUrl = '',
    this.version = '1.0.0',
    this.downloadUrl = '',
  });

  Map<String, dynamic> toJson() => { ... };
}
```

---

## 任务 3：skill_repository.dart — 新增 create 方法 `⬜ 待处理`

文件：`client/lib/skill/repository/skill_repository.dart`（修改）

### 3.1 添加 create 方法 `⬜`

```dart
Future<ApiRet<int>> create(CreateSkillRequest request) {
  return host.post<int>(
    '/skills',
    data: request.toJson(),
    convertor: (data) => data['data']['id'] as int,
  );
}
```

---

## 任务 4：skill_publish_state.dart — 状态定义 `⬜ 待处理`

文件：`client/lib/skill/cubit/skill_publish_state.dart`（新建）

### 4.1 定义 SkillPublishState `⬜`

```dart
enum SkillPublishStatus { initial, submitting, success, error }

class SkillPublishState {
  final SkillPublishStatus status;
  final String errorMsg;

  const SkillPublishState({
    this.status = SkillPublishStatus.initial,
    this.errorMsg = '',
  });

  SkillPublishState copyWith({...});
}
```

---

## 任务 5：skill_publish_cubit.dart — 发布逻辑 `⬜ 待处理`

文件：`client/lib/skill/cubit/skill_publish_cubit.dart`（新建）

### 5.1 定义 SkillPublishCubit `⬜`

```dart
class SkillPublishCubit extends Cubit<SkillPublishState> {
  final SkillRepository _repo = SkillRepository();

  SkillPublishCubit() : super(const SkillPublishState());

  Future<void> publish(CreateSkillRequest request) async { ... }
}
```

publish 逻辑：
1. 校验 name 非空、content 非空
2. emit submitting
3. 调用 _repo.create(request)
4. 成功：emit success
5. 失败：emit error + errorMsg

---

## 任务 6：skill_publish_page.dart — 发布表单页 `⬜ 待处理`

文件：`client/lib/skill/view/skill_publish_page.dart`（新建）

### 6.1 页面结构 `⬜`

- Scaffold，AppBar 标题"发布技能"
- 背景色 #EDEDED
- 表单区域白色块

### 6.2 表单字段 `⬜`

白色块内，微信风格的输入行：
- 名称（必填）
- 描述
- 作者
- 标签（逗号分隔）
- 来源 URL
- 版本号
- 下载链接
- 图标 URL

### 6.3 内容输入区 `⬜`

第二个白色块，TabBar 切换三种模式：
- "选择文件"：点击后用 file_picker 选 .md 文件，读取后显示文件名
- "手动输入"：多行文本框
- "预览"：用 MarkdownBody 渲染当前内容（文件或手动输入的）

### 6.4 发布按钮 `⬜`

底部绿色按钮（#07C160），宽度撑满（左右 16px 边距），高度 44px。

### 6.5 状态响应 `⬜`

- submitting 时按钮显示 loading
- success 时 pop 返回列表页
- error 时 SnackBar 显示错误信息

---

## 任务 7：skill_list_page.dart — 加发布按钮 `⬜ 待处理`

文件：`client/lib/skill/view/skill_list_page.dart`（修改）

### 7.1 AppBar 右侧加按钮 `⬜`

AppBar actions 加一个"+"图标按钮，点击后 push SkillPublishPage。
发布成功返回后刷新列表（通过 Navigator.pop 返回 true，列表页判断后 reload）。

---

## 任务 8：编译验证 `⬜ 待处理`

### 8.1 flutter analyze `⬜`

```bash
flutter analyze
```

确保零错误。
