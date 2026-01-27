CREATE   TRIGGER [dbo].[trg_OrderDetails_Stock]
ON [dbo].[OrderDetails]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    CREATE TABLE #Delta (
        ProductID INT NOT NULL PRIMARY KEY,
        DeltaQty  INT NOT NULL
    );

    INSERT INTO #Delta(ProductID, DeltaQty)
    SELECT ProductID, SUM(Qty) AS DeltaQty
    FROM (
        SELECT i.ProductID, CAST(i.QuantityFromStock AS INT) AS Qty
        FROM inserted i
        UNION ALL
        SELECT d.ProductID, -CAST(d.QuantityFromStock AS INT) AS Qty
        FROM deleted d
    ) x
    GROUP BY ProductID;

    IF EXISTS (
        SELECT 1
        FROM #Delta dt
        JOIN dbo.Products p WITH (UPDLOCK, HOLDLOCK)
          ON p.ProductID = dt.ProductID
        WHERE (p.UnitsInStock - dt.DeltaQty) < 0
    )
    BEGIN
        RAISERROR(N'Brak stanu magazynowego (QuantityFromStock).', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;

    UPDATE p
        SET p.UnitsInStock = p.UnitsInStock - dt.DeltaQty
    FROM dbo.Products p
    JOIN #Delta dt ON dt.ProductID = p.ProductID
    WHERE dt.DeltaQty <> 0;
END

GO

CREATE   TRIGGER [dbo].[trg_Payments_Validate]
ON [dbo].[Payments]
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM inserted WHERE Amount <= 0)
    BEGIN
        RAISERROR('Amount musi być > 0.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN dbo.Orders o ON o.OrderID = i.OrderID
        WHERE i.PaymentDate < o.OrderDate
    )
    BEGIN
        RAISERROR('PaymentDate nie może być wcześniejszy niż OrderDate.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    IF EXISTS (
        SELECT 1
        FROM inserted i
        CROSS APPLY (
            SELECT
                COALESCE(SUM(CAST(p.Amount AS DECIMAL(18,2))), 0) AS PaidTotal
            FROM dbo.Payments p
            WHERE p.OrderID = i.OrderID
        ) x
        WHERE x.PaidTotal > dbo.OrderTotal(i.OrderID)
    )
    BEGIN
        RAISERROR('Suma płatności przekracza wartość zamówienia (OrderTotal).', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;

GO

CREATE   TRIGGER [dbo].[trg_Products_MinPrice]
ON [dbo].[Products]
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN dbo.vProductUnitCost c ON c.ProductID = i.ProductID
        WHERE i.UnitPrice < c.TotalCost
    )
    BEGIN
        THROW 52001, 'Cena sprzedaży nie może być niższa niż łączny koszt (materiały + części + produkcja).', 1;
    END
END;

GO

CREATE TRIGGER [dbo].[trg_Refunds_Approve]
ON [dbo].[Refunds]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    CREATE TABLE #NewlyApproved
    (
        RefundID  int NOT NULL PRIMARY KEY,
        OrderID   int NOT NULL,
        ProductID int NOT NULL,
        Qty       int NOT NULL
    );

    INSERT INTO #NewlyApproved (RefundID, OrderID, ProductID, Qty)
    SELECT i.RefundID, i.OrderID, i.ProductID, CAST(i.Quantity AS int)
    FROM inserted i
    JOIN deleted d ON d.RefundID = i.RefundID
    WHERE i.RefundApproved = 1 AND d.RefundApproved = 0;

    IF NOT EXISTS (SELECT 1 FROM #NewlyApproved)
        RETURN;

    CREATE TABLE #AggNew
    (
        OrderID   int NOT NULL,
        ProductID int NOT NULL,
        NewQty    int NOT NULL,
        CONSTRAINT PK_AggNew PRIMARY KEY (OrderID, ProductID)
    );

    INSERT INTO #AggNew (OrderID, ProductID, NewQty)
    SELECT OrderID, ProductID, SUM(Qty)
    FROM #NewlyApproved
    GROUP BY OrderID, ProductID;

    CREATE TABLE #Purchased
    (
        OrderID int NOT NULL,
        ProductID int NOT NULL,
        PurchasedQty int NOT NULL,
        CONSTRAINT PK_Purchased PRIMARY KEY (OrderID, ProductID)
    );

    INSERT INTO #Purchased (OrderID, ProductID, PurchasedQty)
    SELECT od.OrderID, od.ProductID, SUM(CAST(od.Quantity AS int))
    FROM dbo.OrderDetails od
    GROUP BY od.OrderID, od.ProductID;

    CREATE TABLE #AlreadyApproved
    (
        OrderID int NOT NULL,
        ProductID int NOT NULL,
        AlreadyApprovedQty int NOT NULL,
        CONSTRAINT PK_AlreadyApproved PRIMARY KEY (OrderID, ProductID)
    );

    INSERT INTO #AlreadyApproved (OrderID, ProductID, AlreadyApprovedQty)
    SELECT r.OrderID, r.ProductID, SUM(CAST(r.Quantity AS int))
    FROM dbo.Refunds r
    WHERE r.RefundApproved = 1
      AND NOT EXISTS (SELECT 1 FROM #NewlyApproved na WHERE na.RefundID = r.RefundID)
    GROUP BY r.OrderID, r.ProductID;

    IF EXISTS (
        SELECT 1
        FROM #AggNew n
        LEFT JOIN #Purchased p
               ON p.OrderID = n.OrderID AND p.ProductID = n.ProductID
        LEFT JOIN #AlreadyApproved a
               ON a.OrderID = n.OrderID AND a.ProductID = n.ProductID
        WHERE (ISNULL(a.AlreadyApprovedQty, 0) + n.NewQty) > ISNULL(p.PurchasedQty, 0)
    )
    BEGIN
        RAISERROR(N'Nie można zatwierdzić zwrotu: łączna ilość zwrotów przekracza ilość kupioną w zamówieniu.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;

    UPDATE p
        SET p.UnitsInStock = p.UnitsInStock + n.NewQty
    FROM dbo.Products p
    JOIN #AggNew n ON n.ProductID = p.ProductID
    WHERE n.NewQty <> 0;
END