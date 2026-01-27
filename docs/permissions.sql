DECLARE @RoleName sysname
set @RoleName = N'role_admin'

IF @RoleName <> N'public' and (select is_fixed_role from sys.database_principals where name = @RoleName) = 0
BEGIN
    DECLARE @RoleMemberName sysname
    DECLARE Member_Cursor CURSOR FOR
    select [name]
    from sys.database_principals 
    where principal_id in ( 
        select member_principal_id
        from sys.database_role_members
        where role_principal_id in (
            select principal_id
            FROM sys.database_principals where [name] = @RoleName AND type = 'R'))

    OPEN Member_Cursor;

    FETCH NEXT FROM Member_Cursor
    into @RoleMemberName
    
    DECLARE @SQL NVARCHAR(4000)

    WHILE @@FETCH_STATUS = 0
    BEGIN
        
        SET @SQL = 'ALTER ROLE '+ QUOTENAME(@RoleName,'[') +' DROP MEMBER '+ QUOTENAME(@RoleMemberName,'[')
        EXEC(@SQL)
        
        FETCH NEXT FROM Member_Cursor
        into @RoleMemberName
    END;

    CLOSE Member_Cursor;
    DEALLOCATE Member_Cursor;
END
DROP ROLE [role_admin]

GO

DECLARE @RoleName sysname
set @RoleName = N'role_production'

IF @RoleName <> N'public' and (select is_fixed_role from sys.database_principals where name = @RoleName) = 0
BEGIN
    DECLARE @RoleMemberName sysname
    DECLARE Member_Cursor CURSOR FOR
    select [name]
    from sys.database_principals 
    where principal_id in ( 
        select member_principal_id
        from sys.database_role_members
        where role_principal_id in (
            select principal_id
            FROM sys.database_principals where [name] = @RoleName AND type = 'R'))

    OPEN Member_Cursor;

    FETCH NEXT FROM Member_Cursor
    into @RoleMemberName
    
    DECLARE @SQL NVARCHAR(4000)

    WHILE @@FETCH_STATUS = 0
    BEGIN
        
        SET @SQL = 'ALTER ROLE '+ QUOTENAME(@RoleName,'[') +' DROP MEMBER '+ QUOTENAME(@RoleMemberName,'[')
        EXEC(@SQL)
        
        FETCH NEXT FROM Member_Cursor
        into @RoleMemberName
    END;

    CLOSE Member_Cursor;
    DEALLOCATE Member_Cursor;
END

DROP ROLE [role_production]

GO

DECLARE @RoleName sysname
set @RoleName = N'role_reporting'

IF @RoleName <> N'public' and (select is_fixed_role from sys.database_principals where name = @RoleName) = 0
BEGIN
    DECLARE @RoleMemberName sysname
    DECLARE Member_Cursor CURSOR FOR
    select [name]
    from sys.database_principals 
    where principal_id in ( 
        select member_principal_id
        from sys.database_role_members
        where role_principal_id in (
            select principal_id
            FROM sys.database_principals where [name] = @RoleName AND type = 'R'))

    OPEN Member_Cursor;

    FETCH NEXT FROM Member_Cursor
    into @RoleMemberName
    
    DECLARE @SQL NVARCHAR(4000)

    WHILE @@FETCH_STATUS = 0
    BEGIN
        
        SET @SQL = 'ALTER ROLE '+ QUOTENAME(@RoleName,'[') +' DROP MEMBER '+ QUOTENAME(@RoleMemberName,'[')
        EXEC(@SQL)
        
        FETCH NEXT FROM Member_Cursor
        into @RoleMemberName
    END;

    CLOSE Member_Cursor;
    DEALLOCATE Member_Cursor;
END

DROP ROLE [role_reporting]

GO

DECLARE @RoleName sysname
set @RoleName = N'role_sales'

