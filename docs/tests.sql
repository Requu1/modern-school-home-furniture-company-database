USE [u_micnowak];
SET NOCOUNT ON;

DECLARE @pass int = 0, @fail int = 0, @skip int = 0;
DECLARE @TestName nvarchar(200);

DECLARE @Today date = CONVERT(date, GETDATE());
DECLARE @Yesterday date = DATEADD(DAY, -1, @Today);

------------------------------------------------------------------------------------
-- TEST 01 - AvailableStock() = UnitsInStock
------------------------------------------------------------------------------------
BEGIN TRY
    SET @TestName = N'TEST 01 - AvailableStock() = Products.UnitsInStock';
    DECLARE @pid int = (SELECT TOP 1 ProductID FROM dbo.Products ORDER BY ProductID);

    IF @pid IS NULL
    BEGIN
        PRINT @TestName + N' => SKIPPED (brak Products)';
        SET @skip += 1;
    END
    ELSE
    BEGIN
        DECLARE @s1 int = (SELECT UnitsInStock FROM dbo.Products WHERE ProductID=@pid);
        DECLARE @s2 int = dbo.AvailableStock(@pid);

        IF ISNULL(@s1,0) = ISNULL(@s2,0)
        BEGIN PRINT @TestName + N' => PASS'; SET @pass += 1; END
        ELSE THROW 50001, 'AvailableStock niezgodne z UnitsInStock.', 1;
    END
END TRY
BEGIN CATCH
    PRINT @TestName + N' => FAIL: ' + ERROR_MESSAGE(); SET @fail += 1;
END CATCH;

------------------------------------------------------------------------------------
-- TEST 02 - OrderSubtotal()
------------------------------------------------------------------------------------
BEGIN TRY
    SET @TestName = N'TEST 02 - OrderSubtotal() poprawna';
    DECLARE @oid int = (SELECT TOP 1 OrderID FROM dbo.Orders ORDER BY OrderID);

    IF @oid IS NULL
    BEGIN PRINT @TestName + N' => SKIPPED (brak Orders)'; SET @skip += 1; END
    ELSE
    BEGIN
        DECLARE @expected decimal(18,2) =
        (
            SELECT COALESCE(SUM(CAST(UnitPrice as decimal(18,2))*Quantity),0)
            FROM dbo.OrderDetails WHERE OrderID=@oid
        );
        DECLARE @actual decimal(18,2) = dbo.OrderSubtotal(@oid);

        IF ABS(@expected - @actual) < 0.01
        BEGIN PRINT @TestName + N' => PASS'; SET @pass += 1; END
        ELSE THROW 50002, 'OrderSubtotal błędna.', 1;
    END
END TRY
BEGIN CATCH
    PRINT @TestName + N' => FAIL: ' + ERROR_MESSAGE(); SET @fail += 1;
END CATCH;

------------------------------------------------------------------------------------
-- TEST 03 - OrderDiscount()
------------------------------------------------------------------------------------
BEGIN TRY
    SET @TestName = N'TEST 03 - OrderDiscount() poprawna';
    DECLARE @oid2 int = (SELECT TOP 1 OrderID FROM dbo.Orders ORDER BY OrderID);

    IF @oid2 IS NULL
    BEGIN PRINT @TestName + N' => SKIPPED (brak Orders)'; SET @skip += 1; END
    ELSE
    BEGIN
        DECLARE @expected2 decimal(18,2) =
        (
            SELECT COALESCE(SUM((CAST(UnitPrice as decimal(18,2))*Quantity) * (CAST(Discount as decimal(18,2))/100.0)),0)
            FROM dbo.OrderDetails WHERE OrderID=@oid2
        );
        DECLARE @actual2 decimal(18,2) = dbo.OrderDiscount(@oid2);

        IF ABS(@expected2 - @actual2) < 0.01
        BEGIN PRINT @TestName + N' => PASS'; SET @pass += 1; END
        ELSE THROW 50003, 'OrderDiscount błędna.', 1;
    END
END TRY
BEGIN CATCH
    PRINT @TestName + N' => FAIL: ' + ERROR_MESSAGE(); SET @fail += 1;
