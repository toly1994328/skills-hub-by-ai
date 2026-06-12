use axum::Json;
use serde::Serialize;

#[derive(Serialize)]
pub struct AppResponse<T: Serialize> {
    pub code: i32,
    pub data: Option<T>,
    pub message: String,
}

impl<T: Serialize> AppResponse<T> {
    pub fn success(data: T) -> Json<AppResponse<T>> {
        Json(AppResponse {
            code: 0,
            data: Some(data),
            message: "success".to_string(),
        })
    }
}
