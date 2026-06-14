# GET /api/skills

分页查询技能列表。

## Query Parameters

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| page | int | 否 | 页码，默认 1 |
| page_size | int | 否 | 每页条数，默认 20 |

## Response `200`

```json
{
  "code": 0,
  "data": {
    "list": [
      {
        "id": 1,
        "name": "Test Skill",
        "description": "A test skill for API testing",
        "author": "test_bot",
        "tags": "test,api",
        "icon_url": "",
        "source_url": "https://github.com/test/skill",
        "version": "1.0.0",
        "download_url": "",
        "file_count": 3,
        "total_size": 365,
        "created_at": "2026-06-14 16:43:29",
        "updated_at": "2026-06-14 16:43:29"
      }
    ],
    "total": 1,
    "page": 1,
    "page_size": 20
  },
  "message": "success"
}
```
