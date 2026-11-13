import argparse
from pathlib import Path
import pandas as pd

def main():
    ap=argparse.ArgumentParser(description="Convert CSV to Parquet.")
    ap.add_argument("--input",type=Path,required=True)
    ap.add_argument("--output",type=Path,required=True)
    a=ap.parse_args()
    if not a.input.is_file(): ap.error(f"Input file not found: {a.input}")
    a.output.parent.mkdir(parents=True,exist_ok=True)
    df=pd.read_csv(a.input); df.to_parquet(a.output,index=False)
    print(f"Converted {len(df)} rows: {a.input} -> {a.output}")
if __name__=="__main__": main()
