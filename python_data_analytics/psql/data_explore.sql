-- Show table schema 
\d+ retail;

-- Show first 10 rows
SELECT * FROM retail limit 10;

-- Check # of records
SELECT COUNT(*) FROM retail;

-- number of clients (e.g. unique client ID)
SELECT COUNT(DISTINCT customer_id) FROM retail;

-- Q1: Show first 10 rows
SELECT * FROM retail LIMIT 10;

-- Q2: Check # of records
SELECT COUNT(*) FROM retail;

-- Q3: Number of clients (e.g. unique client ID)
SELECT COUNT(DISTINCT customer_id) FROM retail;

-- Q4: Invoice date range (e.g. max/min dates)
SELECT MIN(invoice_date) AS min_date, MAX(invoice_date) AS max_date FROM retail;

-- Q5: Number of SKU/merchants (e.g. unique stock code)
SELECT COUNT(DISTINCT stock_code) FROM retail;

-- Q6: Calculate average invoice amount excluding invoices with a negative amount
SELECT AVG(unit_price * quantity) FROM retail WHERE quantity > 0;

-- Q7: Calculate total revenue (e.g. sum of unit_price * quantity)
SELECT SUM(unit_price * quantity) FROM retail;

-- Q8: Calculate total revenue by YYYYMM
SELECT TO_CHAR(invoice_date, 'YYYYMM') AS month, SUM(unit_price * quantity) AS revenue 
FROM retail 
GROUP BY month 
ORDER BY month;