END CATCH;

------------------------------------------------------------------------------------
-- TEST 04 - OrderTotal() spójna
------------------------------------------------------------------------------------
BEGIN TRY
    SET @TestName = N'TEST 04 - OrderTotal() spójna';
    DECLARE @oid3 int = (SELECT TOP 1 OrderID FROM dbo.Orders ORDER BY OrderID);

    IF @oid3 IS NULL
    BEGIN PRINT @TestName + N' => SKIPPED (brak Orders)'; SET @skip += 1; END
    ELSE
    BEGIN
        DECLARE @expected3 decimal(18,2) =
            dbo.OrderSubtotal(@oid3) - dbo.OrderDiscount(@oid3)
            + dbo.OrderTax(@oid3)
            + ISNULL((SELECT CAST(Freight as decimal(18,2)) FROM dbo.Orders WHERE OrderID=@oid3),0);

        DECLARE @actual3 decimal(18,2) = dbo.OrderTotal(@oid3);

        IF ABS(@expected3 - @actual3) < 0.01
        BEGIN PRINT @TestName + N' => PASS'; SET @pass += 1; END
        ELSE THROW 50004, 'OrderTotal niespójna.', 1;
    END
END TRY
BEGIN CATCH
    PRINT @TestName + N' => FAIL: ' + ERROR_MESSAGE(); SET @fail += 1;
END CATCH;

------------------------------------------------------------------------------------
-- TEST 05 - vPaymentsByOrder zgodny z Payments
------------------------------------------------------------------------------------
BEGIN TRY
    SET @TestName = N'TEST 05 - vPaymentsByOrder zgodny z Payments';
    DECLARE @oid4 int = (SELECT TOP 1 OrderID FROM dbo.Payments ORDER BY OrderID);

    IF @oid4 IS NULL
    BEGIN PRINT @TestName + N' => SKIPPED (brak Payments)'; SET @skip += 1; END
    ELSE
    BEGIN
        DECLARE @tSum decimal(18,2) =
            (SELECT COALESCE(SUM(CAST(Amount as decimal(18,2))),0) FROM dbo.Payments WHERE OrderID=@oid4);
        DECLARE @vSum decimal(18,2) =
            (SELECT TOP 1 COALESCE(PaidTotal,0) FROM dbo.vPaymentsByOrder WHERE OrderID=@oid4);

        IF ABS(@tSum - @vSum) < 0.01
        BEGIN PRINT @TestName + N' => PASS'; SET @pass += 1; END
        ELSE THROW 50005, 'vPaymentsByOrder niespójny.', 1;
    END
END TRY
BEGIN CATCH
    PRINT @TestName + N' => FAIL: ' + ERROR_MESSAGE(); SET @fail += 1;
END CATCH;

------------------------------------------------------------------------------------
-- TEST 06 - trg_Payments_Validate blokuje Amount<=0
------------------------------------------------------------------------------------
BEGIN TRY
    SET @TestName = N'TEST 06 - trg_Payments_Validate blokuje Amount<=0';
    DECLARE @oid5 int = (SELECT TOP 1 OrderID FROM dbo.Orders ORDER BY OrderID);
    DECLARE @taxid int = (SELECT TOP 1 TaxID FROM dbo.Taxes ORDER BY TaxID);

    IF @oid5 IS NULL OR @taxid IS NULL
    BEGIN PRINT @TestName + N' => SKIPPED (brak Orders/Taxes)'; SET @skip += 1; END
    ELSE
    BEGIN
        BEGIN TRAN;
        BEGIN TRY
            INSERT INTO dbo.Payments(PaymentID, TaxID, OrderID, Amount, PaymentDate)
            VALUES ((SELECT ISNULL(MAX(PaymentID),0)+1 FROM dbo.Payments),
                    @taxid, @oid5, 0, @Today);

            ROLLBACK;
            THROW 50006, 'Trigger nie zablokował Amount<=0.', 1;
        END TRY
        BEGIN CATCH
            ROLLBACK;
            PRINT @TestName + N' => PASS'; SET @pass += 1;
        END CATCH
    END
