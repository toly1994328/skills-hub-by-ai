# POST /api/skills/upload

上传 zip 压缩包创建技能。后端解压、解析 front-matter、存储文件。

## Request

```
Content-Type: application/zip, Body: binary zip data
```

## Response `200`

```json
{
  "code": 0,
  "data": {
    "id": 1,
    "name": "Test Skill",
    "file_count": 3,
    "total_size": 365
  },
  "message": "success"
}
```

> 请求体直接是 zip 二进制内容
