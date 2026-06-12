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

impl AppError {
    pub fn bad_request(msg: impl Into<String>) -> Self {
        AppError::BadRequest(msg.into())
    }

    pub fn not_found(msg: impl Into<String>) -> Self {
        AppError::NotFound(msg.into())
    }

    pub fn internal(err: impl std::fmt::Display, context: &str) -> Self {
        AppError::Internal(format!("{}: {}", context, err))
    }
}

impl IntoResponse for AppError {
    fn into_response(self) -> Response {
        let (status, code, message) = match &self {
            AppError::BadRequest(msg) => (StatusCode::BAD_REQUEST, 400, msg.clone()),
            AppError::NotFound(msg) => (StatusCode::NOT_FOUND, 404, msg.clone()),
            AppError::Internal(msg) => {
                tracing::error!("{}", msg);
                (
                    StatusCode::INTERNAL_SERVER_ERROR,
                    500,
                    "内部服务错误".to_string(),
                )
            }
        };

        let body = json!({
            "code": code,
            "data": null,
            "message": message,
        });

        (status, Json(body)).into_response()
    }
}

impl From<sqlx::Error> for AppError {
    fn from(err: sqlx::Error) -> Self {
        AppError::Internal(format!("Database error: {}", err))
    }
}