END TRY
BEGIN CATCH
    PRINT @TestName + N' => FAIL: ' + ERROR_MESSAGE(); SET @fail += 1;
END CATCH;

------------------------------------------------------------------------------------
-- TEST 07 - AddPayment tworzy płatność
------------------------------------------------------------------------------------
BEGIN TRY
    SET @TestName = N'TEST 07 - AddPayment tworzy płatność';
    DECLARE @oid6 int = (SELECT TOP 1 OrderID FROM dbo.Orders ORDER BY OrderID);
    DECLARE @taxid2 int = (SELECT TOP 1 TaxID FROM dbo.Taxes ORDER BY TaxID);

    IF @oid6 IS NULL OR @taxid2 IS NULL
    BEGIN PRINT @TestName + N' => SKIPPED (brak Orders/Taxes)'; SET @skip += 1; END
    ELSE
    BEGIN
        BEGIN TRAN;
        DECLARE @newPaymentID int;

        EXEC dbo.AddPayment
            @OrderID       = @oid6,
            @TaxID         = @taxid2,
            @Amount        = 1,
            @PaymentDate   = @Today,
            @NewPaymentID  = @newPaymentID OUTPUT;

        IF @newPaymentID IS NOT NULL AND EXISTS (SELECT 1 FROM dbo.Payments WHERE PaymentID=@newPaymentID)
        BEGIN ROLLBACK; PRINT @TestName + N' => PASS'; SET @pass += 1; END
        ELSE BEGIN ROLLBACK; THROW 50007, 'AddPayment nie dodała rekordu.', 1; END
    END
END TRY
BEGIN CATCH
    PRINT @TestName + N' => FAIL: ' + ERROR_MESSAGE(); SET @fail += 1;
END CATCH;

------------------------------------------------------------------------------------
-- TEST 08 - trg_Payments_Validate blokuje PaymentDate w przyszłości
------------------------------------------------------------------------------------
BEGIN TRY
    SET @TestName = N'TEST 08 - trg_Payments_Validate blokuje PaymentDate w przyszłości';
    DECLARE @oid7 int = (SELECT TOP 1 OrderID FROM dbo.Orders ORDER BY OrderID);
    DECLARE @taxid3 int = (SELECT TOP 1 TaxID FROM dbo.Taxes ORDER BY TaxID);

    IF @oid7 IS NULL OR @taxid3 IS NULL
    BEGIN
        PRINT @TestName + N' => SKIPPED (brak Orders/Taxes)';
        SET @skip += 1;
    END
    ELSE
    BEGIN
        BEGIN TRAN;
        BEGIN TRY
            DECLARE @futureDate date = DATEADD(DAY, 1, @Today);

            INSERT INTO dbo.Payments(PaymentID, TaxID, OrderID, Amount, PaymentDate)
            VALUES (
                (SELECT ISNULL(MAX(PaymentID),0)+1 FROM dbo.Payments),
                @taxid3,
                @oid7,
                1,
                @futureDate
            );

            IF @@TRANCOUNT > 0 ROLLBACK;
            THROW 50008, 'Trigger nie zablokował PaymentDate w przyszłości.', 1;
        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0 ROLLBACK;
            PRINT @TestName + N' => PASS';
            SET @pass += 1;
        END CATCH
    END
END TRY
BEGIN CATCH
    PRINT @TestName + N' => FAIL: ' + ERROR_MESSAGE();
    SET @fail += 1;
END CATCH;

