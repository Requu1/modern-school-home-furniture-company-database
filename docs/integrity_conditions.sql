ALTER TABLE [dbo].[ProductProductionSpec] DROP CONSTRAINT [CK_ProductProductionSpec_HoursPerUnit]

GO

ALTER TABLE [dbo].[ProductionOrders] DROP CONSTRAINT [CK_ProductionOrders_Status]

GO

ALTER TABLE [dbo].[ProductionOrders] DROP CONSTRAINT [CK_ProductionOrders_Quantity]

GO

ALTER TABLE [dbo].[ProductionOrders] DROP CONSTRAINT [CK_ProductionOrders_Priority]

GO

ALTER TABLE [dbo].[ProductionOrders] DROP CONSTRAINT [CK_ProductionOrders_Dates]

GO

ALTER TABLE [dbo].[OrderDetails] DROP CONSTRAINT [CK_OrderDetails_QuantityFromStock]

GO

ALTER TABLE [dbo].[FactoryCapacityReservations] DROP CONSTRAINT [CK_FactoryCapacityReservations_Reserved]

GO

ALTER TABLE [dbo].[FactoryCapacityCalendar] DROP CONSTRAINT [CK_FactoryCapacityCalendar_Capacity]

GO

ALTER TABLE [dbo].[Refunds] DROP CONSTRAINT [FK_Refunds_Products]

GO

ALTER TABLE [dbo].[Refunds] DROP CONSTRAINT [FK_Refunds_Orders]

GO

ALTER TABLE [dbo].[Products] DROP CONSTRAINT [FK_Products_Categories]

GO

ALTER TABLE [dbo].[ProductProductionSpec] DROP CONSTRAINT [FK_ProductProductionSpec_Products]

GO

ALTER TABLE [dbo].[ProductionOrders] DROP CONSTRAINT [FK_ProductionOrders_Products]

GO

ALTER TABLE [dbo].[ProductionOrders] DROP CONSTRAINT [FK_ProductionOrders_Orders]

GO

ALTER TABLE [dbo].[ProductionOrders] DROP CONSTRAINT [FK_ProductionOrders_Factories]

GO

ALTER TABLE [dbo].[Payments] DROP CONSTRAINT [FK_Payments_Taxes]

GO

ALTER TABLE [dbo].[Payments] DROP CONSTRAINT [FK_Payments_Orders]

GO

ALTER TABLE [dbo].[PartSuppliers] DROP CONSTRAINT [FK_PartSuppliers_Suppliers]

GO

ALTER TABLE [dbo].[PartSuppliers] DROP CONSTRAINT [FK_PartSuppliers_Parts]

GO

ALTER TABLE [dbo].[PartsForOneUnit] DROP CONSTRAINT [FK_PartsForOneUnit_Products]

GO

ALTER TABLE [dbo].[PartsForOneUnit] DROP CONSTRAINT [FK_PartsForOneUnit_Parts]

GO

ALTER TABLE [dbo].[Orders] DROP CONSTRAINT [FK_Orders_Shippers]

GO

ALTER TABLE [dbo].[Orders] DROP CONSTRAINT [FK_Orders_Employees]

GO

ALTER TABLE [dbo].[Orders] DROP CONSTRAINT [FK_Orders_Customers]

GO

ALTER TABLE [dbo].[OrderDetails] DROP CONSTRAINT [FK_OrderDetails_Products]

GO

ALTER TABLE [dbo].[OrderDetails] DROP CONSTRAINT [FK_OrderDetails_Orders]

GO

ALTER TABLE [dbo].[MaterialSuppliers] DROP CONSTRAINT [FK_MaterialSuppliers_Suppliers]

GO

ALTER TABLE [dbo].[MaterialSuppliers] DROP CONSTRAINT [FK_MaterialSuppliers_Materials]

GO

ALTER TABLE [dbo].[MaterialsForOneUnit] DROP CONSTRAINT [FK_MaterialsForOneUnit_Products]

GO

ALTER TABLE [dbo].[MaterialsForOneUnit] DROP CONSTRAINT [FK_MaterialsForOneUnit_Materials]

GO

ALTER TABLE [dbo].[FactoryCapacityReservations] DROP CONSTRAINT [FK_FactoryCapacityReservations_ProductionOrders]

GO

