"""
Skills Share — 数据库管理脚本（MySQL 版）

用法：
    python scripts/deploy/db.py status     # 查看数据库状态（表列表、行数）
    python scripts/deploy/db.py migrate    # 执行迁移（跳过已执行的）
    python scripts/deploy/db.py clear      # 删除数据库（危险！）
    python scripts/deploy/db.py reset      # 删库重建（clear + migrate）

依赖：
    pip install pymysql python-dotenv
"""

import sys
import os
from pathlib import Path

import pymysql
from dotenv import dotenv_values

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
    sys.exit(1)


# ─── 配置 ───

SCRIPT_DIR = Path(__file__).resolve().parent
PROJECT_ROOT = SCRIPT_DIR / ".." / ".."
SERVER_DIR = PROJECT_ROOT / "server"
MIGRATIONS_DIR = SERVER_DIR / "migrations"
ENV_FILE = SERVER_DIR / ".env"

# 默认配置
DB_CONFIG = {
    "host": "127.0.0.1",
    "port": 3306,
    "user": "root",
    "password": "",
    "database": "skills_share",
}

# 从 .env 解析 DATABASE_URL
if ENV_FILE.exists():
    env = dotenv_values(str(ENV_FILE))
    url = env.get("DATABASE_URL", "")
    if url.startswith("mysql://"):
        # mysql://user:pass@host:port/dbname
        from urllib.parse import urlparse

        parsed = urlparse(url)
        DB_CONFIG["user"] = parsed.username or DB_CONFIG["user"]
        DB_CONFIG["password"] = parsed.password or DB_CONFIG["password"]
        DB_CONFIG["host"] = parsed.hostname or DB_CONFIG["host"]
        DB_CONFIG["port"] = parsed.port or DB_CONFIG["port"]
        DB_CONFIG["database"] = parsed.path.lstrip("/") or DB_CONFIG["database"]


def get_conn(use_db: bool = True):
    """获取数据库连接"""
    kwargs = {
        "host": DB_CONFIG["host"],
        "port": DB_CONFIG["port"],
        "user": DB_CONFIG["user"],
        "password": DB_CONFIG["password"],
        "charset": "utf8mb4",
    }
    if use_db:
        kwargs["database"] = DB_CONFIG["database"]
    return pymysql.connect(**kwargs)


def db_exists() -> bool:
    """检查数据库是否存在"""
    conn = get_conn(use_db=False)
    try:
        with conn.cursor() as cur:
            cur.execute(
                "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME=%s",
                (DB_CONFIG["database"],),
            )
            return cur.fetchone() is not None
    finally:
        conn.close()


# ─── status ───


def do_status():
    print()
    info("━━━ 数据库状态 ━━━")
    print()

    if not db_exists():
        warn(f"数据库 '{DB_CONFIG['database']}' 不存在")
        return

    ok(f"数据库 '{DB_CONFIG['database']}' 存在")
    print()

    conn = get_conn()
    try:
        with conn.cursor() as cur:
            # 表列表
            info("表列表：")
            cur.execute(
                """
                SELECT TABLE_NAME,
                       CONCAT(ROUND((DATA_LENGTH + INDEX_LENGTH) / 1024, 1), ' KB') AS size
                FROM INFORMATION_SCHEMA.TABLES
                WHERE TABLE_SCHEMA = %s
                ORDER BY TABLE_NAME
                """,
                (DB_CONFIG["database"],),
            )
            rows = cur.fetchall()
            if rows:
                print(f"  {'表名':<30} {'大小'}")
                print(f"  {'-' * 30} {'-' * 10}")
                for name, size in rows:
                    print(f"  {name:<30} {size}")
            else:
                print("  （无表）")

            print()
            info("各表行数：")
            for name, _ in rows:
                cur.execute(f"SELECT COUNT(*) FROM `{name}`")
                count = cur.fetchone()[0]
                print(f"  {name:<30} {count} 行")
    finally:
        conn.close()

    print()


# ─── migrate ───


