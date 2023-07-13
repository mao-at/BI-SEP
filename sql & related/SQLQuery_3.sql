--aggregation functions + group by 
--subquery 
--union vs. union all 
--window function 
--cte

--temp table: special type of table to store data temporarily
--local temp table #
CREATE TABLE #LocalTemp(
    Num int
)
DECLARE @Variable int = 1
WHILE (@Variable <= 10) 
BEGIN
INSERT INTO #LocalTemp(Num) VALUES(@Variable)
SET @Variable = @Variable + 1
END

SELECT *
FROM #LocalTemp

SELECT *
FROM tempdb.sys.tables

--global temp table ##
CREATE TABLE ##GlobalTemp(
    Num int
)
DECLARE @Variable2 int = 1
WHILE (@Variable2 <= 10) 
BEGIN
INSERT INTO ##GlobalTemp(Num) VALUES(@Variable2)
SET @Variable2 = @Variable2 + 1
END

SELECT *
FROM ##GlobalTemp

--table variable
declare @today datetime 
select @today = getdate()
print @today

DECLARE @WeekDays Table (
	iden int identity(1,1),
    DayNum int,
    DayAbb varchar(20),
    WeekName varchar(20)
)
INSERT INTO @WeekDays
VALUES
(1,'Mon','Monday')  ,
(2,'Tue','Tuesday') ,
(3,'Wed','Wednesday') ,
(4,'Thu','Thursday'),
(5,'Fri','Friday'),
(6,'Sat','Saturday'),
(7,'Sun','Sunday')	
SELECT * FROM @WeekDays
SELECT *
FROM tempdb.sys.tables

--temp tables vs. table variables
--1. both are stored in tempdb, but tables var will be in memory only unless it gets too big
--2. scope: local/global, current batch
--3. size: >100 rows, <100 rows
--4. do not use temp tables in stored procedures(supported but not recommended) or user defined functions, but we can use table varialbes in sp or udf
	--table stats from temp table might cause sp to be recompiled often
	--temp table always goes inside tempdb, might cause resource contention if sp is called often



--view: virtual table that contains data from one or multiple tables
use FebBatch
go

SELECT *
FROM Employee

INSERT INTO Employee
VALUES(1, 'Fred', 5000),(2, 'Laura', 7000), (3,'Amy', 6000)

CREATE VIEW vwEmp 
AS
SELECT Id, EName, Salary
FROM Employee

SELECT *
FROM vwEmp

--sotred procedure: a prepared sql query that we can save in our db and reuse whenever we want to
-- begin and end are used to define a code block
	--typically used in conditionals,loops, SPs, and error handling
BEGIN
    PRINT 'Hello Anonymous Block'
END

go

CREATE PROC spHello
AS
BEGIN
    PRINT 'Hello Stored Procedures'
END



--sql injection: hackers inject some malicious code to our sql queries thus destroying our database
	--SP helps with this issue mainly by parameterization -> user only send the data needed for SP to run
	--no code/logic involved
SELECT Id, Name
FROM User
WHERE ID = 1 DROP TABLE User 

GO

--input
CREATE PROC spAddNumbers
@a int,
@b int
AS 
BEGIN
    PRINT @a + @b
END

EXEC spAddNumbers 10, 20

go
--output
CREATE PROC spGetName
@id int,
@EName varchar(20) OUT
AS
BEGIN
    SELECT @EName = EName
    FROM Employee
    WHERE Id = @id
END


BEGIN
    DECLARE @en varchar(20)
    EXEC spGetName 2, @en OUT
    PRINT @en
END

SELECT *
FROM Employee

GO
--trigger
--DML trigger
--DDL trigger
--LogOn trigger

--FUNCTION
--built-in
--user defined function
CREATE FUNCTION GetTotalRevenue(@price money, @discount real, @quantity smallint)
returns money
AS
BEGIN
    DECLARE @revenue money
    SET @revenue = @price * (1 - @discount) * @quantity
    RETURN @revenue
END

GO 

SELECT UnitPrice, Quantity, Discount, dbo.GetTotalRevenue(UnitPrice, Discount, Quantity) AS Revenue
FROM [Order Details]

