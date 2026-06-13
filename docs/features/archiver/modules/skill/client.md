# 技能管理 — 前端局域网络

涉及节点：F-01, F-02, F-03, F-04

---

## 一、远景：模块与依赖

### 涉及模块

| 模块 | 位置 | 职责（一句话） |
|------|------|--------------|
| skill_host | client/lib/skill/env/skill_host.dart | fx_dio Host 定义，服务地址配置 |
| skill_summary | client/lib/skill/model/skill_summary.dart | 列表数据模型 |
| skill_detail | client/lib/skill/model/skill_detail.dart | 详情数据模型 |
| create_skill_request | client/lib/skill/model/create_skill_request.dart | 创建请求模型 |
| skill_repository | client/lib/skill/repository/skill_repository.dart | HTTP 请求封装（list/detail/create） |
| skill_list_cubit | client/lib/skill/cubit/skill_list_cubit.dart | 列表页状态管理 |
| skill_detail_cubit | client/lib/skill/cubit/skill_detail_cubit.dart | 详情页状态管理 |
| skill_publish_cubit | client/lib/skill/cubit/skill_publish_cubit.dart | 发布页状态管理 |
| app_shell | client/lib/skill/view/app_shell.dart | 底部导航 + PageView |
| mine_page | client/lib/skill/view/mine_page.dart | 我的页面 |
| skill_list_page | client/lib/skill/view/skill_list_page.dart | 技能广场列表页 |
| skill_card | client/lib/skill/view/skill_card.dart | 技能卡片组件 |
| skill_detail_page | client/lib/skill/view/skill_detail_page.dart | 详情页（SliverAppBar + Tab + 代码高亮） |
| skill_publish_page | client/lib/skill/view/skill_publish_page.dart | 发布表单页 |

### 依赖关系

```mermaid
graph TB
    AppShell[app_shell] --> ListPage[skill_list_page]
    AppShell --> MinePage[mine_page]
    ListPage --> ListCubit[skill_list_cubit]
    ListPage --> Card[skill_card]
    ListPage --> DetailPage[skill_detail_page]
    ListPage --> PublishPage[skill_publish_page]
    DetailPage --> DetailCubit[skill_detail_cubit]
    PublishPage --> PublishCubit[skill_publish_cubit]
    ListCubit --> Repo[skill_repository]
    DetailCubit --> Repo
    PublishCubit --> Repo
    Repo --> Host[skill_host]
    Host -.->|HTTP| Server[后端 P-01]
```

### 节点详情

| 编号 | 功能节点 | 模块 | 职责 |
|------|---------|------|------|
| F-01 | 技能列表页 | skill_list_page + skill_list_cubit + skill_card | 分页展示 + 发布入口 |
| F-02 | 技能详情页 | skill_detail_page + skill_detail_cubit | SliverAppBar 头部 + Tab 面板 + Markdown 高亮 |
| F-03 | 技能发布页 | skill_publish_page + skill_publish_cubit | 表单 + 文件选择 + 预览 + 提交 |
| F-04 | 底部导航 + 我的 | app_shell + mine_page | PageView 切换 + 占位个人页 |

---

## 二、中景：数据通道与事件流

### 数据通道

| 通道 | 协议 | 方向 | 特点 | 例子 |
|------|------|------|------|------|
| 技能列表 | HTTP | 客户端主动 | fx_dio host.get + convertor | SkillRepository.list() |
| 技能详情 | HTTP | 客户端主动 | fx_dio host.get + convertor | SkillRepository.detail(id) |
| 创建技能 | HTTP | 客户端主动 | fx_dio host.post + convertor | SkillRepository.create(request) |

### 关键事件流

```mermaid
sequenceDiagram
    participant U as 用户
    participant Publish as SkillPublishPage
    participant Cubit as SkillPublishCubit
    participant Repo as SkillRepository
    participant API as POST /api/skills

    U->>Publish: 填写表单 + 选文件/输入内容
    U->>Publish: 点击发布
    Publish->>Cubit: publish(request)
    Cubit->>Cubit: 校验 name/content
    Cubit->>Cubit: emit submitting
    Cubit->>Repo: create(request)
    Repo->>API: POST
    API-->>Repo: {id}
    Repo-->>Cubit: ApiRet success
    Cubit->>Cubit: emit success
    Publish->>U: pop 返回列表页
```

---

## 三、近景：生命周期与订阅

### 核心对象生命周期

| 对象 | 创建时机 | 销毁时机 | 生命跨度 |
|------|---------|---------|---------|
| AppShell | App 启动 | App 退出 | 应用级 |
| SkillListCubit | 进入列表页 | 离开列表页 | 页面级 |
| SkillDetailCubit | 进入详情页 | 离开详情页 | 页面级 |
| SkillPublishCubit | 进入发布页 | 离开发布页 | 页面级 |
| PageController | AppShell 创建 | AppShell dispose | 应用级 |

无 Stream 订阅，纯请求-响应模式。

---

## 四、版本演进

| 版本 | 变更 |
|------|------|
| v0.0.1 | 初始版本：列表页 + 详情页 + fx_dio 集成 |
| v0.0.2 | 发布页 + 底部导航 + SliverAppBar + 代码高亮 + 橙色品牌色 |
