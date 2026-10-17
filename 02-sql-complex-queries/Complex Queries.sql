/*
Liraz Menahem
Project 2
SQL Data Analysis
*/

--1
WiTH cte1 AS (
SELECT YEAR (InvoiceDate) InvoiceYear, SUM (UnitPrice*Quantity) IncomePerYear,
COUNT (DISTINCT MONTH (InvoiceDate)) NumberOfDistinctMonth
FROM Sales.Invoices si JOIN Sales.InvoiceLines sil
ON si.InvoiceID=sil.InvoiceID
GROUP BY YEAR (InvoiceDate)),

cte2 AS (
SELECT *, (IncomePerYear*12.0/NumberOfDistinctMonth) YearlyLinearIncome
FROM cte1),

cte3 AS (
SELECT *, ((YearlyLinearIncome-LAG (YearlyLinearIncome) OVER (ORDER BY InvoiceYear))/
LAG (YearlyLinearIncome) OVER (ORDER BY InvoiceYear))*100 GrowthRate
FROM cte2)

SELECT InvoiceYear, IncomePerYear, NumberOfDistinctMonth,
LEFT (CAST(ROUND(YearlyLinearIncome, 2) AS VARCHAR (255)), 11) AS YearlyLinearIncome,
LEFT(CAST(ROUND(GrowthRate, 2) AS VARCHAR (255)), 4) AS GrowthRate
FROM cte3
ORDER BY InvoiceYear

--2
WITH cte1 AS (
SELECT YEAR (InvoiceDate) TheYear, DATEPART (QUARTER, InvoiceDate) TheQuarter, CustomerName,
SUM (UnitPrice*Quantity) IncomePerQuarterYear
FROM Sales.Invoices si JOIN Sales.InvoiceLines sil
ON si.InvoiceID=sil.InvoiceID
JOIN SALES.Customers sc ON si.CustomerID=sc.CustomerID
GROUP BY YEAR (InvoiceDate), DATEPART (QUARTER, InvoiceDate), CustomerName),

cte2 AS (
SELECT *, DENSE_RANK () OVER (PARTITION BY TheYear, TheQuarter ORDER BY IncomePerQuarterYear DESC) DNR
FROM cte1)
SELECT *
FROM cte2
WHERE DNR <=5
ORDER BY TheYear


--3
SELECT TOP 10 sil.StockItemID, StockItemName, SUM(ExtendedPrice-TaxAmount) TotalProfit
FROM Sales.InvoiceLines sil JOIN Warehouse.StockItems wsi
ON sil.StockItemID=wsi.StockItemID
GROUP BY sil.StockItemID, StockItemName
ORDER BY TotalProfit DESC

/*
If you meant that the numbers would be output without a decimal point,
I needed to add CAST (I didn't add it because I didn't know if
you wanted the result to be exactly the same):
--CAST(SUM(ExtendedPrice-TaxAmount) AS INT) TotalProfit
*/


--4
SELECT ROW_NUMBER () OVER (ORDER BY (RecommendedRetailPrice-UnitPrice) DESC) Rn,
StockItemID, StockItemName, UnitPrice, RecommendedRetailPrice, (RecommendedRetailPrice-UnitPrice) NominalProductProfit,
DENSE_RANK () OVER (ORDER BY (RecommendedRetailPrice-UnitPrice) DESC) DNR
FROM Warehouse.StockItems
WHERE ValidTo >=  GETDATE ()


--5
SELECT CAST (ps.SupplierID AS VARCHAR) + ' - '+ SupplierName SupplierDetails,
STRING_AGG (CAST (StockItemID AS VARCHAR)+ ' ' + StockItemName,' /, ') ProductDetails
FROM Purchasing.Suppliers ps JOIN Warehouse.StockItems wsi
ON ps.SupplierID=wsi.SupplierID
GROUP BY ps.SupplierID, ps.SupplierName


--6
SELECT TOP 5 sc.CustomerID, CityName, CountryName, Continent, Region, SUM (ExtendedPrice) TotalExtendedPrice
FROM Sales.Invoices si JOIN Sales.InvoiceLines sil
ON si.InvoiceID=sil.InvoiceID
JOIN Sales.Customers sc ON si.CustomerID=sc.CustomerID
JOIN Application.Cities ac ON sc.DeliveryCityID=ac.CityID
JOIN Application.StateProvinces asp ON ac.StateProvinceID=asp.StateProvinceID
JOIN Application.Countries aco ON asp.CountryID=aco.CountryID
GROUP BY sc.CustomerID, CityName, CountryName, Continent, Region
ORDER BY TotalExtendedPrice DESC


