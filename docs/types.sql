CREATE TYPE [dbo].[OrderItemType] AS TABLE(
	[ProductID] [int] NOT NULL,
	[Quantity] [int] NOT NULL,
	[UnitPrice] [int] NULL,
	[Discount] [int] NULL
)