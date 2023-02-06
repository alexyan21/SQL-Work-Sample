-- BusinessEntityAddress: select cols
WITH BusinessEntityAddress_clean AS (
SELECT BusinessEntityID, AddressID
FROM `AdvantureWorks.BusinessEntityAddress`),

-- Address: select cols
Address_clean AS (
SELECT AddressID, City, StateProvinceID, PostalCode
FROM `AdvantureWorks.Address`),

-- StateProvince: select cols
StateProvince_clean AS (
SELECT StateProvinceID, Name, TerritoryID
FROM `AdvantureWorks.StateProvince`),

SalesTerritory_clean AS(
SELECT TerritoryID, CASE WHEN NAME IN ('Northwest','Northeast','Central','Southwest','Southeast') THEN 'United States' ELSE Name END AS CountryRegion, CountryRegionCode
FROM `AdvantureWorks.SalesTerritory`)

-- AddressMerged: BusinessEntityAddress INNER JOIN Address INNER JOIN StateProvince INNER JOIN SalesTerritory
SELECT b.BusinessEntityID,a.City,a.PostalCode,s.Name AS StateProvince,t.CountryRegion #use PBI to delete duplicates
FROM BusinessEntityAddress_clean b
JOIN Address_clean a
ON b.AddressID=a.AddressID
JOIN StateProvince_clean s
ON a.StateProvinceID=s.StateProvinceID
JOIN SalesTerritory_clean t
ON s.TerritoryID=t.TerritoryID

-- Customer 
## select cols + fill in null PersonID 
WITH Customer_clean AS (
SELECT CustomerID,PersonID,TerritoryID,AccountNumber
FROM `AdvantureWorks.Customer`),

-- Person: select cols
Person_clean AS(
SELECT BusinessEntityID, FirstName, LastName
FROM `AdvantureWorks.Person`)

-- CustomerMerged：Customer LEFT JOIN Person 
SELECT c.CustomerID,c.AccountNumber,'Internet' AS Channel,p.*
FROM Customer_clean c
LEFT JOIN Person_clean p
ON c.PersonID = p.BusinessEntityID
WHERE BusinessEntityID IS NOT NULL AND CustomerID<29484
ORDER BY BusinessEntityID;

SELECT InvoiceNo, DATE_ADD(DATE(InvoiceDate),INTERVAL 10 YEAR) AS InvoiceDate, CustomerID, Quantity, UnitPrice
FROM `concise-reserve-369920.OnlineRetail.OnlineRetail`

-- ProductMerged:Product LEFT JOIN ProductSubcategory LEFT JOIN ProductCategory LEFT JOIN ProductModel
-- Product ## select cols 
WITH Product_clean AS(
SELECT ProductID, Name, StandardCost, ProductSubcategoryID, ProductModelID
FROM `AdvantureWorks.Product`),

-- ProductSubcategory: select cols
ProductSubcategory_clean AS (
SELECT ProductSubcategoryID, ProductCategoryID, Name_Eng
FROM `AdvantureWorks.ProductSubcategory`),

-- ProductCategory: select cols
ProductCategory_clean AS (
SELECT ProductCategoryID, Name
FROM `AdvantureWorks.ProductCategory`),

-- ProductModel: select cols, fill in 'Unknown' for missing "Name"
ProductModel_clean AS (
SELECT ProductModelID, IFNULL(Name,'Unknown') AS Name
FROM `AdvantureWorks.ProductModel1`)

-- ProductMerged: Product LEFT JOIN ProductSubcategory LEFT JOIN ProductCategory LEFT JOIN ProductModel
SELECT p.ProductID, p.Name AS ProductName, p.StandardCost AS ProductCost,IFNULL(sub.Name_Eng,'Unknown') AS Subcategory, IFNULL(cat.Name,'Unknown') AS Category, IFNULL(mode.Name,'Unknown') AS Model
FROM Product_clean p
LEFT JOIN ProductSubcategory_clean sub
ON p.ProductSubcategoryID=sub.ProductSubcategoryID
LEFT JOIN ProductCategory_clean cat
ON sub.ProductCategoryID=cat. ProductCategoryID
LEFT JOIN ProductModel_clean mode
ON CAST(p.ProductModelID AS STRING)=mode.ProductModelID;

-- SalesOrderHeader: OrderDate - add 7 years( i.e MAX(date)='2021')
WITH SalesOrderHeader_clean AS (
SELECT SalesOrderID, DATE_ADD(DATE(OrderDate),INTERVAL 7 YEAR) AS OrderDate, SalesOrderNumber, CustomerID, SubTotal
FROM `AdvantureWorks.SalesOrderHeader`),

-- SalesOrderDetail: select cols
SalesOrderDetail_clean AS
(SELECT SalesOrderID, ProductID, OrderQty, LineTotal
FROM `AdvantureWorks.SalesOrderDetail`)

-- SalesOrderMerged: SalesOrderHeader INNER JOIN SalesOrderDetail
SELECT h.SalesOrderNumber, h.CustomerID, d.ProductID, h.OrderDate,h.SubTotal, d.OrderQty, d.LineTotal
FROM SalesOrderHeader_clean h, SalesOrderDetail_clean d
WHERE h.SalesOrderID=d.SalesOrderID AND CustomerID<29484 AND Date(h.OrderDate) > "2018-06-30";