GO

CREATE FUNCTION ExpensiveProduct(@threshold money) 
RETURNS TABLE
AS
RETURN SELECT *
        FROM Products
        WHERE UnitPrice > @threshold

GO



SELECT *
FROM dbo.ExpensiveProduct(10)

--sp vs. udf
--1. usage: sp for DML, udf for calculations
--2. how to call: sp will be called by its name, functions must be used in sql statements
--3. input/output: sp may or may not have input/output, bur functions may or may not have input, but it must have output
--4. sp can call function, but function cannot call sp

--pagination
--OFFSET: skip
--FETCH NEXT xx ROWS: select

SELECT CustomerID, ContactName, City
FROM Customers
ORDER BY CustomerID
OFFSET 10 ROWS
FETCH NEXT 10 ROWS ONLY

--TOP: use w or w/t order by
--offset and fetch next: use w order by
--2nd
-- DECLARE @PageNum INT
-- DECLARE @RowsOfPage INT
-- SET @PageNum = 2
-- SET @RowsOfPage = 10
-- SELECT CustomerID, ContactName, City
-- FROM Customers
-- ORDER BY CustomerID
-- OFFSET (@PageNum - 1) * @RowsOfPage ROWS
-- FETCH NEXT @RowsOfPage ROWS ONLY

DECLARE @PageNum INT
DECLARE @RowsOfPage INT
DECLARE @MaxTablePage FLOAT 
SET @PageNum = 1
SET @RowsOfPage = 10
SELECT @MaxTablePage = COUNT(*) FROM Customers  --91.0
SET @MaxTablePage = CEILING(@MaxTablePage / @RowsOfPage)
WHILE @PageNum <= @MaxTablePage
BEGIN
    SELECT CustomerID, ContactName, City
    FROM Customers
    ORDER BY CustomerID
    OFFSET (@PageNum - 1) * @RowsOfPage ROWS
    FETCH NEXT @RowsOfPage ROWS ONLY
    SET @PageNum = @PageNum + 1
END

--1 to many relationship
--Department table and Employee table
--add departmentId into Employee table to work as foreign key

--many to many relationship
--Student table and Class table
--need to create a conjunction/junction/join/joint table in between 
--create an enrollment
	--which classes is a particular student taking
	--which students are enrolled in a particular class
--Student:
--SId, SName
--101, Fred,
--102, Laura

--Enrollment:
--  Sid, Cid, grade
--     101  01	86
--     101  02	75	
--     102  01	100

--Class:
--CID, CName, SId1
--01, SQL
--02, C#


USE FebBatch
GO

--constraints
DROP TABLE Employee

CREATE TABLE #Employee(
    Id int,
    EName varchar(20),
    Age int,
	constraint checkage check (age>=18)
)
--check constraint
insert into #Employee values(1,'tom',17)

SELECT *
FROM Employee

INSERT INTO Employee VALUES(1, 'Sam', 45)
INSERT INTO Employee VALUES(null, null, null)

DROP TABLE Employee

CREATE TABLE Employee(
    Id int not null,
    EName varchar(20) not null,
    Age int
)

DROP TABLE Employee
CREATE TABLE Employee (
    Id int UNIQUE,
    EName varchar(20) NOT NULL,
    Age int
)

INSERT INTO Employee VALUES(null, 'Fiona', 32)

DROP TABLE Employee
CREATE TABLE Employee (
    Id int PRIMARY KEY,
    EName varchar(20) NOT NULL,
    Age int
)

--primary key vs. unique constraint
--1. unique constraint can accept one and only one null value, but pk cannot accept any null value
--2. one table can have multiple unique keys but only one pk
--3. pk will sort the data by default, but unique key will not
--4. PK will by default create a clustered index, and unique key will create a non-clustered index
DELETE Employee

SELECT *
FROM Employee

INSERT INTO Employee
VALUES(4, 'Fred', 45)

INSERT INTO Employee
VALUES(1, 'Laura', 34)

INSERT INTO Employee
VALUES(3, 'Peter', 19)

INSERT INTO Employee
VALUES(2, 'Stella', 24)
