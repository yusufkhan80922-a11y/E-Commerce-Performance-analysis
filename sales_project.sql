SELECT *
FROM customers
LIMIT 10;

SELECT *
FROM orders
LIMIT 10;

SELECT *
FROM products
LIMIT 10;

SELECT *
FROM returns
LIMIT 10;

-- Q1. What is the total gross revenue, total net revenue, and total discount amount? 
SELECT
	SUM(sales_amount) AS Total_gross_revenue,
	SUM(sales_amount) - SUM(sales_amount) / SUM(1- discount) * SUM(discount) AS Net_revenue_after_discount,
	 SUM(sales_amount) / SUM(1- discount) * SUM(discount) AS Total_discount_amount
FROM orders;
	
-- Q2. How many unique orders were placed, and what is the average order value (AOV)?
SELECT 
	COUNT(DISTINCT order_id) AS Unique_orders,
	SUM(sales_amount) / COUNT(DISTINCT order_id) AS Average_order_value
FROM orders;

-- Q3. Which product categories generate the highest revenue and how much does each contribute to total revenue?
SELECT 
    p.category,
    SUM(o.sales_amount) AS revenue,
    SUM(o.sales_amount) * 100.0 /
        SUM(SUM(o.sales_amount)) OVER () AS contribution_percentage
FROM products p
INNER JOIN orders o
    ON p.product_id = o.product_id
GROUP BY p.category
ORDER BY revenue DESC;

-- Q4. What is the monthly revenue trend, and which months have the highest and lowest revenue?
SELECT
    EXTRACT(MONTH FROM order_date) AS Month,
    SUM(sales_amount) AS Monthly_revenue_trend
FROM orders
GROUP BY EXTRACT(MONTH FROM order_date)
ORDER BY Monthly_revenue_trend DESC;

-- Q5. Who are the top 3 verified customers by revenue, and what are their total orders and states?
SELECT 
	c.customer_id,
	c.customer_name,
	c.state,
	SUM(o.sales_amount) AS Revenue,
	COUNT(DISTINCT o.order_id) AS Total_orders
FROM customers c
INNER JOIN orders o
	ON c.customer_id = o.customer_id
GROUP BY c.customer_id,
	c.customer_name,
	c.state
ORDER BY Revenue DESC
LIMIT 3;
	
-- Q6. What percentage of customers have placed more than one order?
WITH customer_orders AS (
    SELECT
        customer_id,
        COUNT(DISTINCT order_id) AS total_orders
FROM orders
GROUP BY customer_id
)
SELECT
    ROUND(
        COUNT(*) FILTER (WHERE total_orders > 1) * 100.0
        / (SELECT COUNT(*) FROM customers),
        2
    ) AS repeat_customer_percentage
FROM customer_orders;
-- Q7. Which states generate the highest revenue?
SELECT 
	c.state,
	SUM(o.sales_amount) AS Highest_revenue
FROM customers c
INNER JOIN orders o
	ON c.customer_id = o.customer_id
GROUP BY c.state
ORDER BY Highest_revenue DESC
LIMIT 1;
	
-- Q8. Which five products have the highest profit margins?
SELECT 
	p.product_name,
	SUM(o.sales_amount - p.unit_price) /
	SUM(o.sales_amount) * 100 AS Profit_margins
FROM products p
INNER JOIN orders o
	ON p.product_id = o.product_id
GROUP BY p.product_name
ORDER BY Profit_margins DESC
LIMIT 5;

-- Q9. Which five products have the highest profit margins?
SELECT 
	p.product_name,
	SUM(o.sales_amount - p.unit_price) /
	SUM(o.sales_amount) * 100 AS Profit_margins
FROM products p
INNER JOIN orders o
	ON p.product_id = o.product_id
GROUP BY p.product_name
ORDER BY Profit_margins ASC;

-- Q10. Which product categories receive the highest discounts, and how do discounts relate to their profitability?
SELECT
    p.category,
    ROUND(AVG(o.discount)::numeric, 2) AS average_discount,
    MAX(o.discount) AS highest_discount,
    SUM(o.sales_amount) AS total_sales
FROM products p
INNER JOIN orders o
    ON p.product_id = o.product_id
GROUP BY p.category
ORDER BY average_discount DESC;

-- Q11. What is the overall product return rate?
SELECT
    COUNT(DISTINCT r.order_id) * 100
    / NULLIF(COUNT(DISTINCT o.order_id), 0) AS return_rate_percentage
FROM orders o
LEFT JOIN returns r
    ON o.order_id = r.order_id; 

-- Q12. Which product categories have the most returns?
SELECT
	p.category,
	COUNT(r.return_id) AS Total_returns
FROM products p
INNER JOIN orders o
    ON p.product_id = o.product_id
INNER JOIN returns r
    ON o.order_id = r.order_id
GROUP BY p.category
ORDER BY Total_returns DESC
LIMIT 1;

-- Q13. What are the most common reasons for product returns?
SELECT
	return_reason,
	COUNT(return_id) AS Returns
FROM returns
GROUP BY return_reason
ORDER BY Returns DESC
LIMIT 3;

-- Q14. What are the counts and financial impacts of processed and pending returns?
SELECT
    r.refund_status,
    COUNT(r.return_id) AS total_returns,
    SUM(o.sales_amount) AS total_financial_impact
FROM returns r
JOIN orders o
    ON r.order_id = o.order_id
GROUP BY r.refund_status
ORDER BY total_returns DESC;

-- Q15. Which payment methods and shipping modes are most commonly used by customers?
SELECT
    payment_method,
	ship_mode,
    COUNT(*) AS total_orders
FROM orders
GROUP BY payment_method, ship_mode
ORDER BY total_orders DESC;