ALTER TABLE [dbo].[FactoryCapacityReservations] DROP CONSTRAINT [FK_FactoryCapacityReservations_Factories]

GO

ALTER TABLE [dbo].[FactoryCapacityReservations] DROP CONSTRAINT [FK_FactoryCapacityReservations_Calendar]

GO

ALTER TABLE [dbo].[FactoryCapacityCalendar] DROP CONSTRAINT [FK_FactoryCapacityCalendar_Factories]

GO

ALTER TABLE [dbo].[FactoriesAndCategories] DROP CONSTRAINT [FK_FactoriesAndCategories_Factories]

GO

ALTER TABLE [dbo].[FactoriesAndCategories] DROP CONSTRAINT [FK_FactoriesAndCategories_Categories]

GO

ALTER TABLE [dbo].[Employees] DROP CONSTRAINT [FK_Employees_Occupation]

GO

ALTER TABLE [dbo].[Employees] DROP CONSTRAINT [FK_Employees_Factories]

GO

ALTER TABLE [dbo].[ProductionOrders] DROP CONSTRAINT [DF__Productio__Prior__2FCF1A8A]

GO

ALTER TABLE [dbo].[ProductionOrders] DROP CONSTRAINT [DF__Productio__Statu__2EDAF651]

GO

ALTER TABLE [dbo].[ProductionOrders] DROP CONSTRAINT [DF__Productio__Creat__2DE6D218]

GO

ALTER TABLE [dbo].[OrderDetails] DROP CONSTRAINT [DF_OrderDetails_QuantityFromStock]

GO