IF @RoleName <> N'public' and (select is_fixed_role from sys.database_principals where name = @RoleName) = 0
BEGIN
    DECLARE @RoleMemberName sysname
    DECLARE Member_Cursor CURSOR FOR
    select [name]
    from sys.database_principals 
    where principal_id in ( 
        select member_principal_id
        from sys.database_role_members
        where role_principal_id in (
            select principal_id
            FROM sys.database_principals where [name] = @RoleName AND type = 'R'))

    OPEN Member_Cursor;

    FETCH NEXT FROM Member_Cursor
    into @RoleMemberName
    
    DECLARE @SQL NVARCHAR(4000)

    WHILE @@FETCH_STATUS = 0
    BEGIN
        
        SET @SQL = 'ALTER ROLE '+ QUOTENAME(@RoleName,'[') +' DROP MEMBER '+ QUOTENAME(@RoleMemberName,'[')
        EXEC(@SQL)
        
        FETCH NEXT FROM Member_Cursor
        into @RoleMemberName
    END;

    CLOSE Member_Cursor;
    DEALLOCATE Member_Cursor;
END

DROP ROLE [role_sales]

GO

ALTER AUTHORIZATION ON DATABASE::[u_micnowak] TO [u_micnowak]

GO

CREATE USER [test_reporting] WITHOUT LOGIN WITH DEFAULT_SCHEMA=[dbo]

GO

CREATE ROLE [role_sales]

GO

CREATE ROLE [role_reporting]

GO

CREATE ROLE [role_production]

GO

CREATE ROLE [role_admin]

GO

ALTER AUTHORIZATION ON ROLE::[role_sales] TO [dbo]

GO

ALTER AUTHORIZATION ON ROLE::[role_reporting] TO [dbo]

GO

ALTER AUTHORIZATION ON ROLE::[role_production] TO [dbo]

GO

ALTER AUTHORIZATION ON ROLE::[role_admin] TO [dbo]

GO

ALTER ROLE [role_reporting] ADD MEMBER [test_reporting]

GO

GRANT VIEW ANY COLUMN ENCRYPTION KEY DEFINITION TO [public] AS [dbo]

GO

GRANT VIEW ANY COLUMN MASTER KEY DEFINITION TO [public] AS [dbo]

GO

GRANT CONTROL TO [role_admin] AS [dbo]

GO

GRANT CONNECT TO [test_reporting] AS [dbo]

GO

ALTER AUTHORIZATION ON TYPE::[dbo].[OrderItemType] TO  SCHEMA OWNER

GO

ALTER AUTHORIZATION ON [dbo].[AvailableStock] TO  SCHEMA OWNER

GO

GRANT EXECUTE ON [dbo].[AvailableStock] TO [role_reporting] AS [dbo]

GO

ALTER AUTHORIZATION ON [dbo].[CalculateMaterialCostForProduct] TO  SCHEMA OWNER

GO

ALTER AUTHORIZATION ON [dbo].[CalculatePartCostForProduct] TO  SCHEMA OWNER

GO

ALTER AUTHORIZATION ON [dbo].[CalculateProductionCost] TO  SCHEMA OWNER

GO

ALTER AUTHORIZATION ON [dbo].[GetBestSupplierForMaterial] TO  SCHEMA OWNER

GO

ALTER AUTHORIZATION ON [dbo].[GetBestSupplierForPart] TO  SCHEMA OWNER

GO

ALTER AUTHORIZATION ON [dbo].[OrderDiscount] TO  SCHEMA OWNER

GO

GRANT EXECUTE ON [dbo].[OrderDiscount] TO [role_reporting] AS [dbo]

GO

ALTER AUTHORIZATION ON [dbo].[OrderSubtotal] TO  SCHEMA OWNER

GO

GRANT EXECUTE ON [dbo].[OrderSubtotal] TO [role_reporting] AS [dbo]

GO

ALTER AUTHORIZATION ON [dbo].[OrderTax] TO  SCHEMA OWNER

GO

GRANT EXECUTE ON [dbo].[OrderTax] TO [role_reporting] AS [dbo]

