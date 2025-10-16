/*
===============================================================================
Performance Analysis (Year-over-Year, Month-over-Month)
===============================================================================
Purpose:
    - To measure the performance of products, customers, or regions over time.
    - For benchmarking and identifying high-performing entities.
    - To track yearly trends and growth.

SQL Functions Used:
    - LAG(): Accesses data from previous rows.
    - AVG() OVER(): Computes average values within partitions.
    - CASE: Defines conditional logic for trend analysis.
===============================================================================
*/

/* Analyze the yearly performance of products by comparing their sales 
to both the average sales performance of the product and the previous year's sales */

WITH monthly_product_sales AS (
    SELECT 
        COUNT(quantity) as total_quantity,
        DATETRUNC(month,f.order_date) AS order_month,
        p.product_name,
        SUM (f.sales_amount) as current_sales
    FROM  gold.fact_sales f
    LEFT JOIN gold.dim_products p
    ON f.product_key = p.product_key
    WHERE f.order_date IS NOT NULL
    GROUP BY 
         DATETRUNC(month,f.order_date),
         p.product_name
),
product_sales_analysis AS (
    SELECT 
        order_month,
        product_name,
        current_sales,
        AVG(current_sales) OVER (PARTITION BY product_name) AS avg_sales,
        --Month-Over_Month analysis
        LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_month) AS prev_month_sales,
        total_quantity,
        LAG(total_quantity) OVER (PARTITION BY product_name ORDER BY order_month) AS prev_mq
    FROM monthly_product_sales
)
SELECT 
        order_month,
        product_name,
        current_sales,
        avg_sales,
        current_sales - avg_sales AS diff_avg,
        CASE 
            WHEN current_sales - avg_sales > 0 THEN 'Above Avg'
            WHEN current_sales - avg_sales < 0 THEN 'Below Avg'
            ELSE 'Avg'
        END AS avg_change,
        prev_month_sales,
        current_sales - prev_month_sales AS diff_pm,
        CASE 
            WHEN current_sales - prev_month_sales > 0 THEN 'Increase'
            WHEN current_sales - prev_month_sales < 0 THEN 'Decrease'
            ELSE 'No Change'
        END AS pm_change,
        total_quantity,
        prev_mq,
        total_quantity - prev_mq AS diff_q,
        CASE 
            WHEN total_quantity - prev_mq >0 THEN 'Increase'
            WHEN total_quantity - prev_mq < 0 THEN 'Decrease'
            ELSE 'No Change'
        END AS quantity_change
FROM product_sales_analysis
ORDER BY product_name,order_month
