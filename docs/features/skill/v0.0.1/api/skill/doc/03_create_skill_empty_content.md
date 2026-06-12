# POST /api/skills

创建技能 — content 为空时返回 400。

## Request Body

```json
{
  "name": "Valid Name",
  "content": ""
}
```

## Response `400`

```json
{
  "code": 400,
  "data": null,
  "message": "content 不能为空"
}
```

## curl

```bash
curl -s -X POST "http://localhost:3000/api/skills" -H "Content-Type: application/json" -d '{"name": "Valid Name", "content": ""}'
```

> 错误场景：content 字段不能为空
