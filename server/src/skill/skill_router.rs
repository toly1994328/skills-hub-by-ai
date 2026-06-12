use axum::extract::{Path, Query, State};
use axum::routing::get;
use axum::{Json, Router};
use serde::{Deserialize, Serialize};

use crate::app_error::AppError;
use crate::app_response::AppResponse;
use crate::AppState;

use super::skill_model::{CreateSkillInput, PagedList, Skill, SkillSummary};
use super::skill_service;

#[derive(Deserialize)]
pub struct ListParams {
    pub page: Option<u32>,
    pub page_size: Option<u32>,
}

#[derive(Serialize)]
pub struct InsertResult {
    pub id: u64,
}

async fn list_skills(
    State(state): State<AppState>,
    Query(params): Query<ListParams>,
) -> Result<Json<AppResponse<PagedList<SkillSummary>>>, AppError> {
    let page = params.page.unwrap_or(1);
    let page_size = params.page_size.unwrap_or(20);
    let result = skill_service::list_skills(&state.db, page, page_size).await?;
    Ok(AppResponse::success(result))
}

async fn get_skill(
    State(state): State<AppState>,
    Path(id): Path<u64>,
) -> Result<Json<AppResponse<Skill>>, AppError> {
    let skill = skill_service::get_skill(&state.db, id).await?;
    Ok(AppResponse::success(skill))
}

async fn create_skill(
    State(state): State<AppState>,
    Json(input): Json<CreateSkillInput>,
) -> Result<Json<AppResponse<InsertResult>>, AppError> {
    let id = skill_service::create_skill(&state.db, input).await?;
    Ok(AppResponse::success(InsertResult { id }))
}

pub fn skill_routes() -> Router<AppState> {
    Router::new()
        .route("/api/skills", get(list_skills).post(create_skill))
        .route("/api/skills/:id", get(get_skill))
}
