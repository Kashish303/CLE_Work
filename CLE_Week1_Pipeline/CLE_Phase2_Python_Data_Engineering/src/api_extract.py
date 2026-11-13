import argparse
from pathlib import Path
import requests
import pandas as pd
from common import configure_logging

URL="https://jsonplaceholder.typicode.com/posts"

def fetch_posts(timeout=20):
    response=requests.get(URL,timeout=timeout)
    response.raise_for_status()
    data=response.json()
    if not isinstance(data,list): raise ValueError("Expected a JSON array from API")
    return data

def clean_posts(data):
    df=pd.DataFrame(data)
    required={"userId","id","title","body"}
    missing=required-set(df.columns)
    if missing: raise ValueError(f"Missing API fields: {sorted(missing)}")
    df=df.rename(columns={"userId":"user_id","id":"post_id"})
    df["title"]=df.title.fillna("").astype(str).str.strip()
    df["body"]=df.body.fillna("").astype(str).str.strip()
    df["user_id"]=pd.to_numeric(df.user_id,errors="coerce")
    df["post_id"]=pd.to_numeric(df.post_id,errors="coerce")
    df=df.dropna(subset=["user_id","post_id"]).drop_duplicates("post_id")
    df["user_id"]=df.user_id.astype("int64"); df["post_id"]=df.post_id.astype("int64")
    df["title_length"]=df.title.str.len(); df["body_length"]=df.body.str.len()
    df["fetched_at_utc"]=pd.Timestamp.now(tz="UTC").isoformat()
    return df[["post_id","user_id","title","body","title_length","body_length","fetched_at_utc"]]

def main():
    ap=argparse.ArgumentParser(description="Fetch JSONPlaceholder posts; clean and save CSV + Parquet.")
    ap.add_argument("--output-dir",type=Path,default=Path("data/output/api"))
    ap.add_argument("--timeout",type=int,default=20)
    ap.add_argument("--log-dir",type=Path,default=Path("logs"))
    a=ap.parse_args(); log=configure_logging(a.log_dir); a.output_dir.mkdir(parents=True,exist_ok=True)
    try:
        df=clean_posts(fetch_posts(a.timeout))
        csv_path=a.output_dir/"posts_cleaned.csv"; pq_path=a.output_dir/"posts_cleaned.parquet"
        df.to_csv(csv_path,index=False); df.to_parquet(pq_path,index=False)
        log.info("Saved %s cleaned API rows to CSV and Parquet",len(df))
        print(f"Rows: {len(df)} | CSV: {csv_path} | Parquet: {pq_path}")
    except (requests.RequestException,ValueError,OSError,ImportError):
        log.exception("API extraction failed"); raise SystemExit(1)
if __name__=="__main__": main()