------------------------------------------------------------------------------------
-- TEST 09 - trg_OrderDetails_Stock zmniejsza stock
------------------------------------------------------------------------------------
BEGIN TRY
    SET @TestName = N'TEST 09 - trg_OrderDetails_Stock zmniejsza stock';
    DECLARE @pid2 int = (SELECT TOP 1 ProductID FROM dbo.Products WHERE UnitsInStock >= 2 ORDER BY ProductID);
    DECLARE @oid8 int = (SELECT TOP 1 OrderID FROM dbo.Orders ORDER BY OrderID);

    IF @pid2 IS NULL OR @oid8 IS NULL
    BEGIN PRINT @TestName + N' => SKIPPED (brak produktu>=2 lub brak Orders)'; SET @skip += 1; END
    ELSE
    BEGIN
        BEGIN TRAN;
        DECLARE @before int = (SELECT UnitsInStock FROM dbo.Products WHERE ProductID=@pid2);

        INSERT INTO dbo.OrderDetails(OrderID, ProductID, UnitPrice, Quantity, Discount, QuantityFromStock)
        VALUES(@oid8, @pid2, (SELECT UnitPrice FROM dbo.Products WHERE ProductID=@pid2), 2, 0, 2);

        DECLARE @after int = (SELECT UnitsInStock FROM dbo.Products WHERE ProductID=@pid2);

        IF @after = @before - 2
        BEGIN ROLLBACK; PRINT @TestName + N' => PASS'; SET @pass += 1; END
        ELSE BEGIN ROLLBACK; THROW 50009, 'Stock nie został zmniejszony.', 1; END
    END
END TRY
BEGIN CATCH
    PRINT @TestName + N' => FAIL: ' + ERROR_MESSAGE(); SET @fail += 1;
END CATCH;

------------------------------------------------------------------------------------
-- TEST 10 - trg_OrderDetails_Stock blokuje ujemny stock
------------------------------------------------------------------------------------
BEGIN TRY
    SET @TestName = N'TEST 10 - trg_OrderDetails_Stock blokuje ujemny stock';
    DECLARE @pid3 int = (SELECT TOP 1 ProductID FROM dbo.Products ORDER BY ProductID);
    DECLARE @oid9 int = (SELECT TOP 1 OrderID FROM dbo.Orders ORDER BY OrderID);

    IF @pid3 IS NULL OR @oid9 IS NULL
    BEGIN PRINT @TestName + N' => SKIPPED (brak Products/Orders)'; SET @skip += 1; END
    ELSE
    BEGIN
        BEGIN TRAN;
        DECLARE @stock int = (SELECT UnitsInStock FROM dbo.Products WHERE ProductID=@pid3);

        BEGIN TRY
            INSERT INTO dbo.OrderDetails(OrderID, ProductID, UnitPrice, Quantity, Discount, QuantityFromStock)
            VALUES(@oid9, @pid3, (SELECT UnitPrice FROM dbo.Products WHERE ProductID=@pid3), 1, 0, @stock + 99999);

            ROLLBACK;
            THROW 50010, 'Trigger nie zablokował zejścia poniżej zera.', 1;
        END TRY
        BEGIN CATCH
            ROLLBACK;
            PRINT @TestName + N' => PASS'; SET @pass += 1;
        END CATCH
    END
END TRY
BEGIN CATCH
    PRINT @TestName + N' => FAIL: ' + ERROR_MESSAGE(); SET @fail += 1;
END CATCH;

------------------------------------------------------------------------------------
-- TEST 11 - ReceiveStock zwiększa UnitsInStock
------------------------------------------------------------------------------------
BEGIN TRY
    SET @TestName = N'TEST 11 - ReceiveStock zwiększa UnitsInStock';
    DECLARE @pid4 int = (SELECT TOP 1 ProductID FROM dbo.Products ORDER BY ProductID);

    IF @pid4 IS NULL
    BEGIN PRINT @TestName + N' => SKIPPED (brak Products)'; SET @skip += 1; END
    ELSE
    BEGIN
        BEGIN TRAN;
        DECLARE @before2 int = (SELECT UnitsInStock FROM dbo.Products WHERE ProductID=@pid4);

        EXEC dbo.ReceiveStock @ProductID=@pid4, @Quantity=5;

        DECLARE @after2 int = (SELECT UnitsInStock FROM dbo.Products WHERE ProductID=@pid4);

        IF @after2 = @before2 + 5
        BEGIN ROLLBACK; PRINT @TestName + N' => PASS'; SET @pass += 1; END
        ELSE BEGIN ROLLBACK; THROW 50011, 'ReceiveStock nie zwiększyło UnitsInStock.', 1; END
    END