def do_migrate():
    print()
    info("━━━ 执行数据库迁移 ━━━")
    print()

    # 确保数据库存在
    if not db_exists():
        info(f"数据库 '{DB_CONFIG['database']}' 不存在，正在创建...")
        conn = get_conn(use_db=False)
        try:
            with conn.cursor() as cur:
                cur.execute(
                    f"CREATE DATABASE `{DB_CONFIG['database']}` "
                    f"DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"
                )
            conn.commit()
            ok("数据库已创建")
        finally:
            conn.close()

    conn = get_conn()
    try:
        with conn.cursor() as cur:
            # 确保迁移记录表存在
            cur.execute("""
                CREATE TABLE IF NOT EXISTS _migrations (
                    filename VARCHAR(255) PRIMARY KEY,
                    executed_at DATETIME DEFAULT CURRENT_TIMESTAMP
                )
            """)
            conn.commit()

            # 收集迁移文件
            if not MIGRATIONS_DIR.exists():
                warn(f"迁移目录不存在：{MIGRATIONS_DIR}")
                return

            sql_files = sorted(MIGRATIONS_DIR.glob("*.sql"))
            total = len(sql_files)
            success = 0
            skipped = 0

            for f in sql_files:
                filename = f.name

                # 检查是否已执行
                cur.execute(
                    "SELECT 1 FROM _migrations WHERE filename=%s", (filename,)
                )
                if cur.fetchone():
                    skipped += 1
                    info(f"  {filename}（已执行，跳过）")
                    continue

                # 执行迁移
                sql_content = f.read_text(encoding="utf-8")
                try:
                    # 支持多条语句
                    for statement in sql_content.split(";"):
                        statement = statement.strip()
                        if statement:
                            cur.execute(statement)
                    conn.commit()

                    # 记录已执行
                    cur.execute(
                        "INSERT INTO _migrations (filename) VALUES (%s)", (filename,)
                    )
                    conn.commit()
                    success += 1
                    ok(f"  {filename}")
                except Exception as e:
                    conn.rollback()
                    warn(f"  {filename} 失败：")
                    print(f"    {e}")

            print()
            ok(f"迁移完成：{success} 新执行，{skipped} 已跳过（共 {total} 个文件）")
    finally:
        conn.close()

    print()


# ─── clear ───


def do_clear(force: bool = False):
    print()
    warn("━━━ 危险操作：删除数据库 ━━━")
    print()
    warn(f"这将删除数据库 '{DB_CONFIG['database']}' 及其所有数据！")
    print()

    if not force:
        confirm = input(f"  确认删除？输入数据库名称确认 [{DB_CONFIG['database']}]: ")
        print()
        if confirm != DB_CONFIG["database"]:
            info("已取消")
            return

    info("删除数据库...")
    conn = get_conn(use_db=False)
    try:
        with conn.cursor() as cur:
            cur.execute(f"DROP DATABASE IF EXISTS `{DB_CONFIG['database']}`")
        conn.commit()
        ok(f"数据库 '{DB_CONFIG['database']}' 已删除")
    finally:
        conn.close()


# ─── reset ───


def do_reset():
    do_clear(force=True)
    print()
    info("重新创建数据库...")
    conn = get_conn(use_db=False)
    try:
        with conn.cursor() as cur:
            cur.execute(
                f"CREATE DATABASE `{DB_CONFIG['database']}` "
                f"DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"
            )
        conn.commit()
        ok("数据库已创建")
    finally:
        conn.close()
    do_migrate()


# ─── 主入口 ───

COMMANDS = {
    "status": do_status,
    "migrate": do_migrate,
    "clear": do_clear,
    "reset": do_reset,
}

if __name__ == "__main__":
    action = sys.argv[1] if len(sys.argv) > 1 else "status"

    if action not in COMMANDS:
        print("用法：python db.py [status|migrate|clear|reset]")
        print()
        print("  status   查看数据库状态（表列表、行数）")
        print("  migrate  执行迁移（跳过已执行的）")
        print("  clear    删除数据库（危险！）")
        print("  reset    删库重建（clear + migrate）")
        sys.exit(1)

    COMMANDS[action]()
