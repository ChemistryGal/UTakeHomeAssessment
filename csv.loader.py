from config import load_config
import pyodbc as odbc
import pandas as pd

cfg = load_config()
csv_path = cfg["data"]["csv_path"]
batch_size = cfg["data"]["batch_size"]

conn_str = (
    f"DRIVER={{{cfg['sql']['driver']}}};"
    f"SERVER={cfg['sql']['server']};"
    f"DATABASE={cfg['sql']['database']};"
    f"Trusted_Connection={'yes' if cfg['sql']['trusted'] else 'no'};"
    "TrustServerCertificate=yes;"
)

table = "dbo.raw_incidents" 

cols = COLUMNS = [
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
    "CREATED_DT",
    "CREATED_ID",
    "ROW_HASH"]

col_list = ", ".join(f"[{c}]" for c in cols)
placeholders = ", ".join("?" for _ in cols)

insert_sql = f"INSERT INTO {table} ({col_list}) VALUES ({placeholders})"

def norm(v):
    if v is None:
        return None
    s = str(v).strip()
    return s if s != "" else None

with odbc.connect(conn_str, autocommit=False) as conn:
    cur = conn.cursor()
    cur.fast_executemany = True

    for batch_num, chunk in enumerate(
        pd.read_csv(
            csv_path,
            chunksize=batch_size,
            encoding=cfg["data"]["encoding"],
            sep=cfg["data"]["delimiter"],
            dtype=str,
        ),
        start=1,
    ):
        chunk = chunk[cols].applymap(norm)

        rows = chunk.itertuples(index=False, name=None)  
        cur.executemany(insert_sql, list(rows))          
        conn.commit()                                   

        print(f"Batch {batch_num}: inserted {len(chunk)} rows")
