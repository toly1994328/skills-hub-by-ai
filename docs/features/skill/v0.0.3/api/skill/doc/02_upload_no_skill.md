# POST /api/skills/upload

上传不含 SKILL.md 的 zip — 返回 400。

## Response `400`

```json
{
  "code": 400,
  "data": null,
  "message": "zip 中未找到 SKILL.md 文件"
}
```

> 错误场景
