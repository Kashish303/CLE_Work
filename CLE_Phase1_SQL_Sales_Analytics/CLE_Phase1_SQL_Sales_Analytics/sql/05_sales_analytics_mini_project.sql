-- 05_sales_analytics_mini_project.sql
-- Sales Analytics report: run after setup + sample data scripts.
USE ecommerce_db;

-- Q1. Top five customers by delivered revenue.
SELECT c.customer_id, c.customer_name,
       SUM(oi.quantity * oi.unit_price) AS revenue
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status = 'Delivered'
GROUP BY c.customer_id, c.customer_name
ORDER BY revenue DESC
LIMIT 5;

-- Q2. Revenue by product category.
SELECT p.category, SUM(oi.quantity * oi.unit_price) AS revenue
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.status = 'Delivered'
GROUP BY p.category
ORDER BY revenue DESC;

-- Q3. Monthly revenue.
SELECT DATE_FORMAT(o.order_date,'%Y-%m') AS sales_month,
       SUM(oi.quantity * oi.unit_price) AS revenue
FROM orders o JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status = 'Delivered'
GROUP BY sales_month ORDER BY sales_month;

-- Q4. Repeat-purchase customers (at least two delivered orders).
SELECT c.customer_id, c.customer_name,
       COUNT(DISTINCT o.order_id) AS delivered_orders
FROM customers c JOIN orders o ON c.customer_id = o.customer_id
WHERE o.status = 'Delivered'
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(DISTINCT o.order_id) >= 2;

-- Q5. Average order value (average of delivered order totals).
WITH order_totals AS (
    SELECT o.order_id, SUM(oi.quantity * oi.unit_price) AS order_value
    FROM orders o JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.status = 'Delivered'
    GROUP BY o.order_id
)
SELECT ROUND(AVG(order_value),2) AS average_order_value
FROM order_totals;

-- Q6. Top three products by revenue within each category.
WITH product_revenue AS (
    SELECT p.product_id, p.product_name, p.category,
           SUM(oi.quantity * oi.unit_price) AS revenue
    FROM products p
    JOIN order_items oi ON p.product_id = oi.product_id
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.status = 'Delivered'
    GROUP BY p.product_id, p.product_name, p.category
), ranked AS (
    SELECT *, DENSE_RANK() OVER(
        PARTITION BY category ORDER BY revenue DESC
    ) AS category_rank
    FROM product_revenue
)
SELECT * FROM ranked WHERE category_rank <= 3;

-- Q7. Cancelled order percentage (order count basis).
SELECT ROUND(
    SUM(CASE WHEN status = 'Cancelled' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2
) AS cancellation_percentage
FROM orders;

-- Q8. Customers who have never placed an order.
SELECT c.customer_id, c.customer_name
FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

-- Q9. Year-over-year revenue growth. With this sample dataset only 2025 exists,
-- so previous-year revenue and growth will be NULL; more years are needed to measure YoY.
WITH yearly AS (
    SELECT YEAR(o.order_date) AS sales_year,
           SUM(oi.quantity * oi.unit_price) AS revenue
    FROM orders o JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.status = 'Delivered'
    GROUP BY YEAR(o.order_date)
), compared AS (
    SELECT *, LAG(revenue) OVER(ORDER BY sales_year) AS previous_year_revenue
    FROM yearly
)
SELECT *, ROUND((revenue - previous_year_revenue) * 100.0 /
                NULLIF(previous_year_revenue,0), 2) AS yoy_growth_pct
FROM compared;

-- Q10. Cohort activity counts and retention percentage.
-- Cohort = month of first delivered order. Retention = active customers / cohort size.
WITH first_purchase AS (
    SELECT customer_id, MIN(DATE_FORMAT(order_date,'%Y-%m')) AS cohort_month
    FROM orders
    WHERE status = 'Delivered'
    GROUP BY customer_id
), activity AS (
    SELECT DISTINCT o.customer_id, f.cohort_month,
           DATE_FORMAT(o.order_date,'%Y-%m') AS activity_month
    FROM orders o JOIN first_purchase f ON o.customer_id = f.customer_id
    WHERE o.status = 'Delivered'
), cohort_sizes AS (
    SELECT cohort_month, COUNT(DISTINCT customer_id) AS cohort_size
    FROM first_purchase GROUP BY cohort_month
)
SELECT a.cohort_month, a.activity_month,
       COUNT(DISTINCT a.customer_id) AS active_customers,
       cs.cohort_size,
       ROUND(COUNT(DISTINCT a.customer_id) * 100.0 / cs.cohort_size, 2) AS retention_pct
FROM activity a JOIN cohort_sizes cs ON a.cohort_month = cs.cohort_month
GROUP BY a.cohort_month, a.activity_month, cs.cohort_size
ORDER BY a.cohort_month, a.activity_month;
