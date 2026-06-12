"""
Skills Share — 技能管理 API 测试链

运行方式：
    python skill.py              # 默认 localhost:3000
    python skill.py 192.168.1.5  # 指定 IP

运行后自动生成 ../doc/ 下的接口文档。
"""

import json
import os
import subprocess
import sys

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
YELLOW = "\033[33m"
RESET = "\033[0m"

# ─── 测试框架 ───

link_rows = []


def step(n, desc):
    print(f"{CYAN}========== [{n}] {desc} =========={RESET}")


def fail(msg):
    print(f"{RED}[FAIL] {msg}{RESET}")
    sys.exit(1)


def ok():
    print(f"{GREEN}[PASS]{RESET}")


def write_doc(filename, method, path, desc, body, status, response, token=None, params_desc=None, query_params=None, note=None):
    """生成单个接口文档"""
    lines = []
    lines.append(f"# {method} {path}\n")
    lines.append(f"{desc}\n")

    # Query 参数表格
    if query_params:
        lines.append("## Query Parameters\n")
        lines.append("| 参数 | 类型 | 必填 | 说明 |")
        lines.append("|------|------|------|------|")
        for p in query_params:
            lines.append(f"| {p['name']} | {p['type']} | {p['required']} | {p['desc']} |")
        lines.append("")

    # Body 参数表格
    if params_desc:
        lines.append("## Parameters\n")
        lines.append("| 参数 | 类型 | 必填 | 说明 |")
        lines.append("|------|------|------|------|")
        for p in params_desc:
            lines.append(f"| {p['name']} | {p['type']} | {p['required']} | {p['desc']} |")
        lines.append("")

    # 请求体
    if body:
        lines.append("## Request Body\n")
        lines.append("```json")
        try:
            lines.append(json.dumps(json.loads(body), indent=2, ensure_ascii=False))
        except (json.JSONDecodeError, TypeError):
            lines.append(str(body))
        lines.append("```\n")

    # 响应
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

    # curl
    lines.append("## curl\n")
    lines.append("```bash")
    curl_cmd = f'curl -s -X {method} "{BASE}{path}"'
    if token:
        curl_cmd += f' -H "Authorization: Bearer {token}"'
    if body and method in ("POST", "PUT", "PATCH"):
        curl_cmd += f" -H \"Content-Type: application/json\" -d '{body}'"
    lines.append(curl_cmd)
    lines.append("```\n")

    if note:
        lines.append(f"> {note}\n")

    filepath = os.path.join(DOCS_DIR, filename)
    with open(filepath, "w", encoding="utf-8") as f:
        f.write("\n".join(lines))


def write_link():
    """生成 00_link.md 大纲"""
    lines = []
    lines.append("# skill - API test link\n")
    lines.append(f"Base URL: `{BASE}`\n")
    lines.append("| # | Interface | Status | Result | Doc |")
    lines.append("|---|-----------|--------|--------|-----|")
    for row in link_rows:
        lines.append(f"| {row['n']} | `{row['method']} {row['path']}` | `{row['status']}` | {row['result']} | [{row['doc']}]({row['doc']}) |")
    lines.append("")

    filepath = os.path.join(DOCS_DIR, "00_link.md")
    with open(filepath, "w", encoding="utf-8") as f:
        f.write("\n".join(lines))


# ─── Curl 处理器 ───

class Curl:
    @staticmethod
    def _run(method, url, body=None, token=None):
        cmd = ["curl.exe", "-s", "-w", "\n%{http_code}", "-X", method, url]
        if token:
            cmd += ["-H", f"Authorization: Bearer {token}"]
        if body and method in ("POST", "PUT", "PATCH"):
            cmd += ["-H", "Content-Type: application/json", "-d", body]

        result = subprocess.run(cmd, capture_output=True, text=True, encoding="utf-8")
        output = result.stdout.strip()

        # 最后一行是状态码
        parts = output.rsplit("\n", 1)
        if len(parts) == 2:
            resp_body, status_str = parts
        else:
            resp_body = ""
            status_str = parts[0] if parts else "0"

        try:
            status = int(status_str)
        except ValueError:
            status = 0

        data = None
        if resp_body:
            try:
                parsed = json.loads(resp_body)
                data = parsed.get("data")
            except json.JSONDecodeError:
                pass

        # 构造 curl 命令字符串
        curl_str = f'curl -s -X {method} "{url}"'
        if token:
            curl_str += f' -H "Authorization: Bearer {token}"'
        if body and method in ("POST", "PUT", "PATCH"):
            curl_str += f" -H \"Content-Type: application/json\" -d '{body}'"

        return {"status": status, "body": resp_body, "data": data, "curl": curl_str}

    @staticmethod
    def get(url, token=None):
        return Curl._run("GET", url, token=token)

    @staticmethod
    def post(url, body, token=None):
        return Curl._run("POST", url, body=body, token=token)

    @staticmethod
    def put(url, body, token=None):
        return Curl._run("PUT", url, body=body, token=token)

    @staticmethod
    def delete(url, token=None):
        return Curl._run("DELETE", url, token=token)


