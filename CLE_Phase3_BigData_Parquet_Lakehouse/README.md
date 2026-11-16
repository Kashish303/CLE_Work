# CLE Phase 3 – Big Data: Parquet + Lakehouse

This folder contains the two Phase 3 Week 4 roadmap activities.

## Task 1 — Convert Phase 2 CSV outputs to Parquet and compare size/read speed

- Includes the five CSV outputs from the Phase 2 pandas exercise in `data/phase2_csv_outputs/`.
- `src/convert_and_benchmark.py` converts every CSV to Snappy-compressed Parquet using pandas + PyArrow.
- It checks that the CSV and Parquet data match, compares file sizes, and measures median read speed.
- It creates `benchmark/csv_vs_parquet_benchmark.csv` and `.md` on execution.

### Setup (Windows PowerShell)

```powershell
py -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install -r requirements.txt
```

### Run conversion and benchmark

```powershell
python src/convert_and_benchmark.py --repeats 30
```

Generated Parquet files will appear in `data/parquet_outputs/`. Benchmark results will appear in `benchmark/`.

If PowerShell blocks activation, use `.\.venv\Scripts\python.exe -m pip install -r requirements.txt`, then replace `python` with `.\.venv\Scripts\python.exe`.

### What to compare

- File size: `csv_size_bytes` vs `parquet_size_bytes`
- Read speed: `csv_median_read_ms` vs `parquet_median_read_ms`
- `parquet_read_speedup_x`: CSV median read time divided by Parquet median read time
- `data_equivalent`: must be `True`

The CSV outputs in this folder are the same five Phase 2 reports rebuilt from the Phase 1 synthetic e-commerce data. The actual Parquet binaries and machine-specific timing report are generated when you run the script on your PC. This environment does not have PyArrow installed and cannot download packages, so no fake Parquet files or fabricated benchmark timings are included.

## Task 2 — Databricks Lakehouse blog summary

Read `journal/lakehouse_architecture_summary.md`. It contains a four-line summary in your own-words style, based on Databricks' official blog post:
https://www.databricks.com/blog/what-is-data-lakehouse

## Project structure

```text
CLE_Phase3_BigData_Parquet_Lakehouse/
├── README.md
├── requirements.txt
├── data/
│   ├── customers.csv
│   ├── products.csv
│   ├── orders.csv
│   ├── order_items.csv
│   ├── phase2_csv_outputs/
│   └── parquet_outputs/
├── src/
│   └── convert_and_benchmark.py
├── benchmark/
├── journal/
│   └── lakehouse_architecture_summary.md
└── docs/
    └── benchmark_methodology.md
```
