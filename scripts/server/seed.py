"""
Skills Share — 种子数据灌入脚本

通过 HTTP 接口灌入 seed.json 中的数据，同时验证接口可用性。

用法：
    python scripts/server/seed.py              # 使用默认地址 http://localhost:3000
    python seed.py 192.168.1.5  # 指定服务器 IP
"""

import json
import sys
import urllib.request
import urllib.error
from pathlib import Path

# ─── 颜色 ───

RED = "\033[0;31m"
GREEN = "\033[0;32m"
YELLOW = "\033[1;33m"
BLUE = "\033[0;34m"
NC = "\033[0m"


def info(msg: str):
    print(f"{BLUE}[INFO]{NC} {msg}")


def ok(msg: str):
    print(f"{GREEN}[ OK ]{NC} {msg}")


def warn(msg: str):
    print(f"{YELLOW}[WARN]{NC} {msg}")


def fail(msg: str):
    print(f"{RED}[FAIL]{NC} {msg}")


# ─── 配置 ───

SCRIPT_DIR = Path(__file__).resolve().parent
SEED_FILE = SCRIPT_DIR / "seed.json"

HOST = sys.argv[1] if len(sys.argv) > 1 else "localhost"
BASE_URL = f"http://{HOST}:3000"


def post_json(url: str, data: dict) -> dict:
    """发送 POST 请求"""
    body = json.dumps(data).encode("utf-8")
    req = urllib.request.Request(
        url,
        data=body,
        headers={"Content-Type": "application/json"},
        method="POST",
    )
    try:
        with urllib.request.urlopen(req) as resp:
            return json.loads(resp.read().decode("utf-8"))
    except urllib.error.HTTPError as e:
        return json.loads(e.read().decode("utf-8"))


def get_json(url: str) -> dict:
    """发送 GET 请求"""
    req = urllib.request.Request(url)
    try:
        with urllib.request.urlopen(req) as resp:
            return json.loads(resp.read().decode("utf-8"))
    except urllib.error.HTTPError as e:
        return json.loads(e.read().decode("utf-8"))


def main():
    print()
    info(f"━━━ 灌入种子数据 ━━━")
    info(f"服务器地址：{BASE_URL}")
    print()

    # 检查服务是否可用
    try:
        health = get_json(f"{BASE_URL}/")
        if health.get("status") != "ok":
            fail("服务器健康检查失败")
            sys.exit(1)
        ok("服务器连接正常")
    except Exception as e:
        fail(f"无法连接服务器：{e}")
        sys.exit(1)

    # 读取种子数据
    if not SEED_FILE.exists():
        fail(f"种子文件不存在：{SEED_FILE}")
        sys.exit(1)

    seed_data = json.loads(SEED_FILE.read_text(encoding="utf-8-sig"))
    skills = seed_data.get("skills", [])

    if not skills:
        warn("种子数据为空")
        return

    print()
    info(f"共 {len(skills)} 条技能数据，开始灌入...")
    print()

    # 逐条创建（倒序插入，最新的在前）
    success = 0
    failed = 0
    created_ids = []

    for i, skill in enumerate(reversed(skills), 1):
        # 如果有 content_file 字段，读取文件内容替换 content
        if "content_file" in skill:
            content_path = SCRIPT_DIR / skill["content_file"]
            if content_path.exists():
                skill["content"] = content_path.read_text(encoding="utf-8")
            else:
                fail(f"  [{i}/{len(skills)}] {skill['name']} → 文件不存在: {content_path}")
                failed += 1
                continue
            del skill["content_file"]
        
        resp = post_json(f"{BASE_URL}/api/skills", skill)
        if resp.get("code") == 0:
            skill_id = resp["data"]["id"]
            created_ids.append(skill_id)
            success += 1
            ok(f"  [{i}/{len(skills)}] {skill['name']} → id={skill_id}")
        else:
            failed += 1
            fail(f"  [{i}/{len(skills)}] {skill['name']} → {resp.get('message')}")

    print()
    info(f"灌入完成：{success} 成功，{failed} 失败")

    # 验证列表接口
    print()
    info("━━━ 验证接口 ━━━")
    print()

    # 验证列表
    list_resp = get_json(f"{BASE_URL}/api/skills?page=1&page_size=10")
    if list_resp.get("code") == 0:
        total = list_resp["data"]["total"]
        list_len = len(list_resp["data"]["list"])
        ok(f"GET /api/skills → total={total}, 本页={list_len} 条")

        # 验证列表不含 content
        if list_resp["data"]["list"]:
            first = list_resp["data"]["list"][0]
            if "content" not in first:
                ok("  列表响应不含 content 字段 ✓")
            else:
                warn("  列表响应包含了 content 字段 ✗")
    else:
        fail(f"GET /api/skills 失败：{list_resp.get('message')}")

    # 验证详情
    if created_ids:
        detail_resp = get_json(f"{BASE_URL}/api/skills/{created_ids[0]}")
        if detail_resp.get("code") == 0:
            has_content = "content" in detail_resp["data"] and detail_resp["data"]["content"]
            ok(f"GET /api/skills/{created_ids[0]} → name={detail_resp['data']['name']}")
            if has_content:
                ok("  详情响应包含 content 字段 ✓")
            else:
                warn("  详情响应缺少 content 字段 ✗")
        else:
            fail(f"GET /api/skills/{created_ids[0]} 失败：{detail_resp.get('message')}")

    # 验证 404
    resp_404 = get_json(f"{BASE_URL}/api/skills/99999")
    if resp_404.get("code") == 404:
        ok("GET /api/skills/99999 → 404 ✓")
    else:
        warn(f"GET /api/skills/99999 → 预期 404，实际 code={resp_404.get('code')}")

    print()
    ok("━━━ 全部验证完成 ━━━")
    print()


if __name__ == "__main__":
    main()
