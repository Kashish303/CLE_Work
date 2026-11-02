-- 02_load_sample_data.sql
-- Synthetic training data. It is not the original Kaggle Olist dataset.
USE ecommerce_db;

INSERT INTO customers VALUES
(1,'Aarav','Jaipur','Rajasthan','2025-01-10'),
(2,'Priya','Delhi','Delhi','2025-02-15'),
(3,'Rahul','Mumbai','Maharashtra','2025-01-20'),
(4,'Sneha','Jaipur','Rajasthan','2025-03-10'),
(5,'Amit','Pune','Maharashtra','2025-04-12'),
(6,'Neha','Delhi','Delhi','2025-02-25'),
(7,'Ishita','Bengaluru','Karnataka','2025-03-01'),
(8,'Kabir','Jaipur','Rajasthan','2025-04-05');

INSERT INTO products VALUES
(101,'Laptop','Electronics',55000.00),
(102,'Mobile','Electronics',25000.00),
(103,'Headphones','Accessories',2000.00),
(104,'Keyboard','Accessories',1500.00),
(105,'Chair','Furniture',7000.00),
(106,'Table','Furniture',12000.00),
(107,'Monitor','Electronics',18000.00),
(108,'Mouse','Accessories',800.00);

INSERT INTO orders VALUES
(1001,1,'2025-01-15','Delivered'),
(1002,2,'2025-02-20','Delivered'),
(1003,1,'2025-02-25','Delivered'),
(1004,3,'2025-03-05','Delivered'),
(1005,4,'2025-03-15','Cancelled'),
(1006,5,'2025-04-20','Delivered'),
(1007,2,'2025-04-25','Delivered'),
(1008,6,'2025-05-10','Delivered'),
(1009,3,'2025-05-15','Delivered'),
(1010,1,'2025-06-01','Delivered'),
(1011,7,'2025-06-15','Delivered'),
(1012,5,'2025-07-03','Delivered'),
(1013,8,'2025-07-12','Pending'),
(1014,7,'2025-07-20','Delivered');

INSERT INTO order_items VALUES
(1,1001,101,1,55000.00),
(2,1001,103,2,2000.00),
(3,1002,102,1,25000.00),
(4,1002,104,2,1500.00),
(5,1003,103,1,2000.00),
(6,1003,105,1,7000.00),
(7,1004,106,1,12000.00),
(8,1005,102,1,25000.00),
(9,1006,101,1,55000.00),
(10,1006,104,1,1500.00),
(11,1007,105,2,7000.00),
(12,1008,103,3,2000.00),
(13,1009,102,1,25000.00),
(14,1010,106,1,12000.00),
(15,1010,104,2,1500.00),
(16,1011,107,2,18000.00),
(17,1012,108,4,800.00),
(18,1013,105,1,7000.00),
(19,1014,107,1,18000.00);

-- Verify row counts
SELECT 'customers' AS table_name, COUNT(*) AS row_count FROM customers
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'orders', COUNT(*) FROM orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items;
