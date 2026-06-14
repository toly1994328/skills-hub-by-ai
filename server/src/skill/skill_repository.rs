use sqlx::MySqlPool;

use super::skill_model::{Skill, SkillFile, SkillSummary};

pub async fn insert_skill(
    db: &MySqlPool,
    name: &str,
    description: &str,
    author: &str,
    tags: &str,
    icon_url: &str,
    source_url: &str,
    version: &str,
    download_url: &str,
    storage_path: &str,
) -> Result<u64, sqlx::Error> {
    let result = sqlx::query(
        "INSERT INTO skills (name, description, author, tags, icon_url, source_url, version, download_url, storage_path)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)",
    )
    .bind(name)
    .bind(description)
    .bind(author)
    .bind(tags)
    .bind(icon_url)
    .bind(source_url)
    .bind(version)
    .bind(download_url)
    .bind(storage_path)
    .execute(db)
    .await?;

    Ok(result.last_insert_id())
}

pub async fn insert_file(
    db: &MySqlPool,
    skill_id: u64,
    file_path: &str,
    file_name: &str,
    file_size: u64,
    is_dir: bool,
    mime_type: &str,
) -> Result<(), sqlx::Error> {
    sqlx::query(
        "INSERT INTO skill_files (skill_id, file_path, file_name, file_size, is_dir, mime_type)
         VALUES (?, ?, ?, ?, ?, ?)",
    )
    .bind(skill_id)
    .bind(file_path)
    .bind(file_name)
    .bind(file_size)
    .bind(is_dir)
    .bind(mime_type)
    .execute(db)
    .await?;

    Ok(())
}

pub async fn update_skill_stats(
    db: &MySqlPool,
    skill_id: u64,
    file_count: u32,
    total_size: u64,
) -> Result<(), sqlx::Error> {
    sqlx::query("UPDATE skills SET file_count = ?, total_size = ? WHERE id = ?")
        .bind(file_count)
        .bind(total_size)
        .bind(skill_id)
        .execute(db)
        .await?;

    Ok(())
}

pub async fn find_published(
    db: &MySqlPool,
    offset: u32,
    limit: u32,
) -> Result<Vec<SkillSummary>, sqlx::Error> {
    sqlx::query_as::<_, SkillSummary>(
        "SELECT id, name, description, author, tags, icon_url, source_url, version, download_url,
                file_count, total_size,
                DATE_FORMAT(created_at, '%Y-%m-%d %H:%i:%s') as created_at,
                DATE_FORMAT(updated_at, '%Y-%m-%d %H:%i:%s') as updated_at
         FROM skills WHERE status = 'published'
         ORDER BY updated_at DESC LIMIT ? OFFSET ?",
    )
    .bind(limit)
    .bind(offset)
    .fetch_all(db)
    .await
}

pub async fn count_published(db: &MySqlPool) -> Result<i64, sqlx::Error> {
    let (count,): (i64,) =
        sqlx::query_as("SELECT COUNT(*) FROM skills WHERE status = 'published'")
            .fetch_one(db)
            .await?;
    Ok(count)
}

pub async fn find_by_id(db: &MySqlPool, id: u64) -> Result<Option<Skill>, sqlx::Error> {
    sqlx::query_as::<_, Skill>(
        "SELECT id, name, description, author, tags, icon_url, source_url, version, download_url,
                file_count, total_size, entry_file, storage_path, status,
                DATE_FORMAT(created_at, '%Y-%m-%d %H:%i:%s') as created_at,
                DATE_FORMAT(updated_at, '%Y-%m-%d %H:%i:%s') as updated_at
         FROM skills WHERE id = ?",
    )
    .bind(id)
    .fetch_optional(db)
    .await
}

pub async fn find_files_by_skill_id(
    db: &MySqlPool,
    skill_id: u64,
) -> Result<Vec<SkillFile>, sqlx::Error> {
    sqlx::query_as::<_, SkillFile>(
        "SELECT id, skill_id, file_path, file_name, file_size, is_dir, mime_type
         FROM skill_files WHERE skill_id = ? ORDER BY is_dir DESC, file_path ASC",
    )
    .bind(skill_id)
    .fetch_all(db)
    .await
}

pub async fn delete_skill(db: &MySqlPool, id: u64) -> Result<(), sqlx::Error> {
    sqlx::query("DELETE FROM skills WHERE id = ?")
        .bind(id)
        .execute(db)
        .await?;
    Ok(())
}