CREATE TABLE [dbo].[Orders](
	[OrderID] [int] NOT NULL,
	[EmployeeID] [int] NOT NULL,
	[CustomerID] [int] NOT NULL,
	[ShipperID] [int] NOT NULL,
	[OrderDate] [date] NOT NULL,
	[ShipDate] [date] NULL,
	[Freight] [int] NOT NULL,
	[RequestedDeliveryDate] [date] NOT NULL,
 CONSTRAINT [PK_Orders] PRIMARY KEY CLUSTERED 
(
	[OrderID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[Customers](
	[CustomerID] [int] NOT NULL,
	[CustomerName] [varchar](50) NULL,
	[Address] [varchar](50) NULL,
	[Phone] [varchar](50) NULL,
	[NIP] [int] NULL,
	[EmailAddress] [varchar](50) NULL,
	[Anonymous] [bit] NOT NULL,
 CONSTRAINT [PK_Customers] PRIMARY KEY CLUSTERED 
(
	[CustomerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[Payments](
	[PaymentID] [int] NOT NULL,
	[TaxID] [int] NOT NULL,
	[OrderID] [int] NOT NULL,
	[Amount] [int] NOT NULL,
	[PaymentDate] [date] NOT NULL,
 CONSTRAINT [PK_Payments] PRIMARY KEY CLUSTERED 
(
	[PaymentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[Taxes](
	[TaxID] [int] NOT NULL,
	[TaxName] [varchar](50) NOT NULL,
	[TaxValue] [int] NOT NULL,
 CONSTRAINT [PK_Taxes] PRIMARY KEY CLUSTERED 
(
	[TaxID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[MaterialSuppliers](
	[MaterialID] [int] NOT NULL,
	[SupplierID] [int] NOT NULL,
	[UnitPrice] [int] NOT NULL,
	[Freight] [int] NOT NULL
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[PartSuppliers](
	[SupplierID] [int] NOT NULL,
	[PartID] [int] NOT NULL,
	[UnitPrice] [int] NOT NULL,
	[Freight] [int] NOT NULL
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[Suppliers](
	[SupplierID] [int] NOT NULL,
	[CompanyName] [varchar](50) NOT NULL,
	[Phone] [varchar](50) NOT NULL,
	[Address] [varchar](50) NOT NULL,
	[EmailAdress] [varchar](50) NOT NULL,
 CONSTRAINT [PK_Suppliers] PRIMARY KEY CLUSTERED 
(
	[SupplierID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[Categories](
	[CategoryID] [int] NOT NULL,
	[CategoryName] [varchar](50) NOT NULL,
 CONSTRAINT [PK_Categories] PRIMARY KEY CLUSTERED 
(
	[CategoryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[FactoriesAndCategories](
	[CategoryID] [int] NOT NULL,
	[FactoryID] [int] NOT NULL,
	[ProductionCost] [int] NOT NULL
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[Factories](
	[FactoryID] [int] NOT NULL,
	[FactoryName] [varchar](50) NOT NULL,
	[Address] [varchar](50) NOT NULL,
	[Phone] [varchar](50) NOT NULL,
	[EmailAddress] [varchar](50) NOT NULL,
	[Website] [varchar](50) NULL,
 CONSTRAINT [PK_Factories] PRIMARY KEY CLUSTERED 
(
	[FactoryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[Products](
	[ProductID] [int] NOT NULL,
	[ProductName] [varchar](50) NOT NULL,
	[UnitsInStock] [int] NOT NULL,
	[CategoryID] [int] NOT NULL,
	[UnitPrice] [int] NOT NULL,
 CONSTRAINT [PK_Products] PRIMARY KEY CLUSTERED 
(
	[ProductID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[MaterialsForOneUnit](
	[ProductID] [int] NOT NULL,
	[MaterialID] [int] NOT NULL,
	[QuantityNeeded] [int] NOT NULL
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[PartsForOneUnit](
	[ProductID] [int] NOT NULL,
	[PartID] [int] NOT NULL,
	[QuantityNeeded] [int] NOT NULL
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[OrderDetails](
	[OrderID] [int] NOT NULL,
	[ProductID] [int] NOT NULL,
	[UnitPrice] [int] NOT NULL,
	[Quantity] [int] NOT NULL,
	[Discount] [int] NOT NULL,
	[QuantityFromStock] [int] NOT NULL
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[ProductionOrders](
	[ProductionOrderID] [int] IDENTITY(1,1) NOT NULL,
	[OrderID] [int] NULL,
	[ProductID] [int] NOT NULL,
	[FactoryID] [int] NOT NULL,
	[Quantity] [int] NOT NULL,
	[CreatedAt] [datetime2](0) NOT NULL,
	[PlannedStart] [datetime2](0) NULL,
	[PlannedEnd] [datetime2](0) NULL,
	[DueDate] [datetime2](0) NULL,
	[Status] [tinyint] NOT NULL,
	[Priority] [tinyint] NOT NULL,
	[Notes] [nvarchar](400) NULL,
 CONSTRAINT [PK_ProductionOrders] PRIMARY KEY CLUSTERED 
(
	[ProductionOrderID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[FactoryCapacityCalendar](
	[FactoryID] [int] NOT NULL,
	[WorkDate] [date] NOT NULL,
	[CapacityHours] [decimal](6, 2) NOT NULL,
 CONSTRAINT [PK_FactoryCapacityCalendar] PRIMARY KEY CLUSTERED 
(
	[FactoryID] ASC,
	[WorkDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[FactoryCapacityReservations](
	[FactoryID] [int] NOT NULL,
	[WorkDate] [date] NOT NULL,
	[ProductionOrderID] [int] NOT NULL,
	[ReservedHours] [decimal](6, 2) NOT NULL,
 CONSTRAINT [PK_FactoryCapacityReservations] PRIMARY KEY CLUSTERED 
(
	[FactoryID] ASC,
	[WorkDate] ASC,
	[ProductionOrderID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[Refunds](
	[RefundID] [int] NOT NULL,
	[OrderID] [int] NOT NULL,
	[ProductID] [int] NOT NULL,
	[Quantity] [int] NOT NULL,
	[RefundApproved] [bit] NOT NULL,
 CONSTRAINT [PK_Refunds] PRIMARY KEY CLUSTERED 
(
	[RefundID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[Shippers](
	[ShipperID] [int] NOT NULL,
	[CompanyName] [varchar](50) NOT NULL,
	[Phone] [varchar](50) NOT NULL,
	[Address] [varchar](50) NOT NULL,
	[EmailAddress] [varchar](50) NOT NULL,
 CONSTRAINT [PK_Shippers] PRIMARY KEY CLUSTERED 
(
	[ShipperID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[Employees](
	[EmployeeID] [int] NOT NULL,
	[FactoryID] [int] NOT NULL,
	[OccupationID] [int] NOT NULL,
	[FirstName] [varchar](50) NOT NULL,
	[LastName] [varchar](50) NOT NULL,
	[BirthDate] [date] NOT NULL,
	[Gender] [varchar](50) NOT NULL,
	[Phone] [varchar](50) NOT NULL,
	[Salary] [float] NOT NULL,
	[HireDate] [date] NOT NULL,
	[Nationality] [varchar](50) NOT NULL,
	[EmailAddress] [varchar](50) NOT NULL,
	[DisabilityStatement] [bit] NOT NULL,
 CONSTRAINT [PK_Employees] PRIMARY KEY CLUSTERED 
(
	[EmployeeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[Materials](
	[MaterialID] [int] NOT NULL,
	[MaterialName] [varchar](50) NOT NULL,
	[UnitsInStock] [int] NOT NULL,
 CONSTRAINT [PK_Materials] PRIMARY KEY CLUSTERED 
(
	[MaterialID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[Occupation](
	[OccupationID] [int] NOT NULL,
	[OccupationName] [varchar](50) NOT NULL,
 CONSTRAINT [PK_Occupation] PRIMARY KEY CLUSTERED 
(
	[OccupationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[Parts](
	[PartID] [int] NOT NULL,
	[PartName] [varchar](50) NOT NULL,
	[UnitsInStock] [int] NOT NULL,
 CONSTRAINT [PK_Parts] PRIMARY KEY CLUSTERED 
(
	[PartID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[ProductProductionSpec](
	[ProductID] [int] NOT NULL,
	[HoursPerUnit] [decimal](8, 4) NOT NULL,
 CONSTRAINT [PK_ProductProductionSpec] PRIMARY KEY CLUSTERED 
(
	[ProductID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[OrderDetails] ADD  CONSTRAINT [DF_OrderDetails_QuantityFromStock]  DEFAULT ((0)) FOR [QuantityFromStock]

GO

ALTER TABLE [dbo].[ProductionOrders] ADD  DEFAULT (sysutcdatetime()) FOR [CreatedAt]

GO

ALTER TABLE [dbo].[ProductionOrders] ADD  DEFAULT ((0)) FOR [Status]

GO

ALTER TABLE [dbo].[ProductionOrders] ADD  DEFAULT ((3)) FOR [Priority]

GO

ALTER TABLE [dbo].[Employees]  WITH CHECK ADD  CONSTRAINT [FK_Employees_Factories] FOREIGN KEY([FactoryID])
REFERENCES [dbo].[Factories] ([FactoryID])

GO

ALTER TABLE [dbo].[Employees] CHECK CONSTRAINT [FK_Employees_Factories]

GO

ALTER TABLE [dbo].[Employees]  WITH CHECK ADD  CONSTRAINT [FK_Employees_Occupation] FOREIGN KEY([OccupationID])
REFERENCES [dbo].[Occupation] ([OccupationID])

GO

ALTER TABLE [dbo].[Employees] CHECK CONSTRAINT [FK_Employees_Occupation]

GO

ALTER TABLE [dbo].[FactoriesAndCategories]  WITH CHECK ADD  CONSTRAINT [FK_FactoriesAndCategories_Categories] FOREIGN KEY([CategoryID])
REFERENCES [dbo].[Categories] ([CategoryID])

GO

ALTER TABLE [dbo].[FactoriesAndCategories] CHECK CONSTRAINT [FK_FactoriesAndCategories_Categories]

GO

ALTER TABLE [dbo].[FactoriesAndCategories]  WITH CHECK ADD  CONSTRAINT [FK_FactoriesAndCategories_Factories] FOREIGN KEY([FactoryID])
REFERENCES [dbo].[Factories] ([FactoryID])

GO

ALTER TABLE [dbo].[FactoriesAndCategories] CHECK CONSTRAINT [FK_FactoriesAndCategories_Factories]

GO

ALTER TABLE [dbo].[FactoryCapacityCalendar]  WITH CHECK ADD  CONSTRAINT [FK_FactoryCapacityCalendar_Factories] FOREIGN KEY([FactoryID])
REFERENCES [dbo].[Factories] ([FactoryID])

GO

ALTER TABLE [dbo].[FactoryCapacityCalendar] CHECK CONSTRAINT [FK_FactoryCapacityCalendar_Factories]

GO

ALTER TABLE [dbo].[FactoryCapacityReservations]  WITH CHECK ADD  CONSTRAINT [FK_FactoryCapacityReservations_Calendar] FOREIGN KEY([FactoryID], [WorkDate])
REFERENCES [dbo].[FactoryCapacityCalendar] ([FactoryID], [WorkDate])

GO

ALTER TABLE [dbo].[FactoryCapacityReservations] CHECK CONSTRAINT [FK_FactoryCapacityReservations_Calendar]

GO

ALTER TABLE [dbo].[FactoryCapacityReservations]  WITH CHECK ADD  CONSTRAINT [FK_FactoryCapacityReservations_Factories] FOREIGN KEY([FactoryID])
REFERENCES [dbo].[Factories] ([FactoryID])

GO

ALTER TABLE [dbo].[FactoryCapacityReservations] CHECK CONSTRAINT [FK_FactoryCapacityReservations_Factories]

GO

ALTER TABLE [dbo].[FactoryCapacityReservations]  WITH CHECK ADD  CONSTRAINT [FK_FactoryCapacityReservations_ProductionOrders] FOREIGN KEY([ProductionOrderID])
REFERENCES [dbo].[ProductionOrders] ([ProductionOrderID])

GO

ALTER TABLE [dbo].[FactoryCapacityReservations] CHECK CONSTRAINT [FK_FactoryCapacityReservations_ProductionOrders]

GO

ALTER TABLE [dbo].[MaterialsForOneUnit]  WITH CHECK ADD  CONSTRAINT [FK_MaterialsForOneUnit_Materials] FOREIGN KEY([MaterialID])
REFERENCES [dbo].[Materials] ([MaterialID])

GO

ALTER TABLE [dbo].[MaterialsForOneUnit] CHECK CONSTRAINT [FK_MaterialsForOneUnit_Materials]

GO

ALTER TABLE [dbo].[MaterialsForOneUnit]  WITH CHECK ADD  CONSTRAINT [FK_MaterialsForOneUnit_Products] FOREIGN KEY([ProductID])
REFERENCES [dbo].[Products] ([ProductID])

GO

ALTER TABLE [dbo].[MaterialsForOneUnit] CHECK CONSTRAINT [FK_MaterialsForOneUnit_Products]

GO

ALTER TABLE [dbo].[MaterialSuppliers]  WITH CHECK ADD  CONSTRAINT [FK_MaterialSuppliers_Materials] FOREIGN KEY([MaterialID])
REFERENCES [dbo].[Materials] ([MaterialID])

GO

ALTER TABLE [dbo].[MaterialSuppliers] CHECK CONSTRAINT [FK_MaterialSuppliers_Materials]

GO

ALTER TABLE [dbo].[MaterialSuppliers]  WITH CHECK ADD  CONSTRAINT [FK_MaterialSuppliers_Suppliers] FOREIGN KEY([SupplierID])
REFERENCES [dbo].[Suppliers] ([SupplierID])

GO

ALTER TABLE [dbo].[MaterialSuppliers] CHECK CONSTRAINT [FK_MaterialSuppliers_Suppliers]

GO

ALTER TABLE [dbo].[OrderDetails]  WITH CHECK ADD  CONSTRAINT [FK_OrderDetails_Orders] FOREIGN KEY([OrderID])
REFERENCES [dbo].[Orders] ([OrderID])

GO

ALTER TABLE [dbo].[OrderDetails] CHECK CONSTRAINT [FK_OrderDetails_Orders]

GO

ALTER TABLE [dbo].[OrderDetails]  WITH CHECK ADD  CONSTRAINT [FK_OrderDetails_Products] FOREIGN KEY([ProductID])
REFERENCES [dbo].[Products] ([ProductID])

GO

ALTER TABLE [dbo].[OrderDetails] CHECK CONSTRAINT [FK_OrderDetails_Products]

GO

ALTER TABLE [dbo].[Orders]  WITH CHECK ADD  CONSTRAINT [FK_Orders_Customers] FOREIGN KEY([CustomerID])
REFERENCES [dbo].[Customers] ([CustomerID])

GO

ALTER TABLE [dbo].[Orders] CHECK CONSTRAINT [FK_Orders_Customers]

GO

ALTER TABLE [dbo].[Orders]  WITH CHECK ADD  CONSTRAINT [FK_Orders_Employees] FOREIGN KEY([EmployeeID])
REFERENCES [dbo].[Employees] ([EmployeeID])

GO

ALTER TABLE [dbo].[Orders] CHECK CONSTRAINT [FK_Orders_Employees]

GO

ALTER TABLE [dbo].[Orders]  WITH CHECK ADD  CONSTRAINT [FK_Orders_Shippers] FOREIGN KEY([ShipperID])
REFERENCES [dbo].[Shippers] ([ShipperID])

GO

ALTER TABLE [dbo].[Orders] CHECK CONSTRAINT [FK_Orders_Shippers]

GO

ALTER TABLE [dbo].[PartsForOneUnit]  WITH CHECK ADD  CONSTRAINT [FK_PartsForOneUnit_Parts] FOREIGN KEY([PartID])
REFERENCES [dbo].[Parts] ([PartID])

GO

ALTER TABLE [dbo].[PartsForOneUnit] CHECK CONSTRAINT [FK_PartsForOneUnit_Parts]

GO

ALTER TABLE [dbo].[PartsForOneUnit]  WITH CHECK ADD  CONSTRAINT [FK_PartsForOneUnit_Products] FOREIGN KEY([ProductID])
REFERENCES [dbo].[Products] ([ProductID])

GO

ALTER TABLE [dbo].[PartsForOneUnit] CHECK CONSTRAINT [FK_PartsForOneUnit_Products]

GO

ALTER TABLE [dbo].[PartSuppliers]  WITH CHECK ADD  CONSTRAINT [FK_PartSuppliers_Parts] FOREIGN KEY([PartID])
REFERENCES [dbo].[Parts] ([PartID])

GO

ALTER TABLE [dbo].[PartSuppliers] CHECK CONSTRAINT [FK_PartSuppliers_Parts]

GO

ALTER TABLE [dbo].[PartSuppliers]  WITH CHECK ADD  CONSTRAINT [FK_PartSuppliers_Suppliers] FOREIGN KEY([SupplierID])
REFERENCES [dbo].[Suppliers] ([SupplierID])

GO

ALTER TABLE [dbo].[PartSuppliers] CHECK CONSTRAINT [FK_PartSuppliers_Suppliers]

GO

ALTER TABLE [dbo].[Payments]  WITH CHECK ADD  CONSTRAINT [FK_Payments_Orders] FOREIGN KEY([OrderID])
REFERENCES [dbo].[Orders] ([OrderID])

GO

ALTER TABLE [dbo].[Payments] CHECK CONSTRAINT [FK_Payments_Orders]

GO

ALTER TABLE [dbo].[Payments]  WITH CHECK ADD  CONSTRAINT [FK_Payments_Taxes] FOREIGN KEY([TaxID])
REFERENCES [dbo].[Taxes] ([TaxID])

GO

ALTER TABLE [dbo].[Payments] CHECK CONSTRAINT [FK_Payments_Taxes]

GO

ALTER TABLE [dbo].[ProductionOrders]  WITH CHECK ADD  CONSTRAINT [FK_ProductionOrders_Factories] FOREIGN KEY([FactoryID])
REFERENCES [dbo].[Factories] ([FactoryID])

GO

ALTER TABLE [dbo].[ProductionOrders] CHECK CONSTRAINT [FK_ProductionOrders_Factories]

GO

ALTER TABLE [dbo].[ProductionOrders]  WITH CHECK ADD  CONSTRAINT [FK_ProductionOrders_Orders] FOREIGN KEY([OrderID])
REFERENCES [dbo].[Orders] ([OrderID])

GO

ALTER TABLE [dbo].[ProductionOrders] CHECK CONSTRAINT [FK_ProductionOrders_Orders]

GO

ALTER TABLE [dbo].[ProductionOrders]  WITH CHECK ADD  CONSTRAINT [FK_ProductionOrders_Products] FOREIGN KEY([ProductID])
REFERENCES [dbo].[Products] ([ProductID])

GO

ALTER TABLE [dbo].[ProductionOrders] CHECK CONSTRAINT [FK_ProductionOrders_Products]

GO

ALTER TABLE [dbo].[ProductProductionSpec]  WITH CHECK ADD  CONSTRAINT [FK_ProductProductionSpec_Products] FOREIGN KEY([ProductID])
REFERENCES [dbo].[Products] ([ProductID])

GO

ALTER TABLE [dbo].[ProductProductionSpec] CHECK CONSTRAINT [FK_ProductProductionSpec_Products]

GO

ALTER TABLE [dbo].[Products]  WITH CHECK ADD  CONSTRAINT [FK_Products_Categories] FOREIGN KEY([CategoryID])
REFERENCES [dbo].[Categories] ([CategoryID])

GO

ALTER TABLE [dbo].[Products] CHECK CONSTRAINT [FK_Products_Categories]

GO

ALTER TABLE [dbo].[Refunds]  WITH CHECK ADD  CONSTRAINT [FK_Refunds_Orders] FOREIGN KEY([OrderID])
REFERENCES [dbo].[Orders] ([OrderID])

GO

ALTER TABLE [dbo].[Refunds] CHECK CONSTRAINT [FK_Refunds_Orders]

GO

ALTER TABLE [dbo].[Refunds]  WITH CHECK ADD  CONSTRAINT [FK_Refunds_Products] FOREIGN KEY([ProductID])
REFERENCES [dbo].[Products] ([ProductID])

GO

ALTER TABLE [dbo].[Refunds] CHECK CONSTRAINT [FK_Refunds_Products]

GO

ALTER TABLE [dbo].[FactoryCapacityCalendar]  WITH CHECK ADD  CONSTRAINT [CK_FactoryCapacityCalendar_Capacity] CHECK  (([CapacityHours]>=(0) AND [CapacityHours]<=(24)))

GO

ALTER TABLE [dbo].[FactoryCapacityCalendar] CHECK CONSTRAINT [CK_FactoryCapacityCalendar_Capacity]

GO

ALTER TABLE [dbo].[FactoryCapacityReservations]  WITH CHECK ADD  CONSTRAINT [CK_FactoryCapacityReservations_Reserved] CHECK  (([ReservedHours]>(0) AND [ReservedHours]<=(24)))

GO

ALTER TABLE [dbo].[FactoryCapacityReservations] CHECK CONSTRAINT [CK_FactoryCapacityReservations_Reserved]

GO

ALTER TABLE [dbo].[OrderDetails]  WITH CHECK ADD  CONSTRAINT [CK_OrderDetails_QuantityFromStock] CHECK  (([QuantityFromStock]>=(0) AND [QuantityFromStock]<=[Quantity]))

GO

ALTER TABLE [dbo].[OrderDetails] CHECK CONSTRAINT [CK_OrderDetails_QuantityFromStock]

GO

ALTER TABLE [dbo].[ProductionOrders]  WITH CHECK ADD  CONSTRAINT [CK_ProductionOrders_Dates] CHECK  (([PlannedStart] IS NULL OR [PlannedEnd] IS NULL OR [PlannedEnd]>=[PlannedStart]))

GO

ALTER TABLE [dbo].[ProductionOrders] CHECK CONSTRAINT [CK_ProductionOrders_Dates]

GO

ALTER TABLE [dbo].[ProductionOrders]  WITH CHECK ADD  CONSTRAINT [CK_ProductionOrders_Priority] CHECK  (([Priority]>=(1) AND [Priority]<=(5)))

GO

ALTER TABLE [dbo].[ProductionOrders] CHECK CONSTRAINT [CK_ProductionOrders_Priority]

GO

ALTER TABLE [dbo].[ProductionOrders]  WITH CHECK ADD  CONSTRAINT [CK_ProductionOrders_Quantity] CHECK  (([Quantity]>(0)))

GO

ALTER TABLE [dbo].[ProductionOrders] CHECK CONSTRAINT [CK_ProductionOrders_Quantity]

GO

ALTER TABLE [dbo].[ProductionOrders]  WITH CHECK ADD  CONSTRAINT [CK_ProductionOrders_Status] CHECK  (([Status]=(5) OR [Status]=(4) OR [Status]=(3) OR [Status]=(2) OR [Status]=(1) OR [Status]=(0)))

GO

ALTER TABLE [dbo].[ProductionOrders] CHECK CONSTRAINT [CK_ProductionOrders_Status]

GO

ALTER TABLE [dbo].[ProductProductionSpec]  WITH CHECK ADD  CONSTRAINT [CK_ProductProductionSpec_HoursPerUnit] CHECK  (([HoursPerUnit]>(0) AND [HoursPerUnit]<=(24)))

GO

ALTER TABLE [dbo].[ProductProductionSpec] CHECK CONSTRAINT [CK_ProductProductionSpec_HoursPerUnit]

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