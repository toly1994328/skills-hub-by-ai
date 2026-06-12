# 技能管理 — 后端任务清单

基于 server/design.md 设计，列出需要创建/修改的具体细节。

全局约束：
- 错误处理使用 AppError 统一类型，handler 返回 `Result<Json<...>, AppError>`
- 用 `?` 传播错误，业务错误用 `AppError::not_found(...)` 等便捷方法
- Repository 层一个方法一条 SQL，查询结果用 `#[derive(FromRow)]` 结构体接收
- 不用的 import 及时删除

---

## 执行顺序

1. ✅ 任务 1 — 添加依赖（无依赖）
2. ✅ 任务 2 — AppError 统一错误类型（无依赖）
3. ✅ 任务 3 — AppResponse 统一响应格式（依赖任务 2）
4. ✅ 任务 4 — Skill 数据模型（无依赖）
5. ✅ 任务 5 — Skill Repository 存储层（依赖任务 4）
6. ✅ 任务 6 — Skill Service 服务层（依赖任务 2、4、5）
7. ✅ 任务 7 — Skill Router 路由层（依赖任务 2、3、6）
8. ✅ 任务 8 — 主入口注册模块路由（依赖任务 7）
9. ✅ 任务 9 — 建表 SQL（无依赖）
10. ✅ 任务 10 — 编译验证
11. ✅ 任务 11 — 种子数据脚本 + 验证（依赖任务 8、9）

---

## 任务 1：Cargo.toml — 添加依赖 `⬜ 待处理`

文件：`server/Cargo.toml`

### 1.1 添加 thiserror 依赖 `⬜`

```toml
thiserror = "1.0"
```

用于 AppError 的 derive 宏。

---

## 任务 2：app_error.rs — 统一错误类型 `⬜ 待处理`

文件：`server/src/app_error.rs`（新建）

### 2.1 定义 AppError 枚举 `⬜`

```rust
use axum::http::StatusCode;
use axum::response::{IntoResponse, Response};
use axum::Json;
use serde_json::json;

#[derive(Debug, thiserror::Error)]
pub enum AppError {
    #[error("Bad Request: {0}")]
    BadRequest(String),

    #[error("Not Found: {0}")]
    NotFound(String),

    #[error("Internal Error: {0}")]
    Internal(String),
}
```

### 2.2 便捷构造方法 `⬜`

```rust
impl AppError {
    pub fn bad_request(msg: impl Into<String>) -> Self { ... }
    pub fn not_found(msg: impl Into<String>) -> Self { ... }
    pub fn internal(err: impl std::fmt::Display, context: &str) -> Self { ... }
}
```

### 2.3 实现 IntoResponse `⬜`

将 AppError 转为 HTTP 响应，格式为 `{ code, data: null, message }`：
- BadRequest → 400
- NotFound → 404
- Internal → 500

### 2.4 实现 From<sqlx::Error> `⬜`

```rust
impl From<sqlx::Error> for AppError {
    fn from(err: sqlx::Error) -> Self {
        AppError::Internal(format!("Database error: {}", err))
    }
}
```

---

## 任务 3：app_response.rs — 统一响应格式 `⬜ 待处理`

文件：`server/src/app_response.rs`（新建）

### 3.1 定义 AppResponse 结构体 `⬜`

```rust
use serde::Serialize;

#[derive(Serialize)]
pub struct AppResponse<T: Serialize> {
    pub code: i32,
    pub data: Option<T>,
    pub message: String,
}
```

### 3.2 便捷方法 `⬜`

```rust
impl<T: Serialize> AppResponse<T> {
    pub fn success(data: T) -> Json<AppResponse<T>> { ... }
    // code=0, message="success"
}
```

---

## 任务 4：skill_model.rs — 数据模型 `⬜ 待处理`

文件：`server/src/skill/skill_model.rs`（新建）

### 4.1 定义 Skill 结构体（完整字段，用于详情） `⬜`

```rust
use serde::Serialize;
use sqlx::FromRow;

#[derive(Debug, Clone, Serialize, FromRow)]
pub struct Skill {
    pub id: u64,
    pub name: String,
    pub description: String,
    pub author: String,
    pub tags: String,
    pub icon_url: String,
    pub source_url: String,
    pub version: String,
    pub download_url: String,
    pub content: String,
    pub status: String,
    pub created_at: String,
    pub updated_at: String,
}
```

### 4.2 定义 SkillSummary 结构体（列表用，不含 content） `⬜`