GO

ALTER AUTHORIZATION ON [dbo].[OrderTotal] TO  SCHEMA OWNER

GO

GRANT EXECUTE ON [dbo].[OrderTotal] TO [role_reporting] AS [dbo]

GO

ALTER AUTHORIZATION ON [dbo].[Orders] TO  SCHEMA OWNER

GO

GRANT SELECT ON [dbo].[Orders] TO [role_sales] AS [dbo]

GO

ALTER AUTHORIZATION ON [dbo].[Customers] TO  SCHEMA OWNER

GO

GRANT SELECT ON [dbo].[Customers] TO [role_sales] AS [dbo]

GO

ALTER AUTHORIZATION ON [dbo].[Payments] TO  SCHEMA OWNER

GO

GRANT SELECT ON [dbo].[Payments] TO [role_sales] AS [dbo]

GO

ALTER AUTHORIZATION ON [dbo].[Taxes] TO  SCHEMA OWNER

GO

GRANT SELECT ON [dbo].[Taxes] TO [role_sales] AS [dbo]

GO

ALTER AUTHORIZATION ON [dbo].[vPaymentsByOrder] TO  SCHEMA OWNER

GO

ALTER AUTHORIZATION ON [dbo].[MaterialSuppliers] TO  SCHEMA OWNER

GO

GRANT SELECT ON [dbo].[MaterialSuppliers] TO [role_production] AS [dbo]

GO

ALTER AUTHORIZATION ON [dbo].[PartSuppliers] TO  SCHEMA OWNER

GO

GRANT SELECT ON [dbo].[PartSuppliers] TO [role_production] AS [dbo]

GO

ALTER AUTHORIZATION ON [dbo].[Suppliers] TO  SCHEMA OWNER

GO

GRANT SELECT ON [dbo].[Suppliers] TO [role_production] AS [dbo]

GO

ALTER AUTHORIZATION ON [dbo].[vSupplierPriceList] TO  SCHEMA OWNER

GO

ALTER AUTHORIZATION ON [dbo].[Categories] TO  SCHEMA OWNER

GO

GRANT SELECT ON [dbo].[Categories] TO [role_production] AS [dbo]

GO

GRANT SELECT ON [dbo].[Categories] TO [role_sales] AS [dbo]

GO

ALTER AUTHORIZATION ON [dbo].[FactoriesAndCategories] TO  SCHEMA OWNER

GO

GRANT SELECT ON [dbo].[FactoriesAndCategories] TO [role_production] AS [dbo]

GO

ALTER AUTHORIZATION ON [dbo].[Factories] TO  SCHEMA OWNER

GO

GRANT SELECT ON [dbo].[Factories] TO [role_production] AS [dbo]

GO

ALTER AUTHORIZATION ON [dbo].[vFactoriesCategories] TO  SCHEMA OWNER

GO

ALTER AUTHORIZATION ON [dbo].[Products] TO  SCHEMA OWNER

GO

GRANT SELECT ON [dbo].[Products] TO [role_production] AS [dbo]

GO

GRANT SELECT ON [dbo].[Products] TO [role_sales] AS [dbo]

GO

ALTER AUTHORIZATION ON [dbo].[MaterialsForOneUnit] TO  SCHEMA OWNER

GO

GRANT SELECT ON [dbo].[MaterialsForOneUnit] TO [role_production] AS [dbo]

GO

ALTER AUTHORIZATION ON [dbo].[PartsForOneUnit] TO  SCHEMA OWNER

GO

GRANT SELECT ON [dbo].[PartsForOneUnit] TO [role_production] AS [dbo]

GO

ALTER AUTHORIZATION ON [dbo].[vProductUnitCost] TO  SCHEMA OWNER

GO

GRANT SELECT ON [dbo].[vProductUnitCost] TO [role_reporting] AS [dbo]

GO

ALTER AUTHORIZATION ON [dbo].[OrderDetails] TO  SCHEMA OWNER

