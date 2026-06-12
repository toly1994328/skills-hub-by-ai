use sqlx::MySqlPool;

use crate::app_error::AppError;

use super::skill_model::{CreateSkillInput, PagedList, Skill, SkillSummary};
use super::skill_repository;

/// 分页查询技能列表
pub async fn list_skills(
    db: &MySqlPool,
    page: u32,
    page_size: u32,
) -> Result<PagedList<SkillSummary>, AppError> {
    let page = page.max(1);
    let page_size = page_size.clamp(1, 100);
    let offset = (page - 1) * page_size;

    let list = skill_repository::find_published(db, offset, page_size).await?;
    let total = skill_repository::count_published(db).await?;

    Ok(PagedList {
        list,
        total,
        page,
        page_size,
    })
}

/// 查询技能详情
pub async fn get_skill(db: &MySqlPool, id: u64) -> Result<Skill, AppError> {
    skill_repository::find_by_id(db, id)
        .await?
        .ok_or_else(|| AppError::not_found("技能不存在"))
}

/// 创建技能
pub async fn create_skill(db: &MySqlPool, input: CreateSkillInput) -> Result<u64, AppError> {
    if input.name.trim().is_empty() {
        return Err(AppError::bad_request("name 不能为空"));
    }
    if input.content.trim().is_empty() {
        return Err(AppError::bad_request("content 不能为空"));
    }

    let id = skill_repository::insert(db, &input).await?;
    Ok(id)
}
