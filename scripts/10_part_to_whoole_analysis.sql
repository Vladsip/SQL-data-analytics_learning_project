/*
===============================================================================
Part-to-Whole Analysis
===============================================================================
Purpose:
    - To compare performance or metrics across dimensions or time periods.
    - To evaluate differences between categories.
    - Useful for A/B testing or regional comparisons.

SQL Functions Used:
    - SUM(), AVG(): Aggregates values for comparison.
    - Window Functions: SUM() OVER() for total calculations.
===============================================================================
*/
-- Which categories contribute the most to overall sales?

WITH category_sales AS(
SELECT 
    category, 
    SUM (sales_amount) as category_sales
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON f.product_key = p.product_key
GROUP BY category
)
SELECT 
    category, 
    category_sales,
    SUM (category_sales) OVER () AS total_sales,
    ROUND((CAST(category_sales AS FLOAT) / SUM (category_sales) OVER ()) * 100, 2) AS pct_sales
FROM category_sales
GROUP BY category, 
    category_sales
