"""
Skills Share — 种子数据灌入脚本（v0.0.3）

遍历 data/ 下所有含 SKILL.md 的文件夹，临时压缩为 zip，上传到服务端。

用法：
    python scripts/server/seed.py              # 默认 localhost:3000
    python scripts/server/seed.py 192.168.1.5  # 指定 IP
"""

import io
import json
import os
import subprocess
import sys
import tempfile
import zipfile
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
DATA_DIR = SCRIPT_DIR / "data"

HOST = sys.argv[1] if len(sys.argv) > 1 else "localhost"
BASE_URL = f"http://{HOST}:3000"

# 排除目录
EXCLUDE_DIRS = {".git", ".github", "node_modules", "__pycache__", ".claude-plugin"}


def find_skill_folders() -> list[Path]:
    """遍历 data/ 下所有含 SKILL.md 的文件夹"""
    skill_folders: list[Path] = []
    for root, dirs, files in os.walk(DATA_DIR):
        dirs[:] = [d for d in dirs if d not in EXCLUDE_DIRS]
        if "SKILL.md" in files:
            skill_folders.append(Path(root))
    # 按路径排序
    skill_folders.sort(key=lambda p: p.as_posix())
    return skill_folders


def zip_folder(folder: Path) -> str:
    """将文件夹打包为临时 zip，返回 zip 文件路径"""
    tmp = tempfile.NamedTemporaryFile(suffix=".zip", delete=False)
    tmp.close()

    with zipfile.ZipFile(tmp.name, 'w', zipfile.ZIP_DEFLATED) as zf:
        for root, dirs, files in os.walk(folder):
            dirs[:] = [d for d in dirs if d not in EXCLUDE_DIRS]
            for file in files:
                file_path = Path(root) / file
                arcname = file_path.relative_to(folder).as_posix()
                zf.write(file_path, arcname)

    return tmp.name


def upload_zip(zip_path: str, meta: dict | None = None) -> dict:
    """上传 zip 文件到服务端（multipart: file + meta）"""
    cmd = ["curl.exe", "-s", "-w", "\n%{http_code}", "-X", "POST",
           "-F", f"file=@{zip_path};type=application/zip"]

    if meta:
        import json as _json
        cmd += ["-F", f"meta={_json.dumps(meta, ensure_ascii=False)}"]

    cmd.append(f"{BASE_URL}/api/skills/upload")

    result = subprocess.run(cmd, capture_output=True, text=True, encoding="utf-8")
    output = result.stdout.strip()
    parts = output.rsplit("\n", 1)
    body = parts[0] if len(parts) == 2 else ""
    status = int(parts[-1]) if parts else 0

    resp = {}
    if body:
        try:
            resp = json.loads(body)
        except json.JSONDecodeError:
            pass

    return {"status": status, "body": body, "resp": resp}


def main():
    print()
    info("━━━ 种子数据灌入 ━━━")
    info(f"服务器：{BASE_URL}")
    info(f"数据目录：{DATA_DIR}")
    print()

    # 检查服务可用
    try:
        result = subprocess.run(
            ["curl.exe", "-s", f"{BASE_URL}/"],
            capture_output=True, text=True, encoding="utf-8"
        )
        if '"status":"ok"' not in result.stdout:
            fail("服务器不可用")
            sys.exit(1)
        ok("服务器连接正常")
    except Exception as e:
        fail(f"无法连接：{e}")
        sys.exit(1)

    # 查找所有技能文件夹
    folders = find_skill_folders()
    if not folders:
        warn("未找到任何含 SKILL.md 的文件夹")
        return

    # 加载所有 meta.json
    meta_map: dict = {}  # source_name -> {"author": {...}, "skills": {path: {...}}}
    for meta_file in DATA_DIR.glob("*/meta.json"):
        try:
            meta_data = json.loads(meta_file.read_text(encoding="utf-8"))
            source_name = meta_file.parent.name
            # skills 按 path 索引
            skills_by_path: dict = {}
            for s in meta_data.get("skills", []):
                skills_by_path[s.get("path", "")] = s
            meta_map[source_name] = {
                "author": meta_data.get("author", {}),
                "skills": skills_by_path,
            }
        except Exception:
            pass

    info(f"找到 {len(folders)} 个技能文件夹")
    print()

    # 倒序上传（最新的排前面）
    success = 0
    failed = 0

    for i, folder in enumerate(reversed(folders), 1):
        rel_path = folder.relative_to(DATA_DIR).as_posix()

        # 确定所属 source，提取 author 信息
        source_name = rel_path.split("/")[0]
        source_meta = meta_map.get(source_name, {})
        author_info = source_meta.get("author", {})

        # 匹配 skill 的 keywords
        # rel_path 如 "anthropics/skills/skills/algorithmic-art"
        # 去掉 source_name 得到 "skills/skills/algorithmic-art"
        # meta.json 中 skill.path 如 "skills/algorithmic-art"
        # 需要去掉第一个 "skills/" 前缀来匹配
        skill_rel = "/".join(rel_path.split("/")[1:])  # "skills/skills/algorithmic-art"
        # 尝试直接匹配
        skill_meta = source_meta.get("skills", {}).get(skill_rel, {})
        if not skill_meta:
            # 去掉第一个 "skills/" 再匹配
            if skill_rel.startswith("skills/"):
                skill_rel_short = skill_rel[len("skills/"):]  # "skills/algorithmic-art"
                skill_meta = source_meta.get("skills", {}).get(skill_rel_short, {})
                if not skill_meta:
                    # 也可能 meta 里没有 "skills/" 前缀
                    skill_meta = source_meta.get("skills", {}).get(skill_rel_short.split("/", 1)[-1] if "/" in skill_rel_short else skill_rel_short, {})
        keywords = skill_meta.get("keywords", [])

        # 构造 meta 参数
        upload_meta = {}
        if author_info.get("name"):
            upload_meta["author"] = author_info["name"]
        if author_info.get("image"):
            upload_meta["icon_url"] = author_info["image"]
        if author_info.get("repo"):
            upload_meta["source_url"] = author_info["repo"]
            upload_meta["download_url"] = f"{author_info['repo']}/tree/main/{skill_rel}"
        if keywords:
            upload_meta["tags"] = ",".join(keywords)

        # 打 zip
        zip_path = zip_folder(folder)

        # 上传
        r = upload_zip(zip_path, upload_meta if upload_meta else None)

        # 删临时文件
        os.unlink(zip_path)

        if r["status"] == 200 and r["resp"].get("code") == 0:
            data = r["resp"].get("data", {})
            ok(f"  [{i}/{len(folders)}] {rel_path} → id={data.get('id')}, files={data.get('file_count')}")
            success += 1
        else:
            msg = r["resp"].get("message", r["body"][:80])
            fail(f"  [{i}/{len(folders)}] {rel_path} → {msg}")
            failed += 1

    print()
    info(f"完成：{success} 成功，{failed} 失败（共 {len(folders)} 个）")
    print()


if __name__ == "__main__":
    main()
