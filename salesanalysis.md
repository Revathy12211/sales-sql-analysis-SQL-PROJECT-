SELECT \* FROM dbo.sales\_data\_sample;



**--NO OF ROWS**

SELECT COUNT(\*) FROM dbo.sales\_data\_sample;





**--TOP 5 ROWS**

SELECT TOP 5 \* FROM dbo.sales\_data\_sample;





**--NO OF UNIQUE COUNTRY**

SELECT COUNT(DISTINCT COUNTRY)

FROM dbo.sales\_data\_sample;





**--EARLIEST \& LATEST DATE OF REPORT**

SELECT MIN(orderdate) as mindate, MAX(orderdate) as maxdate

FROM dbo.sales\_data\_sample;





**--TOTAL SOLD QTY \& SALES AMOUNT**

SELECT sum(Quantityordered) as QTYSOLD,SUM(sales) as SOLDAMOUNT,AVG(SALES) AS AVG\_SALES FROM dbo.sales\_data\_sample;





**--YEAR WISE -TOTAL SOLD QTY \& SALES AMOUNT**

SELECT YEAR\_ID, sum(Quantityordered) as QTYSOLD,SUM(sales) as SOLDAMOUNT, AVG(SALES) AS AVG\_SALES

FROM dbo.sales\_data\_sample

GROUP BY YEAR\_ID

ORDER BY YEAR\_ID;





**--YEAR WISE \& MONTHWISE -TOTAL SOLD QTY \& SALES AMOUNT**

SELECT YEAR\_ID, MONTH\_ID, sum(Quantityordered) as QTYSOLD,SUM(sales) as SOLDAMOUNT

FROM dbo.sales\_data\_sample

GROUP BY  YEAR\_ID, MONTH\_ID

ORDER BY  YEAR\_ID, MONTH\_ID





**--TOP 5 CUSTOMERS BASED ON SALES AMOUNT**

SELECT TOP 5 CUSTOMERNAME, SUM(SALES) AS total\_sales

FROM dbo.sales\_data\_sample

GROUP BY CUSTOMERNAME

ORDER BY total\_sales DESC;





**-- TOP 5 CUSTOMERS VS TOTAL SALES**

WITH customer\_sales AS (

&#x20;   SELECT 

&#x20;       CUSTOMERNAME,

&#x20;       SUM(SALES) AS customer\_sales

&#x20;   FROM dbo.sales\_data\_sample

&#x20;   GROUP BY CUSTOMERNAME

),

top5 AS (

&#x20;   SELECT TOP 5 \*

&#x20;   FROM customer\_sales

&#x20;   ORDER BY customer\_sales DESC

),

total AS (

&#x20;   SELECT SUM(SALES) AS total\_sales

&#x20;   FROM dbo.sales\_data\_sample

)

SELECT 

&#x20;   SUM(top5.customer\_sales) AS top5\_sales,

&#x20;   MAX(total.total\_sales) AS total\_sales,

&#x20;   ROUND(

&#x20;       SUM(top5.customer\_sales) \* 100.0 / MAX(total.total\_sales),

&#x20;   2) AS contribution\_pct

FROM top5, total;





**--TOP 5 CUSTOMERS FOR EACH PRODUCTLINE**

SELECT \*

FROM (SELECT PRODUCTLINE,CUSTOMERNAME,

SUM(SALES) AS total\_sales,

ROW\_NUMBER() OVER (PARTITION BY PRODUCTLINE ORDER BY SUM(SALES) DESC ) AS rn

FROM dbo.sales\_data\_sample

&#x20;   GROUP BY PRODUCTLINE, CUSTOMERNAME

) t

WHERE rn <= 5;





**--CUSTOMER SEGMENTATION**

SELECT 

&#x20;   CUSTOMERNAME,

&#x20;   SUM(SALES) AS total\_sales,

&#x20;   CASE 

&#x20;       WHEN SUM(SALES) > 100000 THEN 'High Value'

&#x20;       WHEN SUM(SALES) BETWEEN 50000 AND 100000 THEN 'Medium Value'

&#x20;       ELSE 'Low Value'

&#x20;   END AS customer\_segment

FROM dbo.sales\_data\_sample

GROUP BY CUSTOMERNAME;





**--MOM GROWTH%**

SELECT 

&#x20;   YEAR\_ID,MONTH\_ID,TOTAL\_SALES,

&#x20;   LAG(TOTAL\_SALES) OVER (ORDER BY YEAR\_ID, MONTH\_ID ) AS PREV\_M\_SALES,

