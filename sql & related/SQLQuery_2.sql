--SELECT: retrieve 
--WHERE: filter
--ORDER BY: sort
--JOIN: work on multile tables in one query

--Aggregation functions: perform a calculation on a set of values a return a single aggregated result
--1. COUNT(): return the number of rows
SELECT COUNT(OrderID) AS TotalNumOfRows
FROM Orders

SELECT COUNT(*) AS TotalNumOfRows
FROM Orders

--COUNT(*) vs. COUNT(colName): 
--COUNT(*) will include null values, but COUNT(colName) will not
SELECT FirstName, Region
FROM Employees

SELECT COUNT(Region), COUNT(*)
FROM Employees 

--use w/ GROUP BY: group rows that have the same values into summary rows
--find total number of orders placed by each customers
SELECT c.CustomerID, c.ContactName, c.City, c.Country, COUNT(o.OrderID) AS NumOfOrders
FROM Orders o INNER JOIN Customers c ON o.CustomerID = c.CustomerID
GROUP BY c.CustomerID, c.ContactName, c.City, c.Country
ORDER BY NumOfOrders DESC


--a more complex template: 
--only retreive total order numbers where customers located in USA or Canada, and order number should be greater than or equal to 10
SELECT c.CustomerID, c.ContactName, c.City, c.Country, COUNT(o.OrderID) AS NumOfOrders
FROM Orders o INNER JOIN Customers c ON o.CustomerID = c.CustomerID
WHERE c.Country IN ('USA', 'Canada')
GROUP BY c.CustomerID, c.ContactName, c.City, c.Country
HAVING COUNT(o.OrderID) >= 10
ORDER BY NumOfOrders DESC

--SELECT fields, aggregate(fileds)
--FROM table JOIN table2 ON ...
--WHERE criteria --optional
--GROUP BY fileds -- use when have both aggregated and non-aggregated fileds
--HAVING criteria --optional
--ORDER BY fields DESC --optional

--WHERE vs. HAVING
--1. both are used as filters, HAVING will apply only to groups as a whole, but WHERE is applied to individual rows
--2. WHERE goes before aggregation, but HAVING goes after aggregations
    --sql execution order
    --FROM/JOIN -> WHERE -> GROUP BY -> HAVING -> SELECT -> DINSINCT -> ORDER BY 
    --             |__________________________|
    --              cannot use alias in SELECT

SELECT c.CustomerID, c.ContactName, c.City, c.Country AS Cty, COUNT(o.OrderID) AS NumOfOrders
FROM Orders o INNER JOIN Customers c ON o.CustomerID = c.CustomerID
WHERE cty IN ('USA', 'Canada')
GROUP BY c.CustomerID, c.ContactName, c.City, cty
HAVING NumOfOrders >= 10
ORDER BY NumOfOrders DESC
--3. WHERE can be used with SELECT, UPDATE or DELETE, but HAVING can only be used in SELECT
SELECT *
FROM Products

UPDATE Products
SET UnitPrice = 20
WHERE ProductID = 1

--COUNT DISTINCT: only count unique values
SELECT City
FROM Customers

SELECT COUNT(City), COUNT(DISTINCT City)
FROM Customers

--2. AVG(): return the average value of a numeric column
--list average revenue for each customer
SELECT c.CustomerID, c.ContactName, AVG(od.UnitPrice * od.Quantity) AS AvgRevenue
FROM Customers c JOIN Orders o ON c.CustomerID = o.CustomerID JOIN [Order Details] od ON od.OrderID = o.OrderID
GROUP BY c.CustomerID, c.ContactName

--3. SUM(): 
--list sum of revenue for each customer
SELECT c.CustomerID, c.ContactName, SUM(od.UnitPrice * od.Quantity) AS TotalRevenue
FROM Customers c JOIN Orders o ON c.CustomerID = o.CustomerID JOIN [Order Details] od ON od.OrderID = o.OrderID
GROUP BY c.CustomerID, c.ContactName

select FirstName + ' ' + LastName as 'Full Name' 
from Employees
where FirstName + ' ' + LastName = 'Robert King';
--4. MAX(): 
--list maxinum revenue from each customer
SELECT c.CustomerID, c.ContactName, MAX(od.UnitPrice * od.Quantity) AS MaxRevenue
FROM Customers c JOIN Orders o ON c.CustomerID = o.CustomerID JOIN [Order Details] od ON od.OrderID = o.OrderID
GROUP BY c.CustomerID, c.ContactName

--5.MIN(): 
--list the cheapeast product bought by each customer
SELECT c.CustomerID, c.ContactName, MIN(od.UnitPrice) AS CheapestProduct
FROM Customers c JOIN Orders o ON c.CustomerID = o.CustomerID JOIN [Order Details] od ON od.OrderID = o.OrderID
GROUP BY c.CustomerID, c.ContactName

--TOP predicate: SELECT a specific number or a certain percentage of records
--retrieve top 5 most expensive products
SELECT ProductName, UnitPrice
FROM Products
ORDER BY UnitPrice DESC