GO

GRANT SELECT ON [dbo].[OrderDetails] TO [role_sales] AS [dbo]

GO

ALTER AUTHORIZATION ON [dbo].[vSalesLines] TO  SCHEMA OWNER

GO

GRANT SELECT ON [dbo].[vSalesLines] TO [role_reporting] AS [dbo]

GO

GRANT SELECT ON [dbo].[vSalesLines] TO [role_sales] AS [dbo]

GO

ALTER AUTHORIZATION ON [dbo].[ProductionOrders] TO  SCHEMA OWNER

GO

GRANT SELECT ON [dbo].[ProductionOrders] TO [role_production] AS [dbo]

GO

ALTER AUTHORIZATION ON [dbo].[vProductionCosts_ByCategory_Month] TO  SCHEMA OWNER

GO

GRANT SELECT ON [dbo].[vProductionCosts_ByCategory_Month] TO [role_reporting] AS [dbo]

GO

ALTER AUTHORIZATION ON [dbo].[vProductionCosts_ByCategory_Quarter] TO  SCHEMA OWNER

GO

GRANT SELECT ON [dbo].[vProductionCosts_ByCategory_Quarter] TO [role_reporting] AS [dbo]

GO

ALTER AUTHORIZATION ON [dbo].[vProductionCosts_ByCategory_Year] TO  SCHEMA OWNER

GO

GRANT SELECT ON [dbo].[vProductionCosts_ByCategory_Year] TO [role_reporting] AS [dbo]

GO

ALTER AUTHORIZATION ON [dbo].[vSales_ByCategory_Week] TO  SCHEMA OWNER

GO

GRANT SELECT ON [dbo].[vSales_ByCategory_Week] TO [role_reporting] AS [dbo]

GO

GRANT SELECT ON [dbo].[vSales_ByCategory_Week] TO [role_sales] AS [dbo]

GO

ALTER AUTHORIZATION ON [dbo].[vSales_ByCategory_Month] TO  SCHEMA OWNER

GO

GRANT SELECT ON [dbo].[vSales_ByCategory_Month] TO [role_reporting] AS [dbo]

GO

GRANT SELECT ON [dbo].[vSales_ByCategory_Month] TO [role_sales] AS [dbo]

GO

ALTER AUTHORIZATION ON [dbo].[vInventory_Status] TO  SCHEMA OWNER

GO

GRANT SELECT ON [dbo].[vInventory_Status] TO [role_production] AS [dbo]

GO

GRANT SELECT ON [dbo].[vInventory_Status] TO [role_reporting] AS [dbo]

GO

ALTER AUTHORIZATION ON [dbo].[vProductionPlan_Orders] TO  SCHEMA OWNER

GO

GRANT SELECT ON [dbo].[vProductionPlan_Orders] TO [role_production] AS [dbo]

GO

GRANT SELECT ON [dbo].[vProductionPlan_Orders] TO [role_reporting] AS [dbo]

GO

ALTER AUTHORIZATION ON [dbo].[FactoryCapacityCalendar] TO  SCHEMA OWNER

GO

GRANT SELECT ON [dbo].[FactoryCapacityCalendar] TO [role_production] AS [dbo]

GO

ALTER AUTHORIZATION ON [dbo].[FactoryCapacityReservations] TO  SCHEMA OWNER

GO

GRANT SELECT ON [dbo].[FactoryCapacityReservations] TO [role_production] AS [dbo]

GO

ALTER AUTHORIZATION ON [dbo].[vProductionPlan_FactoryDailyLoad] TO  SCHEMA OWNER

GO

GRANT SELECT ON [dbo].[vProductionPlan_FactoryDailyLoad] TO [role_production] AS [dbo]

GO

GRANT SELECT ON [dbo].[vProductionPlan_FactoryDailyLoad] TO [role_reporting] AS [dbo]

GO

ALTER AUTHORIZATION ON [dbo].[vLowStockProducts] TO  SCHEMA OWNER