END TRY
BEGIN CATCH
    PRINT @TestName + N' => FAIL: ' + ERROR_MESSAGE(); SET @fail += 1;
END CATCH;

------------------------------------------------------------------------------------
-- TEST 12 - PlaceOrder tworzy Orders+OrderDetails i zwraca NewOrderID
------------------------------------------------------------------------------------
BEGIN TRY
    SET @TestName = N'TEST 12 - PlaceOrder tworzy zamówienie i pozycje';
    DECLARE @eid int = (SELECT TOP 1 EmployeeID FROM dbo.Employees ORDER BY EmployeeID);
    DECLARE @cid int = (SELECT TOP 1 CustomerID FROM dbo.Customers ORDER BY CustomerID);
    DECLARE @sid int = (SELECT TOP 1 ShipperID FROM dbo.Shippers ORDER BY ShipperID);
    DECLARE @pid5 int = (SELECT TOP 1 ProductID FROM dbo.Products ORDER BY ProductID);

    IF @eid IS NULL OR @cid IS NULL OR @sid IS NULL OR @pid5 IS NULL
    BEGIN PRINT @TestName + N' => SKIPPED (brak danych ref)'; SET @skip += 1; END
    ELSE
    BEGIN
        BEGIN TRAN;

        DECLARE @items dbo.OrderItemType;
        INSERT INTO @items(ProductID, Quantity, UnitPrice, Discount)
        VALUES(@pid5, 1, NULL, NULL);

        DECLARE @newOrderID int;

        EXEC dbo.PlaceOrder
            @RequestedDeliveryDate = NULL,
            @EmployeeID            = @eid,
            @CustomerID            = @cid,
            @ShipperID             = @sid,
            @OrderDate             = @Today,
            @Freight               = 0,
            @Items                 = @items,
            @NewOrderID            = @newOrderID OUTPUT;

        IF @newOrderID IS NOT NULL
           AND EXISTS (SELECT 1 FROM dbo.Orders WHERE OrderID=@newOrderID)
           AND EXISTS (SELECT 1 FROM dbo.OrderDetails WHERE OrderID=@newOrderID AND ProductID=@pid5)
        BEGIN ROLLBACK; PRINT @TestName + N' => PASS'; SET @pass += 1; END
        ELSE BEGIN ROLLBACK; THROW 50012, 'PlaceOrder nie utworzyło Orders/OrderDetails.', 1; END
    END
END TRY
BEGIN CATCH
    PRINT @TestName + N' => FAIL: ' + ERROR_MESSAGE(); SET @fail += 1;
END CATCH;

------------------------------------------------------------------------------------
-- TEST 13 - PlaceOrder odrzuca RequestedDeliveryDate < OrderDate
------------------------------------------------------------------------------------
BEGIN TRY
    SET @TestName = N'TEST 13 - PlaceOrder odrzuca błędne daty';
    DECLARE @eid2 int = (SELECT TOP 1 EmployeeID FROM dbo.Employees ORDER BY EmployeeID);
    DECLARE @cid2 int = (SELECT TOP 1 CustomerID FROM dbo.Customers ORDER BY CustomerID);
    DECLARE @sid2 int = (SELECT TOP 1 ShipperID FROM dbo.Shippers ORDER BY ShipperID);
    DECLARE @pid6 int = (SELECT TOP 1 ProductID FROM dbo.Products ORDER BY ProductID);

    IF @eid2 IS NULL OR @cid2 IS NULL OR @sid2 IS NULL OR @pid6 IS NULL
    BEGIN PRINT @TestName + N' => SKIPPED (brak danych ref)'; SET @skip += 1; END
    ELSE
    BEGIN
        BEGIN TRAN;

        DECLARE @items2 dbo.OrderItemType;
        INSERT INTO @items2(ProductID, Quantity, UnitPrice, Discount)
        VALUES(@pid6, 1, NULL, NULL);

        BEGIN TRY
            DECLARE @newOrderID2 int;

            EXEC dbo.PlaceOrder
                @RequestedDeliveryDate = @Yesterday,
                @EmployeeID            = @eid2,
                @CustomerID            = @cid2,
                @ShipperID             = @sid2,
                @OrderDate             = @Today,
                @Freight               = 0,
                @Items                 = @items2,
                @NewOrderID            = @newOrderID2 OUTPUT;

            ROLLBACK;
            THROW 50013, 'PlaceOrder nie odrzuciło błędnej daty.', 1;
        END TRY
        BEGIN CATCH
            ROLLBACK;
            PRINT @TestName + N' => PASS'; SET @pass += 1;
        END CATCH
    END
