SELECT * FROM dbo.sales_data_sample;

--NO OF ROWS
SELECT COUNT(*) FROM dbo.sales_data_sample;


--TOP 5 ROWS
SELECT TOP 5 * FROM dbo.sales_data_sample;


--NO OF UNIQUE COUNTRY
SELECT COUNT(DISTINCT COUNTRY)
FROM dbo.sales_data_sample;


--EARLIEST & LATEST DATE OF REPORT
SELECT MIN(orderdate) as mindate, MAX(orderdate) as maxdate
FROM dbo.sales_data_sample;


--TOTAL SOLD QTY & SALES AMOUNT
SELECT sum(Quantityordered) as QTYSOLD,SUM(sales) as SOLDAMOUNT,AVG(SALES) AS AVG_SALES FROM dbo.sales_data_sample;


--YEAR WISE -TOTAL SOLD QTY & SALES AMOUNT
SELECT YEAR_ID, sum(Quantityordered) as QTYSOLD,SUM(sales) as SOLDAMOUNT, AVG(SALES) AS AVG_SALES
FROM dbo.sales_data_sample
GROUP BY YEAR_ID
ORDER BY YEAR_ID;


--YEAR WISE & MONTHWISE -TOTAL SOLD QTY & SALES AMOUNT
SELECT YEAR_ID, MONTH_ID, sum(Quantityordered) as QTYSOLD,SUM(sales) as SOLDAMOUNT
FROM dbo.sales_data_sample
GROUP BY  YEAR_ID, MONTH_ID
ORDER BY  YEAR_ID, MONTH_ID


--TOP 5 CUSTOMERS BASED ON SALES AMOUNT
SELECT TOP 5 CUSTOMERNAME, SUM(SALES) AS total_sales
FROM dbo.sales_data_sample
GROUP BY CUSTOMERNAME
ORDER BY total_sales DESC;


-- TOP 5 CUSTOMERS VS TOTAL SALES
WITH customer_sales AS (
    SELECT 
        CUSTOMERNAME,
        SUM(SALES) AS customer_sales
    FROM dbo.sales_data_sample
    GROUP BY CUSTOMERNAME
),
top5 AS (
    SELECT TOP 5 *
    FROM customer_sales
    ORDER BY customer_sales DESC
),
total AS (
    SELECT SUM(SALES) AS total_sales
    FROM dbo.sales_data_sample
)
SELECT 
    SUM(top5.customer_sales) AS top5_sales,
    MAX(total.total_sales) AS total_sales,
    ROUND(
        SUM(top5.customer_sales) * 100.0 / MAX(total.total_sales),
    2) AS contribution_pct
FROM top5, total;


--TOP 5 CUSTOMERS FOR EACH PRODUCTLINE
SELECT *
FROM (SELECT PRODUCTLINE,CUSTOMERNAME,
SUM(SALES) AS total_sales,
ROW_NUMBER() OVER (PARTITION BY PRODUCTLINE ORDER BY SUM(SALES) DESC ) AS rn
FROM dbo.sales_data_sample
    GROUP BY PRODUCTLINE, CUSTOMERNAME
) t
WHERE rn <= 5;


--CUSTOMER SEGMENTATION
SELECT 
    CUSTOMERNAME,
    SUM(SALES) AS total_sales,
    CASE 
        WHEN SUM(SALES) > 100000 THEN 'High Value'
        WHEN SUM(SALES) BETWEEN 50000 AND 100000 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS customer_segment
FROM dbo.sales_data_sample
GROUP BY CUSTOMERNAME;


--MOM GROWTH%
SELECT 
    YEAR_ID,MONTH_ID,TOTAL_SALES,
    LAG(TOTAL_SALES) OVER (ORDER BY YEAR_ID, MONTH_ID ) AS PREV_M_SALES,
    ROUND((TOTAL_SALES - LAG(TOTAL_SALES) OVER ( ORDER BY YEAR_ID, MONTH_ID )) * 100.0 
    / LAG(TOTAL_SALES) OVER ( ORDER BY YEAR_ID, MONTH_ID ),2) AS MOM_GROWTH_PER  
FROM (
    SELECT YEAR_ID,MONTH_ID, ROUND(SUM(SALES),2) AS TOTAL_SALES 
    FROM dbo.sales_data_sample
    GROUP BY YEAR_ID, MONTH_ID
) AS T


--YOY GROWTH %
SELECT 
    YEAR_ID,TOTAL_SALES,
    LAG(TOTAL_SALES) OVER (ORDER BY YEAR_ID) AS PREV_SALES,
    ROUND((TOTAL_SALES - LAG(TOTAL_SALES) OVER ( ORDER BY YEAR_ID)) * 100.0 
    / LAG(TOTAL_SALES) OVER ( ORDER BY YEAR_ID ),2) AS YOY_GROWTH_PER  
FROM (
    SELECT YEAR_ID, ROUND(SUM(SALES),2) AS TOTAL_SALES 
    FROM dbo.sales_data_sample
    GROUP BY YEAR_ID
) AS T


--BEST MONTH PER YEAR 
SELECT * FROM ( select YEAR_ID,MONTH_ID, SUM(SALES) AS total_sales,
 ROW_NUMBER() OVER (PARTITION BY YEAR_ID ORDER BY SUM(SALES) DESC ) AS rn   
    FROM dbo.sales_data_sample
    GROUP BY YEAR_ID, MONTH_ID
) t
WHERE rn <= 2;


