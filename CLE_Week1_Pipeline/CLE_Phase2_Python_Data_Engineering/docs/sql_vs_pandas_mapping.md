# SQL to pandas mapping

The four CSV files in `data/source/` contain the same synthetic training records used in the Phase 1 SQL project.

| Report | SQL equivalent | pandas equivalent |
|---|---|---|
| Customer count by city | GROUP BY + COUNT DISTINCT | groupby + nunique |
| Delivered orders per customer | LEFT JOIN + GROUP BY | merge(how='left') + groupby |
| Revenue by category | JOIN + GROUP BY + SUM | merge + calculated column + groupby |
| Top 5 customers by revenue | JOIN + GROUP BY + ORDER BY + LIMIT | merge + groupby + sort_values + head |
| Monthly revenue | DATE_FORMAT + GROUP BY | datetime + dt.to_period + groupby |

Run the Phase 1 SQL queries and `python src/pandas_sql_comparison.py`; compare the SQL result grids with the generated CSV outputs.
