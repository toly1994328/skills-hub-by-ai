# GET /api/skills/:id/files

查询技能的文件目录列表。

## Response `200`

```json
{
  "code": 0,
  "data": [
    {
      "id": 3,
      "skill_id": 1,
      "file_path": "examples/demo.py",
      "file_name": "demo.py",
      "file_size": 32,
      "is_dir": false,
      "mime_type": "text/x-python"
    },
    {
      "id": 2,
      "skill_id": 1,
      "file_path": "references/guide.md",
      "file_name": "guide.md",
      "file_size": 36,
      "is_dir": false,
      "mime_type": "text/markdown"
    },
    {
      "id": 1,
      "skill_id": 1,
      "file_path": "SKILL.md",
      "file_name": "SKILL.md",
      "file_size": 297,
      "is_dir": false,
      "mime_type": "text/markdown"
    }
  ],
  "message": "success"
}
```