--NON PERFORMING MONTH PER YEAR 
SELECT * FROM ( select YEAR_ID,MONTH_ID, SUM(SALES) AS total_sales,
 ROW_NUMBER() OVER (PARTITION BY YEAR_ID ORDER BY SUM(SALES) ) AS rn   
    FROM dbo.sales_data_sample
    GROUP BY YEAR_ID, MONTH_ID
) t
WHERE rn <= 2;


--PRODUCTLINE WISE SALES
SELECT PRODUCTLINE, ROUND(SUM(SALES),2) AS total_sales
FROM dbo.sales_data_sample
GROUP BY PRODUCTLINE
ORDER BY total_sales DESC;


--PRODUCT LINE CONTRIBUTIION %
SELECT 
    PRODUCTLINE,
    SUM(SALES) AS product_sales,
    ROUND(
        SUM(SALES) * 100.0 / (SELECT SUM(SALES) FROM dbo.sales_data_sample),
    2) AS contribution_pct
FROM dbo.sales_data_sample
GROUP BY PRODUCTLINE
ORDER BY contribution_pct DESC;


--REPEAT CUSTOMERS
WITH customer_orders AS (
    SELECT 
        CUSTOMERNAME,
        COUNT(DISTINCT ORDERNUMBER) AS order_count
    FROM dbo.sales_data_sample
    GROUP BY CUSTOMERNAME
)
SELECT 
    COUNT(*) AS total_customers,
    SUM(CASE WHEN order_count > 2 THEN 1 ELSE 0 END) AS repeat_customers,
    ROUND(
        SUM(CASE WHEN order_count > 2 THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
    2) AS repeat_pct
FROM customer_orders;


--COHORT ANALYSIS -Cohort = group of customers who started at the same time
WITH first_order AS (
    SELECT 
        CUSTOMERNAME,
        MIN(DATEFROMPARTS(YEAR_ID, MONTH_ID, 1)) AS first_month
    FROM sales_data_sample
    GROUP BY CUSTOMERNAME
),
cohort_data AS (
    SELECT 
        s.CUSTOMERNAME,
        f.first_month,
        DATEFROMPARTS(s.YEAR_ID, s.MONTH_ID, 1) AS order_month,   -- ✅ comma here
        DATEDIFF(MONTH, f.first_month, DATEFROMPARTS(s.YEAR_ID, s.MONTH_ID, 1)) AS month_diff
    FROM sales_data_sample s
    JOIN first_order f 
        ON s.CUSTOMERNAME = f.CUSTOMERNAME
)
SELECT *
FROM (
    SELECT 
        first_month,
        month_diff,
        COUNT(DISTINCT CUSTOMERNAME) AS customers
    FROM cohort_data
    GROUP BY first_month, month_diff
) src
PIVOT (
    SUM(customers)
    FOR month_diff IN ([0],[1],[2],[3],[4],[5],[6])
) p
ORDER BY first_month;


--ROLLING AVG 3 MONTHS
SELECT 
    YEAR_ID,
    MONTH_ID,
    SUM(SALES) AS monthly_sales,
    AVG(SUM(SALES)) OVER (
        ORDER BY YEAR_ID, MONTH_ID 
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS rolling_avg_3_months
FROM dbo.sales_data_sample
GROUP BY YEAR_ID, MONTH_ID;


--CUSTOMER LIFETIME VALUE
SELECT 
    CUSTOMERNAME,
    COUNT(DISTINCT ORDERNUMBER) AS total_orders,
    SUM(SALES) AS total_revenue,
    AVG(SALES) AS avg_order_value
FROM sales_data_sample
GROUP BY CUSTOMERNAME
ORDER BY total_revenue DESC;


--PARETO ANALYSIS (80/20 Rule) IDENTIFY TOP CONTRIBUTORS TO REVENUE
WITH revenue_data AS (
    SELECT 
        CUSTOMERNAME,
        SUM(SALES) AS revenue
    FROM sales_data_sample
    GROUP BY CUSTOMERNAME
),
ranked AS (
    SELECT *,
        SUM(revenue) OVER (ORDER BY revenue DESC) AS running_total,
        SUM(revenue) OVER () AS total_revenue
    FROM revenue_data
)
SELECT *,
    running_total * 100.0 / total_revenue AS cumulative_pct
FROM ranked;


-- SALES CONTRIBUTION BY REGION
SELECT 
    COUNTRY,
    SUM(SALES) AS total_sales,
    ROUND(SUM(SALES) * 100.0 / SUM(SUM(SALES)) OVER (), 2) AS contribution_pct
FROM sales_data_sample
GROUP BY COUNTRY
ORDER BY total_sales DESC;


-- DETECT SALES ANOMALIES -Find unusual spikes/drops
WITH monthly_sales AS (
    SELECT 
        YEAR_ID,
        MONTH_ID,
        SUM(SALES) AS total_sales
    FROM sales_data_sample
    GROUP BY YEAR_ID, MONTH_ID
),
stats AS (
    SELECT *,
        AVG(total_sales) OVER () AS avg_sales,
        STDEV(total_sales) OVER () AS std_dev
    FROM monthly_sales
),
final AS (
    SELECT *,
        CASE 
            WHEN total_sales > avg_sales + (2 * std_dev) THEN 'Hike Spike'
            WHEN total_sales < avg_sales - (2 * std_dev) THEN 'Low Spike'
            ELSE 'Normal'
        END AS sales_status
    FROM stats
)

SELECT *
FROM final
WHERE sales_status IN ('Hike Spike', 'Low Spike');