"""
Skills Share v0.0.3 — 技能管理 API 测试链

运行方式：
    python skill.py              # 默认 localhost:3000
    python skill.py 192.168.1.5  # 指定 IP
"""

import io
import json
import os
import subprocess
import sys
import zipfile
import tempfile

# ─── 配置 ───

HOST = sys.argv[1] if len(sys.argv) > 1 else "localhost"
BASE = f"http://{HOST}:3000"

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
DOCS_DIR = os.path.join(SCRIPT_DIR, "..", "doc")
os.makedirs(DOCS_DIR, exist_ok=True)

# ─── 颜色 ───

CYAN = "\033[36m"
GREEN = "\033[32m"
RED = "\033[31m"
RESET = "\033[0m"

link_rows = []


def step(n, desc):
    print(f"{CYAN}========== [{n}] {desc} =========={RESET}")


def fail(msg):
    print(f"{RED}[FAIL] {msg}{RESET}")
    sys.exit(1)


def ok():
    print(f"{GREEN}[PASS]{RESET}")


def write_doc(filename, method, path, desc, body, status, response, params_desc=None, query_params=None, note=None):
    lines = [f"# {method} {path}\n", f"{desc}\n"]
    if query_params:
        lines.append("## Query Parameters\n")
        lines.append("| 参数 | 类型 | 必填 | 说明 |")
        lines.append("|------|------|------|------|")
        for p in query_params:
            lines.append(f"| {p['name']} | {p['type']} | {p['required']} | {p['desc']} |")
        lines.append("")
    if params_desc:
        lines.append("## Parameters\n")
        lines.append("| 参数 | 类型 | 必填 | 说明 |")
        lines.append("|------|------|------|------|")
        for p in params_desc:
            lines.append(f"| {p['name']} | {p['type']} | {p['required']} | {p['desc']} |")
        lines.append("")
    if body:
        lines.append("## Request\n")
        lines.append("```")
        lines.append(str(body))
        lines.append("```\n")
    lines.append(f"## Response `{status}`\n")
    lines.append("```json")
    if response.strip():
        try:
            lines.append(json.dumps(json.loads(response), indent=2, ensure_ascii=False))
        except json.JSONDecodeError:
            lines.append(response)
    else:
        lines.append("(empty body)")
    lines.append("```\n")
    if note:
        lines.append(f"> {note}\n")
    filepath = os.path.join(DOCS_DIR, filename)
    with open(filepath, "w", encoding="utf-8") as f:
        f.write("\n".join(lines))


def write_link():
    lines = ["# skill - API test link\n", f"Base URL: `{BASE}`\n"]
    lines.append("| # | Interface | Status | Result | Doc |")
    lines.append("|---|-----------|--------|--------|-----|")
    for row in link_rows:
        lines.append(f"| {row['n']} | `{row['method']} {row['path']}` | `{row['status']}` | {row['result']} | [{row['doc']}]({row['doc']}) |")
    lines.append("")
    filepath = os.path.join(DOCS_DIR, "00_link.md")
    with open(filepath, "w", encoding="utf-8") as f:
        f.write("\n".join(lines))


# ─── 工具 ───

def curl_get(url):
    result = subprocess.run(
        ["curl.exe", "-s", "-w", "\n%{http_code}", url],
        capture_output=True, text=True, encoding="utf-8"
    )
    parts = result.stdout.strip().rsplit("\n", 1)
    body = parts[0] if len(parts) == 2 else ""
    status = int(parts[-1]) if parts else 0
    data = None
    if body:
        try:
            data = json.loads(body).get("data")
        except:
            pass
    return {"status": status, "body": body, "data": data}


def curl_upload(url, zip_path):
    result = subprocess.run(
        ["curl.exe", "-s", "-w", "\n%{http_code}", "-X", "POST",
         "-H", "Content-Type: application/zip",
         "--data-binary", f"@{zip_path}", url],
        capture_output=True, text=True, encoding="utf-8"
    )
    parts = result.stdout.strip().rsplit("\n", 1)
    body = parts[0] if len(parts) == 2 else ""
    status = int(parts[-1]) if parts else 0
    data = None
    if body:
        try:
            data = json.loads(body).get("data")
        except:
            pass
    return {"status": status, "body": body, "data": data}


def curl_delete(url):
    result = subprocess.run(
        ["curl.exe", "-s", "-w", "\n%{http_code}", "-X", "DELETE", url],
        capture_output=True, text=True, encoding="utf-8"
    )
    parts = result.stdout.strip().rsplit("\n", 1)
    body = parts[0] if len(parts) == 2 else ""
    status = int(parts[-1]) if parts else 0
    return {"status": status, "body": body}