END TRY
BEGIN CATCH
    PRINT @TestName + N' => FAIL: ' + ERROR_MESSAGE(); SET @fail += 1;
END CATCH;

------------------------------------------------------------------------------------
-- TEST 14 - ShipOrder ustawia ShipDate
------------------------------------------------------------------------------------
BEGIN TRY
    SET @TestName = N'TEST 14 - ShipOrder ustawia ShipDate';
    DECLARE @oid10 int = (SELECT TOP 1 OrderID FROM dbo.Orders ORDER BY OrderID);

    IF @oid10 IS NULL
    BEGIN PRINT @TestName + N' => SKIPPED (brak Orders)'; SET @skip += 1; END
    ELSE
    BEGIN
        BEGIN TRAN;

        UPDATE dbo.Orders SET ShipDate=NULL WHERE OrderID=@oid10;

        EXEC dbo.ShipOrder
            @OrderID  = @oid10,
            @ShipDate = @Today;

        IF (SELECT ShipDate FROM dbo.Orders WHERE OrderID=@oid10) = @Today
        BEGIN ROLLBACK; PRINT @TestName + N' => PASS'; SET @pass += 1; END
        ELSE BEGIN ROLLBACK; THROW 50014, 'ShipOrder nie ustawił ShipDate.', 1; END
    END
END TRY
BEGIN CATCH
    PRINT @TestName + N' => FAIL: ' + ERROR_MESSAGE(); SET @fail += 1;
END CATCH;

------------------------------------------------------------------------------------
-- TEST 15 - vProductUnitCost: TotalCost = suma składowych
------------------------------------------------------------------------------------
BEGIN TRY
    SET @TestName = N'TEST 15 - vProductUnitCost spójny (TotalCost = suma)';
    DECLARE @pid7 int = (SELECT TOP 1 ProductID FROM dbo.vProductUnitCost ORDER BY ProductID);

    IF @pid7 IS NULL
    BEGIN PRINT @TestName + N' => SKIPPED (brak vProductUnitCost)'; SET @skip += 1; END
    ELSE
    BEGIN
        DECLARE @mc decimal(18,2), @pc decimal(18,2), @pr decimal(18,2), @tc decimal(18,2);
        SELECT TOP 1
            @mc=CAST(MaterialsCost as decimal(18,2)),
            @pc=CAST(PartsCost as decimal(18,2)),
            @pr=CAST(ProductionCost as decimal(18,2)),
            @tc=CAST(TotalCost as decimal(18,2))
        FROM dbo.vProductUnitCost WHERE ProductID=@pid7;

        IF ABS((ISNULL(@mc,0)+ISNULL(@pc,0)+ISNULL(@pr,0)) - ISNULL(@tc,0)) < 0.01
        BEGIN PRINT @TestName + N' => PASS'; SET @pass += 1; END
        ELSE THROW 50015, 'vProductUnitCost: TotalCost niespójny.', 1;
    END
END TRY
BEGIN CATCH
    PRINT @TestName + N' => FAIL: ' + ERROR_MESSAGE(); SET @fail += 1;
END CATCH;

