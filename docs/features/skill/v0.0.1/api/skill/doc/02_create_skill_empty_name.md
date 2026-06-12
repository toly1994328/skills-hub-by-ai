# POST /api/skills

创建技能 — name 为空时返回 400。

## Request Body

```json
{
  "name": "",
  "content": "some content"
}
```

## Response `400`

```json
{
  "code": 400,
  "data": null,
  "message": "name 不能为空"
}
```

## curl

```bash
curl -s -X POST "http://localhost:3000/api/skills" -H "Content-Type: application/json" -d '{"name": "", "content": "some content"}'
```

> 错误场景：name 字段不能为空