SELECT TOP 5 ProductName, UnitPrice
FROM Products
ORDER BY UnitPrice DESC

--retrieve top 10 percent most expensive products
SELECT TOP 10 PERCENT ProductName, UnitPrice
FROM Products
ORDER BY UnitPrice DESC

--list top 5 customers who created the most total revenue
SELECT TOP 5 c.CustomerID, c.ContactName, SUM(od.UnitPrice * od.Quantity) AS TotalRevenue
FROM Customers c JOIN Orders o ON c.CustomerID = o.CustomerID 
JOIN [Order Details] od ON od.OrderID = o.OrderID
GROUP BY c.CustomerID, c.ContactName
ORDER BY TotalRevenue DESC

SELECT TOP 5 ContactName
FROM Customers

--LIMIT: we dont have LIMIT in sql server, use TOP instead

--Subquery: a SELECT statement that is embedded in another SQL statement
--find the customers from the same city where Alejandra Camino lives 
SELECT ContactName, City
FROM Customers
WHERE City IN (
SELECT City
FROM Customers
WHERE ContactName = 'Alejandra Camino'
)

--find customers who make any orders
--join
SELECT DISTINCT c.CustomerID, c.ContactName, c.City, c.Country
FROM Customers c INNER JOIN Orders o ON c.CustomerID = o.CustomerID

--subquery
SELECT CustomerId, ContactName, City, Country
FROM Customers
WHERE CustomerId IN
(SELECT DISTINCT CustomerID
FROM Orders)

--subquery vs. join
--1) JOIN can only be used in FROM clause, but subquery can be used in SELECT, FROM, WHERE, HAVING, ORDER BY
--JOIN
SELECT o.OrderDate, e.FirstName, e.LastName
FROM Orders o JOIN Employees e ON o.EmployeeID = e.EmployeeID
WHERE e.City = 'London'
ORDER BY o.OrderDate, e.FirstName, e.LastName

--subquery
SELECT o.OrderDate,
(SELECT e1.FirstName FROM Employees e1 WHERE o.EmployeeID = e1.EmployeeID) AS FirstName,
(SELECT e2.LastName FROM Employees e2 WHERE o.EmployeeID = e2.EmployeeID) AS LastName
FROM Orders o
WHERE (
    SELECT e3.City
    FROM Employees e3
    WHERE e3.EmployeeID = o.EmployeeID
) IN ('London')
ORDER BY o.OrderDate, (SELECT e1.FirstName FROM Employees e1 WHERE o.EmployeeID = e1.EmployeeID), (SELECT e2.LastName FROM Employees e2 WHERE o.EmployeeID = e2.EmployeeID)
--2) subquery is easy to understand and maintain
--find customers who never placed any order
--JOIN
SELECT c.CustomerID, c.ContactName, c.City, c.Country
FROM Customers c LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
WHERE o.OrderID is null

--subquery
SELECT c.CustomerID, c.ContactName, c.City, c.Country
FROM Customers c 
WHERE CustomerID NOT IN (
    SELECT DISTINCT CustomerID
    FROM Orders
)

--3) usually JOIN has a better performance than subquery - mostly due to the way the query optimizer works
--query: INNER JOIN/ LEFT JOIN 
--physical join: HASH JOIN, MERGE JOIN, NESTED LOOP JOIN

--Correlated Subquery: inner query is dependent on the outer query
--Customer name and total number of orders by customer
--JOIN
SELECT c.ContactName, Count(o.OrderID) AS TotalNumOfOrders
FROM Customers c LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.ContactName
ORDER BY TotalNumOfOrders DESC 

--correlated subquery
SELECT c.ContactName,
(SELECT COUNT(o.OrderID) FROM Orders o WHERE o.CustomerID = c.CustomerID) AS TotalNumOfOrders
FROM Customers c 
ORDER BY TotalNumOfOrders DESC

--correlated subquery
SELECT o.OrderDate,
(SELECT e1.FirstName FROM Employees e1 WHERE e1.EmployeeID = o.EmployeeID) FirstName,
(SELECT e2.LastName FROM Employees e2 WHERE e2.EmployeeID = o.EmployeeID) LastName
FROM Orders o 
ORDER BY FirstName, OrderDate

--join
SELECT o.OrderDate, e.FirstName, e.LastName
FROM Orders o JOIN Employees e ON e.EmployeeID = o.EmployeeID
ORDER BY FirstName, OrderDate

--derived table: subquery in from clause
--syntax
SELECT CustomerID, ContactName
FROM
(SELECT *
FROM Customers) dt

--customers and the number of orders they made
SELECT c.ContactName, c.City, c.Country, COUNT(o.OrderID) AS TotalNumOfOrders
FROM Customers c LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.ContactName, c.City, c.Country
ORDER BY TotalNumOfOrders DESC