def create_test_zip():
    """创建一个测试用的 zip 文件"""
    buf = io.BytesIO()
    with zipfile.ZipFile(buf, 'w', zipfile.ZIP_DEFLATED) as zf:
        zf.writestr("SKILL.md", """---
name: Test Skill
description: A test skill for API testing
author: test_bot
tags:
  - test
  - api
version: "1.0.0"
source_url: https://github.com/test/skill
---

# Test Skill

This is a test skill with multiple files.

## Features

- Feature A
- Feature B

```python
print("hello world")
```
""")
        zf.writestr("references/guide.md", "# Guide\n\nThis is a reference guide.\n")
        zf.writestr("examples/demo.py", "# Demo\nprint('Hello from demo')\n")

    # 写到临时文件
    tmp = tempfile.NamedTemporaryFile(suffix=".zip", delete=False)
    tmp.write(buf.getvalue())
    tmp.close()
    return tmp.name


def create_bad_zip_no_skill():
    """创建没有 SKILL.md 的 zip"""
    buf = io.BytesIO()
    with zipfile.ZipFile(buf, 'w') as zf:
        zf.writestr("README.md", "# No skill here\n")
    tmp = tempfile.NamedTemporaryFile(suffix=".zip", delete=False)
    tmp.write(buf.getvalue())
    tmp.close()
    return tmp.name


# ─── 测试步骤 ───

