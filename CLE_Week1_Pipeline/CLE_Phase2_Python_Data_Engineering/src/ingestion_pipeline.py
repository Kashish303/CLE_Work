import argparse, sqlite3, time
from pathlib import Path
import requests
from api_extract import fetch_posts,clean_posts
from common import configure_logging

def upsert_sqlite(df,db_path):
    db_path=Path(db_path); db_path.parent.mkdir(parents=True,exist_ok=True)
    with sqlite3.connect(db_path) as con:
        con.execute("""CREATE TABLE IF NOT EXISTS api_posts(
            post_id INTEGER PRIMARY KEY,user_id INTEGER NOT NULL,title TEXT,body TEXT,
            title_length INTEGER,body_length INTEGER,fetched_at_utc TEXT)""")
        rows=list(df[["post_id","user_id","title","body","title_length","body_length","fetched_at_utc"]]
                  .itertuples(index=False,name=None))
        con.executemany("""INSERT INTO api_posts VALUES(?,?,?,?,?,?,?)
            ON CONFLICT(post_id) DO UPDATE SET user_id=excluded.user_id,title=excluded.title,
            body=excluded.body,title_length=excluded.title_length,body_length=excluded.body_length,
            fetched_at_utc=excluded.fetched_at_utc""",rows)
        con.commit()

def run_once(db_path,logger):
    logger.info("Starting API ingestion")
    df=clean_posts(fetch_posts())
    upsert_sqlite(df,db_path)
    logger.info("Successfully upserted %d records into %s",len(df),db_path)
    return len(df)

def main():
    ap=argparse.ArgumentParser(description="Scheduled JSONPlaceholder -> pandas -> SQLite ingestion.")
    ap.add_argument("--db-path",type=Path,default=Path("data/output/ingestion.db"))
    ap.add_argument("--interval-seconds",type=int,default=3600)
    ap.add_argument("--max-runs",type=int,default=1,help="0 means run until Ctrl+C")
    ap.add_argument("--log-dir",type=Path,default=Path("logs"))
    a=ap.parse_args()
    if a.interval_seconds<1 or a.max_runs<0: ap.error("interval must be >=1 and max-runs >=0")
    log=configure_logging(a.log_dir); runs=0
    try:
        while a.max_runs==0 or runs<a.max_runs:
            try: run_once(a.db_path,log)
            except (requests.RequestException,ValueError,sqlite3.Error,OSError):
                log.exception("Ingestion run failed; continuing if more runs remain")
            runs+=1
            if a.max_runs==0 or runs<a.max_runs:
                log.info("Waiting %d seconds until next run",a.interval_seconds)
                time.sleep(a.interval_seconds)
    except KeyboardInterrupt: log.info("Stopped by user")
    log.info("Pipeline stopped after %d run(s)",runs)
if __name__=="__main__": main()
