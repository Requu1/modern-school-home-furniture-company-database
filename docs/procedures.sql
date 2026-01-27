CREATE   PROCEDURE [dbo].[AddPayment]
    @OrderID     INT,
    @TaxID       INT,
    @Amount      INT,
    @PaymentDate DATE = NULL,
    @NewPaymentID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF @PaymentDate IS NULL
        SET @PaymentDate = CAST(GETDATE() AS DATE);

    IF @Amount <= 0
        THROW 51100, 'Amount musi być > 0.', 1;

    IF NOT EXISTS (SELECT 1 FROM dbo.Orders WHERE OrderID = @OrderID)
        THROW 51101, 'Nie istnieje OrderID.', 1;

    IF NOT EXISTS (SELECT 1 FROM dbo.Taxes WHERE TaxID = @TaxID)
        THROW 51102, 'Nie istnieje TaxID.', 1;

    DECLARE @OrderDate DATE;
    SELECT @OrderDate = o.OrderDate FROM dbo.Orders o WHERE o.OrderID = @OrderID;

    IF @PaymentDate < @OrderDate
        THROW 51103, 'PaymentDate nie może być wcześniejszy niż OrderDate.', 1;

    BEGIN TRY
        BEGIN TRAN;

        SELECT @NewPaymentID = ISNULL(MAX(PaymentID), 0) + 1
        FROM dbo.Payments WITH (UPDLOCK, HOLDLOCK);

        DECLARE @Total DECIMAL(18,2) = dbo.OrderTotal(@OrderID);
        DECLARE @AlreadyPaid DECIMAL(18,2) = (
            SELECT COALESCE(SUM(CAST(p.Amount AS DECIMAL(18,2))), 0)
            FROM dbo.Payments p
            WHERE p.OrderID = @OrderID
        );

        IF (@AlreadyPaid + CAST(@Amount AS DECIMAL(18,2))) > @Total
            THROW 51104, 'Suma płatności przekroczyłaby wartość zamówienia (OrderTotal).', 1;

        INSERT INTO dbo.Payments (PaymentID, TaxID, OrderID, Amount, PaymentDate)
        VALUES (@NewPaymentID, @TaxID, @OrderID, @Amount, @PaymentDate);

        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        THROW;
    END CATCH
END;

GO

CREATE   PROCEDURE [dbo].[ApproveRefund]
    @RefundID int
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRAN;

        IF NOT EXISTS (SELECT 1 FROM dbo.Refunds WITH (UPDLOCK, HOLDLOCK) WHERE RefundID = @RefundID)
        BEGIN
            RAISERROR(N'Nie znaleziono refundu o podanym RefundID.', 16, 1);
            ROLLBACK TRAN;
            RETURN;
        END;

        IF EXISTS (SELECT 1 FROM dbo.Refunds WITH (UPDLOCK, HOLDLOCK) WHERE RefundID = @RefundID AND RefundApproved = 1)
        BEGIN
            RAISERROR(N'Refund jest już zatwierdzony.', 16, 1);
            ROLLBACK TRAN;
            RETURN;
        END;

        UPDATE dbo.Refunds
            SET RefundApproved = 1
        WHERE RefundID = @RefundID;
        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;

        DECLARE @msg nvarchar(4000) = ERROR_MESSAGE();
        DECLARE @sev int = ERROR_SEVERITY();
        DECLARE @st  int = ERROR_STATE();
        RAISERROR(@msg, @sev, @st);
    END CATCH
END

GO

