CREATE   VIEW [dbo].[vPaymentsByOrder]
AS
SELECT
    o.OrderID,
    o.OrderDate,
    c.CustomerName,
    p.PaymentID,
    p.PaymentDate,
    p.Amount,
    t.TaxName,
    t.TaxValue,
    dbo.OrderTotal(o.OrderID) AS OrderTotal,
    COALESCE(SUM(CAST(p2.Amount AS DECIMAL(18,2))) OVER (PARTITION BY o.OrderID), 0) AS PaidTotal,
    dbo.OrderTotal(o.OrderID) - COALESCE(SUM(CAST(p2.Amount AS DECIMAL(18,2))) OVER (PARTITION BY o.OrderID), 0) AS RemainingToPay
FROM dbo.Orders o
JOIN dbo.Customers c ON c.CustomerID = o.CustomerID
LEFT JOIN dbo.Payments p ON p.OrderID = o.OrderID
LEFT JOIN dbo.Taxes t ON t.TaxID = p.TaxID
LEFT JOIN dbo.Payments p2 ON p2.OrderID = o.OrderID;

GO

CREATE VIEW [dbo].[vSupplierPriceList]
AS
SELECT s.SupplierID, s.CompanyName, ps.PartID, ps.UnitPrice AS ProductPrice, ms.MaterialID, ms.UnitPrice AS MaterialPrice, ms.Freight AS MaterialFreight, ps.Freight AS PartFreight
FROM     dbo.Suppliers AS s LEFT OUTER JOIN
                  dbo.PartSuppliers AS ps ON ps.SupplierID = s.SupplierID LEFT OUTER JOIN
                  dbo.MaterialSuppliers AS ms ON ms.SupplierID = s.SupplierID

GO

CREATE VIEW [dbo].[vFactoriesCategories]
AS
SELECT DISTINCT f.FactoryID, f.FactoryName, c.CategoryID, c.CategoryName
FROM     dbo.Factories AS f INNER JOIN
                  dbo.FactoriesAndCategories AS fc ON f.FactoryID = fc.CategoryID INNER JOIN
                  dbo.Categories AS c ON fc.CategoryID = c.CategoryID

GO

CREATE   VIEW [dbo].[vProductUnitCost]
AS
WITH MatMin AS (
    SELECT MaterialID, MIN(UnitPrice) AS MinPrice
    FROM dbo.MaterialSuppliers
    GROUP BY MaterialID
),
PartMin AS (
    SELECT PartID, MIN(UnitPrice) AS MinPrice
    FROM dbo.PartSuppliers
    GROUP BY PartID
),
MatCost AS (
    SELECT mfu.ProductID, SUM(mfu.QuantityNeeded * mm.MinPrice) AS MaterialsCost
    FROM dbo.MaterialsForOneUnit mfu
    JOIN MatMin mm ON mm.MaterialID = mfu.MaterialID
    GROUP BY mfu.ProductID
),
PartCost AS (
    SELECT pfu.ProductID, SUM(pfu.QuantityNeeded * pm.MinPrice) AS PartsCost
    FROM dbo.PartsForOneUnit pfu
    JOIN PartMin pm ON pm.PartID = pfu.PartID
    GROUP BY pfu.ProductID
),
ProdCost AS (
    SELECT CategoryID, MIN(ProductionCost) AS ProductionCost
    FROM dbo.FactoriesAndCategories
    GROUP BY CategoryID
)
SELECT
    p.ProductID,
    p.CategoryID,
    COALESCE(mc.MaterialsCost, 0) AS MaterialsCost,
    COALESCE(pc.PartsCost, 0) AS PartsCost,
    COALESCE(pr.ProductionCost, 0) AS ProductionCost,
    COALESCE(mc.MaterialsCost, 0) + COALESCE(pc.PartsCost, 0) + COALESCE(pr.ProductionCost, 0) AS TotalCost
FROM dbo.Products p
LEFT JOIN MatCost mc ON mc.ProductID = p.ProductID
LEFT JOIN PartCost pc ON pc.ProductID = p.ProductID
LEFT JOIN ProdCost pr ON pr.CategoryID = p.CategoryID;

