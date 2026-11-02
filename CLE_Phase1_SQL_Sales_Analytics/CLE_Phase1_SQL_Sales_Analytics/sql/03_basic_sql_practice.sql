-- 03_basic_sql_practice.sql
USE ecommerce_db;

-- 1. Display all customers.
SELECT * FROM customers;

-- 2. Find customers from Jaipur.
SELECT * FROM customers WHERE city = 'Jaipur';

-- 3. Find products priced above 5000.
SELECT * FROM products WHERE price > 5000;

-- 4. Display products from highest to lowest price.
SELECT * FROM products ORDER BY price DESC;

-- 5. Find distinct customer cities.
SELECT DISTINCT city FROM customers;

-- 6. Count customers.
SELECT COUNT(*) AS total_customers FROM customers;

-- 7. Find average product price.
SELECT AVG(price) AS average_product_price FROM products;

-- 8. Find maximum and minimum product price.
SELECT MAX(price) AS max_price, MIN(price) AS min_price FROM products;

-- 9. Display customer names and their orders.
SELECT c.customer_name, o.order_id, o.order_date, o.status
FROM customers c JOIN orders o ON c.customer_id = o.customer_id;

-- 10. Find customers who have never ordered.
SELECT c.*
FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

-- 11. Count orders per customer (including customers with zero orders).
SELECT c.customer_id, c.customer_name, COUNT(o.order_id) AS order_count
FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name;

-- 12. Calculate revenue for each order (delivered orders only).
SELECT o.order_id, SUM(oi.quantity * oi.unit_price) AS revenue
FROM orders o JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status = 'Delivered'
GROUP BY o.order_id;

-- 13. Revenue by product category.
SELECT p.category, SUM(oi.quantity * oi.unit_price) AS revenue
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.status = 'Delivered'
GROUP BY p.category;

-- 14. Categories with revenue greater than 20000.
SELECT p.category, SUM(oi.quantity * oi.unit_price) AS revenue
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.status = 'Delivered'
GROUP BY p.category
HAVING SUM(oi.quantity * oi.unit_price) > 20000;

-- 15. Find the most expensive product in each category.
SELECT p.*
FROM products p
JOIN (
    SELECT category, MAX(price) AS max_price
    FROM products GROUP BY category
) x ON p.category = x.category AND p.price = x.max_price;

-- 16. Customers who placed more than one delivered order.
SELECT c.customer_id, c.customer_name, COUNT(*) AS delivered_orders
FROM customers c JOIN orders o ON c.customer_id = o.customer_id
WHERE o.status = 'Delivered'
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(*) > 1;

-- 17. Products priced above the overall average.
SELECT * FROM products WHERE price > (SELECT AVG(price) FROM products);

-- 18. Second-highest distinct product price.
SELECT MAX(price) AS second_highest_price
FROM products WHERE price < (SELECT MAX(price) FROM products);

-- 19. Customers whose delivered spending is above average customer spending.
WITH customer_spend AS (
    SELECT o.customer_id, SUM(oi.quantity * oi.unit_price) AS spend
    FROM orders o JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.status = 'Delivered'
    GROUP BY o.customer_id
)
SELECT c.customer_name, cs.spend
FROM customer_spend cs JOIN customers c ON c.customer_id = cs.customer_id
WHERE cs.spend > (SELECT AVG(spend) FROM customer_spend);

-- 20. Orders with value above average delivered order value.
WITH order_totals AS (
    SELECT o.order_id, SUM(oi.quantity * oi.unit_price) AS order_value
    FROM orders o JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.status = 'Delivered'
    GROUP BY o.order_id
)
SELECT * FROM order_totals
WHERE order_value > (SELECT AVG(order_value) FROM order_totals);

-- 21. Use a CTE to calculate customer spending.
WITH customer_spend AS (
    SELECT o.customer_id, SUM(oi.quantity * oi.unit_price) AS spend
    FROM orders o JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.status = 'Delivered'
    GROUP BY o.customer_id
)
SELECT c.customer_name, cs.spend
FROM customer_spend cs JOIN customers c ON c.customer_id = cs.customer_id;

-- 22. Latest order of every customer.
WITH ranked AS (
    SELECT o.*, ROW_NUMBER() OVER(
        PARTITION BY customer_id ORDER BY order_date DESC, order_id DESC
    ) AS rn
    FROM orders o
)
SELECT * FROM ranked WHERE rn = 1;

-- 23. Customers who purchased Electronics.
SELECT DISTINCT c.customer_id, c.customer_name
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
WHERE p.category = 'Electronics' AND o.status = 'Delivered';

-- 24. Products never ordered.
SELECT p.*
FROM products p LEFT JOIN order_items oi ON p.product_id = oi.product_id
WHERE oi.product_id IS NULL;