CREATE PROCEDURE [dbo].[PlaceOrder]
    @RequestedDeliveryDate date = NULL,
    @EmployeeID INT,
    @CustomerID INT,
    @ShipperID  INT,
    @OrderDate  DATE = NULL,
    @Freight    INT = 0,
    @Items      dbo.OrderItemType READONLY,
    @NewOrderID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF @OrderDate IS NULL
        SET @OrderDate = CAST(GETDATE() AS DATE);

    IF @RequestedDeliveryDate IS NULL
        SET @RequestedDeliveryDate = DATEADD(DAY, 14, @OrderDate);

    IF @RequestedDeliveryDate < @OrderDate
        THROW 51000, 'RequestedDeliveryDate nie może być wcześniejsza niż OrderDate.', 1;

    IF @Freight < 0
        THROW 51001, 'Freight nie może być ujemny.', 1;

    IF NOT EXISTS (SELECT 1 FROM @Items)
        THROW 51002, 'Lista pozycji @Items jest pusta.', 1;

    IF EXISTS (SELECT 1 FROM @Items WHERE Quantity <= 0)
        THROW 51003, 'Quantity musi być > 0.', 1;

    IF NOT EXISTS (SELECT 1 FROM dbo.Employees WHERE EmployeeID=@EmployeeID)
        THROW 51004, 'EmployeeID nie istnieje.', 1;
    IF NOT EXISTS (SELECT 1 FROM dbo.Customers WHERE CustomerID=@CustomerID)
        THROW 51005, 'CustomerID nie istnieje.', 1;
    IF NOT EXISTS (SELECT 1 FROM dbo.Shippers WHERE ShipperID=@ShipperID)
        THROW 51006, 'ShipperID nie istnieje.', 1;

    IF EXISTS (
        SELECT 1
        FROM @Items i
        LEFT JOIN dbo.Products p ON p.ProductID = i.ProductID
        WHERE p.ProductID IS NULL
    )
        THROW 51007, 'Co najmniej jeden ProductID z @Items nie istnieje.', 1;

    BEGIN TRY
        BEGIN TRAN;

        SELECT @NewOrderID = ISNULL(MAX(OrderID), 0) + 1
        FROM dbo.Orders WITH (UPDLOCK, HOLDLOCK);

        INSERT INTO dbo.Orders
            (OrderID, EmployeeID, CustomerID, ShipperID, OrderDate, ShipDate, Freight, RequestedDeliveryDate)
        VALUES
            (@NewOrderID, @EmployeeID, @CustomerID, @ShipperID, @OrderDate, NULL, @Freight, @RequestedDeliveryDate);

        CREATE TABLE #Alloc
        (
            ProductID INT NOT NULL PRIMARY KEY,
            Quantity INT NOT NULL,
            UnitPrice INT NOT NULL,
            Discount INT NOT NULL,
            QuantityFromStock INT NOT NULL,
            MissingQty INT NOT NULL,
            FactoryID INT NULL
        );

        INSERT INTO #Alloc(ProductID, Quantity, UnitPrice, Discount, QuantityFromStock, MissingQty, FactoryID)
        SELECT
            i.ProductID,
            i.Quantity,
            COALESCE(i.UnitPrice, p.UnitPrice) AS UnitPrice,
            COALESCE(i.Discount, 0) AS Discount,
            CASE
                WHEN p.UnitsInStock >= i.Quantity THEN i.Quantity
                WHEN p.UnitsInStock > 0 THEN p.UnitsInStock
                ELSE 0
            END AS QuantityFromStock,
            CASE
                WHEN p.UnitsInStock >= i.Quantity THEN 0
                WHEN p.UnitsInStock > 0 THEN i.Quantity - p.UnitsInStock
                ELSE i.Quantity
            END AS MissingQty,
            NULL
        FROM @Items i
        JOIN dbo.Products p WITH (UPDLOCK, HOLDLOCK) ON p.ProductID = i.ProductID;

        INSERT INTO dbo.OrderDetails (OrderID, ProductID, UnitPrice, Quantity, Discount, QuantityFromStock)
        SELECT
            @NewOrderID,
            a.ProductID,
            a.UnitPrice,
            a.Quantity,
            a.Discount,
            a.QuantityFromStock
        FROM #Alloc a;

        UPDATE a
        SET FactoryID = fac.FactoryID
        FROM #Alloc a
        JOIN dbo.Products p ON p.ProductID = a.ProductID
        OUTER APPLY (
            SELECT TOP 1 fc.FactoryID
            FROM dbo.FactoriesAndCategories fc
            WHERE fc.CategoryID = p.CategoryID
            ORDER BY fc.ProductionCost ASC
        ) fac
        WHERE a.MissingQty > 0;

        IF EXISTS (SELECT 1 FROM #Alloc WHERE MissingQty > 0 AND FactoryID IS NULL)
            THROW 51010, 'Brak fabryki zdolnej produkować kategorię dla co najmniej jednego produktu.', 1;

        DECLARE @NewPO TABLE (ProductionOrderID INT NOT NULL);

        INSERT INTO dbo.ProductionOrders (OrderID, ProductID, FactoryID, Quantity, DueDate, Status, Priority, Notes)
        OUTPUT inserted.ProductionOrderID INTO @NewPO(ProductionOrderID)
        SELECT
            @NewOrderID,
            a.ProductID,
            a.FactoryID,
            a.MissingQty,
            CAST(@RequestedDeliveryDate AS DATETIME2(0)),
            0,
            3,
            N'Auto-created from PlaceOrder (missing stock)'
        FROM #Alloc a
        WHERE a.MissingQty > 0;

        DECLARE @POID INT;
        DECLARE cur CURSOR LOCAL FAST_FORWARD FOR
            SELECT ProductionOrderID FROM @NewPO;

        OPEN cur;
        FETCH NEXT FROM cur INTO @POID;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            EXEC dbo.ScheduleProductionOrder @ProductionOrderID = @POID, @StartDate = @OrderDate;
            FETCH NEXT FROM cur INTO @POID;
        END
        CLOSE cur;
        DEALLOCATE cur;

        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        DECLARE @Msg NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 52000, @Msg, 1;
    END CATCH
END;

GO

CREATE   PROCEDURE [dbo].[ReceiveStock]
    @ProductID int,
    @Quantity  int
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF @Quantity IS NULL OR @Quantity <= 0
    BEGIN
        RAISERROR(N'Quantity musi być > 0.', 16, 1);
        RETURN;
    END;

    UPDATE dbo.Products
        SET UnitsInStock = UnitsInStock + @Quantity
    WHERE ProductID = @ProductID;

    IF @@ROWCOUNT = 0
        RAISERROR(N'Nie znaleziono produktu o podanym ProductID.', 16, 1);
END

GO

CREATE   PROCEDURE [dbo].[ScheduleProductionOrder]
    @ProductionOrderID INT,
    @StartDate DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF @StartDate IS NULL
        SET @StartDate = CONVERT(DATE, SYSUTCDATETIME());

    DECLARE
        @FactoryID INT,
        @ProductID INT,
        @Quantity INT,
        @HoursPerUnit DECIMAL(8,4),
        @RequiredHours DECIMAL(12,4),
        @RemainingHours DECIMAL(12,4),
        @Day DATE,
        @Capacity DECIMAL(6,2),
        @Reserved DECIMAL(12,4),
        @Free DECIMAL(12,4),
        @Take DECIMAL(12,4),
        @PlannedStart DATETIME2(0),
        @PlannedEnd DATETIME2(0);

    SELECT
        @FactoryID = FactoryID,
        @ProductID = ProductID,
        @Quantity  = Quantity
    FROM dbo.ProductionOrders WITH (UPDLOCK, HOLDLOCK)
    WHERE ProductionOrderID = @ProductionOrderID;

    IF @FactoryID IS NULL
        THROW 50001, 'ProductionOrder not found.', 1;

    SELECT @HoursPerUnit = HoursPerUnit
    FROM dbo.ProductProductionSpec
    WHERE ProductID = @ProductID;

    IF @HoursPerUnit IS NULL
        THROW 50002, 'Missing ProductProductionSpec for this ProductID.', 1;

    SET @RequiredHours = CAST(@Quantity AS DECIMAL(12,4)) * CAST(@HoursPerUnit AS DECIMAL(12,4));
    SET @RemainingHours = @RequiredHours;

    BEGIN TRAN;

        DELETE FROM dbo.FactoryCapacityReservations
        WHERE ProductionOrderID = @ProductionOrderID;

        SET @Day = @StartDate;

        WHILE @RemainingHours > 0
        BEGIN
            SELECT @Capacity = CapacityHours
            FROM dbo.FactoryCapacityCalendar WITH (UPDLOCK, HOLDLOCK)
            WHERE FactoryID = @FactoryID AND WorkDate = @Day;

            IF @Capacity IS NULL
                THROW 50003, 'Missing FactoryCapacityCalendar entry (cannot schedule).', 1;

            SELECT @Reserved = ISNULL(SUM(ReservedHours), 0)
            FROM dbo.FactoryCapacityReservations WITH (UPDLOCK, HOLDLOCK)
            WHERE FactoryID = @FactoryID AND WorkDate = @Day;

            SET @Free = CAST(@Capacity AS DECIMAL(12,4)) - CAST(@Reserved AS DECIMAL(12,4));

            IF @Free > 0
            BEGIN
                SET @Take = CASE WHEN @Free >= @RemainingHours THEN @RemainingHours ELSE @Free END;

                INSERT INTO dbo.FactoryCapacityReservations(FactoryID, WorkDate, ProductionOrderID, ReservedHours)
                VALUES (@FactoryID, @Day, @ProductionOrderID, CAST(@Take AS DECIMAL(6,2)));

                IF @PlannedStart IS NULL
                    SET @PlannedStart = CAST(@Day AS DATETIME2(0));

                SET @RemainingHours = @RemainingHours - @Take;
                SET @PlannedEnd = DATEADD(SECOND, -1, DATEADD(DAY, 1, CAST(@Day AS DATETIME2(0))));
            END

            SET @Day = DATEADD(DAY, 1, @Day);

            IF DATEDIFF(DAY, @StartDate, @Day) > 3660
                THROW 50004, 'Scheduling exceeded horizon; check capacity.', 1;
        END

        UPDATE dbo.ProductionOrders
        SET PlannedStart = @PlannedStart,
            PlannedEnd   = @PlannedEnd,
            Status       = 1
        WHERE ProductionOrderID = @ProductionOrderID;

    COMMIT;
END;

GO

CREATE   PROCEDURE [dbo].[SeedFactoryCapacityCalendar]
    @StartDate DATE,
    @EndDate DATE,
    @WeekdayHours DECIMAL(6,2) = 16.0,
    @WeekendHours DECIMAL(6,2) = 0.0
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH Dates AS (
        SELECT @StartDate AS d
        UNION ALL
        SELECT DATEADD(DAY, 1, d)
        FROM Dates
        WHERE d < @EndDate
    )
    INSERT INTO dbo.FactoryCapacityCalendar (FactoryID, WorkDate, CapacityHours)
    SELECT
        f.FactoryID,
        d.d,
        CASE
            WHEN DATENAME(WEEKDAY, d.d) IN ('Saturday','Sunday') THEN @WeekendHours
            ELSE @WeekdayHours
        END
    FROM dbo.Factories f
    CROSS JOIN Dates d
    WHERE NOT EXISTS (
        SELECT 1
        FROM dbo.FactoryCapacityCalendar c
        WHERE c.FactoryID = f.FactoryID AND c.WorkDate = d.d
    )
    OPTION (MAXRECURSION 0);
END;

GO

CREATE   PROCEDURE [dbo].[ShipOrder]
    @OrderID   INT,
    @ShipDate  DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @ShipDate IS NULL
        SET @ShipDate = CAST(GETDATE() AS DATE);

    IF NOT EXISTS (SELECT 1 FROM dbo.Orders WHERE OrderID = @OrderID)
        THROW 51200, 'Nie istnieje OrderID.', 1;

    DECLARE @OrderDate DATE, @ExistingShip DATE;
    SELECT @OrderDate = OrderDate, @ExistingShip = ShipDate
    FROM dbo.Orders
    WHERE OrderID = @OrderID;

    IF @ExistingShip IS NOT NULL
        THROW 51201, 'Zamówienie ma już ustawioną datę wysyłki.', 1;

    IF @ShipDate < @OrderDate
        THROW 51202, 'ShipDate nie może być wcześniejsza niż OrderDate.', 1;

    UPDATE dbo.Orders
    SET ShipDate = @ShipDate
    WHERE OrderID = @OrderID;
END;