GO

CREATE   VIEW [dbo].[vSalesLines] AS
SELECT
    o.OrderID,
    o.OrderDate,
    od.ProductID,
    p.CategoryID,
    c.CategoryName,
    od.Quantity,
    od.UnitPrice,
    od.Discount,
    CAST(od.Quantity * od.UnitPrice * (1.0 - od.Discount / 100.0) AS DECIMAL(18,2)) AS LineValue
FROM dbo.Orders o
JOIN dbo.OrderDetails od ON od.OrderID = o.OrderID
JOIN dbo.Products p ON p.ProductID = od.ProductID
JOIN dbo.Categories c ON c.CategoryID = p.CategoryID;

GO

CREATE   VIEW [dbo].[vProductionCosts_ByCategory_Month] AS
SELECT
    DATEFROMPARTS(YEAR(po.CreatedAt), MONTH(po.CreatedAt), 1) AS PeriodStart,
    YEAR(po.CreatedAt) AS [Year],
    MONTH(po.CreatedAt) AS [Month],
    p.CategoryID,
    c.CategoryName,
    SUM(po.Quantity) AS UnitsPlanned,
    CAST(SUM(po.Quantity * fac.ProductionCost) AS DECIMAL(18,2)) AS ProductionCostTotal
FROM dbo.ProductionOrders po
JOIN dbo.Products p ON p.ProductID = po.ProductID
JOIN dbo.Categories c ON c.CategoryID = p.CategoryID
JOIN dbo.FactoriesAndCategories fac
    ON fac.FactoryID = po.FactoryID AND fac.CategoryID = p.CategoryID
WHERE po.Status NOT IN (4,5)  -- pomijamy Cancelled/Failed
GROUP BY
    DATEFROMPARTS(YEAR(po.CreatedAt), MONTH(po.CreatedAt), 1),
    YEAR(po.CreatedAt), MONTH(po.CreatedAt),
    p.CategoryID, c.CategoryName;

GO

CREATE   VIEW [dbo].[vProductionCosts_ByCategory_Quarter] AS
SELECT
    DATEFROMPARTS(YEAR(po.CreatedAt), ((DATEPART(QUARTER, po.CreatedAt)-1)*3)+1, 1) AS PeriodStart,
    YEAR(po.CreatedAt) AS [Year],
    DATEPART(QUARTER, po.CreatedAt) AS [Quarter],
    p.CategoryID,
    c.CategoryName,
    SUM(po.Quantity) AS UnitsPlanned,
    CAST(SUM(po.Quantity * fac.ProductionCost) AS DECIMAL(18,2)) AS ProductionCostTotal
FROM dbo.ProductionOrders po
JOIN dbo.Products p ON p.ProductID = po.ProductID
JOIN dbo.Categories c ON c.CategoryID = p.CategoryID
JOIN dbo.FactoriesAndCategories fac
    ON fac.FactoryID = po.FactoryID AND fac.CategoryID = p.CategoryID
WHERE po.Status NOT IN (4,5)
GROUP BY
    DATEFROMPARTS(YEAR(po.CreatedAt), ((DATEPART(QUARTER, po.CreatedAt)-1)*3)+1, 1),
    YEAR(po.CreatedAt), DATEPART(QUARTER, po.CreatedAt),
    p.CategoryID, c.CategoryName;

GO

CREATE   VIEW [dbo].[vProductionCosts_ByCategory_Year] AS
SELECT
    DATEFROMPARTS(YEAR(po.CreatedAt), 1, 1) AS PeriodStart,
    YEAR(po.CreatedAt) AS [Year],
    p.CategoryID,
    c.CategoryName,
    SUM(po.Quantity) AS UnitsPlanned,
    CAST(SUM(po.Quantity * fac.ProductionCost) AS DECIMAL(18,2)) AS ProductionCostTotal