-- 25. Top 3 customers by delivered revenue.
SELECT c.customer_id, c.customer_name, SUM(oi.quantity * oi.unit_price) AS revenue
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status = 'Delivered'
GROUP BY c.customer_id, c.customer_name
ORDER BY revenue DESC LIMIT 3;

-- 26. Monthly delivered revenue.
SELECT DATE_FORMAT(o.order_date, '%Y-%m') AS sales_month,
       SUM(oi.quantity * oi.unit_price) AS revenue
FROM orders o JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status = 'Delivered'
GROUP BY sales_month ORDER BY sales_month;

-- 27. Month-over-month revenue growth.
WITH monthly AS (
    SELECT DATE_FORMAT(o.order_date, '%Y-%m') AS sales_month,
           SUM(oi.quantity * oi.unit_price) AS revenue
    FROM orders o JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.status = 'Delivered'
    GROUP BY sales_month
), compared AS (
    SELECT *, LAG(revenue) OVER (ORDER BY sales_month) AS previous_revenue
    FROM monthly
)
SELECT sales_month, revenue, previous_revenue,
       ROUND((revenue - previous_revenue) * 100.0 /
             NULLIF(previous_revenue, 0), 2) AS mom_growth_pct
FROM compared;

-- 28. First delivered order date for each customer.
SELECT customer_id, MIN(order_date) AS first_order_date
FROM orders WHERE status = 'Delivered' GROUP BY customer_id;

-- 29. Second delivered order of each customer.
WITH ranked AS (
    SELECT o.*, ROW_NUMBER() OVER(
        PARTITION BY customer_id ORDER BY order_date, order_id
    ) AS rn
    FROM orders o WHERE status = 'Delivered'
)
SELECT * FROM ranked WHERE rn = 2;

-- 30. Running total of monthly revenue.
WITH monthly AS (
    SELECT DATE_FORMAT(o.order_date, '%Y-%m') AS sales_month,
           SUM(oi.quantity * oi.unit_price) AS revenue
    FROM orders o JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.status = 'Delivered'
    GROUP BY sales_month
)
SELECT sales_month, revenue,
       SUM(revenue) OVER (ORDER BY sales_month) AS running_revenue
FROM monthly;

-- 31. Three-month moving average (current month + previous two available months).
WITH monthly AS (
    SELECT DATE_FORMAT(o.order_date, '%Y-%m') AS sales_month,
           SUM(oi.quantity * oi.unit_price) AS revenue
    FROM orders o JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.status = 'Delivered'
    GROUP BY sales_month
)
SELECT sales_month, revenue,
       ROUND(AVG(revenue) OVER (
           ORDER BY sales_month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
       ), 2) AS moving_average
FROM monthly;

-- 32. Rank products by revenue within category.
WITH product_revenue AS (
    SELECT p.product_id, p.product_name, p.category,
           SUM(oi.quantity * oi.unit_price) AS revenue
    FROM products p
    JOIN order_items oi ON p.product_id = oi.product_id
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.status = 'Delivered'
    GROUP BY p.product_id, p.product_name, p.category
)
SELECT *, DENSE_RANK() OVER(
    PARTITION BY category ORDER BY revenue DESC
) AS category_rank
FROM product_revenue;

-- 33. Create a reporting table from a SELECT query.
CREATE TABLE IF NOT EXISTS product_price_snapshot AS
SELECT product_id, product_name, price FROM products;

-- 34. Add a discount column.
ALTER TABLE product_price_snapshot
ADD COLUMN discount_pct DECIMAL(5,2) DEFAULT 0;

-- 35. Update a product price in the snapshot table only.
UPDATE product_price_snapshot SET price = price * 1.05 WHERE product_id = 101;

-- 36. Demonstrate DELETE safely on a temporary practice table.
CREATE TEMPORARY TABLE cancelled_order_test AS
SELECT * FROM orders WHERE status = 'Cancelled';
DELETE FROM cancelled_order_test WHERE status = 'Cancelled';
SELECT COUNT(*) AS remaining_test_rows FROM cancelled_order_test;

-- 37. Create an index on order_date.
CREATE INDEX idx_orders_order_date ON orders(order_date);

-- 38. Inspect a date-filter query plan.
EXPLAIN SELECT * FROM orders
WHERE order_date >= '2025-04-01' AND order_date < '2025-07-01';

-- 39. Demonstrate transaction rollback.
START TRANSACTION;
UPDATE products SET price = price + 100 WHERE product_id = 108;
ROLLBACK;
SELECT product_id, price FROM products WHERE product_id = 108;

-- 40. Create a view for delivered order revenue.
CREATE OR REPLACE VIEW delivered_order_revenue AS
SELECT o.order_id, o.customer_id, o.order_date,
       SUM(oi.quantity * oi.unit_price) AS revenue
FROM orders o JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status = 'Delivered'
GROUP BY o.order_id, o.customer_id, o.order_date;

SELECT * FROM delivered_order_revenue;
