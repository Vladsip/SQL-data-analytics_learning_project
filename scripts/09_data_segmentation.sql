/*
===============================================================================
Data Segmentation Analysis
===============================================================================
Purpose:
    - To group data into meaningful categories for targeted insights.
    - For customer segmentation, product categorization, or regional analysis.

SQL Functions Used:
    - CASE: Defines custom segmentation logic.
    - GROUP BY: Groups data into segments.
===============================================================================
*/

/*Segment products into cost ranges and 
count how many products fall into each segment*/
WITH cost_range AS(
SELECT 
    product_key,
    product_name,
    cost,
    CASE 
            WHEN cost < 100 THEN 'Below 100'
            WHEN cost BETWEEN 100 AND 500 THEN '100-500'
            WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
            ELSE 'Above 1000'
    END AS cost_range
FROM gold.dim_products
)
SELECT 
    cost_range,
    COUNT(product_key) as total_products
FROM cost_range
GROUP BY cost_range
ORDER BY total_products DESC



/*Group customers into three segments based on their spending behavior:
	- VIP: Customers with at least 12 months of history and spending more than €5,000.
	- Regular: Customers with at least 12 months of history but spending €5,000 or less.
	- New: Customers with a lifespan less than 12 months.
And find the total number of customers by each group
*/

WITH customer_spending AS (
    SELECT 
        f.customer_key,
        CONCAT(first_name, ' ', last_name) AS name,
        SUM (sales_amount) AS total_sales,
        MIN (order_date) AS first_order,
        MAX (order_date) AS last_order,
        DATEDIFF(month, MIN (order_date), MAX (order_date) ) as lifespan
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_customers c
    ON f.customer_key = c.customer_key
    GROUP BY  
        f.customer_key,
        first_name,
        last_name
),
customer_segment AS(
    SELECT  
        customer_key,
        name,
        total_sales,
        lifespan,
        CASE    
            WHEN total_sales > 5000 AND lifespan >= 12 THEN 'VIP'
            WHEN total_sales <= 5000 AND lifespan >= 12 THEN 'Regular'
            ELSE 'New'
        END as customer_segment
    FROM customer_spending
)
SELECT 
    customer_segment,
    COUNT(*) AS total_customers,
    ROUND(COUNT(*) * 100.0 / 
      CAST(SUM(COUNT(*)) OVER () AS FLOAT), 2) AS percent_share
FROM customer_segment
GROUP BY customer_segment
