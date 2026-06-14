# 技能管理 v0.0.3 — 后端任务清单

基于 server/design.md 设计，列出需要创建/修改的具体细节。

全局约束：
- 错误处理使用 AppError，handler 返回 `Result<Json<...>, AppError>`
- 用 `?` 传播错误
- Repository 层一个方法一条 SQL，结果用 `#[derive(FromRow)]` 结构体接收
- 文件写入一律使用 fs_write 工具（开发时），不用 PowerShell 写文件

---

## 执行顺序

1. ⬜ 任务 1 — 添加依赖
2. ⬜ 任务 2 — 数据库重建
3. ⬜ 任务 3 — 数据模型（skill_model.rs 重写）
4. ⬜ 任务 4 — Repository（skill_repository.rs 重写）
5. ⬜ 任务 5 — Service（skill_service.rs 重写，核心：zip 解压 + front-matter 解析）
6. ⬜ 任务 6 — Router（skill_router.rs 重写）
7. ⬜ 任务 7 — main.rs 更新
8. ⬜ 任务 8 — 编译验证
9. ⬜ 任务 9 — 种子脚本 generate_meta.py
10. ⬜ 任务 10 — 启动验证 + 种子灌入

---

## 任务 1：Cargo.toml — 添加依赖 `⬜ 待处理`

文件：`server/Cargo.toml`（修改）

### 1.1 新增依赖 `⬜`

```toml
zip = "2.1"
serde_yaml = "0.9"
```

---

## 任务 2：数据库重建 `⬜ 待处理`

### 2.1 执行 reset `⬜`

```bash
python scripts/deploy/db.py reset
```

会删库重建，执行 `20260614_001_skills.sql`。

---

## 任务 3：skill_model.rs — 数据模型 `⬜ 待处理`

文件：`server/src/skill/skill_model.rs`（重写）

### 3.1 Skill 结构体 `⬜`

```rust
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
    pub file_count: u32,
    pub total_size: u64,
    pub entry_file: String,
    pub storage_path: String,
    pub status: String,
    pub created_at: String,
    pub updated_at: String,
}
```