------------------------------------------------------------------------------------
-- TEST 16 - trg_Products_MinPrice blokuje UnitPrice < TotalCost
------------------------------------------------------------------------------------
BEGIN TRY
    SET @TestName = N'TEST 16 - trg_Products_MinPrice blokuje UnitPrice < TotalCost';
    DECLARE @pid8 int = (SELECT TOP 1 ProductID FROM dbo.vProductUnitCost ORDER BY ProductID);

    IF @pid8 IS NULL
    BEGIN PRINT @TestName + N' => SKIPPED (brak vProductUnitCost)'; SET @skip += 1; END
    ELSE
    BEGIN
        DECLARE @totalCost int = (SELECT TOP 1 CAST(TotalCost as int) FROM dbo.vProductUnitCost WHERE ProductID=@pid8);

        BEGIN TRAN;
        BEGIN TRY
            UPDATE dbo.Products SET UnitPrice = @totalCost - 1 WHERE ProductID=@pid8;
            ROLLBACK;
            THROW 50016, 'Trigger nie zablokował ceny.', 1;
        END TRY
        BEGIN CATCH
            ROLLBACK;
            PRINT @TestName + N' => PASS'; SET @pass += 1;
        END CATCH
    END
END TRY
BEGIN CATCH
    PRINT @TestName + N' => FAIL: ' + ERROR_MESSAGE(); SET @fail += 1;
END CATCH;

------------------------------------------------------------------------------------
-- TEST 17 - trg_Refunds_Approve: approve zwiększa stock
------------------------------------------------------------------------------------
BEGIN TRY
    SET @TestName = N'TEST 17 - trg_Refunds_Approve zwiększa stock po approve';
    DECLARE @rid int = (SELECT TOP 1 RefundID FROM dbo.Refunds WHERE RefundApproved=0 ORDER BY RefundID);

    IF @rid IS NULL
    BEGIN PRINT @TestName + N' => SKIPPED (brak niezatwierdzonych Refunds)'; SET @skip += 1; END
    ELSE
    BEGIN
        DECLARE @rpid int, @rqty int;
        SELECT @rpid=ProductID, @rqty=Quantity FROM dbo.Refunds WHERE RefundID=@rid;

        IF @rpid IS NULL
        BEGIN PRINT @TestName + N' => SKIPPED (Refund bez ProductID)'; SET @skip += 1; END
        ELSE
        BEGIN
            BEGIN TRAN;
            DECLARE @before3 int = (SELECT UnitsInStock FROM dbo.Products WHERE ProductID=@rpid);

            UPDATE dbo.Refunds SET RefundApproved=1 WHERE RefundID=@rid;

            DECLARE @after3 int = (SELECT UnitsInStock FROM dbo.Products WHERE ProductID=@rpid);

            IF @after3 = @before3 + ISNULL(@rqty,0)
            BEGIN ROLLBACK; PRINT @TestName + N' => PASS'; SET @pass += 1; END
            ELSE BEGIN ROLLBACK; THROW 50017, 'Stock nie wzrósł po approve.', 1; END
        END
    END
END TRY
BEGIN CATCH
    PRINT @TestName + N' => FAIL: ' + ERROR_MESSAGE(); SET @fail += 1;
END CATCH;

------------------------------------------------------------------------------------
-- TEST 18 - trg_Refunds_Approve blokuje refund > zakup
------------------------------------------------------------------------------------
BEGIN TRY
    SET @TestName = N'TEST 18 - trg_Refunds_Approve blokuje zwrot > zakup';
    DECLARE @rid2 int = (SELECT TOP 1 RefundID FROM dbo.Refunds WHERE RefundApproved=0 ORDER BY RefundID);

    IF @rid2 IS NULL
    BEGIN PRINT @TestName + N' => SKIPPED (brak niezatwierdzonych Refunds)'; SET @skip += 1; END
    ELSE
    BEGIN
        DECLARE @roid int, @rpid2 int;
        SELECT @roid=OrderID, @rpid2=ProductID FROM dbo.Refunds WHERE RefundID=@rid2;

        DECLARE @purchased int =
        (
            SELECT COALESCE(SUM(CAST(od.Quantity as int)),0)
            FROM dbo.OrderDetails od
            WHERE od.OrderID=@roid AND od.ProductID=@rpid2
        );

        IF @purchased = 0
        BEGIN PRINT @TestName + N' => SKIPPED (brak zakupów dla refundu)'; SET @skip += 1; END
        ELSE
        BEGIN
            BEGIN TRAN;

            UPDATE dbo.Refunds SET Quantity = @purchased + 9999 WHERE RefundID=@rid2;

            BEGIN TRY
                UPDATE dbo.Refunds SET RefundApproved=1 WHERE RefundID=@rid2;

                ROLLBACK;
                THROW 50018, 'Trigger nie zablokował nadmiarowego zwrotu.', 1;
            END TRY
            BEGIN CATCH
                ROLLBACK;
                PRINT @TestName + N' => PASS'; SET @pass += 1;
            END CATCH
        END
    END
