-- 04_window_functions_10.sql
USE ecommerce_db;

-- 1. ROW_NUMBER: sequence orders per customer.
SELECT order_id, customer_id, order_date,
       ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY order_date, order_id) AS order_number
FROM orders;

-- 2. RANK: rank products by price (ties share rank; gaps may occur).
SELECT product_name, price, RANK() OVER(ORDER BY price DESC) AS price_rank
FROM products;

-- 3. DENSE_RANK: second-highest distinct product price.
WITH ranked AS (
    SELECT product_name, price,
           DENSE_RANK() OVER(ORDER BY price DESC) AS price_rank
    FROM products
)
SELECT * FROM ranked WHERE price_rank = 2;

-- 4. LAG: previous order date per customer.
SELECT customer_id, order_id, order_date,
       LAG(order_date) OVER(PARTITION BY customer_id ORDER BY order_date, order_id) AS previous_order_date
FROM orders;

-- 5. LEAD: next order date per customer.
SELECT customer_id, order_id, order_date,
       LEAD(order_date) OVER(PARTITION BY customer_id ORDER BY order_date, order_id) AS next_order_date
FROM orders;

-- 6. Running total of delivered revenue by month.
WITH monthly AS (
    SELECT DATE_FORMAT(o.order_date,'%Y-%m') AS sales_month,
           SUM(oi.quantity * oi.unit_price) AS revenue
    FROM orders o JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.status = 'Delivered'
    GROUP BY sales_month
)
SELECT *, SUM(revenue) OVER(ORDER BY sales_month) AS running_total
FROM monthly;

-- 7. Three-month moving average of delivered revenue.
WITH monthly AS (
    SELECT DATE_FORMAT(o.order_date,'%Y-%m') AS sales_month,
           SUM(oi.quantity * oi.unit_price) AS revenue
    FROM orders o JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.status = 'Delivered'
    GROUP BY sales_month
)
SELECT *, AVG(revenue) OVER(
    ORDER BY sales_month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
) AS moving_average
FROM monthly;

-- 8. Third order for each customer (all statuses).
WITH ranked AS (
    SELECT o.*, ROW_NUMBER() OVER(
        PARTITION BY customer_id ORDER BY order_date, order_id
    ) AS rn
    FROM orders o
)
SELECT * FROM ranked WHERE rn = 3;

-- 9. Rank customers by delivered lifetime spend.
WITH spend AS (
    SELECT o.customer_id, SUM(oi.quantity * oi.unit_price) AS total_spend
    FROM orders o JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.status = 'Delivered'
    GROUP BY o.customer_id
)
SELECT *, DENSE_RANK() OVER(ORDER BY total_spend DESC) AS spend_rank
FROM spend;

-- 10. Month-over-month revenue growth.
WITH monthly AS (
    SELECT DATE_FORMAT(o.order_date,'%Y-%m') AS sales_month,
           SUM(oi.quantity * oi.unit_price) AS revenue
    FROM orders o JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.status = 'Delivered'
    GROUP BY sales_month
), compared AS (
    SELECT *, LAG(revenue) OVER(ORDER BY sales_month) AS previous_revenue
    FROM monthly
)
SELECT sales_month, revenue, previous_revenue,
       ROUND((revenue - previous_revenue) * 100.0 /
             NULLIF(previous_revenue, 0), 2) AS growth_percentage
FROM compared;
