use axum::body::Bytes;
use axum::extract::{Path, Query, State};
use axum::routing::{get, post};
use axum::{Json, Router};
use serde::{Deserialize, Serialize};

use crate::app_error::AppError;
use crate::app_response::AppResponse;
use crate::AppState;

use super::skill_model::{FileContent, PagedList, Skill, SkillFile, SkillSummary, UploadResult};
use super::skill_service;

#[derive(Deserialize)]
pub struct ListParams {
    pub page: Option<u32>,
    pub page_size: Option<u32>,
}

#[derive(Serialize)]
pub struct SkillDetail {
    #[serde(flatten)]
    pub skill: Skill,
    pub entry_content: String,
}

async fn upload(
    State(state): State<AppState>,
    body: Bytes,
) -> Result<Json<AppResponse<UploadResult>>, AppError> {
    if body.is_empty() {
        return Err(AppError::bad_request("未找到上传文件"));
    }
    let result: UploadResult =
        skill_service::upload_skill(&state.db, &state.storage_root, body.to_vec()).await?;
    Ok(AppResponse::success(result))
}

async fn list_skills(
    State(state): State<AppState>,
    Query(params): Query<ListParams>,
) -> Result<Json<AppResponse<PagedList<SkillSummary>>>, AppError> {
    let page: u32 = params.page.unwrap_or(1);
    let page_size: u32 = params.page_size.unwrap_or(20);
    let result: PagedList<SkillSummary> =
        skill_service::list_skills(&state.db, page, page_size).await?;
    Ok(AppResponse::success(result))
}

async fn get_skill(
    State(state): State<AppState>,
    Path(id): Path<u64>,
) -> Result<Json<AppResponse<SkillDetail>>, AppError> {
    let (skill, entry_content): (Skill, String) =
        skill_service::get_skill(&state.db, &state.storage_root, id).await?;
    Ok(AppResponse::success(SkillDetail {
        skill,
        entry_content,
    }))
}

async fn get_files(
    State(state): State<AppState>,
    Path(id): Path<u64>,
) -> Result<Json<AppResponse<Vec<SkillFile>>>, AppError> {
    let files: Vec<SkillFile> = skill_service::get_files(&state.db, id).await?;
    Ok(AppResponse::success(files))
}

async fn get_file_content(
    State(state): State<AppState>,
    Path((id, path)): Path<(u64, String)>,
) -> Result<Json<AppResponse<FileContent>>, AppError> {
    let content: FileContent =
        skill_service::get_file_content(&state.db, &state.storage_root, id, &path).await?;
    Ok(AppResponse::success(content))
}

async fn delete_skill_handler(
    State(state): State<AppState>,
    Path(id): Path<u64>,
) -> Result<Json<AppResponse<()>>, AppError> {
    skill_service::delete_skill(&state.db, &state.storage_root, id).await?;
    Ok(AppResponse::success(()))
}

pub fn skill_routes() -> Router<AppState> {
    Router::new()
        .route("/api/skills", get(list_skills))
        .route("/api/skills/upload", post(upload))
        .route(
            "/api/skills/:id",
            get(get_skill).delete(delete_skill_handler),
        )
        .route("/api/skills/:id/files", get(get_files))
        .route("/api/skills/:id/files/*path", get(get_file_content))
}
