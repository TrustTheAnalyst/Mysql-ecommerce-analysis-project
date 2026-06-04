-- MySQL schema for Ecommerce Analytics Project

CREATE DATABASE IF NOT EXISTS ecommerce_project;
USE ecommerce_project;

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS `returns`;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS marketing_campaigns;

SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE customers (
  customer_id VARCHAR(10) PRIMARY KEY,
  customer_name VARCHAR(100),
  segment VARCHAR(50),
  country VARCHAR(50),
  region VARCHAR(50),
  signup_date DATE,
  preferred_channel VARCHAR(50)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE products (
  product_id VARCHAR(10) PRIMARY KEY,
  product_name VARCHAR(100),
  category VARCHAR(50),
  unit_cost DECIMAL(10,2),
  unit_price DECIMAL(10,2),
  supplier VARCHAR(50)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
describe products;
show columns from products;

CREATE TABLE orders (
  order_id VARCHAR(10) PRIMARY KEY,
  order_date DATE,
  customer_id VARCHAR(10),
  channel VARCHAR(50),
  payment_method VARCHAR(50),
  order_status VARCHAR(20),
  discount_rate DECIMAL(5,2),
  shipping_cost DECIMAL(10,2),
  CONSTRAINT fk_orders_customers
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE order_items (
  order_item_id VARCHAR(20) PRIMARY KEY,
  order_id VARCHAR(10),
  product_id VARCHAR(10),
  quantity INT,
  unit_price DECIMAL(10,2),
  discount_amount DECIMAL(10,2),
  revenue DECIMAL(12,2),
  cost DECIMAL(12,2),
  profit DECIMAL(12,2),
  CONSTRAINT fk_order_items_orders
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
  CONSTRAINT fk_order_items_products
    FOREIGN KEY (product_id) REFERENCES products(product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `returns` (
  return_id VARCHAR(10) PRIMARY KEY,
  order_id VARCHAR(10),
  order_item_id VARCHAR(20),
  return_date DATE,
  return_reason VARCHAR(50),
  refund_amount DECIMAL(12,2),
  CONSTRAINT fk_returns_orders
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
  CONSTRAINT fk_returns_order_items
    FOREIGN KEY (order_item_id) REFERENCES order_items(order_item_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE marketing_campaigns (
  campaign_id VARCHAR(10) PRIMARY KEY,
  campaign_month DATE,
  channel VARCHAR(50),
  marketing_spend DECIMAL(12,2),
  target_region VARCHAR(50)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

select * from customers limit 1000;
use ecommerce_project;
select count(*) from customers;
select count(*) from products;
select count(*) from orders;
select count(*) from order_items;
select count(*) from returns;
select count(*) from marketing_campaigns;

use ecommerce_analytics_project;
show tables;
select count(*) from customers;

SHOW VARIABLES LIKE 'local_infile';
USE ecommerce_analytics_project;
SET FOREIGN_KEY_CHECKS = 0;

select * from marketing_campaigns limit 5;
select * from customers limit 5;
select * from products limit 5;
select * from order_items limit 5;
select * from orders limit 5;
select * from returns limit 5;

select * from orders where order_id is null or customer_id is null or order_date is null;
select * from orders where channel is null or payment_method is null or order_status is null or discount_rate is null or shipping_cost is null;
select * from order_items where order_item_id is null or order_id is null or product_id is null or quantity is null or unit_price is null;
-- Check invalid or missing discount rates
SELECT *
FROM orders
WHERE discount_rate IS NULL
   OR discount_rate < 0
   OR discount_rate > 1;
   
   select * from customers where customer_id is null or customer_name is null or segment is null or country is null or region is null or signup_date is null or preferred_channel is null;
 select * from  products where product_id is null or product_name is null or category is null or unit_cost is null or unit_price is null or supplier is null;
select * from returns where return_id is null or order_id is null or order_item_id is null or return_date is null or return_reason is null or refund_amount is null;
 select * from marketing_campaigns where campaign_id is null or campaign_month is null or channel is null or marketing_spend is null or target_region is null;
-- 2. Check duplicate orders
SELECT order_id, COUNT(*) AS duplicate_count
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1; 
 SELECT
    COUNT(*) - COUNT(DISTINCT customer_id) AS total_duplicate_customer_id
FROM customers;
SELECT
    COUNT(*) - COUNT(DISTINCT order_item_id) AS total_duplicate_order_item_id
FROM order_items;
SELECT
    COUNT(*) - COUNT(DISTINCT campaign_id) AS total_duplicate_campaign_id
FROM marketing_campaigns;
SELECT
    SUM(order_date IS NULL) AS missing_order_dates,
    SUM(order_date > CURDATE()) AS future_order_dates,
    SUM(order_date < '2020-01-01') AS very_old_order_dates
FROM orders;
SELECT *
FROM orders
WHERE order_date IS NULL
   OR order_date > CURDATE()
   OR order_date < '2020-01-01';
SELECT
    SUM(return_date IS NULL) AS missing_return_dates,
    SUM(return_date > CURDATE()) AS future_return_dates
FROM returns;   
SELECT
    SUM(start_date > end_date) AS invalid_campaign_dates
FROM marketing_campaigns;
describe marketing_campaigns;
SELECT
    SUM(campaign_month IS NULL) AS missing_campaign_dates,
    SUM(campaign_month > CURDATE()) AS future_campaign_dates,
    SUM(campaign_month < '2020-01-01') AS very_old_campaign_dates
FROM marketing_campaigns;
SELECT
    SUM(signup_date IS NULL) AS missing_signup_dates,
    SUM(signup_date > CURDATE()) AS future_signup_dates,
    SUM(signup_date < '2020-01-01') AS very_old_signup_dates
FRom customers;



-- DATA CLEANING

-- REMOVING DUPLICATES
SELECT order_id, COUNT(*) AS duplicate_count
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;

-- NULL check
select * 
from orders 
where order_id is null
or customer_id is null
or order_date is null;

-- NEGATIVE REVENUE/PROFIT
SELECT *
FROM order_items
WHERE revenue < 0
   OR profit < 0;
   
-- INVALID DISCOUNT RATES
SELECT *
FROM orders
WHERE discount_rate < 0
   OR discount_rate > 1;
   
-- DATE FORMAT CHECK   
SELECT STR_TO_DATE(order_date, '%m/%d/%Y')
FROM orders;
   
   
-- SALES PERFORMANCE

-- WHAT IS THE TOTAL REVENUE?
-- TOTAL REVENUE

SELECT 
    SUM(revenue) AS TOTAL_REVENUE
FROM order_items;

-- BUINESS INSIGHT
-- The business generated a total revenue of 21,471,379.42, reflecting strong customer purchasing activity and healthy sales performance across the ecommerce platform. This indicates that the business successfully attracted customer demand and maintained consistent transaction flow throughout its operations.
-- BUINESS IMPACT
-- This level of revenue gives management a clear picture of the company’s strong sales performance and overall business growth. It also highlights the company’s ability to generate consistent income, making revenue an important KPI for tracking profitability, customer demand, and long-term business success.



-- WHICH PRODUCTS GENERATE THE MOST REVENUE?
-- REVENUE BY PRODUCT CATEGORY
SELECT 
    p.category,
    ROUND(SUM(oi.revenue), 2) AS total_revenue
FROM order_items oi
JOIN products p
ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY total_revenue DESC;

-- Business Insight
-- This suggests that technology products are a major contributor to sales growth and customer spending.
-- Business Impact
-- Focusing on the Technology category through better product availability and targeted promotions can help drive sales growth and attract more customers.


-- MONTLY REVENUE/SALES TREND
SELECT 
    DATE_FORMAT(order_date, '%Y-%m') AS month,
    ROUND(SUM(oi.revenue), 2) AS total_revenue
FROM order_items oi
JOIN orders o
ON oi.order_id = o.order_id
GROUP BY month
ORDER BY month;

-- Business Insight
-- Sales fluctuated throughout the year, reaching a peak in May 2024 and a low in February 2024, highlighting seasonal changes in customer demand.
-- Business Impact
-- Understanding these trends helps the business better plan inventory, staffing, and marketing throughout the year.


-- WHICH PRODUCTS GENERATE THE MOST REVENUE?
-- TOP SELLING PRODUCTS
SELECT 
    p.product_name,
    ROUND(SUM(oi.quantity), 0) AS total_units_sold,
    ROUND(SUM(oi.revenue), 2) AS total_revenue
FROM order_items oi
JOIN products p
ON oi.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_units_sold DESC
LIMIT 10;

-- Business Insight
-- Keyboard Model 3 stood out as a top-performing product, selling 307 units and generating 402,330.71 in revenue, reflecting strong customer demand and popularity.
-- Business Impact
-- The company can focus on promoting and keeping these top products in stock to drive sales and meet customer demand.


-- WHO ARE THE TOP CUSTOMERS BY SPENDING?
-- TOP CUSTOMERS
SELECT 
    c.customer_name,
    ROUND(SUM(oi.revenue), 2) AS total_revenue,
    ROUND(SUM(oi.quantity), 0) AS total_items_purchased
FROM order_items oi
JOIN orders o
ON oi.order_id = o.order_id
JOIN customers c
ON o.customer_id = c.customer_id
GROUP BY c.customer_name
ORDER BY total_revenue DESC
LIMIT 10;

-- Business Insight
-- A small group of loyal customers generated a significant share of revenue through frequent and high-value purchases with Carlos Okafor leading the list.
-- Business Impact
-- This highlights the value of customer loyalty and the opportunity to strengthen it through personalized offers, loyalty programs, and enhanced customer experiences.



-- WHICH CUSTOMERS ARE THE TOP REPEAT BUYERS?
-- CUSTOMER RETENTION
SELECT 
    c.customer_name,
    COUNT(DISTINCT o.order_id) AS total_orders,
    MIN(o.order_date) AS first_order,
    MAX(o.order_date) AS last_order
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY c.customer_name
HAVING COUNT(DISTINCT o.order_id) > 1
ORDER BY total_orders DESC;

-- Business Insight
-- Many customers made repeat purchases, showing strong customer satisfaction and loyalty with Mei Garcia leading on the list.
-- Business Impact
-- Keeping existing customers is more cost-effective than acquiring new ones and helps drive long-term growth and profitability.


-- AVERAGE ORDER VALUE (AOV)
SELECT 
    ROUND(SUM(oi.revenue) / COUNT(DISTINCT o.order_id), 2) AS average_order_value
FROM order_items oi
JOIN orders o
ON oi.order_id = o.order_id;

-- Business Insight
-- Customers spend an average of 2.53K per order, showing strong purchasing value.
-- Business Impact
-- Increasing upselling and cross-selling efforts can further boost revenue from each transaction.


-- WINDOW FUNCTIONS
SELECT 
    p.product_name,
    ROUND(SUM(oi.revenue), 2) AS total_revenue,
    RANK() OVER (
        ORDER BY SUM(oi.revenue) DESC
    ) AS product_rank
FROM order_items oi
JOIN products p
ON oi.product_id = p.product_id
GROUP BY p.product_name;

-- Business Insight
-- Products were ranked by revenue, making it easy to identify the best- and worst-performing items.
-- Business Impact
-- This helps the business make better pricing, marketing, and inventory decisions while identifying products that may need improvement or replacement.


-- Customers With Repeat Purchases
SELECT 
    c.customer_name,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.revenue), 2) AS total_revenue
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
JOIN order_items oi
ON o.order_id = oi.order_id
GROUP BY c.customer_name
HAVING COUNT(DISTINCT o.order_id) > 1
ORDER BY total_orders DESC;

-- Business Insight
-- Repeat customers made multiple purchases over time, showing strong loyalty and engagement with the brand.
-- Business Impact
-- This highlights strong customer loyalty and creates opportunities for targeted marketing, loyalty programs, and long-term customer retention.


-- Common Table Expressions (CTEs)
WITH product_sales AS (
    SELECT 
        p.product_name,
        ROUND(SUM(oi.revenue), 2) AS total_revenue
    FROM order_items oi
    JOIN products p
    ON oi.product_id = p.product_id
    GROUP BY p.product_name
)
-- Business Insight
-- CTEs made complex sales and customer analysis easier by breaking calculations into clear, manageable steps.
-- Business Impact
-- This made queries easier to read, maintain, and scale, supporting more efficient business reporting and analytics.


SELECT *
FROM product_sales
ORDER BY total_revenue DESC;

-- SUBQUERIES
SELECT 
    product_name,
    unit_price
FROM products
WHERE unit_price > (
    SELECT AVG(unit_price)
    FROM products
);

-- Business Insight
-- Subqueries helped identify top-performing products and customers by comparing them against overall business performance.
-- Business Impact
-- This helps the business focus on its best products and customers, supporting smarter decisions and revenue growth.



-- CREATE VIEWS
CREATE VIEW category_sales_summary AS
SELECT 
    p.category,
    ROUND(SUM(oi.revenue), 2) AS total_revenue,
    ROUND(SUM(oi.quantity), 0) AS total_units_sold
FROM order_items oi
JOIN products p
ON oi.product_id = p.product_id
GROUP BY p.category;

-- Business Insight
-- Views simplified access to key sales and customer insights by providing reusable business reports.
-- Business Impact
-- This made reporting faster and easier, supporting dashboards while reducing repetitive work for analysts and decision-makers.



-- INDEXING AND OPTIMIZATION
CREATE INDEX idx_product_id
ON order_items(product_id);

-- Business Insight
-- Indexes helped speed up data retrieval, making queries run faster even on large datasets.
-- Business Impact
-- Faster queries improved dashboard performance and reporting speed, helping the database handle growing business data more efficiently.


EXPLAIN SELECT *
FROM orders
WHERE customer_id = 101;


-- Create Stored Procedures
DELIMITER //

CREATE PROCEDURE GetTopSellingProducts()
BEGIN
    SELECT 
        p.product_name,
        ROUND(SUM(oi.quantity), 0) AS total_units_sold,
        ROUND(SUM(oi.revenue), 2) AS total_revenue
    FROM order_items oi
    JOIN products p
    ON oi.product_id = p.product_id
    GROUP BY p.product_name
    ORDER BY total_units_sold DESC
    LIMIT 10;
END //

DELIMITER ;

-- Business Insight
-- Stored procedures automated routine queries and reports, improving efficiency and reducing manual work.
-- Business Impact
-- This improves efficiency, minimizes errors, and supports business growth through automated, reusable SQL processes.


-- Build Triggers
DELIMITER //

CREATE TRIGGER update_stock_after_sale
AFTER INSERT ON order_items
FOR EACH ROW
BEGIN
    UPDATE products
    SET stock_quantity = stock_quantity - NEW.quantity
    WHERE product_id = NEW.product_id;
END //

DELIMITER ;

-- Business Insight
-- Triggers automated important business actions such as updating stock levels after sales transactions.
-- Business Impact
-- This helps keep data accurate and consistent across the business, improves inventory tracking, and automates routine tasks, reducing the need for manual work in day-to-day operations.