# ─── 测试步骤 ───

def main():
    created_id = None

    # ── Step 1: POST /api/skills — 创建技能（正常） ──

    step(1, "POST /api/skills - 创建技能")
    body = json.dumps({
        "name": "Test Skill",
        "description": "用于测试的技能",
        "author": "test_author",
        "tags": "测试,API",
        "icon_url": "https://example.com/icon.png",
        "source_url": "https://github.com/test/skill",
        "version": "1.0.0",
        "download_url": "https://example.com/download.zip",
        "content": "# Test Skill\n\n这是测试技能的 Markdown 文档。\n\n## 功能\n\n- 功能A\n- 功能B"
    }, ensure_ascii=False)
    r = Curl.post(f"{BASE}/api/skills", body)
    if r["status"] != 200:
        fail(f"创建失败: status={r['status']}, body={r['body']}")
    created_id = r["data"]["id"]
    print(f"  created_id: {created_id}")
    ok()
    write_doc("01_create_skill.md", "POST", "/api/skills",
        "创建新技能。", body, r["status"], r["body"],
        params_desc=[
            {"name": "name", "type": "string", "required": "是", "desc": "技能名称"},
            {"name": "description", "type": "string", "required": "否", "desc": "简短描述"},
            {"name": "author", "type": "string", "required": "否", "desc": "作者"},
            {"name": "tags", "type": "string", "required": "否", "desc": "标签，逗号分隔"},
            {"name": "icon_url", "type": "string", "required": "否", "desc": "图标 URL"},
            {"name": "source_url", "type": "string", "required": "否", "desc": "来源网站 URL"},
            {"name": "version", "type": "string", "required": "否", "desc": "语义化版本号"},
            {"name": "download_url", "type": "string", "required": "否", "desc": "下载链接"},
            {"name": "content", "type": "string", "required": "是", "desc": "Markdown 说明文档"},
        ])
    link_rows.append({"n": 1, "method": "POST", "path": "/api/skills", "status": r["status"], "result": "PASS", "doc": "01_create_skill.md"})

    # ── Step 2: POST /api/skills — name 为空（400） ──

    step(2, "POST /api/skills - name 为空")
    body_empty_name = json.dumps({"name": "", "content": "some content"}, ensure_ascii=False)
    r = Curl.post(f"{BASE}/api/skills", body_empty_name)
    if r["status"] != 400:
        fail(f"预期 400，实际: {r['status']}")
    print(f"  message: {json.loads(r['body']).get('message')}")
    ok()
    write_doc("02_create_skill_empty_name.md", "POST", "/api/skills",
        "创建技能 — name 为空时返回 400。", body_empty_name, r["status"], r["body"],
        note="错误场景：name 字段不能为空")
    link_rows.append({"n": 2, "method": "POST", "path": "/api/skills", "status": r["status"], "result": "PASS", "doc": "02_create_skill_empty_name.md"})

    # ── Step 3: POST /api/skills — content 为空（400） ──

    step(3, "POST /api/skills - content 为空")
    body_empty_content = json.dumps({"name": "Valid Name", "content": ""}, ensure_ascii=False)
    r = Curl.post(f"{BASE}/api/skills", body_empty_content)
    if r["status"] != 400:
        fail(f"预期 400，实际: {r['status']}")
    print(f"  message: {json.loads(r['body']).get('message')}")
    ok()
    write_doc("03_create_skill_empty_content.md", "POST", "/api/skills",
        "创建技能 — content 为空时返回 400。", body_empty_content, r["status"], r["body"],
        note="错误场景：content 字段不能为空")
    link_rows.append({"n": 3, "method": "POST", "path": "/api/skills", "status": r["status"], "result": "PASS", "doc": "03_create_skill_empty_content.md"})

    # ── Step 4: GET /api/skills — 列表查询 ──

    step(4, "GET /api/skills - 列表查询")
    r = Curl.get(f"{BASE}/api/skills")
    if r["status"] != 200:
        fail(f"列表查询失败: {r['status']}")
    total = r["data"]["total"]
    list_len = len(r["data"]["list"])
    print(f"  total: {total}, 本页: {list_len} 条")
    # 验证列表不含 content
    if r["data"]["list"] and "content" in r["data"]["list"][0]:
        fail("列表响应不应包含 content 字段")
    ok()
    write_doc("04_list_skills.md", "GET", "/api/skills",
        "分页查询已发布的技能列表。列表不返回 content 字段。", None, r["status"], r["body"],
        query_params=[
            {"name": "page", "type": "int", "required": "否", "desc": "页码，默认 1"},
            {"name": "page_size", "type": "int", "required": "否", "desc": "每页条数，默认 20，最大 100"},
        ])
    link_rows.append({"n": 4, "method": "GET", "path": "/api/skills", "status": r["status"], "result": "PASS", "doc": "04_list_skills.md"})

    # ── Step 5: GET /api/skills?page=1&page_size=1 — 分页验证 ──

    step(5, "GET /api/skills?page=1&page_size=1 - 分页")
    r = Curl.get(f"{BASE}/api/skills?page=1&page_size=1")
    if r["status"] != 200:
        fail(f"分页查询失败: {r['status']}")
    if len(r["data"]["list"]) != 1:
        fail(f"预期 1 条，实际 {len(r['data']['list'])} 条")
    if r["data"]["page_size"] != 1:
        fail(f"page_size 不一致")
    print(f"  page: {r['data']['page']}, page_size: {r['data']['page_size']}, total: {r['data']['total']}")
    ok()
    write_doc("05_list_skills_paged.md", "GET", "/api/skills?page=1&page_size=1",
        "分页查询验证 — page_size=1 时只返回 1 条。", None, r["status"], r["body"],
        note="验证分页参数生效")
    link_rows.append({"n": 5, "method": "GET", "path": "/api/skills?page=1&page_size=1", "status": r["status"], "result": "PASS", "doc": "05_list_skills_paged.md"})

    # ── Step 6: GET /api/skills/:id — 详情查询 ──

    step(6, f"GET /api/skills/{created_id} - 详情查询")
    r = Curl.get(f"{BASE}/api/skills/{created_id}")
    if r["status"] != 200:
        fail(f"详情查询失败: {r['status']}")
    if "content" not in r["data"] or not r["data"]["content"]:
        fail("详情响应应包含 content 字段")
    print(f"  name: {r['data']['name']}, version: {r['data']['version']}")
    ok()
    write_doc("06_get_skill.md", "GET", "/api/skills/:id",
        "查询技能详情。返回完整信息，包含 Markdown 说明文档。", None, r["status"], r["body"],
        note=f"实际请求路径：/api/skills/{created_id}")
    link_rows.append({"n": 6, "method": "GET", "path": "/api/skills/:id", "status": r["status"], "result": "PASS", "doc": "06_get_skill.md"})

    # ── Step 7: GET /api/skills/99999 — 不存在（404） ──

    step(7, "GET /api/skills/99999 - 不存在")
    r = Curl.get(f"{BASE}/api/skills/99999")
    if r["status"] != 404:
        fail(f"预期 404，实际: {r['status']}")
    print(f"  message: {json.loads(r['body']).get('message')}")
    ok()
    write_doc("07_get_skill_not_found.md", "GET", "/api/skills/:id",
        "查询不存在的技能 — 返回 404。", None, r["status"], r["body"],
        note="错误场景：ID 不存在时返回 404")
    link_rows.append({"n": 7, "method": "GET", "path": "/api/skills/99999", "status": r["status"], "result": "PASS", "doc": "07_get_skill_not_found.md"})

    # ── 生成大纲 ──

    write_link()
    print()
    print(f"{GREEN}━━━ 全部测试通过，文档已生成 ━━━{RESET}")
    print(f"  文档目录：{DOCS_DIR}")
    print()


if __name__ == "__main__":
    main()
