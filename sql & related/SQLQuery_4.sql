--basic queries: SELECT, WHERE, ORDER BY, JOIN, AGGREGATION FUNCTIONS + GROUP BY, HAVING 
--advanced topics: Subquery, cte, window functions, pagination 
--temp tables, table variables, sp, udf


SELECT *
FROM Employee

INSERT INTO Employee VALUES(5, 'Monster', 3000)
INSERT INTO Employee VALUES(6, 'Monster', -3000)

--check constraint: limit the value range that can be placed in to a column
DELETE Employee

ALTER TABLE Employee
ADD Constraint Chk_Age_Employee CHECK(Age BETWEEN 18 AND 65)

INSERT INTO Employee VALUES(1, 'Fred', 30)

--identity property
CREATE TABLE Product (
    Id int PRIMARY KEY IDENTITY(1, 1),
    ProductName varchar(20) UNIQUE NOT NULL,
    UnitPrice Money
)

SELECT *
FROM Product

INSERT INTO Product VALUES('Green Tea', 2)
INSERT INTO Product VALUES('Latte', 3)
INSERT INTO Product VALUES('Cold Brew', 4)

--truncate vs. delete
--1. DELETE is a DML, it will not reset the property value; TRUNCATE is a DDL, will reset the property value
DELETE Product
TRUNCATE TABLE Product
--2. DELETE can be used with WHERE, but TRUNCATE cannot
DELETE Product
WHERE Id = 3

--DROP: DDL

SET IDENTITY_INSERT Product ON
INSERT INTO Product(Id, ProductName, UnitPrice) VALUES(4, 'Cold Brew', 4)

--referential integrity: you cannot make changes in the referenced 
	--table that will make the fk link invalid
--domain integrity: all non-relational contraints are 
	--basically used to ensure this(data type, size, check constraint...)
--entity integrity: every table should have a primary key

--Department table
--Employee table
DROP TABLE Employee

CREATE Table Department(
    Id int primary key,
    DepartmentName varchar(20),
    Location varchar(20)
)

DROP TABLE Employee

CREATE TABLE Employee(
    Id int primary key,
    EmployeeName varchar(20),
    Age int CHECK(Age BETWEEN 18 AND 65),
    DepartmentId int FOREIGN KEY REFERENCES Department(Id) ON DELETE CASCADE
)

SELECT *
FROM Employee

SELECT *
FROM Department

INSERT INTO Employee VALUES(1, 'Fred', 34, 1)
INSERT INTO Employee VALUES(2, 'Laura', 34, 1)

INSERT INTO Department VALUES(1, 'IT', 'Chicago')
INSERT INTO Department VALUES(2, 'HR', 'Sterling')
INSERT INTO Department VALUES(3, 'QA', 'Paris')

DELETE FROM Department
WHERE ID = 1

--Composite pk
--Student
CREATE TABLE Student(
    Id int Primary key,
    StudentName varchar(20)
)

--Class

CREATE TABLE Class(
    Id int Primary key,
    ClassName varchar(20)
)

CREATE TABLE Enrollment(
    StudentId int NOT NULL, --in a composite key, it's okay to have null values in one or few columns that participates in a composite PK, however, it's not recommended
    ClassId int NOT NULL,
    CONSTRAINT PK_Enrollment PRIMARY KEY(StudentId, ClassId),
    CONSTRAINT FK_Entrollment_Student FOREIGN KEY (StudentId) REFERENCES Student(Id),
    CONSTRAINT FK_Entrollment_Class FOREIGN KEY (ClassId) REFERENCES Class(Id)
)

--transaction: a group of logically related DML statements that will either succeed together or fail together

--Autocommit transaction: default
	--Each individual statement is a transaction.
	--use SET IMPLICIT_TRANSACTIONS ON to disable
--Implicit transaction
	--transactions are automatically started for each query that modifies data, but you still have to manually COMMIT or ROLLBACK
	--use SET IMPLICIT_TRANSACTIONS ON to enable
