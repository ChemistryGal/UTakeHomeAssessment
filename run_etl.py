import os
import sys
import time
import subprocess
from pathlib import Path

import pyodbc
from config import load_config
# -----------------------------------------
BRONZE_SCRIPTS = [
    "00_CreateDatabase.sql",
    "01_CreateSchema.sql",
    "02_CreateRawTable.sql",
]

SILVER_SCRIPTS = [
    "03_CreateStageTable.sql",
    "04_CreateDimTables.sql",
    "05_CreateFactTable.sql",
    "06_DimUnknownsInserted.sql",
    "07_CleanseTransform.sql",
    "08_LoadDimensions.sql",
    "09_LoadFact.sql",
    "10_Validation.sql",
]

PYTHON_LOAD_SCRIPT = "load_raw.py"
# -----------------------------------------


def split_go_batches(sql_text: str) -> list[str]:
    """
    Split SQL into batches on lines that contain only GO (case-insensitive).
    Keep GO on its own line.
    """
    batches = []
    current = []
    for line in sql_text.splitlines():
        if line.strip().upper() == "GO":
            batch = "\n".join(current).strip()
            if batch:
                batches.append(batch)
            current = []
        else:
            current.append(line)
    tail = "\n".join(current).strip()
    if tail:
        batches.append(tail)
    return batches


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def exec_sql_file(conn: pyodbc.Connection, path: Path) -> None:
    sql_text = read_text(path)
    batches = split_go_batches(sql_text)

    cur = conn.cursor()
    for i, batch in enumerate(batches, start=1):
        if not batch.strip():
            continue
        try:
            cur.execute(batch)
        except Exception as e:
            conn.rollback()
            snippet = batch.strip()
            if len(snippet) > 1200:
                snippet = snippet[:1200] + "\n... [truncated]"
            raise RuntimeError(
                f"SQL failed in {path.name} (batch {i}/{len(batches)}): {e}\n\nBatch snippet:\n{snippet}"
            ) from e

    conn.commit()


def build_conn_str(cfg: dict, database_override: str | None = None, autocommit: bool = False) -> str:
    sql = cfg["sql"]
    db = database_override or sql["database"]
    trusted_str = "yes" if sql.get("trusted", True) else "no"
    return (
        f"DRIVER={{{sql['driver']}}};"
        f"SERVER={sql['server']};"
        f"DATABASE={db};"
        f"Trusted_Connection={trusted_str};"
        "TrustServerCertificate=yes;"
    )


def run_python_loader(repo_root: Path) -> None:
    script_path = repo_root / PYTHON_LOAD_SCRIPT
    if not script_path.exists():
        raise FileNotFoundError(f"Missing python loader script: {script_path}")

    cmd = [sys.executable, str(script_path)]
    print(f"\n==> Running Python loader: {' '.join(cmd)}\n")
    result = subprocess.run(cmd, cwd=str(repo_root), capture_output=True, text=True)

    if result.stdout:
        print(result.stdout)
    if result.stderr:
        print(result.stderr, file=sys.stderr)

    if result.returncode != 0:
        raise RuntimeError(f"Python loader failed (exit code {result.returncode}).")


def main() -> int:
    repo_root = Path(__file__).resolve().parent
    cfg = load_config()

    bronze_dir = repo_root / "sql" / "Bronze"
    silver_dir = repo_root / "sql" / "Silver"

    bronze_paths = [bronze_dir / f for f in BRONZE_SCRIPTS]
    silver_paths = [silver_dir / f for f in SILVER_SCRIPTS]

    missing = [p for p in (bronze_paths + silver_paths) if not p.exists()]
    if missing:
        print("Missing SQL script(s):", file=sys.stderr)
        for p in missing:
            print(f" - {p}", file=sys.stderr)
        return 2
# Bronze phase
    master_conn_str = build_conn_str(cfg, database_override="master")
    print(f"Connecting to SQL Server (master): {cfg['sql']['server']}")
    try:
        with pyodbc.connect(master_conn_str, autocommit=False) as conn_master:
            for p in bronze_paths:
                print(f"==> Running {p.name}")
                t0 = time.perf_counter()
                exec_sql_file(conn_master, p)
                print(f"    done in {time.perf_counter() - t0:.2f}s")
    except Exception as e:
        print(f"\n Bronze phase failed: {e}", file=sys.stderr)
        return 1

    try:
        run_python_loader(repo_root)
    except Exception as e:
        print(f"\n CSV load failed: {e}", file=sys.stderr)
        return 1
#Silver phase
    db_conn_str = build_conn_str(cfg, database_override=cfg["sql"]["database"])
    print(f"\nConnecting to SQL Server (db): {cfg['sql']['server']} | {cfg['sql']['database']}")
    try:
        with pyodbc.connect(db_conn_str, autocommit=False) as conn_db:
            for p in silver_paths:
                print(f"==> Running {p.name}")
                t0 = time.perf_counter()
                exec_sql_file(conn_db, p)
                print(f"    done in {time.perf_counter() - t0:.2f}s")

        print("\n ETL complete.")
        return 0
    except Exception as e:
        print(f"\n Silver phase failed: {e}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
