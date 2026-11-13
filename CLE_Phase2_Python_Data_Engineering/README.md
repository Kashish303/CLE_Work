# CLE Phase 2 – Python for Data Engineering

Completed practical starter project aligned with the Phase 2 tasks in the CLE roadmap.

## Included tasks

1. **SQL to pandas:** Rebuilds five Phase 1 analyses using the same sample e-commerce data: customer counts by city, delivered orders per customer, category revenue, top five customers by revenue, and monthly revenue. Saves five CSV reports.
2. **Public REST API:** Fetches JSONPlaceholder posts, validates and cleans the response, removes duplicate IDs, adds text lengths and UTC fetch timestamp, and saves CSV + Parquet.
3. **argparse CLI:** `csv_to_parquet.py` accepts `--input` and `--output` paths. Other scripts also expose command-line arguments.
4. **Mini-project:** Repeated API ingestion with a simple scheduling loop, pandas transformations, SQLite upsert, logging, timeout and error handling.

## Folder structure

- `data/source/`: four Phase 1 sample CSV tables.
- `data/output/`: generated outputs and SQLite database.
- `src/`: runnable Python scripts.
- `logs/`: pipeline log.
- `tests/`: basic test.
- `docs/`: SQL-to-pandas mapping.

## Setup (Windows PowerShell)

```powershell
py -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
pip install -r requirements.txt
```

If PowerShell blocks activation, run `.\.venv\Scripts\python.exe -m pip install -r requirements.txt` and use `.\.venv\Scripts\python.exe` instead of `python`.

## Task 1: SQL queries rebuilt with pandas

```powershell
python src/pandas_sql_comparison.py
```

Custom input/output folders:

```powershell
python src/pandas_sql_comparison.py --input-dir data/source --output-dir data/output/pandas_reports
```

Compare generated CSVs in `data/output/pandas_reports/` against the Phase 1 SQL query results. See `docs/sql_vs_pandas_mapping.md`.

## Task 2: REST API to CSV and Parquet

Internet access is required when running:

```powershell
python src/api_extract.py --output-dir data/output/api --timeout 20
```

Outputs: `posts_cleaned.csv` and `posts_cleaned.parquet`.

## Task 3: argparse CLI

```powershell
python src/csv_to_parquet.py --input data/source/customers.csv --output data/output/customers.parquet
python src/csv_to_parquet.py --help
```

## Mini-project: scheduled API ingestion to SQLite

One run:

```powershell
python src/ingestion_pipeline.py --db-path data/output/ingestion.db --max-runs 1
```

Three runs, 60 seconds apart:

```powershell
python src/ingestion_pipeline.py --db-path data/output/ingestion.db --interval-seconds 60 --max-runs 3
```

Run continuously until Ctrl+C:

```powershell
python src/ingestion_pipeline.py --db-path data/output/ingestion.db --interval-seconds 3600 --max-runs 0
```

Inspect the SQLite table:

```powershell
python -c "import sqlite3; c=sqlite3.connect('data/output/ingestion.db'); print(c.execute('SELECT COUNT(*) FROM api_posts').fetchone()); print(c.execute('SELECT post_id,user_id,title FROM api_posts LIMIT 5').fetchall()); c.close()"
```

Logs are written to `logs/pipeline.log`. The SQLite `post_id` primary key and upsert prevent duplicate rows across repeated runs.

## Tests

```powershell
python -m unittest discover -s tests -v
```

## Notes
- Phase 1 e-commerce records are synthetic sample data, not the Kaggle Olist dataset.
- The REST API scripts require internet access at runtime.
- Parquet requires `pyarrow`, included in requirements.
- Scheduler is a simple loop; the process/terminal must remain running.
- External API execution and package installation are not pre-run in this packaged project.
