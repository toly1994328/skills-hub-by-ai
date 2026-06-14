# GET /api/skills/:id/files/*path

查询单个文件的文本内容。

## Response `200`

```json
{
  "code": 0,
  "data": {
    "file_path": "SKILL.md",
    "mime_type": "text/markdown",
    "content": "---\nname: Test Skill\ndescription: A test skill for API testing\nauthor: test_bot\ntags:\n  - test\n  - api\nversion: \"1.0.0\"\nsource_url: https://github.com/test/skill\n---\n\n# Test Skill\n\nThis is a test skill with multiple files.\n\n## Features\n\n- Feature A\n- Feature B\n\n```python\nprint(\"hello world\")\n```\n"
  },
  "message": "success"
}
```