--Explicit transaction
	--when you use BEGIN TRAN, must also manually COMMIT or ROLLBACK
--Batch-scoped transactions <- FYI
	--can be either implicit or explict, when Multiple Active Result Sets(MARS) is enabled(allow you to run multiple queries using the same connection simultaneously, which makes transaction control much more difficult, hense rare to see in OLTP)
	--A batch-scoped transaction that is not committed or rolled back when a batch completes is automatically rolled back by SQL Server.
	

DROP TABLE Product
CREATE TABLE Product (
    ID int primary key,
    ProductName varchar(20) not null,
    UnitPrice money,
    Quantity int
)

SELECT *
FROM Product

INSERT INTO Product VALUES(1, 'Green Tea', 2, 100)
INSERT INTO Product VALUES(2, 'Latte', 3, 100)
INSERT INTO Product VALUES(3, 'Cold Brew', 4, 100)

BEGIN TRAN
INSERT INTO Product VALUES(4, 'Flat White', 4, 100)

SELECT *
FROM Product
COMMIT

BEGIN TRAN
INSERT INTO Product VALUES(5, 'Earl Gray', 4, 100)

SELECT *
FROM Product
ROLLBACK

--Properties
--ACID
--A: Atomicity - work is atomic, all or nothing
--C: Consistency - whatever happends in the mid of the transaction, this property will never leave our db in half-completed state
--I: Isolation - locking the resource -> so different transactions do not interfere with eachother
--D: Durability - once the trasnaction is completed, the changes it has made to the db will be permanent

--Concurrency problems: when two or more than two users trying to access the same data 
--dirty reads: if t1 allows t2 to read uncommited data and then t1 rolled back; happen when isolation level is read uncommitted; update the isolation level to read committed
--lost update: when t1 and t2 read and update the same data but t2 finishe its work earlier, so the udpate from t2 will be missing; happend when isolation level is READ COMMITTED; solved by ISOLATION LEVEL repeatable read 
--non repeatable read: t1 read the same data twice while t2 is updating the data; happen when isolation level read committed
--phamtom read: t1 reads the same data twice while t2 is inserting data; happen when isolation level is REPEATABLE READ, solved by isolation level serializable

--

--ATS
--Candidate

--1. update candidate table
--2. insert into Employee table
--3. insert into timesheet table

--index: on-disk structure to increase data **retrival** speed -- SELECT
--clustered index: sort the record, one clustered index in one table, generated by pk
--NONCLUSTERED index: will not sort record, stored elsewhere and point to data row, genearaed by unique constraint, one table can have multiple non clustered index

CREATE TABLE Customer (
    Id int,
    FullName varchar(20),
    City varchar(20),
    Country varchar(20)
)

SELECT *
FROM Customer

CREATE CLUSTERED INDEX Cluster_IX_Customer_ID ON Customer(Id)

INSERT INTO CUSTOMER VALUES(2, 'David','Chicago', 'USA')
INSERT INTO CUSTOMER VALUES(1, 'Fred','Jersey City', 'USA')

DROP TABLE Customer

CREATE TABLE Customer (
    Id int PRIMARY KEY,
    FullName varchar(20),
    City varchar(20),
    Country varchar(20)
)

CREATE INDEX Noncluster_IX_Customer_City ON Customer(City)

--disadvantages:
--extra space, slow down UPDATE/INSERT/DELETE

--performance tuning
	--typically starts with monitoring ->try to pin point the issue first, and then try to optimize
--look at the execution plan / sql profiler /extended events
--create index wisely
	--tuning advisor might be helpful, need to consider actual usage ->what queries are ran the most?
--avoid unnecessary joins
	--join is always considered to be expensive
	--we do de-normalization in OLAP to reduce the need of joins
--avoid select * -> what if shcema changes?
--derived table to avoid grouping of lots of non-aggregated fields
--use join to replace subquery
	--make sure to verify with a realistic workload, joins are not always faster
    
