CREATE TABLE customers (
    customer_id VARCHAR(50) PRIMARY KEY,
    customer_unique_id VARCHAR(50),
    customer_zip_code_prefix VARCHAR(10),
    customer_city VARCHAR(100),
    customer_state CHAR(2)
);


SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public';

SELECT COUNT(*) AS total_customers
FROM public.customers;

SELECT *
FROM public.customers
LIMIT 10;


SELECT customer_id, COUNT(*)
FROM public.customers
GROUP BY customer_id
HAVING COUNT(*) > 1;












