create database reatail;
use reatil;

-- 1️⃣ Create parent tables first
CREATE TABLE orders (
  order_id        VARCHAR(20) PRIMARY KEY,
  order_date      DATE,
  ship_mode       VARCHAR(50),
  segment         VARCHAR(50),
  region          VARCHAR(50),
  country         VARCHAR(50),
  state           VARCHAR(100),
  city            VARCHAR(100),
  postal_code     VARCHAR(20)
);

CREATE TABLE products (
  product_id      VARCHAR(20) PRIMARY KEY,
  category        VARCHAR(50),
  sub_category    VARCHAR(50),
  list_price      DECIMAL(10,2),
  cost_price      DECIMAL(10,2)
);

-- 2️⃣ Then create child table that references them
CREATE TABLE order_items (
  order_id          VARCHAR(20),
  product_id        VARCHAR(20),
  quantity          INT,
  discount_percent  DECIMAL(5,2),
  PRIMARY KEY (order_id, product_id),
  FOREIGN KEY (order_id) REFERENCES orders(order_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
  FOREIGN KEY (product_id) REFERENCES products(product_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE
);
SELECT * FROM orders;
SELECT * FROM products;
SELECT * FROM order_items;
-- 1) List all orders

-- Query:

SELECT * FROM orders;
-- 2) Show all distinct regions

-- Query:

SELECT DISTINCT region FROM orders;
-- 3) Count total number of orders

-- Query:

SELECT COUNT(*) AS total_orders FROM orders;
-- 4) Count unique products

-- Query:

SELECT COUNT(DISTINCT product_id) AS unique_products FROM products;
-- 5) List products in category "Technology"

-- Query:

SELECT * FROM products WHERE category = 'Technology';
-- 6) Orders from region 'West'

-- Query:

SELECT * FROM orders WHERE region = 'West';
-- 7) Count orders shipped by 'Second Class'

-- Query:

SELECT COUNT(*) AS second_class_orders FROM orders WHERE ship_mode = 'Second Class';
 -- 8) Total sales revenue (after discount)

-- Query:

SELECT ROUND(SUM(p.list_price * (1 - oi.discount_percent/100.0) * oi.quantity), 2) AS total_revenue FROM order_items oi JOIN products p ON oi.product_id = p.product_id;
-- 9) Total revenue per category

-- Query:

SELECT p.category, ROUND(SUM(p.list_price * (1 - oi.discount_percent/100.0) * oi.quantity), 2) AS total_revenue FROM order_items oi JOIN products p ON oi.product_id = p.product_id GROUP BY p.category ORDER BY total_revenue DESC;
 -- 10) Average discount percentage overall

-- Query:

SELECT ROUND(AVG(discount_percent), 2) AS average_discount FROM order_items;
-- 11) Top 5 states by total sales

-- Query:

SELECT o.state, ROUND(SUM(p.list_price * (1 - oi.discount_percent/100.0) * oi.quantity), 2) AS total_sales FROM order_items oi JOIN products p ON oi.product_id = p.product_id JOIN orders o ON oi.order_id = o.order_id GROUP BY o.state ORDER BY total_sales DESC LIMIT 5;
-- 12) Total quantity sold per sub-category

-- Query:

SELECT p.sub_category, SUM(oi.quantity) AS total_quantity FROM order_items oi JOIN products p ON oi.product_id = p.product_id GROUP BY p.sub_category ORDER BY total_quantity DESC;
-- 13) Orders per region

-- Query:

SELECT region, COUNT(order_id) AS total_orders FROM orders GROUP BY region ORDER BY total_orders DESC;
-- 14) All order lines with discount > 2%

-- Query:

SELECT * FROM order_items WHERE discount_percent > 2 ORDER BY discount_percent DESC;
-- 15) Profit per product (revenue − cost)

-- Query:

SELECT p.product_id, p.sub_category, ROUND(SUM((p.list_price * (1 - oi.discount_percent/100.0) * oi.quantity) - (p.cost_price * oi.quantity)), 2) AS total_profit FROM order_items oi JOIN products p ON oi.product_id = p.product_id GROUP BY p.product_id, p.sub_category ORDER BY total_profit DESC;
-- 16) Region with highest profit

-- Query:

SELECT o.region, ROUND(SUM((p.list_price * (1 - oi.discount_percent/100.0) * oi.quantity) - (p.cost_price * oi.quantity)), 2) AS total_profit FROM order_items oi JOIN products p ON oi.product_id = p.product_id JOIN orders o ON oi.order_id = o.order_id GROUP BY o.region ORDER BY total_profit DESC LIMIT 1;
-- 17) Top 10 most profitable products

-- Query:

SELECT p.product_id, p.sub_category, ROUND(SUM((p.list_price * (1 - oi.discount_percent/100.0) * oi.quantity) - (p.cost_price * oi.quantity)), 2) AS profit FROM order_items oi JOIN products p ON oi.product_id = p.product_id GROUP BY p.product_id, p.sub_category ORDER BY profit DESC LIMIT 10;
-- 18) Average revenue per order (AOV)

-- Query:

SELECT ROUND(SUM(p.list_price * (1 - oi.discount_percent/100.0) * oi.quantity) / COUNT(DISTINCT oi.order_id), 2) AS avg_order_value FROM order_items oi JOIN products p ON oi.product_id = p.product_id;
-- 19) Average quantity per line by region

-- Query:

SELECT o.region, ROUND(AVG(oi.quantity), 2) AS avg_qty_per_line FROM order_items oi JOIN orders o ON oi.order_id = o.order_id GROUP BY o.region ORDER BY avg_qty_per_line DESC;
-- 20) Rank top products by total revenue
-- Query:
SELECT
    p.product_id,
    p.sub_category,
    ROUND(SUM(p.list_price * (1 - oi.discount_percent/100.0) * oi.quantity), 2) AS total_revenue,
    RANK() OVER (ORDER BY SUM(p.list_price * (1 - oi.discount_percent/100.0) * oi.quantity) DESC) AS revenue_rank
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_id, p.sub_category
ORDER BY revenue_rank;
-- 21) Rank products by profit within each category
-- Query:
SELECT *
FROM (
    SELECT
        p.category,
        p.product_id,
        p.sub_category,
        ROUND(SUM((p.list_price * (1 - oi.discount_percent/100.0) * oi.quantity) - (p.cost_price * oi.quantity)), 2) AS total_profit,
        RANK() OVER (PARTITION BY p.category ORDER BY SUM((p.list_price * (1 - oi.discount_percent/100.0) * oi.quantity) - (p.cost_price * oi.quantity)) DESC) AS profit_rank
    FROM order_items oi
    JOIN products p ON oi.product_id = p.product_id
    GROUP BY p.category, p.product_id, p.sub_category
) ranked
WHERE profit_rank <= 3
ORDER BY category, profit_rank;
-- 22) Cumulative sales by date
-- Query:
SELECT
    o.order_date,
    ROUND(SUM(p.list_price * (1 - oi.discount_percent/100.0) * oi.quantity), 2) AS daily_sales,
    ROUND(SUM(SUM(p.list_price * (1 - oi.discount_percent/100.0) * oi.quantity)) 
          OVER (ORDER BY o.order_date ROWS UNBOUNDED PRECEDING), 2) AS cumulative_sales
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN orders o ON oi.order_id = o.order_id
GROUP BY o.order_date
ORDER BY o.order_date;