END TRY
BEGIN CATCH
    PRINT @TestName + N' => FAIL: ' + ERROR_MESSAGE(); SET @fail += 1;
END CATCH;

------------------------------------------------------------------------------------
-- TEST 19 - ApproveRefund zatwierdza zwrot i stock rośnie
------------------------------------------------------------------------------------
BEGIN TRY
    SET @TestName = N'TEST 19 - ApproveRefund zatwierdza zwrot + stock';
    DECLARE @rid3 int = (SELECT TOP 1 RefundID FROM dbo.Refunds WHERE RefundApproved=0 ORDER BY RefundID);

    IF @rid3 IS NULL
    BEGIN PRINT @TestName + N' => SKIPPED (brak niezatwierdzonych Refunds)'; SET @skip += 1; END
    ELSE
    BEGIN
        DECLARE @rpid3 int, @rqty3 int;
        SELECT @rpid3=ProductID, @rqty3=Quantity FROM dbo.Refunds WHERE RefundID=@rid3;

        IF @rpid3 IS NULL
        BEGIN PRINT @TestName + N' => SKIPPED (Refund bez ProductID)'; SET @skip += 1; END
        ELSE
        BEGIN
            BEGIN TRAN;

            DECLARE @before4 int = (SELECT UnitsInStock FROM dbo.Products WHERE ProductID=@rpid3);

            EXEC dbo.ApproveRefund @RefundID=@rid3;

            DECLARE @approved bit = (SELECT RefundApproved FROM dbo.Refunds WHERE RefundID=@rid3);
            DECLARE @after4 int = (SELECT UnitsInStock FROM dbo.Products WHERE ProductID=@rpid3);

            IF @approved=1 AND @after4 = @before4 + ISNULL(@rqty3,0)
            BEGIN ROLLBACK; PRINT @TestName + N' => PASS'; SET @pass += 1; END
            ELSE BEGIN ROLLBACK; THROW 50019, 'ApproveRefund nie zadziałał (approve/stock).', 1; END
        END
    END
END TRY
BEGIN CATCH
    PRINT @TestName + N' => FAIL: ' + ERROR_MESSAGE(); SET @fail += 1;
END CATCH;

------------------------------------------------------------------------------------
-- TEST 20 - Widoki raportowe SELECT TOP 1 (smoke)
------------------------------------------------------------------------------------
BEGIN TRY
    SET @TestName = N'TEST 20 - Widoki raportowe SELECT TOP 1 (smoke test)';

    SELECT TOP 1 * FROM dbo.vSales_ByCategory_Week;
    SELECT TOP 1 * FROM dbo.vSales_ByCategory_Month;
    SELECT TOP 1 * FROM dbo.vProductionCosts_ByCategory_Month;
    SELECT TOP 1 * FROM dbo.vProductionCosts_ByCategory_Quarter;
    SELECT TOP 1 * FROM dbo.vProductionCosts_ByCategory_Year;

    PRINT @TestName + N' => PASS';
    SET @pass += 1;
END TRY
BEGIN CATCH
    PRINT @TestName + N' => FAIL: ' + ERROR_MESSAGE();
    SET @fail += 1;
END CATCH;

PRINT '==================== PODSUMOWANIE ====================';
PRINT 'PASS: ' + CAST(@pass as varchar(20));
PRINT 'FAIL: ' + CAST(@fail as varchar(20));
PRINT 'SKIP: ' + CAST(@skip as varchar(20));
PRINT '======================================================';
