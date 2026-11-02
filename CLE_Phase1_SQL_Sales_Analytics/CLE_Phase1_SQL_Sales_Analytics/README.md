# CLE Phase 1 – SQL Sales Analytics

A beginner-to-advanced SQL practice project aligned with Phase 1 (Week 1–2) of the CLE Big Data & EDW roadmap.

## Technology
- MySQL 8.0+
- MySQL Workbench

## Project structure
```text
CLE_Phase1_SQL_Sales_Analytics/
├── README.md
├── dataset/
│   └── README.md
├── sql/
│   ├── 01_database_setup.sql
│   ├── 02_load_sample_data.sql
│   ├── 03_basic_sql_practice.sql
│   ├── 04_window_functions_10.sql
│   └── 05_sales_analytics_mini_project.sql
└── screenshots/
```

## Setup and execution
1. Open MySQL Workbench and connect to your local MySQL 8.0+ server.
2. Open and execute `sql/01_database_setup.sql`.
3. Execute `sql/02_load_sample_data.sql`.
4. Execute the remaining SQL files in numerical order.
5. Review each result grid and save screenshots in `screenshots/`.

Run each file in order. The setup script drops and recreates the four project tables, so do not rerun it if you need to preserve your own changes.

## Database design
- `customers`: one row per customer.
- `products`: one row per product.
- `orders`: one row per order; references a customer.
- `order_items`: one row per product line in an order; references orders and products.

Relationship summary:
- One customer can have many orders.
- One order can have many order items.
- One product can appear in many order items.

## Activities covered
- Database and relational table setup
- Sample data loading and validation
- SELECT, filtering, sorting, grouping, joins, subqueries and CTEs
- Window functions: ROW_NUMBER, RANK, DENSE_RANK, LAG, LEAD, running total and moving average
- DDL/DML, view, index, EXPLAIN and transaction rollback
- Sales analytics mini-project: customers, category revenue, monthly revenue, repeat purchase, AOV, product ranking, cancellation rate, inactive customers, YoY growth and cohort retention

## Important data note
The included records are synthetic sample data created for learning and testing. They are not the Kaggle Olist dataset. The sample data contains only 2025 orders, so the YoY query correctly returns NULL growth because there is no prior-year comparison. Use a multi-year public dataset for a meaningful YoY analysis.

## Business metric definitions
- Revenue: `quantity * unit_price` for orders whose status is `Delivered`.
- Average order value (AOV): average of delivered order totals, not average line-item value.
- Repeat customer: customer with at least two delivered orders.
- Cancellation percentage: cancelled order count divided by all orders.
- Cohort: month of a customer's first delivered order.
- Retention percentage: active customers in a cohort/activity month divided by the original cohort size.