GO

GRANT SELECT ON [dbo].[vLowStockProducts] TO [role_production] AS [dbo]

GO

GRANT SELECT ON [dbo].[vLowStockProducts] TO [role_reporting] AS [dbo]

GO

ALTER AUTHORIZATION ON [dbo].[Refunds] TO  SCHEMA OWNER

GO

GRANT SELECT ON [dbo].[Refunds] TO [role_sales] AS [dbo]

GO

ALTER AUTHORIZATION ON [dbo].[vRefundsWithOrderInfo] TO  SCHEMA OWNER

GO

ALTER AUTHORIZATION ON [dbo].[vProductBOM] TO  SCHEMA OWNER

GO

ALTER AUTHORIZATION ON [dbo].[Shippers] TO  SCHEMA OWNER

GO

GRANT SELECT ON [dbo].[Shippers] TO [role_sales] AS [dbo]

GO

ALTER AUTHORIZATION ON [dbo].[Employees] TO  SCHEMA OWNER

GO

GRANT SELECT ON [dbo].[Employees] TO [role_production] AS [dbo]

GO

ALTER AUTHORIZATION ON [dbo].[vOrderSummary] TO  SCHEMA OWNER

GO

GRANT SELECT ON [dbo].[vOrderSummary] TO [role_reporting] AS [dbo]

GO

GRANT SELECT ON [dbo].[vOrderSummary] TO [role_sales] AS [dbo]

GO

ALTER AUTHORIZATION ON [dbo].[Materials] TO  SCHEMA OWNER

GO

GRANT SELECT ON [dbo].[Materials] TO [role_production] AS [dbo]

GO

ALTER AUTHORIZATION ON [dbo].[Occupation] TO  SCHEMA OWNER

GO

GRANT SELECT ON [dbo].[Occupation] TO [role_production] AS [dbo]

GO

ALTER AUTHORIZATION ON [dbo].[Parts] TO  SCHEMA OWNER

GO

GRANT SELECT ON [dbo].[Parts] TO [role_production] AS [dbo]

GO

ALTER AUTHORIZATION ON [dbo].[ProductProductionSpec] TO  SCHEMA OWNER

GO

GRANT SELECT ON [dbo].[ProductProductionSpec] TO [role_production] AS [dbo]

GO

ALTER AUTHORIZATION ON [dbo].[AddPayment] TO  SCHEMA OWNER

GO

GRANT EXECUTE ON [dbo].[AddPayment] TO [role_sales] AS [dbo]

GO

ALTER AUTHORIZATION ON [dbo].[ApproveRefund] TO  SCHEMA OWNER

GO

GRANT EXECUTE ON [dbo].[ApproveRefund] TO [role_sales] AS [dbo]

GO

ALTER AUTHORIZATION ON [dbo].[PlaceOrder] TO  SCHEMA OWNER

GO

GRANT EXECUTE ON [dbo].[PlaceOrder] TO [role_sales] AS [dbo]

GO

ALTER AUTHORIZATION ON [dbo].[ReceiveStock] TO  SCHEMA OWNER

GO

GRANT EXECUTE ON [dbo].[ReceiveStock] TO [role_production] AS [dbo]

GO

ALTER AUTHORIZATION ON [dbo].[ScheduleProductionOrder] TO  SCHEMA OWNER

GO

GRANT EXECUTE ON [dbo].[ScheduleProductionOrder] TO [role_production] AS [dbo]

GO

ALTER AUTHORIZATION ON [dbo].[SeedFactoryCapacityCalendar] TO  SCHEMA OWNER

GO

GRANT EXECUTE ON [dbo].[SeedFactoryCapacityCalendar] TO [role_production] AS [dbo]

GO

ALTER AUTHORIZATION ON [dbo].[ShipOrder] TO  SCHEMA OWNER

GO

GRANT EXECUTE ON [dbo].[ShipOrder] TO [role_sales] AS [dbo]