```rust
#[derive(Debug, Clone, Serialize, FromRow)]
pub struct SkillSummary {
    pub id: u64,
    pub name: String,
    pub description: String,
    pub author: String,
    pub tags: String,
    pub icon_url: String,
    pub source_url: String,
    pub version: String,
    pub download_url: String,
    pub created_at: String,
    pub updated_at: String,
}
```

### 4.3 定义分页结果结构体 `⬜`

```rust
#[derive(Debug, Serialize)]
pub struct PagedList<T: Serialize> {
    pub list: Vec<T>,
    pub total: i64,
    pub page: u32,
    pub page_size: u32,
}
```

### 4.4 定义创建技能输入结构体 `⬜`

```rust
use serde::Deserialize;

#[derive(Debug, Deserialize)]
pub struct CreateSkillInput {
    pub name: String,
    pub description: Option<String>,
    pub author: Option<String>,
    pub tags: Option<String>,
    pub icon_url: Option<String>,
    pub source_url: Option<String>,
    pub version: Option<String>,
    pub download_url: Option<String>,
    pub content: String,
}
```

---

## 任务 5：skill_repository.rs — 存储层 `⬜ 待处理`

文件：`server/src/skill/skill_repository.rs`（新建）

### 5.1 find_published — 分页查询已发布技能列表 `⬜`

```rust
pub async fn find_published(
    db: &MySqlPool,
    offset: u32,
    limit: u32,
) -> Result<Vec<SkillSummary>, sqlx::Error>
```

SQL：
```sql
SELECT id, name, description, author, tags, icon_url, source_url, version, download_url,
       DATE_FORMAT(created_at, '%Y-%m-%d %H:%i:%s') as created_at,
       DATE_FORMAT(updated_at, '%Y-%m-%d %H:%i:%s') as updated_at
FROM skills
WHERE status = 'published'
ORDER BY updated_at DESC
LIMIT ? OFFSET ?
```

### 5.2 count_published — 查询已发布总数 `⬜`

```rust
pub async fn count_published(db: &MySqlPool) -> Result<i64, sqlx::Error>
```

SQL：
```sql
SELECT COUNT(*) as count FROM skills WHERE status = 'published'
```

### 5.3 find_by_id — 按 ID 查询详情 `⬜`

```rust
pub async fn find_by_id(db: &MySqlPool, id: u64) -> Result<Option<Skill>, sqlx::Error>
```

SQL：
```sql
SELECT id, name, description, author, tags, icon_url, source_url, version, download_url, content, status,
       DATE_FORMAT(created_at, '%Y-%m-%d %H:%i:%s') as created_at,
       DATE_FORMAT(updated_at, '%Y-%m-%d %H:%i:%s') as updated_at
FROM skills
WHERE id = ? AND status = 'published'
```

### 5.4 insert — 插入新技能 `⬜`

```rust
pub async fn insert(db: &MySqlPool, input: &CreateSkillInput) -> Result<u64, sqlx::Error>
```

SQL：
```sql
INSERT INTO skills (name, description, author, tags, icon_url, source_url, version, download_url, content, status)
VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'published')
```

返回 `last_insert_id`。

---

## 任务 6：skill_service.rs — 服务层 `⬜ 待处理`

文件：`server/src/skill/skill_service.rs`（新建）

### 6.1 list_skills — 列表查询 `⬜`

```rust
pub async fn list_skills(
    db: &MySqlPool,
    page: u32,
    page_size: u32,
) -> Result<PagedList<SkillSummary>, AppError>
```

逻辑步骤：
1. 校验 page >= 1，page_size 用 `.clamp(1, 100)` 限制范围
2. 计算 offset = (page - 1) * page_size
3. 调用 `skill_repository::find_published(db, offset, page_size)`
4. 调用 `skill_repository::count_published(db)`
5. 组装 PagedList 返回

### 6.2 get_skill — 详情查询 `⬜`

```rust
pub async fn get_skill(db: &MySqlPool, id: u64) -> Result<Skill, AppError>
```

逻辑步骤：
1. 调用 `skill_repository::find_by_id(db, id)`
2. 如果 None，返回 `AppError::not_found("技能不存在")`
3. 如果 Some，返回 Skill

### 6.3 create_skill — 创建技能 `⬜`

```rust
pub async fn create_skill(db: &MySqlPool, input: CreateSkillInput) -> Result<u64, AppError>
```