def main():
    created_id = None

    # ── Step 1: 上传 zip 成功 ──
    step(1, "POST /api/skills/upload - 上传 zip")
    zip_path = create_test_zip()
    r = curl_upload(f"{BASE}/api/skills/upload", zip_path)
    os.unlink(zip_path)
    if r["status"] != 200:
        fail(f"上传失败: status={r['status']}, body={r['body']}")
    created_id = r["data"]["id"]
    print(f"  id={created_id}, name={r['data']['name']}, files={r['data']['file_count']}")
    ok()
    write_doc("01_upload.md", "POST", "/api/skills/upload",
        "上传 zip 压缩包创建技能。后端解压、解析 front-matter、存储文件。",
        "Content-Type: application/zip, Body: binary zip data", r["status"], r["body"],
        note="请求体直接是 zip 二进制内容")
    link_rows.append({"n": 1, "method": "POST", "path": "/api/skills/upload", "status": r["status"], "result": "PASS", "doc": "01_upload.md"})

    # ── Step 2: 上传无 SKILL.md 的 zip (400) ──
    step(2, "POST /api/skills/upload - 无 SKILL.md")
    zip_path = create_bad_zip_no_skill()
    r = curl_upload(f"{BASE}/api/skills/upload", zip_path)
    os.unlink(zip_path)
    if r["status"] != 400:
        fail(f"预期 400，实际: {r['status']}")
    print(f"  message: {json.loads(r['body']).get('message')}")
    ok()
    write_doc("02_upload_no_skill.md", "POST", "/api/skills/upload",
        "上传不含 SKILL.md 的 zip — 返回 400。", None, r["status"], r["body"],
        note="错误场景")
    link_rows.append({"n": 2, "method": "POST", "path": "/api/skills/upload", "status": r["status"], "result": "PASS", "doc": "02_upload_no_skill.md"})

    # ── Step 3: 列表查询 ──
    step(3, "GET /api/skills - 列表")
    r = curl_get(f"{BASE}/api/skills")
    if r["status"] != 200:
        fail(f"列表查询失败: {r['status']}")
    print(f"  total={r['data']['total']}, 本页={len(r['data']['list'])} 条")
    ok()
    write_doc("03_list.md", "GET", "/api/skills",
        "分页查询技能列表。", None, r["status"], r["body"],
        query_params=[
            {"name": "page", "type": "int", "required": "否", "desc": "页码，默认 1"},
            {"name": "page_size", "type": "int", "required": "否", "desc": "每页条数，默认 20"},
        ])
    link_rows.append({"n": 3, "method": "GET", "path": "/api/skills", "status": r["status"], "result": "PASS", "doc": "03_list.md"})

    # ── Step 4: 详情查询 ──
    step(4, f"GET /api/skills/{created_id} - 详情")
    r = curl_get(f"{BASE}/api/skills/{created_id}")
    if r["status"] != 200:
        fail(f"详情查询失败: {r['status']}")
    print(f"  name={r['data']['name']}, file_count={r['data']['file_count']}")
    if "entry_content" not in r["data"]:
        fail("缺少 entry_content 字段")
    ok()
    write_doc("04_detail.md", "GET", "/api/skills/:id",
        "查询技能详情，含 entry_file 内容。", None, r["status"], r["body"])
    link_rows.append({"n": 4, "method": "GET", "path": "/api/skills/:id", "status": r["status"], "result": "PASS", "doc": "04_detail.md"})

    # ── Step 5: 文件目录 ──
    step(5, f"GET /api/skills/{created_id}/files - 文件列表")
    r = curl_get(f"{BASE}/api/skills/{created_id}/files")
    if r["status"] != 200:
        fail(f"文件列表失败: {r['status']}")
    print(f"  文件数: {len(r['data'])}")
    for f_item in r["data"][:5]:
        flag = "📁" if f_item["is_dir"] else "📄"
        print(f"    {flag} {f_item['file_path']}")
    ok()
    write_doc("05_files.md", "GET", "/api/skills/:id/files",
        "查询技能的文件目录列表。", None, r["status"], r["body"])
    link_rows.append({"n": 5, "method": "GET", "path": "/api/skills/:id/files", "status": r["status"], "result": "PASS", "doc": "05_files.md"})

    # ── Step 6: 单文件内容 ──
    step(6, f"GET /api/skills/{created_id}/files/SKILL.md - 文件内容")
    r = curl_get(f"{BASE}/api/skills/{created_id}/files/SKILL.md")
    if r["status"] != 200:
        fail(f"文件内容失败: {r['status']}")
    print(f"  mime_type={r['data']['mime_type']}, content_len={len(r['data']['content'])}")
    ok()
    write_doc("06_file_content.md", "GET", "/api/skills/:id/files/*path",
        "查询单个文件的文本内容。", None, r["status"], r["body"])
    link_rows.append({"n": 6, "method": "GET", "path": "/api/skills/:id/files/*path", "status": r["status"], "result": "PASS", "doc": "06_file_content.md"})

    # ── Step 7: 子目录文件内容 ──
    step(7, f"GET /api/skills/{created_id}/files/references/guide.md")
    r = curl_get(f"{BASE}/api/skills/{created_id}/files/references/guide.md")
    if r["status"] != 200:
        fail(f"子目录文件失败: {r['status']}")
    print(f"  content 前 30 字符: {r['data']['content'][:30]}")
    ok()
    write_doc("07_file_subdir.md", "GET", "/api/skills/:id/files/*path",
        "查询子目录下文件内容。", None, r["status"], r["body"],
        note="支持任意深度路径")
    link_rows.append({"n": 7, "method": "GET", "path": "/api/skills/:id/files/references/guide.md", "status": r["status"], "result": "PASS", "doc": "07_file_subdir.md"})

    # ── Step 8: 不存在的文件 (404) ──
    step(8, f"GET /api/skills/{created_id}/files/nonexist.md - 404")
    r = curl_get(f"{BASE}/api/skills/{created_id}/files/nonexist.md")
    if r["status"] != 404:
        fail(f"预期 404，实际: {r['status']}")
    ok()
    write_doc("08_file_not_found.md", "GET", "/api/skills/:id/files/*path",
        "文件不存在时返回 404。", None, r["status"], r["body"],
        note="错误场景")
    link_rows.append({"n": 8, "method": "GET", "path": "/api/skills/:id/files/nonexist.md", "status": r["status"], "result": "PASS", "doc": "08_file_not_found.md"})

    # ── Step 9: 删除技能 ──
    step(9, f"DELETE /api/skills/{created_id}")
    r = curl_delete(f"{BASE}/api/skills/{created_id}")
    if r["status"] != 200:
        fail(f"删除失败: {r['status']}")
    ok()
    write_doc("09_delete.md", "DELETE", "/api/skills/:id",
        "删除技能（含磁盘文件清理）。", None, r["status"], r["body"])
    link_rows.append({"n": 9, "method": "DELETE", "path": "/api/skills/:id", "status": r["status"], "result": "PASS", "doc": "09_delete.md"})

    # ── Step 10: 删除后确认 404 ──
    step(10, f"GET /api/skills/{created_id} - 删除后 404")
    r = curl_get(f"{BASE}/api/skills/{created_id}")
    if r["status"] != 404:
        fail(f"预期 404，实际: {r['status']}")
    ok()
    write_doc("10_deleted_404.md", "GET", "/api/skills/:id",
        "删除后查询返回 404。", None, r["status"], r["body"],
        note="验证删除成功")
    link_rows.append({"n": 10, "method": "GET", "path": "/api/skills/:id", "status": r["status"], "result": "PASS", "doc": "10_deleted_404.md"})

    # ── 生成大纲 ──
    write_link()
    print()
    print(f"{GREEN}━━━ 全部测试通过，文档已生成 ━━━{RESET}")
    print(f"  文档目录：{DOCS_DIR}")
    print()


if __name__ == "__main__":
    main()
