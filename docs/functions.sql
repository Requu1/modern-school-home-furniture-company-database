CREATE   FUNCTION [dbo].[AvailableStock]
(
    @ProductID int
)
RETURNS int
AS
BEGIN
    DECLARE @x int;

    SELECT @x = UnitsInStock
    FROM dbo.Products
    WHERE ProductID = @ProductID;

    RETURN ISNULL(@x, 0);
END

GO

CREATE FUNCTION [dbo].[CalculateMaterialCostForProduct]
(
    @ProductID INT
)
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @MaterialCost DECIMAL(18,2);

    SELECT
        @MaterialCost = SUM(
            mf.QuantityNeeded *
            (ms.UnitPrice + ms.Freight)
        )
    FROM MaterialsForOneUnit mf
    CROSS APPLY (
        SELECT TOP (1)
            ms.UnitPrice,
            ms.Freight
        FROM MaterialSuppliers ms
        WHERE ms.MaterialID = mf.MaterialID
        ORDER BY
            (ms.UnitPrice + ms.Freight) ASC
    ) ms
    WHERE mf.ProductID = @ProductID;

    RETURN COALESCE(@MaterialCost, 0);
END;

GO

CREATE FUNCTION [dbo].[CalculatePartCostForProduct]
(
    @ProductID INT
)
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @PartCost DECIMAL(18,2);

    SELECT
        @PartCost = SUM(
            pf.QuantityNeeded *
            (ps.UnitPrice + ps.Freight)
        )
    FROM PartsForOneUnit pf
    CROSS APPLY (
        SELECT TOP (1)
            ps.UnitPrice,
            ps.Freight
        FROM PartSuppliers ps
        WHERE ps.PartID = pf.PartID
        ORDER BY
            (ps.UnitPrice + ps.Freight) ASC
    ) ps
    WHERE pf.ProductID = @ProductID;

    RETURN COALESCE(@PartCost, 0);
END;

GO

CREATE FUNCTION [dbo].[CalculateProductionCost]
(
    @ProductID INT
)
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @MaterialCost DECIMAL(18,2);
    DECLARE @PartCost DECIMAL(18,2);

    SELECT
        @MaterialCost = SUM(
            mf.QuantityNeeded *
            (ms.UnitPrice + ms.Freight)
        )
    FROM MaterialsForOneUnit mf
    CROSS APPLY (
        SELECT TOP (1)
            ms.UnitPrice,
            ms.Freight
        FROM MaterialSuppliers ms
        WHERE ms.MaterialID = mf.MaterialID
        ORDER BY
            (ms.UnitPrice + ms.Freight) ASC
    ) ms
    WHERE mf.ProductID = @ProductID;

    SELECT
        @PartCost = SUM(
            pf.QuantityNeeded *
            (ps.UnitPrice + ps.Freight)
        )
    FROM PartsForOneUnit pf
    CROSS APPLY (
        SELECT TOP (1)
            ps.UnitPrice,
            ps.Freight
        FROM PartSuppliers ps
        WHERE ps.PartID = pf.PartID
        ORDER BY
            (ps.UnitPrice + ps.Freight) ASC
    ) ps
    WHERE pf.ProductID = @ProductID;

    RETURN COALESCE(@MaterialCost, 0) + COALESCE(@PartCost, 0);
END;

GO

CREATE FUNCTION [dbo].[GetBestSupplierForMaterial]
(
    @MaterialID INT
)
RETURNS INT
AS
BEGIN
    DECLARE @BestSupplierID INT;

    SELECT TOP (1)
        @BestSupplierID = ms.SupplierID
    FROM MaterialSuppliers ms
    WHERE ms.MaterialID = @MaterialID
    ORDER BY
        (ms.UnitPrice + ms.Freight) ASC,
        ms.SupplierID ASC;

    RETURN @BestSupplierID;
END;

GO

CREATE FUNCTION [dbo].[GetBestSupplierForPart]
(
    @PartID INT
)
RETURNS INT
AS
BEGIN
    DECLARE @BestSupplierID INT;

    SELECT TOP (1)
        @BestSupplierID = ps.SupplierID
    FROM PartSuppliers ps
    WHERE ps.PartID = @PartID
    ORDER BY
        (ps.UnitPrice + ps.Freight) ASC,
        ps.SupplierID ASC;

    RETURN @BestSupplierID;
END;

GO

CREATE   FUNCTION [dbo].[OrderDiscount] (@OrderID INT)
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @DiscountAmt DECIMAL(18,2);

    SELECT @DiscountAmt = COALESCE(SUM(
        (CAST(od.UnitPrice AS DECIMAL(18,2)) * od.Quantity) * (CAST(od.Discount AS DECIMAL(18,2)) / 100.0)
    ), 0)
    FROM dbo.OrderDetails od
    WHERE od.OrderID = @OrderID;

    RETURN COALESCE(@DiscountAmt, 0);
END;

GO

CREATE   FUNCTION [dbo].[OrderSubtotal] (@OrderID INT)
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @Subtotal DECIMAL(18,2);

    SELECT @Subtotal = COALESCE(SUM(CAST(od.UnitPrice AS DECIMAL(18,2)) * od.Quantity), 0)
    FROM dbo.OrderDetails od
    WHERE od.OrderID = @OrderID;

    RETURN COALESCE(@Subtotal, 0);
END;

GO

CREATE   FUNCTION [dbo].[OrderTax] (@OrderID INT)
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @TaxValue INT = 0;

    SELECT TOP (1) @TaxValue = t.TaxValue
    FROM dbo.Payments p
    JOIN dbo.Taxes t ON t.TaxID = p.TaxID
    WHERE p.OrderID = @OrderID
    ORDER BY p.PaymentDate DESC, p.PaymentID DESC;

    DECLARE @TaxBase DECIMAL(18,2) = dbo.OrderSubtotal(@OrderID) - dbo.OrderDiscount(@OrderID);

    RETURN COALESCE(@TaxBase * (CAST(@TaxValue AS DECIMAL(18,2)) / 100.0), 0);
END;

GO

CREATE   FUNCTION [dbo].[OrderTotal] (@OrderID INT)
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @Freight DECIMAL(18,2) = 0;

    SELECT @Freight = CAST(o.Freight AS DECIMAL(18,2))
    FROM dbo.Orders o
    WHERE o.OrderID = @OrderID;

    RETURN (dbo.OrderSubtotal(@OrderID) - dbo.OrderDiscount(@OrderID)) + COALESCE(@Freight, 0) + dbo.OrderTax(@OrderID);
END;