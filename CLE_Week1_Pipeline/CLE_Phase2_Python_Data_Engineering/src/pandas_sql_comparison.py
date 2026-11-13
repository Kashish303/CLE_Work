import argparse
from pathlib import Path
import pandas as pd

def load_tables(folder):
    t = {n: pd.read_csv(Path(folder) / f"{n}.csv")
         for n in ["customers","products","orders","order_items"]}
    t["orders"]["order_date"] = pd.to_datetime(t["orders"]["order_date"])
    return t

def build_reports(t):
    c,p,o,i = t["customers"],t["products"],t["orders"],t["order_items"]
    delivered = o[o.status.eq("Delivered")]
    lines = delivered.merge(i,on="order_id").merge(p,on="product_id")
    lines["revenue"] = lines.quantity * lines.unit_price

    r1 = c.groupby("city",as_index=False).agg(customer_count=("customer_id","nunique")).sort_values("city")
    r2 = c[["customer_id","customer_name"]].merge(
        delivered.groupby("customer_id",as_index=False).agg(delivered_order_count=("order_id","nunique")),
        on="customer_id",how="left")
    r2["delivered_order_count"] = r2.delivered_order_count.fillna(0).astype(int)
    r2 = r2.sort_values("customer_id")
    r3 = lines.groupby("category",as_index=False).agg(revenue=("revenue","sum")).sort_values("revenue",ascending=False)
    r4 = (lines.groupby("customer_id",as_index=False).agg(revenue=("revenue","sum"))
          .merge(c[["customer_id","customer_name"]],on="customer_id")
          [["customer_id","customer_name","revenue"]]
          .sort_values(["revenue","customer_id"],ascending=[False,True]).head(5))
    lines["sales_month"] = lines.order_date.dt.to_period("M").astype(str)
    r5 = lines.groupby("sales_month",as_index=False).agg(revenue=("revenue","sum")).sort_values("sales_month")
    return {
        "01_customer_count_by_city":r1,
        "02_delivered_orders_per_customer":r2,
        "03_revenue_by_category":r3,
        "04_top_5_customers_by_revenue":r4,
        "05_monthly_revenue":r5
    }

def main():
    ap=argparse.ArgumentParser(description="Rebuild five Phase 1 SQL reports with pandas.")
    ap.add_argument("--input-dir",type=Path,default=Path("data/source"))
    ap.add_argument("--output-dir",type=Path,default=Path("data/output/pandas_reports"))
    a=ap.parse_args(); a.output_dir.mkdir(parents=True,exist_ok=True)
    for name,df in build_reports(load_tables(a.input_dir)).items():
        path=a.output_dir/f"{name}.csv"; df.to_csv(path,index=False)
        print(f"Saved {path} ({len(df)} rows)")
if __name__=="__main__": main()
