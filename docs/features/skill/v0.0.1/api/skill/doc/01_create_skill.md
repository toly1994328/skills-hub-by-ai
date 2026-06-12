# POST /api/skills

创建新技能。

## Parameters

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| name | string | 是 | 技能名称 |
| description | string | 否 | 简短描述 |
| author | string | 否 | 作者 |
| tags | string | 否 | 标签，逗号分隔 |
| icon_url | string | 否 | 图标 URL |
| source_url | string | 否 | 来源网站 URL |
| version | string | 否 | 语义化版本号 |
| download_url | string | 否 | 下载链接 |
| content | string | 是 | Markdown 说明文档 |

## Request Body

```json
{
  "name": "Test Skill",
  "description": "用于测试的技能",
  "author": "test_author",
  "tags": "测试,API",
  "icon_url": "https://example.com/icon.png",
  "source_url": "https://github.com/test/skill",
  "version": "1.0.0",
  "download_url": "https://example.com/download.zip",
  "content": "# Test Skill\n\n这是测试技能的 Markdown 文档。\n\n## 功能\n\n- 功能A\n- 功能B"
}
```

## Response `200`

```json
{
  "code": 0,
  "data": {
    "id": 7
  },
  "message": "success"
}
```

## curl

```bash
curl -s -X POST "http://localhost:3000/api/skills" -H "Content-Type: application/json" -d '{"name": "Test Skill", "description": "用于测试的技能", "author": "test_author", "tags": "测试,API", "icon_url": "https://example.com/icon.png", "source_url": "https://github.com/test/skill", "version": "1.0.0", "download_url": "https://example.com/download.zip", "content": "# Test Skill\n\n这是测试技能的 Markdown 文档。\n\n## 功能\n\n- 功能A\n- 功能B"}'
```
