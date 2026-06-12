# GET /api/skills?page=1&page_size=1

分页查询验证 — page_size=1 时只返回 1 条。

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
      }
    ],
    "total": 7,
    "page": 1,
    "page_size": 1
  },
  "message": "success"
}
```

## curl

```bash
curl -s -X GET "http://localhost:3000/api/skills?page=1&page_size=1"
```

> 验证分页参数生效
