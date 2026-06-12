# GET /api/skills/:id

查询不存在的技能 — 返回 404。

## Response `404`

```json
{
  "code": 404,
  "data": null,
  "message": "技能不存在"
}
```

## curl

```bash
curl -s -X GET "http://localhost:3000/api/skills/:id"
```

> 错误场景：ID 不存在时返回 404