&#x20;   ROUND((TOTAL\_SALES - LAG(TOTAL\_SALES) OVER ( ORDER BY YEAR\_ID, MONTH\_ID )) \* 100.0 

&#x20;   / LAG(TOTAL\_SALES) OVER ( ORDER BY YEAR\_ID, MONTH\_ID ),2) AS MOM\_GROWTH\_PER  

FROM (

&#x20;   SELECT YEAR\_ID,MONTH\_ID, ROUND(SUM(SALES),2) AS TOTAL\_SALES 

&#x20;   FROM dbo.sales\_data\_sample

&#x20;   GROUP BY YEAR\_ID, MONTH\_ID

) AS T





**--YOY GROWTH %**

SELECT 

&#x20;   YEAR\_ID,TOTAL\_SALES,

&#x20;   LAG(TOTAL\_SALES) OVER (ORDER BY YEAR\_ID) AS PREV\_SALES,

&#x20;   ROUND((TOTAL\_SALES - LAG(TOTAL\_SALES) OVER ( ORDER BY YEAR\_ID)) \* 100.0 

&#x20;   / LAG(TOTAL\_SALES) OVER ( ORDER BY YEAR\_ID ),2) AS YOY\_GROWTH\_PER  

FROM (

&#x20;   SELECT YEAR\_ID, ROUND(SUM(SALES),2) AS TOTAL\_SALES 

&#x20;   FROM dbo.sales\_data\_sample

&#x20;   GROUP BY YEAR\_ID

) AS T





**--BEST MONTH PER YEAR** 

SELECT \* FROM ( select YEAR\_ID,MONTH\_ID, SUM(SALES) AS total\_sales,

&#x20;ROW\_NUMBER() OVER (PARTITION BY YEAR\_ID ORDER BY SUM(SALES) DESC ) AS rn   

&#x20;   FROM dbo.sales\_data\_sample

&#x20;   GROUP BY YEAR\_ID, MONTH\_ID

) t

WHERE rn <= 2;





**--NON PERFORMING MONTH PER YEAR** 

SELECT \* FROM ( select YEAR\_ID,MONTH\_ID, SUM(SALES) AS total\_sales,

&#x20;ROW\_NUMBER() OVER (PARTITION BY YEAR\_ID ORDER BY SUM(SALES) ) AS rn   

&#x20;   FROM dbo.sales\_data\_sample

&#x20;   GROUP BY YEAR\_ID, MONTH\_ID

) t

WHERE rn <= 2;





**--PRODUCTLINE WISE SALES**

SELECT PRODUCTLINE, ROUND(SUM(SALES),2) AS total\_sales

FROM dbo.sales\_data\_sample

GROUP BY PRODUCTLINE

ORDER BY total\_sales DESC;





**--PRODUCT LINE CONTRIBUTIION %**

SELECT 

&#x20;   PRODUCTLINE,

&#x20;   SUM(SALES) AS product\_sales,

&#x20;   ROUND(

&#x20;       SUM(SALES) \* 100.0 / (SELECT SUM(SALES) FROM dbo.sales\_data\_sample),

&#x20;   2) AS contribution\_pct

FROM dbo.sales\_data\_sample

GROUP BY PRODUCTLINE

ORDER BY contribution\_pct DESC;





**--REPEAT CUSTOMERS**

WITH customer\_orders AS (

&#x20;   SELECT 

&#x20;       CUSTOMERNAME,

&#x20;       COUNT(DISTINCT ORDERNUMBER) AS order\_count

&#x20;   FROM dbo.sales\_data\_sample

&#x20;   GROUP BY CUSTOMERNAME

)

SELECT 

&#x20;   COUNT(\*) AS total\_customers,

&#x20;   SUM(CASE WHEN order\_count > 2 THEN 1 ELSE 0 END) AS repeat\_customers,

&#x20;   ROUND(

&#x20;       SUM(CASE WHEN order\_count > 2 THEN 1 ELSE 0 END) \* 100.0 / COUNT(\*),

&#x20;   2) AS repeat\_pct

FROM customer\_orders;





**--COHORT ANALYSIS -Cohort = group of customers who started at the same time**

WITH first\_order AS (

&#x20;   SELECT 

&#x20;       CUSTOMERNAME,

&#x20;       MIN(DATEFROMPARTS(YEAR\_ID, MONTH\_ID, 1)) AS first\_month

&#x20;   FROM sales\_data\_sample

&#x20;   GROUP BY CUSTOMERNAME

),