逻辑步骤：
1. 校验 `name` 非空，否则返回 `AppError::bad_request("name 不能为空")`
2. 校验 `content` 非空，否则返回 `AppError::bad_request("content 不能为空")`
3. 调用 `skill_repository::insert(db, &input)`
4. 返回新记录 ID

---

## 任务 7：skill_router.rs — 路由层 `⬜ 待处理`

文件：`server/src/skill/skill_router.rs`（新建）

### 7.1 定义查询参数结构体 `⬜`

```rust
use serde::Deserialize;

#[derive(Deserialize)]
pub struct ListParams {
    pub page: Option<u32>,
    pub page_size: Option<u32>,
}
```

### 7.2 list_skills handler `⬜`

```rust
pub async fn list_skills(
    State(state): State<AppState>,
    Query(params): Query<ListParams>,
) -> Result<Json<AppResponse<PagedList<SkillSummary>>>, AppError>
```

逻辑：提取 page（默认 1）和 page_size（默认 20），调用 service，包装 AppResponse::success 返回。

### 7.3 get_skill handler `⬜`

```rust
pub async fn get_skill(
    State(state): State<AppState>,
    Path(id): Path<u64>,
) -> Result<Json<AppResponse<Skill>>, AppError>
```

逻辑：提取路径参数 id，调用 service，包装 AppResponse::success 返回。

### 7.4 create_skill handler `⬜`

```rust
pub async fn create_skill(
    State(state): State<AppState>,
    Json(input): Json<CreateSkillInput>,
) -> Result<Json<AppResponse<InsertResult>>, AppError>
```

逻辑：提取 JSON body，调用 service::create_skill，返回 `{ id }` 包装。

`InsertResult` 定义：
```rust
#[derive(Serialize)]
pub struct InsertResult { pub id: u64 }
```

### 7.5 定义路由函数 `⬜`

```rust
pub fn skill_routes() -> Router<AppState> {
    Router::new()
        .route("/api/skills", get(list_skills).post(create_skill))
        .route("/api/skills/{id}", get(get_skill))
}
```

---

## 任务 8：main.rs — 注册模块路由 `⬜ 待处理`

文件：`server/src/main.rs`（修改）

### 8.1 声明新模块 `⬜`

在文件顶部添加：
```rust
mod app_error;
mod app_response;
mod skill;
```

### 8.2 合并技能路由 `⬜`

在 Router 构建处合并 skill_routes：
```rust
let app = Router::new()
    .route("/", get(health))
    .route("/date", get(query_date))
    .merge(skill::skill_router::skill_routes())  // 新增
    .layer(...)
    .with_state(state);
```

---

## 任务 9：建表 SQL `⬜ 待处理`

文件：`server/migrations/20260612_012_skills.sql`（新建）

### 9.1 建表语句 `⬜`

按 design.md 中的 CREATE TABLE 语句创建 skills 表。

### 9.2 执行迁移 `⬜`

```bash
python scripts/deploy/db.py migrate
```

确认输出 `20260612_012_skills.sql` 执行成功。

---

## 任务 10：编译验证 `⬜ 待处理`

### 10.1 编译验证 `⬜`

```bash
cargo build
```

确保零错误零警告。

---

## 任务 11：种子数据脚本 + 验证 `⬜ 待处理`

文件：`scripts/server/seed.json`（新建）+ `scripts/server/seed.py`（新建）

### 11.1 编写 seed.json `⬜`

```json
{
  "skills": [
    {
      "name": "示例技能A",
      "description": "一个演示用的技能",
      "author": "toly",
      "tags": "效率,工具",
      "icon_url": "https://example.com/icon1.png",
      "source_url": "https://github.com/example/a",
      "version": "1.0.0",
      "download_url": "https://example.com/a.zip",
      "content": "# 示例技能A\n\n这是说明文档。"
    }
  ]
}
```

插入 2-3 条完整数据。

### 11.2 编写 seed.py `⬜`

读取 `seed.json`，逐条调用 POST /api/skills 接口灌入数据。

逻辑：
1. 读取 seed.json
2. 遍历 skills 数组，对每条数据发送 POST 请求
3. 检查响应 code == 0，打印成功/失败
4. 最后调用 GET /api/skills 验证列表返回数据正确

### 11.3 启动服务并执行 seed `⬜`

```bash
# 终端 1：启动服务
cargo run

# 终端 2：灌入种子数据
python scripts/server/seed.py
```

验证：
- POST 每条数据返回 `{ code: 0, data: { id: ... } }`
- 最终 GET /api/skills 列表包含所有种子数据
- GET /api/skills/:id 返回完整详情含 content
