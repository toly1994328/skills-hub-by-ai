mod app_error;
mod app_response;
mod net_util;
mod skill;

use std::env;
use std::net::SocketAddr;

use axum::extract::DefaultBodyLimit;
use axum::routing::get;
use axum::{Json, Router};
use dotenvy::dotenv;
use serde_json::{json, Value};
use sqlx::MySqlPool;
use tower_http::cors::{Any, CorsLayer};
use tower_http::trace::TraceLayer;

#[derive(Clone)]
pub struct AppState {
    pub db: MySqlPool,
    pub storage_root: String,
}

#[tokio::main]
async fn main() {
    dotenv().ok();
    tracing_subscriber::fmt::init();

    let db_url: String = env::var("DATABASE_URL").expect("DATABASE_URL must be set");
    let pool: MySqlPool = MySqlPool::connect(&db_url)
        .await
        .expect("Failed to connect to database");

    // 启动时查询当前日期
    let row: (String,) = sqlx::query_as("SELECT CAST(CURDATE() AS CHAR) as today")
        .fetch_one(&pool)
        .await
        .expect("Failed to query current date");
    println!("Database connected! Current date: {}", row.0);

    // 存储根路径
    let storage_root: String = env::var("STORAGE_PATH").unwrap_or_else(|_| "./storage".to_string());
    std::fs::create_dir_all(format!("{}/skills", &storage_root)).ok();
    println!("Storage root: {}", &storage_root);

    let state: AppState = AppState {
        db: pool,
        storage_root,
    };

    let app: Router = Router::new()
        .route("/", get(health))
        .merge(skill::skill_router::skill_routes())
        .layer(DefaultBodyLimit::max(50 * 1024 * 1024)) // 50MB
        .layer(
            CorsLayer::new()
                .allow_origin(Any)
                .allow_methods(Any)
                .allow_headers(Any),
        )
        .layer(TraceLayer::new_for_http())
        .with_state(state);

    let addr: String = env::var("SERVER_ADDRESS").unwrap_or_else(|_| "0.0.0.0:3000".to_string());
    let listener: tokio::net::TcpListener = tokio::net::TcpListener::bind(&addr).await.unwrap();
    let local_ip: String = net_util::get_local_ip();
    let port: u16 = listener.local_addr().unwrap().port();
    println!("Server listening on {}", listener.local_addr().unwrap());
    println!("LAN access: http://{}:{}", local_ip, port);
    axum::serve(
        listener,
        app.into_make_service_with_connect_info::<SocketAddr>(),
    )
    .await
    .unwrap();
}

async fn health() -> Json<Value> {
    Json(json!({ "status": "ok" }))
}
