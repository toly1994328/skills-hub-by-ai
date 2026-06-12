mod app_error;
mod app_response;
mod net_util;
mod skill;

use std::env;
use std::net::SocketAddr;

use axum::extract::State;
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
}

#[tokio::main]
async fn main() {
    dotenv().ok();
    tracing_subscriber::fmt::init();

    let db_url = env::var("DATABASE_URL").expect("DATABASE_URL must be set");
    let pool = MySqlPool::connect(&db_url)
        .await
        .expect("Failed to connect to database");

    // 启动时查询当前日期
    let row: (String,) = sqlx::query_as("SELECT CAST(CURDATE() AS CHAR) as today")
        .fetch_one(&pool)
        .await
        .expect("Failed to query current date");
    println!("Database connected! Current date: {}", row.0);

    let state = AppState { db: pool };

    let app = Router::new()
        .route("/", get(health))
        .route("/date", get(query_date))
        .merge(skill::skill_router::skill_routes())
        .layer(
            CorsLayer::new()
                .allow_origin(Any)
                .allow_methods(Any)
                .allow_headers(Any),
        )
        .layer(TraceLayer::new_for_http())
        .with_state(state);

    let addr = env::var("SERVER_ADDRESS").unwrap_or_else(|_| "0.0.0.0:3000".to_string());
    let listener = tokio::net::TcpListener::bind(&addr).await.unwrap();
    let local_ip = net_util::get_local_ip();
    let port = listener.local_addr().unwrap().port();
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

async fn query_date(State(state): State<AppState>) -> Json<Value> {
    let row: (String,) = sqlx::query_as("SELECT CAST(CURDATE() AS CHAR) as today")
        .fetch_one(&state.db)
        .await
        .unwrap();
    Json(json!({ "date": row.0 }))
}
