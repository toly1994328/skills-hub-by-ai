# GET /api/skills/:id

查询技能详情。返回完整信息，包含 Markdown 说明文档。

## Response `200`

```json
{
  "code": 0,
  "data": {
    "id": 7,
    "name": "Test Skill",
    "description": "用于测试的技能",
    "author": "test_author",
    "tags": "测试,API",
    "icon_url": "https://example.com/icon.png",
    "source_url": "https://github.com/test/skill",
    "version": "1.0.0",
    "download_url": "https://example.com/download.zip",
    "content": "# Test Skill\n\n这是测试技能的 Markdown 文档。\n\n## 功能\n\n- 功能A\n- 功能B",
    "status": "published",
    "created_at": "2026-06-12 00:32:31",
    "updated_at": "2026-06-12 00:32:31"
  },
  "message": "success"
}
```

## curl

```bash
curl -s -X GET "http://localhost:3000/api/skills/:id"
```

> 实际请求路径：/api/skills/7