### 3.2 SkillSummary 结构体（列表用，不含 storage_path） `⬜`

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
    pub file_count: u32,
    pub total_size: u64,
    pub created_at: String,
    pub updated_at: String,
}
```

### 3.3 SkillFile 结构体 `⬜`

```rust
#[derive(Debug, Clone, Serialize, FromRow)]
pub struct SkillFile {
    pub id: u64,
    pub skill_id: u64,
    pub file_path: String,
    pub file_name: String,
    pub file_size: u64,
    pub is_dir: bool,
    pub mime_type: String,
}
```

### 3.4 UploadResult 结构体 `⬜`

```rust
#[derive(Debug, Serialize)]
pub struct UploadResult {
    pub id: u64,
    pub name: String,
    pub file_count: u32,
    pub total_size: u64,
}
```

### 3.5 PagedList 结构体 `⬜`

```rust
#[derive(Debug, Serialize)]
pub struct PagedList<T: Serialize> {
    pub list: Vec<T>,
    pub total: i64,
    pub page: u32,
    pub page_size: u32,
}
```

### 3.6 SkillMeta（从 front-matter 解析） `⬜`

```rust
#[derive(Debug, Deserialize)]
pub struct SkillMeta {
    pub name: String,
    pub description: Option<String>,
    pub author: Option<String>,
    pub tags: Option<Vec<String>>,
    pub icon_url: Option<String>,
    pub source_url: Option<String>,
    pub version: Option<String>,
    pub download_url: Option<String>,
}
```

---

## 任务 4：skill_repository.rs — 存储层 `⬜ 待处理`

文件：`server/src/skill/skill_repository.rs`（重写）

### 4.1 insert_skill `⬜`

```rust
pub async fn insert_skill(db: &MySqlPool, meta: &SkillMeta, storage_path: &str) -> Result<u64, sqlx::Error>
```

SQL: INSERT INTO skills (name, description, author, tags, icon_url, source_url, version, download_url, storage_path)

### 4.2 insert_file `⬜`

```rust
pub async fn insert_file(db: &MySqlPool, skill_id: u64, file_path: &str, file_name: &str, file_size: u64, is_dir: bool, mime_type: &str) -> Result<(), sqlx::Error>
```

### 4.3 update_skill_stats `⬜`

```rust
pub async fn update_skill_stats(db: &MySqlPool, skill_id: u64, file_count: u32, total_size: u64) -> Result<(), sqlx::Error>
```

### 4.4 find_published（分页列表） `⬜`

```rust
pub async fn find_published(db: &MySqlPool, offset: u32, limit: u32) -> Result<Vec<SkillSummary>, sqlx::Error>
```

### 4.5 count_published `⬜`

```rust
pub async fn count_published(db: &MySqlPool) -> Result<i64, sqlx::Error>
```

### 4.6 find_by_id `⬜`

```rust
pub async fn find_by_id(db: &MySqlPool, id: u64) -> Result<Option<Skill>, sqlx::Error>
```

### 4.7 find_files_by_skill_id `⬜`

```rust
pub async fn find_files_by_skill_id(db: &MySqlPool, skill_id: u64) -> Result<Vec<SkillFile>, sqlx::Error>
```

### 4.8 delete_skill `⬜`

```rust
pub async fn delete_skill(db: &MySqlPool, id: u64) -> Result<(), sqlx::Error>
```

SQL: DELETE FROM skills WHERE id = ?（CASCADE 自动删 skill_files）

---

## 任务 5：skill_service.rs — 服务层 `⬜ 待处理`

文件：`server/src/skill/skill_service.rs`（重写）

### 5.1 upload_skill — 核心上传逻辑 `⬜`

```rust
pub async fn upload_skill(db: &MySqlPool, storage_root: &str, zip_bytes: Vec<u8>) -> Result<UploadResult, AppError>
```

逻辑步骤：
1. 用 `zip::ZipArchive::new(Cursor::new(zip_bytes))` 打开 zip
2. 遍历文件列表，找到 SKILL.md（可能在根目录或子目录）
3. 读取 SKILL.md 内容，解析 YAML front-matter → SkillMeta
4. 如果 name 为空，返回 400
5. 调用 repository::insert_skill，获取 skill_id
6. 创建磁盘目录 `{storage_root}/skills/{skill_id}/`
7. 遍历 zip 中所有文件：
   - 写入磁盘
   - 调用 repository::insert_file 记录元信息
   - 累计 file_count 和 total_size
8. 调用 repository::update_skill_stats
9. 返回 UploadResult

### 5.2 parse_front_matter — 解析 YAML `⬜`

```rust
fn parse_front_matter(content: &str) -> Option<SkillMeta>
```

逻辑：找 `---` 开头和第二个 `---`，中间内容用 serde_yaml 解析。

### 5.3 guess_mime_type — 推断 MIME 类型 `⬜`

```rust
fn guess_mime_type(file_name: &str) -> &'static str
```

匹配规则：.md → text/markdown, .dart → text/x-dart, .rs → text/x-rust, .py → text/x-python, .yaml/.yml → text/yaml, .json → application/json, 其他 → application/octet-stream

### 5.4 list_skills — 列表查询 `⬜`

同 v0.0.2，调用 repository 分页查询。

### 5.5 get_skill — 详情查询 `⬜`

查询 skill + 读取 entry_file 内容返回。

### 5.6 get_files — 文件目录 `⬜`

调用 repository::find_files_by_skill_id。

### 5.7 get_file_content — 单文件内容 `⬜`

```rust
pub async fn get_file_content(db: &MySqlPool, storage_root: &str, skill_id: u64, file_path: &str) -> Result<FileContent, AppError>
```

逻辑：
1. 查询 skill 获取 storage_path
2. 拼接磁盘路径，读取文件内容
3. 判断 mime_type，如果是二进制返回 400
4. 返回 { content, mime_type }

### 5.8 delete_skill — 删除 `⬜`

1. 查询 skill 获取 storage_path
2. 删除磁盘目录 `rm_rf`
3. 调用 repository::delete_skill（CASCADE 删 files 记录）

---

## 任务 6：skill_router.rs — 路由层 `⬜ 待处理`

文件：`server/src/skill/skill_router.rs`（重写）

### 6.1 upload handler `⬜`

```rust
async fn upload(State(state): State<AppState>, mut multipart: Multipart) -> Result<Json<AppResponse<UploadResult>>, AppError>
```

从 multipart 提取 `file` 字段的 bytes，调用 service::upload_skill。

### 6.2 list_skills handler `⬜`

同 v0.0.2。

### 6.3 get_skill handler `⬜`

同 v0.0.2（响应扩展 file_count/total_size/entry_file 内容）。

### 6.4 get_files handler `⬜`

```rust
async fn get_files(State(state): State<AppState>, Path(id): Path<u64>) -> Result<Json<AppResponse<Vec<SkillFile>>>, AppError>
```

### 6.5 get_file_content handler `⬜`

```rust
async fn get_file_content(State(state): State<AppState>, Path((id, path)): Path<(u64, String)>) -> Result<Json<AppResponse<FileContent>>, AppError>
```

### 6.6 delete_skill handler `⬜`

```rust
async fn delete_skill(State(state): State<AppState>, Path(id): Path<u64>) -> Result<Json<AppResponse<()>>, AppError>
```

### 6.7 路由定义 `⬜`

```rust
pub fn skill_routes() -> Router<AppState> {
    Router::new()
        .route("/api/skills", get(list_skills))
        .route("/api/skills/upload", post(upload))
        .route("/api/skills/:id", get(get_skill).delete(delete_skill))
        .route("/api/skills/:id/files", get(get_files))
        .route("/api/skills/:id/files/*path", get(get_file_content))
}
```

---

## 任务 7：main.rs — 更新 `⬜ 待处理`

文件：`server/src/main.rs`（修改）

### 7.1 AppState 增加 storage_root `⬜`

```rust
#[derive(Clone)]
pub struct AppState {
    pub db: MySqlPool,
    pub storage_root: String,
}
```

从环境变量 `STORAGE_PATH` 读取，默认 `./storage`。

### 7.2 启动时创建 storage 目录 `⬜`

```rust
std::fs::create_dir_all(format!("{}/skills", &storage_root)).ok();
```

---

## 任务 8：编译验证 `⬜ 待处理`

```bash
cargo build
```

---

## 任务 9：generate_meta.py — 种子脚本 `⬜ 待处理`

文件：`scripts/server/generate_meta.py`（新建）

### 9.1 逻辑 `⬜`

1. 遍历 `scripts/server/data/` 下所有包含 SKILL.md 的文件夹
2. 将每个文件夹打包为内存 zip
3. 调用 `POST /api/skills/upload` multipart 上传
4. 打印结果

### 9.2 倒序上传 `⬜`

按文件夹名排序后倒序上传，保证列表顺序合理。

---

## 任务 10：启动验证 `⬜ 待处理`

### 10.1 数据库重建 `⬜`

```bash
python scripts/deploy/db.py reset
```

### 10.2 启动服务 + 种子灌入 `⬜`

```bash
cargo run
# 另一终端
python scripts/server/generate_meta.py
```

### 10.3 手动验证 `⬜`

```bash
# 列表
curl http://localhost:3000/api/skills

# 文件目录
curl http://localhost:3000/api/skills/1/files

# 单文件内容
curl http://localhost:3000/api/skills/1/files/SKILL.md
```
