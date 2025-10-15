/*
===============================================================================
Ranking Analysis
===============================================================================
Purpose:
    - To rank items (e.g., products, customers) based on performance or other metrics.
    - To identify top performers or laggards.

SQL Functions Used:
    - Window Ranking Functions: RANK(), DENSE_RANK(), ROW_NUMBER(), TOP
    - Clauses: GROUP BY, ORDER BY
===============================================================================
*/

-- Which 5 products Generating the Highest Revenue?
-- Simple Ranking
SELECT TOP 5
    p.product_name,
    SUM(sales_amount) as total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON f.product_key = p.product_key
GROUP BY 
    p.product_name
ORDER BY total_revenue DESC

-- Complex but Flexibly Ranking Using Window Functions

SELECT *
FROM (
    SELECT
        p.product_name,
        SUM(f.sales_amount) AS total_revenue,
        RANK() OVER (ORDER BY SUM(f.sales_amount) DESC) AS rank_products
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p
        ON p.product_key = f.product_key
    GROUP BY p.product_name
) AS ranked_products
WHERE rank_products <= 5;

-- CTE
WITH ranked_products AS (
    SELECT 
        p.product_name,
        SUM(sales_amount) as total_revenue,
        RANK() OVER (ORDER BY SUM(sales_amount) DESC) rank_revenue
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p
    ON f.product_key = p.product_key
    GROUP BY p.product_name
) 
SELECT *
FROM ranked_products
WHERE rank_revenue <= 5 


-- What are the 5 worst-performing products in terms of sales?
SELECT TOP 5
    p.product_name,
    SUM(sales_amount) as total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON f.product_key = p.product_key
GROUP BY 
    p.product_name
ORDER BY total_revenue 

-- Find the top 10 customers who have generated the highest revenue

SELECT TOP 10
    CONCAT (first_name, ' ', last_name) as name,
    SUM(sales_amount) as total_spend
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON f.customer_key = c.customer_key
GROUP BY first_name, last_name
ORDER BY total_spend DESC

SELECT *
FROM gold.dim_products

-- The 3 customers with the fewest orders placed
SELECT TOP 3
    CONCAT (first_name, ' ', last_name) as name,
    COUNT (DISTINCT order_number) as total_orders
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON f.customer_key = c.customer_key
GROUP BY first_name, last_name
ORDER BY total_orders 