--derived table
SELECT c.ContactName, c.City, c.Country, dt.TotalNumOfOrders
FROM Customers c LEFT JOIN (
    SELECT CustomerID, COUNT(OrderID) AS TotalNumOfOrders
    FROM Orders 
    GROUP BY CustomerID
) dt ON c.CustomerID = dt.CustomerID
ORDER BY dt.TotalNumOfOrders DESC

--Union vs. Union ALL: 
--common features:
--1. both are used to combine different result sets vertically
SELECT City, Country
FROM Customers
UNION
SELECT City, Country
FROM Employees

SELECT City, Country
FROM Customers
UNION ALL
SELECT City, Country
FROM Employees
--2. criteria
--number of cols must be the same
SELECT City, Country, CustomerID
FROM Customers
UNION
SELECT City, Country
FROM Employees
--data types of each column must be identical
SELECT City, Country, Region
FROM Customers
UNION
SELECT City, Country, EmployeeID
FROM Employees

--differences
--1. UNION will remove duplicate values, UNION ALL will not
--2. UNION: the records from the first column will be sorted ascendingly
--3. UNION cannot be used in recursive cte, but UNION ALL can

--Window Function: operate on a set of rows and return a single aggregated value for each row by adding extra columns
--RANK(): give a rank based on certain order
--rank for product price, when there is a tie, there will be a value gap
SELECT ProductID, ProductName, UnitPrice, RANK() OVER (ORDER BY UnitPrice DESC) RNK
FROM Products


--product with the 2nd highest price 
SELECT dt.ProductID, dt.ProductName, dt.UnitPrice, dt.RNK
FROM
(SELECT ProductID, ProductName, UnitPrice, RANK() OVER (ORDER BY UnitPrice DESC) RNK
FROM Products) dt
WHERE dt.RNK = 2 

--DENSE_RANK(): 
SELECT ProductID, ProductName, UnitPrice, RANK() OVER (ORDER BY UnitPrice DESC) RNK, DENSE_RANK() OVER (ORDER BY UnitPrice DESC) DenseRNK
FROM Products

--ROW_NUMBER(): return the row number of the sorted records starting from 1
SELECT ProductID, ProductName, UnitPrice, RANK() OVER (ORDER BY UnitPrice DESC) RNK, DENSE_RANK() OVER (ORDER BY UnitPrice DESC) DenseRNK, ROW_NUMBER() OVER (ORDER BY UnitPrice DESC) RowNum
FROM Products

--partition by: divide the result set into paritions and perform calculation on each subset
--list customers from every country with the ranking for number of orders
SELECT c.ContactName, c.Country, COUNT(o.OrderID) AS NumOfOrders, RANK() OVER (PARTITION BY c.Country ORDER BY COUNT(o.OrderID) DESC) RNK
FROM Customers c JOIN Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.ContactName, c.Country

--- find top 3 customers from every country with maximum orders
SELECT dt.ContactName, dt.Country, dt.NumOfOrders, dt.RNK
FROM
(SELECT c.ContactName, c.Country, COUNT(o.OrderID) AS NumOfOrders, RANK() OVER (PARTITION BY c.Country ORDER BY COUNT(o.OrderID) DESC) RNK
FROM Customers c JOIN Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.ContactName, c.Country) dt
WHERE dt.RNK <= 3

--cte: common table expression -- temporary named result set
--cte has readability benifits,can be referenced multiple times, and maybe some performance benifits
SELECT c.ContactName, c.City, c.Country, dt.TotalNumOfOrders
FROM Customers c LEFT JOIN (
    SELECT CustomerID, COUNT(OrderID) AS TotalNumOfOrders
    FROM Orders 
    GROUP BY CustomerID
) dt ON c.CustomerID = dt.CustomerID
ORDER BY dt.TotalNumOfOrders DESC

WITH OrderCntCTE
AS
(
    SELECT CustomerID, COUNT(OrderID) AS TotalNumOfOrders
    FROM Orders 
    GROUP BY CustomerID
)
SELECT c.ContactName, c.City, c.Country, cte.TotalNumOfOrders
FROM Customers c LEFT JOIN OrderCntCTE cte ON c.CustomerID = cte.CustomerID
ORDER BY cte.TotalNumOfOrders DESC

--lifecycle: created and used in the very next select statement 

--recursive CTE: 
--initialization: initial call to the cte which passes in some values to get things started
--recursive rule
SELECT EmployeeID, FirstName, ReportsTo
FROM Employees

-- level 1: Andrew
-- level 2: Nancy, Janet, Margaret, Steven, Laura
-- level 3: Michael, Robert, Anne

WITH EmpHierachyCTE
AS
(
    SELECT EmployeeID, FirstName, ReportsTo, 1 lvl
    FROM Employees
    WHERE ReportsTo is null
    UNION ALL
    SELECT e.EmployeeID, e.FirstName, e.ReportsTo, cte.lvl + 1
    FROM Employees e INNER JOIN EmpHierachyCTE cte ON e.ReportsTo = cte.EmployeeID
)
SELECT * FROM EmpHierachyCTE