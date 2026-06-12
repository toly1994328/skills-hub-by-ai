use sqlx::MySqlPool;

use super::skill_model::{CreateSkillInput, Skill, SkillSummary};

/// 分页查询已发布技能列表
pub async fn find_published(
    db: &MySqlPool,
    offset: u32,
    limit: u32,
) -> Result<Vec<SkillSummary>, sqlx::Error> {
    let rows = sqlx::query_as::<_, SkillSummary>(
        "SELECT id, name, description, author, tags, icon_url, source_url, version, download_url,
                DATE_FORMAT(created_at, '%Y-%m-%d %H:%i:%s') as created_at,
                DATE_FORMAT(updated_at, '%Y-%m-%d %H:%i:%s') as updated_at
         FROM skills
         WHERE status = 'published'
         ORDER BY updated_at DESC
         LIMIT ? OFFSET ?",
    )
    .bind(limit)
    .bind(offset)
    .fetch_all(db)
    .await?;

    Ok(rows)
}

/// 查询已发布技能总数
pub async fn count_published(db: &MySqlPool) -> Result<i64, sqlx::Error> {
    let (count,): (i64,) =
        sqlx::query_as("SELECT COUNT(*) FROM skills WHERE status = 'published'")
            .fetch_one(db)
            .await?;

    Ok(count)
}

/// 按 ID 查询技能详情
pub async fn find_by_id(db: &MySqlPool, id: u64) -> Result<Option<Skill>, sqlx::Error> {
    let row = sqlx::query_as::<_, Skill>(
        "SELECT id, name, description, author, tags, icon_url, source_url, version, download_url,
                content, status,
                DATE_FORMAT(created_at, '%Y-%m-%d %H:%i:%s') as created_at,
                DATE_FORMAT(updated_at, '%Y-%m-%d %H:%i:%s') as updated_at
         FROM skills
         WHERE id = ? AND status = 'published'",
    )
    .bind(id)
    .fetch_optional(db)
    .await?;

    Ok(row)
}

/// 插入新技能，返回新记录 ID
pub async fn insert(db: &MySqlPool, input: &CreateSkillInput) -> Result<u64, sqlx::Error> {
    let result = sqlx::query(
        "INSERT INTO skills (name, description, author, tags, icon_url, source_url, version, download_url, content, status)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'published')",
    )
    .bind(&input.name)
    .bind(input.description.as_deref().unwrap_or(""))
    .bind(input.author.as_deref().unwrap_or(""))
    .bind(input.tags.as_deref().unwrap_or(""))
    .bind(input.icon_url.as_deref().unwrap_or(""))
    .bind(input.source_url.as_deref().unwrap_or(""))
    .bind(input.version.as_deref().unwrap_or("0.0.1"))
    .bind(input.download_url.as_deref().unwrap_or(""))
    .bind(&input.content)
    .execute(db)
    .await?;

    Ok(result.last_insert_id())
}
