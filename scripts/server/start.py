#!/usr/bin/env python3
"""
启动后端服务：检查 MySQL → 停旧进程 → cargo build → cargo run
用法: python scripts/server/start.py

支持 Windows / macOS / Linux
"""

import os
import platform
import shutil
import subprocess
import sys
import time

SYSTEM = platform.system()  # "Windows" / "Darwin" / "Linux"
PROCESS_NAME = "server"

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
SERVER_DIR = os.path.normpath(os.path.join(SCRIPT_DIR, "..", "..", "server"))

# ─── MySQL 配置（按平台） ───

if SYSTEM == "Windows":
    MYSQL_DIR = r"C:\Program Files\MySQL\MySQL Server 8.0"
    MYSQLADMIN = os.path.join(MYSQL_DIR, "bin", "mysqladmin.exe")
    MYSQL_SERVICE_NAME = "MySQL80"
else:
    MYSQLADMIN = shutil.which("mysqladmin")
    MYSQL_SERVICE_NAME = "mysql"


def run(cmd, encoding="utf-8", **kwargs):
    return subprocess.run(cmd, capture_output=True, text=(encoding is not None),
                          encoding=encoding, **kwargs)


# ─── 1. 检测并启动 MySQL ───

def ensure_mysql():
    if _is_port_listening(3306):
        print("[MySQL] MySQL is ready (port 3306 listening).")
        return

    if MYSQLADMIN and os.path.exists(MYSQLADMIN):
        r = run([MYSQLADMIN, "ping", "--silent"])
        if r.returncode == 0:
            print("[MySQL] MySQL is ready.")
            return

    print("[MySQL] MySQL not ready, attempting to start...")

    if SYSTEM == "Windows":
        r = run(["net", "start", MYSQL_SERVICE_NAME], encoding=None)
        output = r.stdout.decode("gbk", errors="ignore") if r.stdout else ""
        err = r.stderr.decode("gbk", errors="ignore") if r.stderr else ""
        if r.returncode == 0 or "已经启动" in output or "already been started" in output:
            print("[MySQL] MySQL service started.")
        else:
            print(f"[MySQL] WARNING: Could not start MySQL service. {err.strip()}")
            print("[MySQL] Please start MySQL manually.")
    elif SYSTEM == "Darwin":
        subprocess.run(["brew", "services", "start", "mysql"], capture_output=True)
    else:
        subprocess.run(["sudo", "systemctl", "start", "mysql"], capture_output=True)

    for i in range(10):
        if _is_port_listening(3306):
            print("[MySQL] MySQL is ready.")
            return
        time.sleep(1)
    print("[MySQL] WARNING: MySQL may not have started. Please check manually.")


def _is_port_listening(port):
    import socket
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.settimeout(1)
        return s.connect_ex(("127.0.0.1", port)) == 0


# ─── 1.5 检查并创建数据库 ───

def ensure_database():
    """从 server/.env 读取 DATABASE_URL，检查数据库是否存在，不存在则创建"""
    env_file = os.path.join(SERVER_DIR, ".env")
    if not os.path.exists(env_file):
        print("[DB] .env file not found, skipping database check.")
        return

    db_url = None
    with open(env_file, "r", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if line.startswith("DATABASE_URL="):
                db_url = line[len("DATABASE_URL="):]
                break

    if not db_url:
        print("[DB] DATABASE_URL not found in .env, skipping.")
        return

    # 解析: mysql://user:password@host/dbname
    # 简单解析
    try:
        parts = db_url.replace("mysql://", "")
        user_pass, host_db = parts.split("@", 1)
        if ":" in user_pass:
            user, password = user_pass.split(":", 1)
        else:
            user, password = user_pass, ""
        if "/" in host_db:
            host, db_name = host_db.split("/", 1)
        else:
            print("[DB] No database name in URL, skipping.")
            return
    except Exception as e:
        print(f"[DB] Failed to parse DATABASE_URL: {e}")
        return

    # 使用 mysql 命令检查数据库是否存在
    mysql_cmd = shutil.which("mysql")
    if not mysql_cmd:
        if SYSTEM == "Windows":
            candidate = os.path.join(MYSQL_DIR, "bin", "mysql.exe")
            if os.path.exists(candidate):
                mysql_cmd = candidate
    if not mysql_cmd:
        print("[DB] mysql client not found, skipping database check.")
        return

    check_sql = f"SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = '{db_name}';"
    r = run([mysql_cmd, f"-u{user}", f"-p{password}", "-h", host.split(":")[0], "-e", check_sql])

    if db_name in (r.stdout or ""):
        print(f"[DB] Database '{db_name}' exists.")
    else:
        print(f"[DB] Database '{db_name}' not found, creating...")
        create_sql = f"CREATE DATABASE `{db_name}` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
        r = run([mysql_cmd, f"-u{user}", f"-p{password}", "-h", host.split(":")[0], "-e", create_sql])
        if r.returncode == 0:
            print(f"[DB] Database '{db_name}' created.")
        else:
            print(f"[DB] Failed to create database: {(r.stderr or '').strip()}")


# ─── 2. 停止旧进程 ───

def stop_existing():
    if SYSTEM == "Windows":
        try:
            r = run(["tasklist", "/FI", f"IMAGENAME eq {PROCESS_NAME}.exe", "/NH"],
                    encoding=None)
            output = r.stdout.decode("gbk", errors="ignore") if r.stdout else ""
        except Exception:
            output = ""

        if PROCESS_NAME in output:
            print(f"[SERVER] Stopping existing {PROCESS_NAME}...")
            run(["taskkill", "/F", "/IM", f"{PROCESS_NAME}.exe"], encoding=None)
            time.sleep(1)
            print("[SERVER] Stopped.")
        else:
            print(f"[SERVER] No existing {PROCESS_NAME} process.")
    else:
        r = run(["pgrep", "-f", PROCESS_NAME])
        if r.returncode == 0 and r.stdout.strip():
            print(f"[SERVER] Stopping existing {PROCESS_NAME}...")
            run(["pkill", "-f", PROCESS_NAME])
            time.sleep(1)
            print("[SERVER] Stopped.")
        else:
            print(f"[SERVER] No existing {PROCESS_NAME} process.")


# ─── 3. 构建并运行 ───

def build_and_run():
    env = os.environ.copy()
    env["RUSTFLAGS"] = ""
    env["RUST_BACKTRACE"] = "0"

    print("[SERVER] Building...")
    r = subprocess.run(["cargo", "build"], cwd=SERVER_DIR, env=env,
                       capture_output=True, text=True, encoding="utf-8")
    if r.returncode != 0:
        print(r.stdout)
        print(r.stderr)
        print("[SERVER] Build failed.")
        sys.exit(1)
    print("[SERVER] Build succeeded.")

    print("[SERVER] Starting...")
    try:
        subprocess.run(["cargo", "run"], cwd=SERVER_DIR, env=env)
    except KeyboardInterrupt:
        print("\n[SERVER] Stopped.")


if __name__ == "__main__":
    ensure_mysql()
    ensure_database()
    stop_existing()
    build_and_run()
