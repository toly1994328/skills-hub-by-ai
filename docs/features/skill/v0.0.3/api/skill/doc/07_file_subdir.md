# GET /api/skills/:id/files/*path

查询子目录下文件内容。

## Response `200`

```json
{
  "code": 0,
  "data": {
    "file_path": "references/guide.md",
    "mime_type": "text/markdown",
    "content": "# Guide\n\nThis is a reference guide.\n"
  },
  "message": "success"
}
```

> 支持任意深度路径