FROM dbo.ProductionOrders po
JOIN dbo.Products p ON p.ProductID = po.ProductID
JOIN dbo.Categories c ON c.CategoryID = p.CategoryID
JOIN dbo.FactoriesAndCategories fac
    ON fac.FactoryID = po.FactoryID AND fac.CategoryID = p.CategoryID
WHERE po.Status NOT IN (4,5)
GROUP BY
    DATEFROMPARTS(YEAR(po.CreatedAt), 1, 1),
    YEAR(po.CreatedAt),
    p.CategoryID, c.CategoryName;

GO

CREATE   VIEW [dbo].[vSales_ByCategory_Week] AS
SELECT
    DATEPART(ISO_WEEK, sl.OrderDate) AS IsoWeek,
    YEAR(sl.OrderDate) AS [Year],
    p.CategoryID,
    c.CategoryName,
    SUM(sl.Quantity) AS UnitsSold,
    CAST(SUM(sl.LineValue) AS DECIMAL(18,2)) AS SalesValue
FROM dbo.vSalesLines sl
JOIN dbo.Products p ON p.ProductID = sl.ProductID
JOIN dbo.Categories c ON c.CategoryID = p.CategoryID
GROUP BY
    YEAR(sl.OrderDate),
    DATEPART(ISO_WEEK, sl.OrderDate),
    p.CategoryID, c.CategoryName;

GO

CREATE   VIEW [dbo].[vSales_ByCategory_Month] AS
SELECT
    DATEFROMPARTS(YEAR(sl.OrderDate), MONTH(sl.OrderDate), 1) AS PeriodStart,
    YEAR(sl.OrderDate) AS [Year],
    MONTH(sl.OrderDate) AS [Month],
    p.CategoryID,
    c.CategoryName,
    SUM(sl.Quantity) AS UnitsSold,
    CAST(SUM(sl.LineValue) AS DECIMAL(18,2)) AS SalesValue
FROM dbo.vSalesLines sl
JOIN dbo.Products p ON p.ProductID = sl.ProductID
JOIN dbo.Categories c ON c.CategoryID = p.CategoryID
GROUP BY
    DATEFROMPARTS(YEAR(sl.OrderDate), MONTH(sl.OrderDate), 1),
    YEAR(sl.OrderDate), MONTH(sl.OrderDate),
    p.CategoryID, c.CategoryName;

GO

CREATE   VIEW [dbo].[vInventory_Status] AS
SELECT
    p.ProductID,
    p.ProductName,
    p.CategoryID,
    c.CategoryName,
    p.UnitsInStock AS UnitsInStock,

    ISNULL(SUM(CASE WHEN po.Status IN (0,1) THEN po.Quantity ELSE 0 END), 0) AS UnitsScheduled,
    ISNULL(SUM(CASE WHEN po.Status = 2 THEN po.Quantity ELSE 0 END), 0) AS UnitsInProgress,
    ISNULL(SUM(CASE WHEN po.Status IN (0,1,2) THEN po.Quantity ELSE 0 END), 0) AS UnitsPlannedOrInProgress
FROM dbo.Products p
JOIN dbo.Categories c ON c.CategoryID = p.CategoryID
LEFT JOIN dbo.ProductionOrders po
    ON po.ProductID = p.ProductID
   AND po.Status NOT IN (3,4,5) -- nie liczymy Completed/Cancelled/Failed jako "w produkcji"
GROUP BY
    p.ProductID, p.ProductName, p.CategoryID, c.CategoryName, p.UnitsInStock;

GO

CREATE   VIEW [dbo].[vProductionPlan_Orders] AS
SELECT
    po.ProductionOrderID,
    po.OrderID,
    po.FactoryID,
    f.FactoryName,
    po.ProductID,
    p.ProductName,
    p.CategoryID,
    c.CategoryName,
    po.Quantity,
    po.Status,
    po.CreatedAt,
    po.PlannedStart,
    po.PlannedEnd,
    po.DueDate
