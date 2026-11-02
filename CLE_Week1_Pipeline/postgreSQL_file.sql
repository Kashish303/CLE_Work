CREATE DATABASE IF NOT EXISTS olist_source;
USE olist_source;
SELECT DATABASE();

USE olist_source;

CREATE TABLE customers (
    customer_id VARCHAR(50) PRIMARY KEY,
    customer_unique_id VARCHAR(50),
    customer_zip_code_prefix VARCHAR(10),
    customer_city VARCHAR(100),
    customer_state CHAR(2)
);

SHOW TABLES;
DESCRIBE customers;

TRUNCATE TABLE olist_source.customers;

SELECT COUNT(*) AS total_customers
FROM olist_source.customers;

USE olist_source;

-- Check total records
SELECT COUNT(*) AS total_customers
FROM customers;

-- View sample data
SELECT *
FROM customers
LIMIT 10;

-- Check unique customer IDs
SELECT COUNT(DISTINCT customer_id) AS unique_customers
FROM customers;

SELECT COUNT(*) AS total_records
FROM customers;


