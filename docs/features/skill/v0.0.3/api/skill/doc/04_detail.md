# GET /api/skills/:id

查询技能详情，含 entry_file 内容。

## Response `200`

```json
{
  "code": 0,
  "data": {
    "id": 1,
    "name": "Test Skill",
    "description": "A test skill for API testing",
    "author": "test_bot",
    "tags": "test,api",
    "icon_url": "",
    "source_url": "https://github.com/test/skill",
    "version": "1.0.0",
    "download_url": "",
    "file_count": 3,
    "total_size": 365,
    "entry_file": "SKILL.md",
    "storage_path": "1",
    "status": "published",
    "created_at": "2026-06-14 16:43:29",
    "updated_at": "2026-06-14 16:43:29",
    "entry_content": "---\nname: Test Skill\ndescription: A test skill for API testing\nauthor: test_bot\ntags:\n  - test\n  - api\nversion: \"1.0.0\"\nsource_url: https://github.com/test/skill\n---\n\n# Test Skill\n\nThis is a test skill with multiple files.\n\n## Features\n\n- Feature A\n- Feature B\n\n```python\nprint(\"hello world\")\n```\n"
  },
  "message": "success"
}
```
