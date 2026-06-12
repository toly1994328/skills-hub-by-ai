# GET /api/skills

分页查询已发布的技能列表。列表不返回 content 字段。

## Query Parameters

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| page | int | 否 | 页码，默认 1 |
| page_size | int | 否 | 每页条数，默认 20，最大 100 |

## Response `200`

```json
{
  "code": 0,
  "data": {
    "list": [
      {
        "id": 7,
        "name": "Test Skill",
        "description": "用于测试的技能",
        "author": "test_author",
        "tags": "测试,API",
        "icon_url": "https://example.com/icon.png",
        "source_url": "https://github.com/test/skill",
        "version": "1.0.0",
        "download_url": "https://example.com/download.zip",
        "created_at": "2026-06-12 00:32:31",
        "updated_at": "2026-06-12 00:32:31"
      },
      {
        "id": 6,
        "name": "Rust API Scaffold",
        "description": "Axum + SQLx 后端项目脚手架，内置分层架构、错误处理、日志追踪",
        "author": "李四",
        "tags": "Rust,后端,脚手架,Axum",
        "icon_url": "https://img.icons8.com/external-tal-revivo-color-tal-revivo/96/rust.png",
        "source_url": "https://github.com/example/rust-api-scaffold",
        "version": "0.5.0",
        "download_url": "https://github.com/example/rust-api-scaffold/releases/v0.5.0",
        "created_at": "2026-06-12 00:27:02",
        "updated_at": "2026-06-12 00:27:02"
      },
      {
        "id": 5,
        "name": "Flutter Bloc Snippet",
        "description": "一键生成 Flutter BLoC/Cubit 模板代码，包含 State、Event、Cubit 文件",
        "author": "张三",
        "tags": "Flutter,代码生成,状态管理",
        "icon_url": "https://img.icons8.com/color/96/flutter.png",
        "source_url": "https://github.com/example/flutter-bloc-snippet",
        "version": "2.0.1",
        "download_url": "https://github.com/example/flutter-bloc-snippet/releases/v2.0.1",
        "created_at": "2026-06-12 00:27:00",
        "updated_at": "2026-06-12 00:27:00"
      },
      {
        "id": 4,
        "name": "Cursor Rules Generator",
        "description": "根据项目结构自动生成 .cursorrules 文件，帮助 AI 理解项目上下文",
        "author": "toly",
        "tags": "AI,效率,开发工具",
        "icon_url": "https://img.icons8.com/fluency/96/cursor.png",
        "source_url": "https://github.com/example/cursor-rules-gen",
        "version": "1.2.0",
        "download_url": "https://github.com/example/cursor-rules-gen/releases/v1.2.0",
        "created_at": "2026-06-12 00:26:58",
        "updated_at": "2026-06-12 00:26:58"
      },
      {
        "id": 3,
        "name": "Rust API Scaffold",
        "description": "Axum + SQLx 后端项目脚手架，内置分层架构、错误处理、日志追踪",
        "author": "李四",
        "tags": "Rust,后端,脚手架,Axum",
        "icon_url": "https://img.icons8.com/external-tal-revivo-color-tal-revivo/96/rust.png",
        "source_url": "https://github.com/example/rust-api-scaffold",
        "version": "0.5.0",
        "download_url": "https://github.com/example/rust-api-scaffold/releases/v0.5.0",
        "created_at": "2026-06-12 00:24:58",
        "updated_at": "2026-06-12 00:24:58"
      },
      {
        "id": 2,
        "name": "Flutter Bloc Snippet",
        "description": "一键生成 Flutter BLoC/Cubit 模板代码，包含 State、Event、Cubit 文件",
        "author": "张三",
        "tags": "Flutter,代码生成,状态管理",
        "icon_url": "https://img.icons8.com/color/96/flutter.png",
        "source_url": "https://github.com/example/flutter-bloc-snippet",
        "version": "2.0.1",
        "download_url": "https://github.com/example/flutter-bloc-snippet/releases/v2.0.1",
        "created_at": "2026-06-12 00:24:56",
        "updated_at": "2026-06-12 00:24:56"
      },
      {
        "id": 1,
        "name": "Cursor Rules Generator",
        "description": "根据项目结构自动生成 .cursorrules 文件，帮助 AI 理解项目上下文",
        "author": "toly",
        "tags": "AI,效率,开发工具",
        "icon_url": "https://img.icons8.com/fluency/96/cursor.png",
        "source_url": "https://github.com/example/cursor-rules-gen",
        "version": "1.2.0",
        "download_url": "https://github.com/example/cursor-rules-gen/releases/v1.2.0",
        "created_at": "2026-06-12 00:24:54",
        "updated_at": "2026-06-12 00:24:54"
      }
    ],
    "total": 7,
    "page": 1,
    "page_size": 20
  },
  "message": "success"
}
```

## curl

```bash
curl -s -X GET "http://localhost:3000/api/skills"
```
