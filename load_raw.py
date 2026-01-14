import pandas as pd
import pyodbc
from config import load_config

cfg = load_config()

CSV_PATH = cfg["data"]["csv_path"]
BATCH_SIZE = cfg["data"]["batch_size"]

TABLE = "er.Raw_EMS_Runs"

conn_str = (
    f"DRIVER={{{cfg['sql']['driver']}}};"
    f"SERVER={cfg['sql']['server']};"
    f"DATABASE={cfg['sql']['database']};"
    f"Trusted_Connection={'yes' if cfg['sql']['trusted'] else 'no'};"
    "TrustServerCertificate=yes;"
)

EXPECTED_COLS = [
    "INCIDENT_DT",
    "INCIDENT_COUNTY",
    "CHIEF_COMPLAINT_DISPATCH",
    "CHIEF_COMPLAINT_ANATOMIC_LOC",
    "PRIMARY_SYMPTOM",
    "PROVIDER_IMPRESSION_PRIMARY",
    "DISPOSITION_ED",
    "DISPOSITION_HOSPITAL",
    "INJURY_FLG",
    "NALOXONE_GIVEN_FLG",
    "MEDICATION_GIVEN_OTHER_FLG",
    "DESTINATION_TYPE",
    "PROVIDER_TYPE_STRUCTURE",
    "PROVIDER_TYPE_SERVICE",
    "PROVIDER_TYPE_SERVICE_LEVEL",
    "PROVIDER_TO_SCENE_MINS",
    "PROVIDER_TO_DESTINATION_MINS",
    "UNIT_NOTIFIED_BY_DISPATCH_DT",
    "UNIT_ARRIVED_ON_SCENE_DT",
    "UNIT_ARRIVED_TO_PATIENT_DT",
    "UNIT_LEFT_SCENE_DT",
    "PATIENT_ARRIVED_DESTINATION_DT",
]

def norm(v):
    if v is None:
        return None
    s = str(v).strip()
    return s if s != "" else None

def main():
    with pyodbc.connect(conn_str, autocommit=False) as conn:
        cur = conn.cursor()
        cur.fast_executemany = True

        # repeatable runs
        cur.execute(f"TRUNCATE TABLE {TABLE}")
        conn.commit()

        total = 0
        batch_num = 0

        for chunk in pd.read_csv(
            CSV_PATH,
            dtype=str,
            chunksize=BATCH_SIZE,
            sep=cfg["data"]["delimiter"],
            encoding=cfg["data"]["encoding"],
            keep_default_na=False,
        ):
            batch_num += 1

            # Validate schema
            missing = [c for c in EXPECTED_COLS if c not in chunk.columns]
            if missing:
                raise ValueError(f"CSV is missing expected columns: {missing}")

            # Insert only expected cols in expected order
            chunk = chunk[EXPECTED_COLS].applymap(norm)

            col_list = ", ".join(f"[{c}]" for c in EXPECTED_COLS)
            placeholders = ", ".join("?" for _ in EXPECTED_COLS)
            insert_sql = f"INSERT INTO {TABLE} ({col_list}) VALUES ({placeholders})"

            rows = list(chunk.itertuples(index=False, name=None))

            try:
                cur.executemany(insert_sql, rows)
                conn.commit()
                total += len(rows)
                print(f"Batch {batch_num}: inserted {len(rows)} rows (total={total})")
            except Exception as e:
                conn.rollback()
                print(f"Failed on batch {batch_num}: {e}")
                raise

    print(f"Finished loading {total} rows into {TABLE}")

if __name__ == "__main__":
    main()
