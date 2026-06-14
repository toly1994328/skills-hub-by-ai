# GET /api/skills/:id/files/*path

文件不存在时返回 404。

## Response `404`

```json
{
  "code": 404,
  "data": null,
  "message": "文件不存在"
}
```

> 错误场景
