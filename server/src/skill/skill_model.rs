use serde::{Deserialize, Serialize};
use sqlx::FromRow;

/// 技能完整信息（详情接口返回）
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

/// 技能摘要（列表接口返回，不含 content）
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

/// 分页结果
#[derive(Debug, Serialize)]
pub struct PagedList<T: Serialize> {
    pub list: Vec<T>,
    pub total: i64,
    pub page: u32,
    pub page_size: u32,
}

/// 创建技能输入
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