FROM dbo.ProductionOrders po
JOIN dbo.Factories f ON f.FactoryID = po.FactoryID
JOIN dbo.Products p ON p.ProductID = po.ProductID
JOIN dbo.Categories c ON c.CategoryID = p.CategoryID
WHERE po.Status NOT IN (4,5); -- Cancelled/Failed out

GO

CREATE   VIEW [dbo].[vProductionPlan_FactoryDailyLoad] AS
SELECT
    r.FactoryID,
    f.FactoryName,
    r.WorkDate,
    CAST(SUM(r.ReservedHours) AS DECIMAL(18,2)) AS ReservedHours,
    c.CapacityHours,
    CAST(c.CapacityHours - SUM(r.ReservedHours) AS DECIMAL(18,2)) AS FreeHours
FROM dbo.FactoryCapacityReservations r
JOIN dbo.FactoryCapacityCalendar c
    ON c.FactoryID = r.FactoryID AND c.WorkDate = r.WorkDate
JOIN dbo.Factories f ON f.FactoryID = r.FactoryID
GROUP BY
    r.FactoryID, f.FactoryName, r.WorkDate, c.CapacityHours;

GO

CREATE   VIEW [dbo].[vLowStockProducts]
AS
SELECT
    p.ProductID,
    p.ProductName,
    p.UnitsInStock,
    p.UnitPrice,
    p.CategoryID,
    c.CategoryName
FROM dbo.Products p
JOIN dbo.Categories c ON c.CategoryID = p.CategoryID
WHERE p.UnitsInStock <= 10;

GO

CREATE   VIEW [dbo].[vRefundsWithOrderInfo]
AS
SELECT
    r.RefundID,
    r.RefundApproved,
    r.OrderID,
    o.OrderDate,
    o.ShipDate,
    o.CustomerID,
    c.CustomerName,
    r.ProductID,
    p.ProductName,
    r.Quantity
FROM dbo.Refunds r
JOIN dbo.Orders o     ON o.OrderID = r.OrderID
JOIN dbo.Customers c  ON c.CustomerID = o.CustomerID
JOIN dbo.Products p   ON p.ProductID = r.ProductID;

GO

CREATE VIEW [dbo].[vProductBOM]
AS
SELECT p.ProductID, p.ProductName, pf.PartID, pf.QuantityNeeded AS PartQuantityNeeded, mf.MaterialID, mf.QuantityNeeded AS MaterialQuantityNeeded
FROM     dbo.Products AS p LEFT OUTER JOIN
                  dbo.PartsForOneUnit AS pf ON pf.ProductID = p.ProductID LEFT OUTER JOIN
                  dbo.MaterialsForOneUnit AS mf ON mf.ProductID = p.ProductID

GO

CREATE   VIEW [dbo].[vOrderSummary]
AS
SELECT
    o.OrderID,
    o.OrderDate,
    o.ShipDate,
    o.Freight,
    c.CustomerID,
    c.CustomerName,
    e.EmployeeID,
    (e.FirstName + ' ' + e.LastName) AS EmployeeName,
    s.ShipperID,
    s.CompanyName AS ShipperCompany,
    COUNT(od.ProductID) AS LinesCount,
    SUM(CAST(od.Quantity AS INT)) AS TotalQuantity,
    dbo.OrderSubtotal(o.OrderID) AS Subtotal,
    dbo.OrderDiscount(o.OrderID) AS DiscountAmount,
    dbo.OrderTax(o.OrderID) AS TaxAmount,
    dbo.OrderTotal(o.OrderID) AS TotalAmount
FROM dbo.Orders o
JOIN dbo.Customers c ON c.CustomerID = o.CustomerID
JOIN dbo.Employees e ON e.EmployeeID = o.EmployeeID
JOIN dbo.Shippers s ON s.ShipperID = o.ShipperID
LEFT JOIN dbo.OrderDetails od ON od.OrderID = o.OrderID
GROUP BY
    o.OrderID, o.OrderDate, o.ShipDate, o.Freight,
    c.CustomerID, c.CustomerName,
    e.EmployeeID, e.FirstName, e.LastName,
    s.ShipperID, s.CompanyName;