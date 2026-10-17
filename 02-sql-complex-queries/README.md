# Project 2: Complex SQL Queries (SQL Server)

## Overview
Ten business-oriented queries on Microsoft's **WideWorldImporters** sample database,
covering sales trends, customer behavior and product performance.

## Dataset
WideWorldImporters is a free sample database from Microsoft.
Download: https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0

## Queries
| # | Business question | Techniques |
|---|-------------------|------------|
| 1 | Yearly income and growth rate (annualized for incomplete years) | CTE, `LAG`, `COUNT DISTINCT` |
| 2 | Top 5 customers by income in every quarter | CTE, `DENSE_RANK`, `PARTITION BY` |
| 3 | Top 10 products by profit | `JOIN`, `TOP`, aggregation |
| 4 | Nominal profit per product, with ranking | `ROW_NUMBER`, `DENSE_RANK` |
| 5 | Products listed per supplier | `STRING_AGG` |
| 6 | Top 5 customers by geography (city, country, continent) | multi-table `JOIN` |
| 7 | Monthly income with running total and grand total per year | window `SUM`, `ROLLUP`, `GROUPING` |
| 8 | Number of orders per month, split by year | `PIVOT` |
| 9 | Customer churn detection based on ordering frequency | `LAG`, `DATEDIFF`, `CASE` |
| 10 | Share of customers per category | window functions |

## Files
- `Complex_Queries.sql` - all ten queries

## How to run
Restore the WideWorldImporters database, then run the queries in `Complex_Queries.sql`.

## Skills demonstrated
CTEs · window functions · `PIVOT` · `ROLLUP` · string aggregation · date functions · multi-table joins
