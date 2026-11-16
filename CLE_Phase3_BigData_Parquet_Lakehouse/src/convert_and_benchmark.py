"""Convert Phase 2 CSV outputs to Parquet and compare size/read speed.

Run from the project root:
    python src/convert_and_benchmark.py --repeats 30

Requires pandas and pyarrow. The script creates Parquet files, measures file sizes,
measures median read time after warm-up, checks row/column equivalence, and writes
CSV + Markdown benchmark reports.
"""
from __future__ import annotations
import argparse
from pathlib import Path
import statistics
import time
import pandas as pd

def median_read_ms(path: Path, fmt: str, repeats: int) -> float:
    reader = (lambda: pd.read_csv(path)) if fmt == "CSV" else (lambda: pd.read_parquet(path, engine="pyarrow"))
    reader()  # warm-up; exclude first read from timed repetitions
    timings = []
    for _ in range(repeats):
        start = time.perf_counter()
        reader()
        timings.append((time.perf_counter() - start) * 1000)
    return statistics.median(timings)

def main() -> None:
    ap = argparse.ArgumentParser(description="Convert Phase 2 CSV reports to Parquet and benchmark both formats.")
    ap.add_argument("--csv-dir", type=Path, default=Path("data/phase2_csv_outputs"))
    ap.add_argument("--parquet-dir", type=Path, default=Path("data/parquet_outputs"))
    ap.add_argument("--report-dir", type=Path, default=Path("benchmark"))
    ap.add_argument("--repeats", type=int, default=30)
    args = ap.parse_args()
    if args.repeats < 3:
        ap.error("--repeats must be at least 3 for a more stable median.")
    if not args.csv_dir.exists():
        ap.error(f"CSV folder not found: {args.csv_dir}")
    try:
        import pyarrow  # noqa: F401
    except ImportError as exc:
        raise SystemExit("pyarrow is required. Run: python -m pip install -r requirements.txt") from exc

    args.parquet_dir.mkdir(parents=True, exist_ok=True)
    args.report_dir.mkdir(parents=True, exist_ok=True)
    rows = []
    csv_files = sorted(args.csv_dir.glob("*.csv"))
    if not csv_files:
        raise SystemExit(f"No CSV files found in {args.csv_dir}")

    for csv_path in csv_files:
        df = pd.read_csv(csv_path)
        parquet_path = args.parquet_dir / f"{csv_path.stem}.parquet"
        df.to_parquet(parquet_path, engine="pyarrow", index=False, compression="snappy")

        # Validate logical data equality. CSV may infer types slightly differently,
        # so compare values after normalizing both frames to strings.
        csv_check = pd.read_csv(csv_path).fillna("").astype(str).reset_index(drop=True)
        pq_check = pd.read_parquet(parquet_path, engine="pyarrow").fillna("").astype(str).reset_index(drop=True)
        equivalent = csv_check.equals(pq_check)
        if not equivalent:
            raise AssertionError(f"CSV/Parquet data mismatch for {csv_path.name}")

        csv_bytes = csv_path.stat().st_size
        pq_bytes = parquet_path.stat().st_size
        csv_ms = median_read_ms(csv_path, "CSV", args.repeats)
        pq_ms = median_read_ms(parquet_path, "PARQUET", args.repeats)
        rows.append({
            "dataset": csv_path.stem,
            "rows": len(df),
            "columns": len(df.columns),
            "csv_size_bytes": csv_bytes,
            "parquet_size_bytes": pq_bytes,
            "size_reduction_pct": round((1 - pq_bytes / csv_bytes) * 100, 2) if csv_bytes else 0,
            "csv_median_read_ms": round(csv_ms, 4),
            "parquet_median_read_ms": round(pq_ms, 4),
            "parquet_read_speedup_x": round(csv_ms / pq_ms, 3) if pq_ms else None,
            "data_equivalent": equivalent,
        })

    result = pd.DataFrame(rows)
    csv_report = args.report_dir / "csv_vs_parquet_benchmark.csv"
    md_report = args.report_dir / "csv_vs_parquet_benchmark.md"
    result.to_csv(csv_report, index=False)
    total_csv = int(result.csv_size_bytes.sum())
    total_pq = int(result.parquet_size_bytes.sum())
    summary = [
        "# CSV vs Parquet benchmark",
        "",
        f"- Datasets tested: {len(result)}",
        f"- Total CSV size: {total_csv:,} bytes",
        f"- Total Parquet size: {total_pq:,} bytes",
        f"- Total size reduction: {(1-total_pq/total_csv)*100:.2f}%" if total_csv else "- Total size reduction: n/a",
        f"- Read benchmark: median of {args.repeats} timed reads after one warm-up read per format.",
        "- All CSV and Parquet outputs passed the data-equivalence check.",
        "",
        result.to_markdown(index=False),
        "",
        "## Interpretation",
        "Parquet is a columnar format and can be more compact and efficient for analytical reads, especially when selecting only a subset of columns or working with larger datasets. "
        "For these small sample reports, measured read times can be dominated by file-open and runtime overhead; do not generalize the results to large production datasets.",
        "",
    ]
    md_report.write_text("\n".join(summary), encoding="utf-8")
    print(result.to_string(index=False))
    print(f"\nWrote: {csv_report}\nWrote: {md_report}\nParquet files: {args.parquet_dir}")

if __name__ == "__main__":
    main()
