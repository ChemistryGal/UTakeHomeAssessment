Subject: README.md for EMS Take-Home Repository

# EMS Records – Mini ETL + Star Schema (Take-Home)

This repo contains a simple and easily reproducible ETL pipeline that loads an EMS CSV into SQL Server, cleans it into a typed staging table, and loads a small star schema (dimensions + fact). The goal is to keep the implementation **easy to understand**, **set-based**, and **repeatable**.

---

## What’s Included

* **SQL scripts** (Bronze/Silver) to create tables, cleanse data, load dims, load fact, and validate results.
* **Python loader** to import the source CSV into a raw landing table (batched inserts).
* **`run_etl.py`** orchestration script to run the SQL scripts + Python loader in the correct order.
* **Schema diagram** (ERD) in the repo.

---

## Tech Stack

* **SQL Server Express** (local)
* **Python**
* **pyodbc**, **pandas**
* **ODBC Driver 17 for SQL Server**

---

## Repository Structure

```
.
├─ sql/
│  ├─ Bronze/
│  │  ├─ 00_CreateDatabase.sql
│  │  ├─ 01_CreateSchema.sql
│  │  └─ 02_CreateRawTable.sql
│  └─ Silver/
│     ├─ 03_CreateStageTable.sql
│     ├─ 04_CreateDimTables.sql
│     ├─ 05_CreateFactTable.sql
│     ├─ 06_DimUnknownsInserted.sql
│     ├─ 07_CleanseTransform.sql
│     ├─ 08_LoadDimensions.sql
│     ├─ 09_LoadFact.sql
│     └─ 10_Validation.sql
├─ diagram/
│  └─ erd.png
├─ config.ini
├─ config.py
├─ load_raw.py
├─ run_etl.py
└─ requirements.txt
```

> Note: All tables in this project use the `er` schema (ex: `er.Raw_EMS_Runs`, `er.Stg_EMS_Runs`, `er.Dim_*`, `er.Fact_*`).

---

## Setup
Configure `config.ini`

Update values as needed:

```ini
[sqlserver]
server = localhost\SQLEXPRESS
database = EMSRecords
driver = ODBC Driver 17 for SQL Server
trusted_connection = yes

[data]
csv_path = data/ems.csv
batch_size = 50000
delimiter = ,
encoding = utf-8
```
---

## How to Run
This runs:

1. Bronze SQL (database/schema/raw table)
2. Python CSV load into raw
3. Silver SQL (stage/dims/fact/validation)

```bash
python run_etl.py
```

## Validation

The `sql/Silver/10_Validation.sql` script checks:

* row counts for raw, staging, each dimension, and fact
* duplicate `row_hash` detection in staging

---

## Author

Katie Hancock