cohort\_data AS (

&#x20;   SELECT 

&#x20;       s.CUSTOMERNAME,

&#x20;       f.first\_month,

&#x20;       DATEFROMPARTS(s.YEAR\_ID, s.MONTH\_ID, 1) AS order\_month,   -- ✅ comma here

&#x20;       DATEDIFF(MONTH, f.first\_month, DATEFROMPARTS(s.YEAR\_ID, s.MONTH\_ID, 1)) AS month\_diff

&#x20;   FROM sales\_data\_sample s

&#x20;   JOIN first\_order f 

&#x20;       ON s.CUSTOMERNAME = f.CUSTOMERNAME

)

SELECT \*

FROM (

&#x20;   SELECT 

&#x20;       first\_month,

&#x20;       month\_diff,

&#x20;       COUNT(DISTINCT CUSTOMERNAME) AS customers

&#x20;   FROM cohort\_data

&#x20;   GROUP BY first\_month, month\_diff

) src

PIVOT (

&#x20;   SUM(customers)

&#x20;   FOR month\_diff IN (\[0],\[1],\[2],\[3],\[4],\[5],\[6])

) p

ORDER BY first\_month;





\-**-ROLLING AVG 3 MONTHS**

SELECT 

&#x20;   YEAR\_ID,

&#x20;   MONTH\_ID,

&#x20;   SUM(SALES) AS monthly\_sales,

&#x20;   AVG(SUM(SALES)) OVER (

&#x20;       ORDER BY YEAR\_ID, MONTH\_ID 

&#x20;       ROWS BETWEEN 2 PRECEDING AND CURRENT ROW

&#x20;   ) AS rolling\_avg\_3\_months

FROM dbo.sales\_data\_sample

GROUP BY YEAR\_ID, MONTH\_ID;





**--CUSTOMER LIFETIME VALUE**

SELECT 

&#x20;   CUSTOMERNAME,

&#x20;   COUNT(DISTINCT ORDERNUMBER) AS total\_orders,

&#x20;   SUM(SALES) AS total\_revenue,

&#x20;   AVG(SALES) AS avg\_order\_value

FROM sales\_data\_sample

GROUP BY CUSTOMERNAME

ORDER BY total\_revenue DESC;





**--PARETO ANALYSIS (80/20 Rule) IDENTIFY TOP CONTRIBUTORS TO REVENUE**

WITH revenue\_data AS (

&#x20;   SELECT 

&#x20;       CUSTOMERNAME,

&#x20;       SUM(SALES) AS revenue

&#x20;   FROM sales\_data\_sample

&#x20;   GROUP BY CUSTOMERNAME

),

ranked AS (

&#x20;   SELECT \*,

&#x20;       SUM(revenue) OVER (ORDER BY revenue DESC) AS running\_total,

&#x20;       SUM(revenue) OVER () AS total\_revenue

&#x20;   FROM revenue\_data

)

SELECT \*,

&#x20;   running\_total \* 100.0 / total\_revenue AS cumulative\_pct

FROM ranked;





**-- SALES CONTRIBUTION BY REGION**

SELECT 

&#x20;   COUNTRY,

&#x20;   SUM(SALES) AS total\_sales,

&#x20;   ROUND(SUM(SALES) \* 100.0 / SUM(SUM(SALES)) OVER (), 2) AS contribution\_pct

FROM sales\_data\_sample

GROUP BY COUNTRY

ORDER BY total\_sales DESC;





**-- DETECT SALES ANOMALIES -Find unusual spikes/drops**

WITH monthly\_sales AS (

&#x20;   SELECT 

&#x20;       YEAR\_ID,

&#x20;       MONTH\_ID,

&#x20;       SUM(SALES) AS total\_sales

&#x20;   FROM sales\_data\_sample

&#x20;   GROUP BY YEAR\_ID, MONTH\_ID

),

stats AS (

&#x20;   SELECT \*,

&#x20;       AVG(total\_sales) OVER () AS avg\_sales,

&#x20;       STDEV(total\_sales) OVER () AS std\_dev

&#x20;   FROM monthly\_sales

),

final AS (

&#x20;   SELECT \*,

&#x20;       CASE 

&#x20;           WHEN total\_sales > avg\_sales + (2 \* std\_dev) THEN 'Hike Spike'

&#x20;           WHEN total\_sales < avg\_sales - (2 \* std\_dev) THEN 'Low Spike'

&#x20;           ELSE 'Normal'

&#x20;       END AS sales\_status

&#x20;   FROM stats

)



SELECT \*

FROM final

WHERE sales\_status IN ('Hike Spike', 'Low Spike');

