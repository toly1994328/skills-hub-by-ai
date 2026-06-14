use serde::{Deserialize, Serialize};
use sqlx::FromRow;

/// 技能完整信息
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

/// 技能摘要（列表用）
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

/// 技能文件元信息
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

/// 上传结果
#[derive(Debug, Serialize)]
pub struct UploadResult {
    pub id: u64,
    pub name: String,
    pub file_count: u32,
    pub total_size: u64,
}

/// 文件内容响应
#[derive(Debug, Serialize)]
pub struct FileContent {
    pub file_path: String,
    pub mime_type: String,
    pub content: String,
}

/// 分页结果
#[derive(Debug, Serialize)]
pub struct PagedList<T: Serialize> {
    pub list: Vec<T>,
    pub total: i64,
    pub page: u32,
    pub page_size: u32,
}

/// 从 SKILL.md front-matter 解析的元信息
#[derive(Debug, Deserialize)]
pub struct SkillMeta {
    pub name: String,
    #[serde(default)]
    pub description: Option<String>,
    #[serde(default)]
    pub author: Option<String>,
    #[serde(default)]
    pub tags: Option<Vec<String>>,
    #[serde(default)]
    pub icon_url: Option<String>,
    #[serde(default)]
    pub source_url: Option<String>,
    #[serde(default)]
    pub version: Option<String>,
    #[serde(default)]
    pub download_url: Option<String>,
}
