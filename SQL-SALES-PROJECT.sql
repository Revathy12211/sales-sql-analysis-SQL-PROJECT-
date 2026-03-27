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

--PRODUCTLINE WISE SALES
SELECT PRODUCTLINE, ROUND(SUM(SALES),2) AS total_sales
FROM dbo.sales_data_sample
GROUP BY PRODUCTLINE
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