--7
WITH cte1 AS (
SELECT YEAR (InvoiceDate) InvoiceYear, MONTH (InvoiceDate) InvoiceMonth, SUM (Quantity*UnitPrice) MonthlyTotal
FROM Sales.Invoices si JOIN Sales.InvoiceLines sil
ON si.InvoiceID=sil.InvoiceID
GROUP BY YEAR (InvoiceDate), MONTH (InvoiceDate)),

cte2 AS (
SELECT InvoiceYear, InvoiceMonth, MonthlyTotal, SUM (MonthlyTotal) OVER (PARTITION BY InvoiceYear ORDER BY InvoiceMonth
ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) CumulativeTotal
FROM cte1)

SELECT 
InvoiceYear,
CASE WHEN GROUPING (InvoiceMonth) = 1 THEN 'Grand Total'
ELSE CAST (InvoiceMonth AS VARCHAR(255))
END InvoiceMonth,
SUM (MonthlyTotal) MonthlyTotal,
CASE WHEN GROUPING(InvoiceMonth) = 1 THEN SUM (MonthlyTotal)
ELSE MAX (CumulativeTotal)
END CumulativeTotal
FROM cte2
GROUP BY InvoiceYear,ROLLUP (InvoiceMonth)
ORDER BY InvoiceYear


--8
SELECT * 
FROM 
(
SELECT MONTH (OrderDate) OrderMonth, YEAR (OrderDate) OrderYear, OrderID
FROM Sales.Orders) tbl
PIVOT (
		COUNT (OrderID)
		FOR OrderYear IN ([2013], [2014], [2015], [2016])) pvt
ORDER BY OrderMonth


--9
WITH cte1 AS (
SELECT so.CustomerID,sc.CustomerName, so.OrderDate,
LAG(OrderDate) OVER (PARTITION BY so.CustomerID ORDER BY OrderDate) PreviousOrderDate,
MAX(OrderDate) OVER () LasrOrderDateAll
FROM Sales.Orders so JOIN Sales.Customers sc
ON so.CustomerID = sc.CustomerID),

cte2 AS (
SELECT *, AVG(DATEDIFF(d,PreviousOrderDate,OrderDate)) OVER (PARTITION BY CustomerID) AvgDaysBetweenOrders,
MAX(OrderDate) OVER (PARTITION BY CustomerID) LastCustOrderDate
FROM cte1)

SELECT CustomerID, CustomerName, OrderDate, PreviousOrderDate,
    AvgDaysBetweenOrders, LastCustOrderDate, LasrOrderDateAll,
    DATEDIFF (d, LastCustOrderDate, LasrOrderDateAll) DaysSinceLastOrder,
	CASE WHEN DATEDIFF (d, LastCustOrderDate, LasrOrderDateAll) > (2*AvgDaysBetweenOrders) THEN 'Potential Churn'
	ELSE 'Active'
	END CustomerStatus
FROM cte2
ORDER BY CustomerID, OrderDate


--10
WITH cte1 AS (
SELECT CustomerCategoryName, COUNT(DISTINCT
CASE WHEN CustomerName LIKE 'Wingtip%' THEN 'Wingtip'
WHEN CustomerName LIKE 'Tailspin%' THEN 'Tailspin'
ELSE CustomerName
END) CustomerCOUNT
FROM Sales.Customers sc JOIN Sales.CustomerCategories scc
ON sc.CustomerCategoryID =scc.CustomerCategoryID
GROUP BY CustomerCategoryName),

cte2 AS (
SELECT *, SUM (CustomerCOUNT) OVER () TotalCustCount
FROM cte1)
SELECT CustomerCategoryName, CustomerCOUNT, TotalCustCount, LEFT (CAST (ROUND (CustomerCOUNT*100.0/TotalCustCount,2) AS VARCHAR (255)),5)+'%'
FROM cte2
ORDER BY CustomerCategoryName