**# 📊 Sales Performance Analysis using SQL**



\---



**## 🔍 Problem Statement**



The business aims to understand revenue trends, customer behavior, and product performance to identify growth opportunities and potential risks.



\---



**## 🎯 Objectives**



\* Analyze revenue growth over time (YoY \& MoM)

\* Identify seasonal sales patterns

\* Evaluate customer and product contribution

\* Assess revenue concentration risk

\* Analyze customer retention and behavior



\---



**## 🧠 Approach**



\* Used SQL (CTE, Window Functions, Aggregations, CASE WHEN)

\* Performed time-based analysis (YoY, MoM, Rolling Average)

\* Conducted Pareto analysis for customer contribution

\* Performed cohort analysis for customer retention

\* Evaluated customer lifetime value (CLV)

\* Identified trends, anomalies, and business risks



\---



**## 🛠 Tools \& Technologies**



\* SQL Server

\* SSMS (SQL Server Management Studio)



\---



**## 📂 Dataset Description**



The dataset contains sales transactions with the following key fields:



\* `ORDERNUMBER` – Unique order ID

\* `ORDERDATE` – Date of order

\* `SALES` – Revenue generated

\* `CUSTOMERNAME` – Customer name

\* `PRODUCTLINE` – Product category

\* `YEAR\_ID`, `MONTH\_ID` – Time dimensions



\---



**## 📊 Key Insights**



\### 🔹 Revenue \& Growth



\* Revenue grew by \~30–35% YoY, indicating strong business expansion

\* MoM growth is highly volatile (-74% to +115%), reflecting seasonal demand



\### 🔹 Seasonal Trends



\* Sales peak consistently in November (\~$1M+), confirming strong year-end demand

\* Rolling 3-month average highlights underlying trends by smoothing volatility



\### 🔹 Customer Contribution (Pareto)



\* Top 5 customers contribute \~20–21% of total revenue

\* \~60%+ of customers are required to reach 80% revenue → indicates diversified customer base



\### 🔹 Product Performance



\* One product line contributes \~40% of total revenue → concentration risk



\### 🔹 Customer Retention (Cohort Analysis)



\* Immediate retention is low (few customers return next month)

\* Delayed retention exists (customers return after 2–4 months)

\* Retention declines over time → churn risk



\### 🔹 Customer Lifetime Value (CLV)



\* High-value customers generate revenue through repeat purchases

\* Average order value is consistent (\~3000–4000)

\* Many customers have low purchase frequency → opportunity for retention improvement



\### 🔹 Anomaly Detection



\* Significant revenue spikes observed during seasonal months (especially November)

\* Sales variability indicates strong seasonal dependency



\---



**## ⚠️ Business Impact**



\* Moderate dependency on key customers and product lines introduces risk

\* Strong seasonal patterns drive revenue spikes but also volatility

\* Customer retention gaps limit long-term revenue growth



\---



**## 💡 Recommendations**



\* Diversify customer base to reduce dependency risk

\* Increase customer retention through engagement strategies

\* Target high-value and low-frequency customers for repeat purchases

\* Expand product portfolio to reduce concentration

\* Leverage seasonal peaks for marketing and promotions

\* Improve demand forecasting using trend analysis



\---



**## 📁 Project Files**



\* `salesanalysis.sql` → SQL queries used for analysis

\* `insights.md` → Detailed business insights



\---



**## 🚀 Conclusion**



This project demonstrates how SQL can be used to perform end-to-end business analysis, including trend analysis, customer behavior evaluation, and risk identification. The insights highlight strong growth potential while also identifying key areas for improvement in customer retention and revenue diversification.



