# MSH Company – dokumentacja bazy danych (MS SQL Server)

## 1. Cel systemu i kontekst biznesowy

Baza danych wspiera firmę produkcyjno‑usługową zajmującą się **produkcją i sprzedażą mebli** (m.in. biurka, krzesła, stoły, fotele, stojaki i tablice interaktywne), wraz z planowaniem produkcji, kontrolą stanów magazynowych, obsługą zamówień, płatności oraz analityką (raporty sprzedaży i kosztów). fileciteturn1file0

Kluczowe wymagania projektu obejmują m.in.: warunki integralności, widoki raportowe, procedury/funkcje/triggery realizujące kluczową logikę, indeksy oraz role i uprawnienia. fileciteturn1file1

## 2. Jak uruchomić skrypt

1. Otwórz `msh_company_script.sql` w SQL Server Management Studio (SSMS).
2. Upewnij się, że na górze skryptu jest poprawna baza (`USE [...]`).
3. Uruchom cały skrypt (F5). Skrypt zawiera wiele batchy `GO`.
4. Po wykonaniu skryptu obiekty będą dostępne w schemacie `dbo` (tabele, widoki, procedury, funkcje, triggery, typy) oraz zostaną utworzone role i nadane uprawnienia.

## 3. Inwentarz obiektów

- **Tabele**: 24
- **Typy tabelaryczne (UDTT)**: 1
- **Funkcje (UDF)**: 10
- **Procedury składowane**: 7
- **Widoki**: 17
- **Triggery**: 4
- **Ograniczenia (ALTER TABLE … ADD CONSTRAINT)**: 39
- **Indeksy (CREATE INDEX)**: 28
- **Role**: 4

## 4. Tabele i warunki integralności

Poniżej znajduje się opis każdej tabeli: kolumny, podstawowe ograniczenia (NOT NULL / DEFAULT / CHECK), klucze (PK/UK) oraz relacje (FK).

### 4.1. `dbo.Categories`

| Kolumna | Typ | NULL | DEFAULT | CHECK |
|---|---|---:|---|---|
| `CategoryID` | [int] | NIE |  |  |
| `CategoryName` | [varchar](50) | NIE |  |  |

**Ograniczenia w definicji tabeli (CREATE TABLE):**
- `CONSTRAINT [PK_Categories] PRIMARY KEY CLUSTERED ( [CategoryID] ASC )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]`

<details><summary>DDL (kod tworzący tabelę + powiązane ograniczenia/indeksy)</summary>

```sql
CREATE TABLE [dbo].[Categories](
	[CategoryID] [int] NOT NULL,
	[CategoryName] [varchar](50) NOT NULL,
 CONSTRAINT [PK_Categories] PRIMARY KEY CLUSTERED 
(
	[CategoryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
```
</details>

### 4.2. `dbo.Customers`

| Kolumna | Typ | NULL | DEFAULT | CHECK |
|---|---|---:|---|---|
| `CustomerID` | [int] | NIE |  |  |
| `CustomerName` | [varchar](50) | TAK |  |  |
| `Address` | [varchar](50) | TAK |  |  |
| `Phone` | [varchar](50) | TAK |  |  |
| `NIP` | [int] | TAK |  |  |
| `EmailAddress` | [varchar](50) | TAK |  |  |
| `Anonymous` | [bit] | NIE |  |  |

**Ograniczenia w definicji tabeli (CREATE TABLE):**
- `CONSTRAINT [PK_Customers] PRIMARY KEY CLUSTERED ( [CustomerID] ASC )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]`

<details><summary>DDL (kod tworzący tabelę + powiązane ograniczenia/indeksy)</summary>

```sql
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
```
</details>

### 4.3. `dbo.Employees`

| Kolumna | Typ | NULL | DEFAULT | CHECK |
|---|---|---:|---|---|
| `EmployeeID` | [int] | NIE |  |  |
| `FactoryID` | [int] | NIE |  |  |
| `OccupationID` | [int] | NIE |  |  |
| `FirstName` | [varchar](50) | NIE |  |  |
| `LastName` | [varchar](50) | NIE |  |  |
| `BirthDate` | [date] | NIE |  |  |
| `Gender` | [varchar](50) | NIE |  |  |
| `Phone` | [varchar](50) | NIE |  |  |
| `Salary` | [float] | NIE |  |  |
| `HireDate` | [date] | NIE |  |  |
| `Nationality` | [varchar](50) | NIE |  |  |
| `EmailAddress` | [varchar](50) | NIE |  |  |
| `DisabilityStatement` | [bit] | NIE |  |  |

**Ograniczenia w definicji tabeli (CREATE TABLE):**
- `CONSTRAINT [PK_Employees] PRIMARY KEY CLUSTERED ( [EmployeeID] ASC )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]`

**Dodatkowe ograniczenia (ALTER TABLE … ADD CONSTRAINT):**
- `ALTER TABLE [dbo].[Employees]  WITH CHECK ADD  CONSTRAINT [FK_Employees_Factories] FOREIGN KEY([FactoryID])`
- `ALTER TABLE [dbo].[Employees]  WITH CHECK ADD  CONSTRAINT [FK_Employees_Occupation] FOREIGN KEY([OccupationID])`

**Indeksy:**
- `IX_Employees_FactoryID` na ([FactoryID] ASC)
- `IX_Employees_OccupationID` na ([OccupationID] ASC)

<details><summary>DDL (kod tworzący tabelę + powiązane ograniczenia/indeksy)</summary>

```sql
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

-- ALTER TABLE constraints
ALTER TABLE [dbo].[Employees]  WITH CHECK ADD  CONSTRAINT [FK_Employees_Factories] FOREIGN KEY([FactoryID])
REFERENCES [dbo].[Factories] ([FactoryID])
ALTER TABLE [dbo].[Employees]  WITH CHECK ADD  CONSTRAINT [FK_Employees_Occupation] FOREIGN KEY([OccupationID])
REFERENCES [dbo].[Occupation] ([OccupationID])

-- Indexes
/****** Object:  Index [IX_Employees_FactoryID]    Script Date: 27.01.2026 13:39:51 ******/
CREATE NONCLUSTERED INDEX [IX_Employees_FactoryID] ON [dbo].[Employees]
(
	[FactoryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
/****** Object:  Index [IX_Employees_OccupationID]    Script Date: 27.01.2026 13:39:51 ******/
CREATE NONCLUSTERED INDEX [IX_Employees_OccupationID] ON [dbo].[Employees]
(
	[OccupationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
```
</details>

### 4.4. `dbo.Factories`

| Kolumna | Typ | NULL | DEFAULT | CHECK |
|---|---|---:|---|---|
| `FactoryID` | [int] | NIE |  |  |
| `FactoryName` | [varchar](50) | NIE |  |  |
| `Address` | [varchar](50) | NIE |  |  |
| `Phone` | [varchar](50) | NIE |  |  |
| `EmailAddress` | [varchar](50) | NIE |  |  |
| `Website` | [varchar](50) | TAK |  |  |

**Ograniczenia w definicji tabeli (CREATE TABLE):**
- `CONSTRAINT [PK_Factories] PRIMARY KEY CLUSTERED ( [FactoryID] ASC )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]`

<details><summary>DDL (kod tworzący tabelę + powiązane ograniczenia/indeksy)</summary>

```sql
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
```
</details>

### 4.5. `dbo.FactoriesAndCategories`

| Kolumna | Typ | NULL | DEFAULT | CHECK |
|---|---|---:|---|---|
| `CategoryID` | [int] | NIE |  |  |
| `FactoryID` | [int] | NIE |  |  |
| `ProductionCost` | [int] | NIE |  |  |


**Dodatkowe ograniczenia (ALTER TABLE … ADD CONSTRAINT):**
- `ALTER TABLE [dbo].[FactoriesAndCategories]  WITH CHECK ADD  CONSTRAINT [FK_FactoriesAndCategories_Categories] FOREIGN KEY([CategoryID])`
- `ALTER TABLE [dbo].[FactoriesAndCategories]  WITH CHECK ADD  CONSTRAINT [FK_FactoriesAndCategories_Factories] FOREIGN KEY([FactoryID])`

<details><summary>DDL (kod tworzący tabelę + powiązane ograniczenia/indeksy)</summary>

```sql
CREATE TABLE [dbo].[FactoriesAndCategories](
	[CategoryID] [int] NOT NULL,
	[FactoryID] [int] NOT NULL,
	[ProductionCost] [int] NOT NULL
) ON [PRIMARY]

-- ALTER TABLE constraints
ALTER TABLE [dbo].[FactoriesAndCategories]  WITH CHECK ADD  CONSTRAINT [FK_FactoriesAndCategories_Categories] FOREIGN KEY([CategoryID])
REFERENCES [dbo].[Categories] ([CategoryID])
ALTER TABLE [dbo].[FactoriesAndCategories]  WITH CHECK ADD  CONSTRAINT [FK_FactoriesAndCategories_Factories] FOREIGN KEY([FactoryID])
REFERENCES [dbo].[Factories] ([FactoryID])
```
</details>

### 4.6. `dbo.FactoryCapacityCalendar`

| Kolumna | Typ | NULL | DEFAULT | CHECK |
|---|---|---:|---|---|
| `FactoryID` | [int] | NIE |  |  |
| `WorkDate` | [date] | NIE |  |  |
| `CapacityHours` | [decimal](6, 2) | NIE |  |  |

**Ograniczenia w definicji tabeli (CREATE TABLE):**
- `CONSTRAINT [PK_FactoryCapacityCalendar] PRIMARY KEY CLUSTERED ( [FactoryID] ASC, [WorkDate] ASC )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]`

**Dodatkowe ograniczenia (ALTER TABLE … ADD CONSTRAINT):**
- `ALTER TABLE [dbo].[FactoryCapacityCalendar]  WITH CHECK ADD  CONSTRAINT [FK_FactoryCapacityCalendar_Factories] FOREIGN KEY([FactoryID])`
- `ALTER TABLE [dbo].[FactoryCapacityCalendar]  WITH CHECK ADD  CONSTRAINT [CK_FactoryCapacityCalendar_Capacity] CHECK  (([CapacityHours]>=(0) AND [CapacityHours]<=(24)))`

**Indeksy:**
- `IX_FactoryCapacityCalendar_WorkDate` na ([WorkDate] ASC)

<details><summary>DDL (kod tworzący tabelę + powiązane ograniczenia/indeksy)</summary>

```sql
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

-- ALTER TABLE constraints
ALTER TABLE [dbo].[FactoryCapacityCalendar]  WITH CHECK ADD  CONSTRAINT [FK_FactoryCapacityCalendar_Factories] FOREIGN KEY([FactoryID])
REFERENCES [dbo].[Factories] ([FactoryID])
ALTER TABLE [dbo].[FactoryCapacityCalendar]  WITH CHECK ADD  CONSTRAINT [CK_FactoryCapacityCalendar_Capacity] CHECK  (([CapacityHours]>=(0) AND [CapacityHours]<=(24)))

-- Indexes
/****** Object:  Index [IX_FactoryCapacityCalendar_WorkDate]    Script Date: 27.01.2026 13:39:51 ******/
CREATE NONCLUSTERED INDEX [IX_FactoryCapacityCalendar_WorkDate] ON [dbo].[FactoryCapacityCalendar]
(
	[WorkDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
```
</details>

### 4.7. `dbo.FactoryCapacityReservations`

| Kolumna | Typ | NULL | DEFAULT | CHECK |
|---|---|---:|---|---|
| `FactoryID` | [int] | NIE |  |  |
| `WorkDate` | [date] | NIE |  |  |
| `ProductionOrderID` | [int] | NIE |  |  |
| `ReservedHours` | [decimal](6, 2) | NIE |  |  |

**Ograniczenia w definicji tabeli (CREATE TABLE):**
- `CONSTRAINT [PK_FactoryCapacityReservations] PRIMARY KEY CLUSTERED ( [FactoryID] ASC, [WorkDate] ASC, [ProductionOrderID] ASC )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]`

**Dodatkowe ograniczenia (ALTER TABLE … ADD CONSTRAINT):**
- `ALTER TABLE [dbo].[FactoryCapacityReservations]  WITH CHECK ADD  CONSTRAINT [FK_FactoryCapacityReservations_Calendar] FOREIGN KEY([FactoryID], [WorkDate])`
- `ALTER TABLE [dbo].[FactoryCapacityReservations]  WITH CHECK ADD  CONSTRAINT [FK_FactoryCapacityReservations_Factories] FOREIGN KEY([FactoryID])`
- `ALTER TABLE [dbo].[FactoryCapacityReservations]  WITH CHECK ADD  CONSTRAINT [FK_FactoryCapacityReservations_ProductionOrders] FOREIGN KEY([ProductionOrderID])`
- `ALTER TABLE [dbo].[FactoryCapacityReservations]  WITH CHECK ADD  CONSTRAINT [CK_FactoryCapacityReservations_Reserved] CHECK  (([ReservedHours]>(0) AND [ReservedHours]<=(24)))`

**Indeksy:**
- `IX_FactoryCapacityReservations_POID` na ([ProductionOrderID] ASC)

<details><summary>DDL (kod tworzący tabelę + powiązane ograniczenia/indeksy)</summary>

```sql
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

-- ALTER TABLE constraints
ALTER TABLE [dbo].[FactoryCapacityReservations]  WITH CHECK ADD  CONSTRAINT [FK_FactoryCapacityReservations_Calendar] FOREIGN KEY([FactoryID], [WorkDate])
REFERENCES [dbo].[FactoryCapacityCalendar] ([FactoryID], [WorkDate])
ALTER TABLE [dbo].[FactoryCapacityReservations]  WITH CHECK ADD  CONSTRAINT [FK_FactoryCapacityReservations_Factories] FOREIGN KEY([FactoryID])
REFERENCES [dbo].[Factories] ([FactoryID])
ALTER TABLE [dbo].[FactoryCapacityReservations]  WITH CHECK ADD  CONSTRAINT [FK_FactoryCapacityReservations_ProductionOrders] FOREIGN KEY([ProductionOrderID])
REFERENCES [dbo].[ProductionOrders] ([ProductionOrderID])
ALTER TABLE [dbo].[FactoryCapacityReservations]  WITH CHECK ADD  CONSTRAINT [CK_FactoryCapacityReservations_Reserved] CHECK  (([ReservedHours]>(0) AND [ReservedHours]<=(24)))

-- Indexes
/****** Object:  Index [IX_FactoryCapacityReservations_POID]    Script Date: 27.01.2026 13:39:51 ******/
CREATE NONCLUSTERED INDEX [IX_FactoryCapacityReservations_POID] ON [dbo].[FactoryCapacityReservations]
(
	[ProductionOrderID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
```
</details>

### 4.8. `dbo.MaterialSuppliers`

| Kolumna | Typ | NULL | DEFAULT | CHECK |
|---|---|---:|---|---|
| `MaterialID` | [int] | NIE |  |  |
| `SupplierID` | [int] | NIE |  |  |
| `UnitPrice` | [int] | NIE |  |  |
| `Freight` | [int] | NIE |  |  |


**Dodatkowe ograniczenia (ALTER TABLE … ADD CONSTRAINT):**
- `ALTER TABLE [dbo].[MaterialSuppliers]  WITH CHECK ADD  CONSTRAINT [FK_MaterialSuppliers_Materials] FOREIGN KEY([MaterialID])`
- `ALTER TABLE [dbo].[MaterialSuppliers]  WITH CHECK ADD  CONSTRAINT [FK_MaterialSuppliers_Suppliers] FOREIGN KEY([SupplierID])`

**Indeksy:**
- `IX_MaterialSuppliers_MaterialID` na ([MaterialID] ASC)
- `IX_MaterialSuppliers_SupplierID` na ([SupplierID] ASC)

<details><summary>DDL (kod tworzący tabelę + powiązane ograniczenia/indeksy)</summary>

```sql
CREATE TABLE [dbo].[MaterialSuppliers](
	[MaterialID] [int] NOT NULL,
	[SupplierID] [int] NOT NULL,
	[UnitPrice] [int] NOT NULL,
	[Freight] [int] NOT NULL
) ON [PRIMARY]

-- ALTER TABLE constraints
ALTER TABLE [dbo].[MaterialSuppliers]  WITH CHECK ADD  CONSTRAINT [FK_MaterialSuppliers_Materials] FOREIGN KEY([MaterialID])
REFERENCES [dbo].[Materials] ([MaterialID])
ALTER TABLE [dbo].[MaterialSuppliers]  WITH CHECK ADD  CONSTRAINT [FK_MaterialSuppliers_Suppliers] FOREIGN KEY([SupplierID])
REFERENCES [dbo].[Suppliers] ([SupplierID])

-- Indexes
/****** Object:  Index [IX_MaterialSuppliers_MaterialID]    Script Date: 27.01.2026 13:39:51 ******/
CREATE NONCLUSTERED INDEX [IX_MaterialSuppliers_MaterialID] ON [dbo].[MaterialSuppliers]
(
	[MaterialID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
/****** Object:  Index [IX_MaterialSuppliers_SupplierID]    Script Date: 27.01.2026 13:39:51 ******/
CREATE NONCLUSTERED INDEX [IX_MaterialSuppliers_SupplierID] ON [dbo].[MaterialSuppliers]
(
	[SupplierID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
```
</details>

### 4.9. `dbo.Materials`

| Kolumna | Typ | NULL | DEFAULT | CHECK |
|---|---|---:|---|---|
| `MaterialID` | [int] | NIE |  |  |
| `MaterialName` | [varchar](50) | NIE |  |  |
| `UnitsInStock` | [int] | NIE |  |  |

**Ograniczenia w definicji tabeli (CREATE TABLE):**
- `CONSTRAINT [PK_Materials] PRIMARY KEY CLUSTERED ( [MaterialID] ASC )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]`

<details><summary>DDL (kod tworzący tabelę + powiązane ograniczenia/indeksy)</summary>

```sql
CREATE TABLE [dbo].[Materials](
	[MaterialID] [int] NOT NULL,
	[MaterialName] [varchar](50) NOT NULL,
	[UnitsInStock] [int] NOT NULL,
 CONSTRAINT [PK_Materials] PRIMARY KEY CLUSTERED 
(
	[MaterialID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
```
</details>

### 4.10. `dbo.MaterialsForOneUnit`

| Kolumna | Typ | NULL | DEFAULT | CHECK |
|---|---|---:|---|---|
| `ProductID` | [int] | NIE |  |  |
| `MaterialID` | [int] | NIE |  |  |
| `QuantityNeeded` | [int] | NIE |  |  |


**Dodatkowe ograniczenia (ALTER TABLE … ADD CONSTRAINT):**
- `ALTER TABLE [dbo].[MaterialsForOneUnit]  WITH CHECK ADD  CONSTRAINT [FK_MaterialsForOneUnit_Materials] FOREIGN KEY([MaterialID])`
- `ALTER TABLE [dbo].[MaterialsForOneUnit]  WITH CHECK ADD  CONSTRAINT [FK_MaterialsForOneUnit_Products] FOREIGN KEY([ProductID])`

**Indeksy:**
- `IX_MaterialsForOneUnit_MaterialID` na ([MaterialID] ASC)
- `IX_MaterialsForOneUnit_ProductID` na ([ProductID] ASC)

<details><summary>DDL (kod tworzący tabelę + powiązane ograniczenia/indeksy)</summary>

```sql
CREATE TABLE [dbo].[MaterialsForOneUnit](
	[ProductID] [int] NOT NULL,
	[MaterialID] [int] NOT NULL,
	[QuantityNeeded] [int] NOT NULL
) ON [PRIMARY]

-- ALTER TABLE constraints
ALTER TABLE [dbo].[MaterialsForOneUnit]  WITH CHECK ADD  CONSTRAINT [FK_MaterialsForOneUnit_Materials] FOREIGN KEY([MaterialID])
REFERENCES [dbo].[Materials] ([MaterialID])
ALTER TABLE [dbo].[MaterialsForOneUnit]  WITH CHECK ADD  CONSTRAINT [FK_MaterialsForOneUnit_Products] FOREIGN KEY([ProductID])
REFERENCES [dbo].[Products] ([ProductID])

-- Indexes
/****** Object:  Index [IX_MaterialsForOneUnit_MaterialID]    Script Date: 27.01.2026 13:39:51 ******/
CREATE NONCLUSTERED INDEX [IX_MaterialsForOneUnit_MaterialID] ON [dbo].[MaterialsForOneUnit]
(
	[MaterialID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
/****** Object:  Index [IX_MaterialsForOneUnit_ProductID]    Script Date: 27.01.2026 13:39:51 ******/
CREATE NONCLUSTERED INDEX [IX_MaterialsForOneUnit_ProductID] ON [dbo].[MaterialsForOneUnit]
(
	[ProductID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
```
</details>

### 4.11. `dbo.Occupation`

| Kolumna | Typ | NULL | DEFAULT | CHECK |
|---|---|---:|---|---|
| `OccupationID` | [int] | NIE |  |  |
| `OccupationName` | [varchar](50) | NIE |  |  |

**Ograniczenia w definicji tabeli (CREATE TABLE):**
- `CONSTRAINT [PK_Occupation] PRIMARY KEY CLUSTERED ( [OccupationID] ASC )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]`

<details><summary>DDL (kod tworzący tabelę + powiązane ograniczenia/indeksy)</summary>

```sql
CREATE TABLE [dbo].[Occupation](
	[OccupationID] [int] NOT NULL,
	[OccupationName] [varchar](50) NOT NULL,
 CONSTRAINT [PK_Occupation] PRIMARY KEY CLUSTERED 
(
	[OccupationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
```
</details>

### 4.12. `dbo.OrderDetails`

| Kolumna | Typ | NULL | DEFAULT | CHECK |
|---|---|---:|---|---|
| `OrderID` | [int] | NIE |  |  |
| `ProductID` | [int] | NIE |  |  |
| `UnitPrice` | [int] | NIE |  |  |
| `Quantity` | [int] | NIE |  |  |
| `Discount` | [int] | NIE |  |  |
| `QuantityFromStock` | [int] | NIE |  |  |


**Dodatkowe ograniczenia (ALTER TABLE … ADD CONSTRAINT):**
- `ALTER TABLE [dbo].[OrderDetails]  WITH CHECK ADD  CONSTRAINT [FK_OrderDetails_Orders] FOREIGN KEY([OrderID])`
- `ALTER TABLE [dbo].[OrderDetails]  WITH CHECK ADD  CONSTRAINT [FK_OrderDetails_Products] FOREIGN KEY([ProductID])`
- `ALTER TABLE [dbo].[OrderDetails]  WITH CHECK ADD  CONSTRAINT [CK_OrderDetails_QuantityFromStock] CHECK  (([QuantityFromStock]>=(0) AND [QuantityFromStock]<=[Quantity]))`

**Indeksy:**
- `IX_OrderDetails_OrderID` na ([OrderID] ASC)
- `IX_OrderDetails_ProductID` na ([ProductID] ASC)

<details><summary>DDL (kod tworzący tabelę + powiązane ograniczenia/indeksy)</summary>

```sql
CREATE TABLE [dbo].[OrderDetails](
	[OrderID] [int] NOT NULL,
	[ProductID] [int] NOT NULL,
	[UnitPrice] [int] NOT NULL,
	[Quantity] [int] NOT NULL,
	[Discount] [int] NOT NULL,
	[QuantityFromStock] [int] NOT NULL
) ON [PRIMARY]

-- ALTER TABLE constraints
ALTER TABLE [dbo].[OrderDetails]  WITH CHECK ADD  CONSTRAINT [FK_OrderDetails_Orders] FOREIGN KEY([OrderID])
REFERENCES [dbo].[Orders] ([OrderID])
ALTER TABLE [dbo].[OrderDetails]  WITH CHECK ADD  CONSTRAINT [FK_OrderDetails_Products] FOREIGN KEY([ProductID])
REFERENCES [dbo].[Products] ([ProductID])
ALTER TABLE [dbo].[OrderDetails]  WITH CHECK ADD  CONSTRAINT [CK_OrderDetails_QuantityFromStock] CHECK  (([QuantityFromStock]>=(0) AND [QuantityFromStock]<=[Quantity]))

-- Indexes
/****** Object:  Index [IX_OrderDetails_OrderID]    Script Date: 27.01.2026 13:39:51 ******/
CREATE NONCLUSTERED INDEX [IX_OrderDetails_OrderID] ON [dbo].[OrderDetails]
(
	[OrderID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
/****** Object:  Index [IX_OrderDetails_ProductID]    Script Date: 27.01.2026 13:39:51 ******/
CREATE NONCLUSTERED INDEX [IX_OrderDetails_ProductID] ON [dbo].[OrderDetails]
(
	[ProductID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
```
</details>

### 4.13. `dbo.Orders`

| Kolumna | Typ | NULL | DEFAULT | CHECK |
|---|---|---:|---|---|
| `OrderID` | [int] | NIE |  |  |
| `EmployeeID` | [int] | NIE |  |  |
| `CustomerID` | [int] | NIE |  |  |
| `ShipperID` | [int] | NIE |  |  |
| `OrderDate` | [date] | NIE |  |  |
| `ShipDate` | [date] | TAK |  |  |
| `Freight` | [int] | NIE |  |  |
| `RequestedDeliveryDate` | [date] | NIE |  |  |

**Ograniczenia w definicji tabeli (CREATE TABLE):**
- `CONSTRAINT [PK_Orders] PRIMARY KEY CLUSTERED ( [OrderID] ASC )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]`

**Dodatkowe ograniczenia (ALTER TABLE … ADD CONSTRAINT):**
- `ALTER TABLE [dbo].[Orders]  WITH CHECK ADD  CONSTRAINT [FK_Orders_Customers] FOREIGN KEY([CustomerID])`
- `ALTER TABLE [dbo].[Orders]  WITH CHECK ADD  CONSTRAINT [FK_Orders_Employees] FOREIGN KEY([EmployeeID])`
- `ALTER TABLE [dbo].[Orders]  WITH CHECK ADD  CONSTRAINT [FK_Orders_Shippers] FOREIGN KEY([ShipperID])`

**Indeksy:**
- `IX_Orders_CustomerID` na ([CustomerID] ASC)
- `IX_Orders_EmployeeID` na ([EmployeeID] ASC)
- `IX_Orders_OrderDate` na ([OrderDate] ASC)
- `IX_Orders_ShipperID` na ([ShipperID] ASC)

<details><summary>DDL (kod tworzący tabelę + powiązane ograniczenia/indeksy)</summary>

```sql
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

-- ALTER TABLE constraints
ALTER TABLE [dbo].[Orders]  WITH CHECK ADD  CONSTRAINT [FK_Orders_Customers] FOREIGN KEY([CustomerID])
REFERENCES [dbo].[Customers] ([CustomerID])
ALTER TABLE [dbo].[Orders]  WITH CHECK ADD  CONSTRAINT [FK_Orders_Employees] FOREIGN KEY([EmployeeID])
REFERENCES [dbo].[Employees] ([EmployeeID])
ALTER TABLE [dbo].[Orders]  WITH CHECK ADD  CONSTRAINT [FK_Orders_Shippers] FOREIGN KEY([ShipperID])
REFERENCES [dbo].[Shippers] ([ShipperID])

-- Indexes
/****** Object:  Index [IX_Orders_CustomerID]    Script Date: 27.01.2026 13:39:51 ******/
CREATE NONCLUSTERED INDEX [IX_Orders_CustomerID] ON [dbo].[Orders]
(
	[CustomerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
/****** Object:  Index [IX_Orders_EmployeeID]    Script Date: 27.01.2026 13:39:51 ******/
CREATE NONCLUSTERED INDEX [IX_Orders_EmployeeID] ON [dbo].[Orders]
(
	[EmployeeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
/****** Object:  Index [IX_Orders_OrderDate]    Script Date: 27.01.2026 13:39:51 ******/
CREATE NONCLUSTERED INDEX [IX_Orders_OrderDate] ON [dbo].[Orders]
(
	[OrderDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
/****** Object:  Index [IX_Orders_ShipperID]    Script Date: 27.01.2026 13:39:51 ******/
CREATE NONCLUSTERED INDEX [IX_Orders_ShipperID] ON [dbo].[Orders]
(
	[ShipperID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
```
</details>

### 4.14. `dbo.PartSuppliers`

| Kolumna | Typ | NULL | DEFAULT | CHECK |
|---|---|---:|---|---|
| `SupplierID` | [int] | NIE |  |  |
| `PartID` | [int] | NIE |  |  |
| `UnitPrice` | [int] | NIE |  |  |
| `Freight` | [int] | NIE |  |  |


**Dodatkowe ograniczenia (ALTER TABLE … ADD CONSTRAINT):**
- `ALTER TABLE [dbo].[PartSuppliers]  WITH CHECK ADD  CONSTRAINT [FK_PartSuppliers_Parts] FOREIGN KEY([PartID])`
- `ALTER TABLE [dbo].[PartSuppliers]  WITH CHECK ADD  CONSTRAINT [FK_PartSuppliers_Suppliers] FOREIGN KEY([SupplierID])`

**Indeksy:**
- `IX_PartSuppliers_PartID` na ([PartID] ASC)
- `IX_PartSuppliers_SupplierID` na ([SupplierID] ASC)

<details><summary>DDL (kod tworzący tabelę + powiązane ograniczenia/indeksy)</summary>

```sql
CREATE TABLE [dbo].[PartSuppliers](
	[SupplierID] [int] NOT NULL,
	[PartID] [int] NOT NULL,
	[UnitPrice] [int] NOT NULL,
	[Freight] [int] NOT NULL
) ON [PRIMARY]

-- ALTER TABLE constraints
ALTER TABLE [dbo].[PartSuppliers]  WITH CHECK ADD  CONSTRAINT [FK_PartSuppliers_Parts] FOREIGN KEY([PartID])
REFERENCES [dbo].[Parts] ([PartID])
ALTER TABLE [dbo].[PartSuppliers]  WITH CHECK ADD  CONSTRAINT [FK_PartSuppliers_Suppliers] FOREIGN KEY([SupplierID])
REFERENCES [dbo].[Suppliers] ([SupplierID])

-- Indexes
/****** Object:  Index [IX_PartSuppliers_PartID]    Script Date: 27.01.2026 13:39:51 ******/
CREATE NONCLUSTERED INDEX [IX_PartSuppliers_PartID] ON [dbo].[PartSuppliers]
(
	[PartID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
/****** Object:  Index [IX_PartSuppliers_SupplierID]    Script Date: 27.01.2026 13:39:51 ******/
CREATE NONCLUSTERED INDEX [IX_PartSuppliers_SupplierID] ON [dbo].[PartSuppliers]
(
	[SupplierID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
```
</details>

### 4.15. `dbo.Parts`

| Kolumna | Typ | NULL | DEFAULT | CHECK |
|---|---|---:|---|---|
| `PartID` | [int] | NIE |  |  |
| `PartName` | [varchar](50) | NIE |  |  |
| `UnitsInStock` | [int] | NIE |  |  |

**Ograniczenia w definicji tabeli (CREATE TABLE):**
- `CONSTRAINT [PK_Parts] PRIMARY KEY CLUSTERED ( [PartID] ASC )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]`

<details><summary>DDL (kod tworzący tabelę + powiązane ograniczenia/indeksy)</summary>

```sql
CREATE TABLE [dbo].[Parts](
	[PartID] [int] NOT NULL,
	[PartName] [varchar](50) NOT NULL,
	[UnitsInStock] [int] NOT NULL,
 CONSTRAINT [PK_Parts] PRIMARY KEY CLUSTERED 
(
	[PartID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
```
</details>

### 4.16. `dbo.PartsForOneUnit`

| Kolumna | Typ | NULL | DEFAULT | CHECK |
|---|---|---:|---|---|
| `ProductID` | [int] | NIE |  |  |
| `PartID` | [int] | NIE |  |  |
| `QuantityNeeded` | [int] | NIE |  |  |


**Dodatkowe ograniczenia (ALTER TABLE … ADD CONSTRAINT):**
- `ALTER TABLE [dbo].[PartsForOneUnit]  WITH CHECK ADD  CONSTRAINT [FK_PartsForOneUnit_Parts] FOREIGN KEY([PartID])`
- `ALTER TABLE [dbo].[PartsForOneUnit]  WITH CHECK ADD  CONSTRAINT [FK_PartsForOneUnit_Products] FOREIGN KEY([ProductID])`

**Indeksy:**
- `IX_PartsForOneUnit_PartID` na ([PartID] ASC)
- `IX_PartsForOneUnit_ProductID` na ([ProductID] ASC)

<details><summary>DDL (kod tworzący tabelę + powiązane ograniczenia/indeksy)</summary>

```sql
CREATE TABLE [dbo].[PartsForOneUnit](
	[ProductID] [int] NOT NULL,
	[PartID] [int] NOT NULL,
	[QuantityNeeded] [int] NOT NULL
) ON [PRIMARY]

-- ALTER TABLE constraints
ALTER TABLE [dbo].[PartsForOneUnit]  WITH CHECK ADD  CONSTRAINT [FK_PartsForOneUnit_Parts] FOREIGN KEY([PartID])
REFERENCES [dbo].[Parts] ([PartID])
ALTER TABLE [dbo].[PartsForOneUnit]  WITH CHECK ADD  CONSTRAINT [FK_PartsForOneUnit_Products] FOREIGN KEY([ProductID])
REFERENCES [dbo].[Products] ([ProductID])

-- Indexes
/****** Object:  Index [IX_PartsForOneUnit_PartID]    Script Date: 27.01.2026 13:39:51 ******/
CREATE NONCLUSTERED INDEX [IX_PartsForOneUnit_PartID] ON [dbo].[PartsForOneUnit]
(
	[PartID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
/****** Object:  Index [IX_PartsForOneUnit_ProductID]    Script Date: 27.01.2026 13:39:51 ******/
CREATE NONCLUSTERED INDEX [IX_PartsForOneUnit_ProductID] ON [dbo].[PartsForOneUnit]
(
	[ProductID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
```
</details>

### 4.17. `dbo.Payments`

| Kolumna | Typ | NULL | DEFAULT | CHECK |
|---|---|---:|---|---|
| `PaymentID` | [int] | NIE |  |  |
| `TaxID` | [int] | NIE |  |  |
| `OrderID` | [int] | NIE |  |  |
| `Amount` | [int] | NIE |  |  |
| `PaymentDate` | [date] | NIE |  |  |

**Ograniczenia w definicji tabeli (CREATE TABLE):**
- `CONSTRAINT [PK_Payments] PRIMARY KEY CLUSTERED ( [PaymentID] ASC )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]`

**Dodatkowe ograniczenia (ALTER TABLE … ADD CONSTRAINT):**
- `ALTER TABLE [dbo].[Payments]  WITH CHECK ADD  CONSTRAINT [FK_Payments_Orders] FOREIGN KEY([OrderID])`
- `ALTER TABLE [dbo].[Payments]  WITH CHECK ADD  CONSTRAINT [FK_Payments_Taxes] FOREIGN KEY([TaxID])`

**Indeksy:**
- `IX_Payments_OrderID` na ([OrderID] ASC)
- `IX_Payments_PaymentDate` na ([PaymentDate] ASC)
- `IX_Payments_TaxID` na ([TaxID] ASC)

<details><summary>DDL (kod tworzący tabelę + powiązane ograniczenia/indeksy)</summary>

```sql
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

-- ALTER TABLE constraints
ALTER TABLE [dbo].[Payments]  WITH CHECK ADD  CONSTRAINT [FK_Payments_Orders] FOREIGN KEY([OrderID])
REFERENCES [dbo].[Orders] ([OrderID])
ALTER TABLE [dbo].[Payments]  WITH CHECK ADD  CONSTRAINT [FK_Payments_Taxes] FOREIGN KEY([TaxID])
REFERENCES [dbo].[Taxes] ([TaxID])

-- Indexes
/****** Object:  Index [IX_Payments_OrderID]    Script Date: 27.01.2026 13:39:51 ******/
CREATE NONCLUSTERED INDEX [IX_Payments_OrderID] ON [dbo].[Payments]
(
	[OrderID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
/****** Object:  Index [IX_Payments_PaymentDate]    Script Date: 27.01.2026 13:39:51 ******/
CREATE NONCLUSTERED INDEX [IX_Payments_PaymentDate] ON [dbo].[Payments]
(
	[PaymentDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
/****** Object:  Index [IX_Payments_TaxID]    Script Date: 27.01.2026 13:39:51 ******/
CREATE NONCLUSTERED INDEX [IX_Payments_TaxID] ON [dbo].[Payments]
(
	[TaxID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
```
</details>

### 4.18. `dbo.ProductProductionSpec`

| Kolumna | Typ | NULL | DEFAULT | CHECK |
|---|---|---:|---|---|
| `ProductID` | [int] | NIE |  |  |
| `HoursPerUnit` | [decimal](8, 4) | NIE |  |  |

**Ograniczenia w definicji tabeli (CREATE TABLE):**
- `CONSTRAINT [PK_ProductProductionSpec] PRIMARY KEY CLUSTERED ( [ProductID] ASC )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]`

**Dodatkowe ograniczenia (ALTER TABLE … ADD CONSTRAINT):**
- `ALTER TABLE [dbo].[ProductProductionSpec]  WITH CHECK ADD  CONSTRAINT [FK_ProductProductionSpec_Products] FOREIGN KEY([ProductID])`
- `ALTER TABLE [dbo].[ProductProductionSpec]  WITH CHECK ADD  CONSTRAINT [CK_ProductProductionSpec_HoursPerUnit] CHECK  (([HoursPerUnit]>(0) AND [HoursPerUnit]<=(24)))`

<details><summary>DDL (kod tworzący tabelę + powiązane ograniczenia/indeksy)</summary>

```sql
CREATE TABLE [dbo].[ProductProductionSpec](
	[ProductID] [int] NOT NULL,
	[HoursPerUnit] [decimal](8, 4) NOT NULL,
 CONSTRAINT [PK_ProductProductionSpec] PRIMARY KEY CLUSTERED 
(
	[ProductID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

-- ALTER TABLE constraints
ALTER TABLE [dbo].[ProductProductionSpec]  WITH CHECK ADD  CONSTRAINT [FK_ProductProductionSpec_Products] FOREIGN KEY([ProductID])
REFERENCES [dbo].[Products] ([ProductID])
ALTER TABLE [dbo].[ProductProductionSpec]  WITH CHECK ADD  CONSTRAINT [CK_ProductProductionSpec_HoursPerUnit] CHECK  (([HoursPerUnit]>(0) AND [HoursPerUnit]<=(24)))
```
</details>

### 4.19. `dbo.ProductionOrders`

| Kolumna | Typ | NULL | DEFAULT | CHECK |
|---|---|---:|---|---|
| `ProductionOrderID` | [int] IDENTITY(1,1) | NIE |  |  |
| `OrderID` | [int] | TAK |  |  |
| `ProductID` | [int] | NIE |  |  |
| `FactoryID` | [int] | NIE |  |  |
| `Quantity` | [int] | NIE |  |  |
| `CreatedAt` | [datetime2](0) | NIE |  |  |
| `PlannedStart` | [datetime2](0) | TAK |  |  |
| `PlannedEnd` | [datetime2](0) | TAK |  |  |
| `DueDate` | [datetime2](0) | TAK |  |  |
| `Status` | [tinyint] | NIE |  |  |
| `Priority` | [tinyint] | NIE |  |  |
| `Notes` | [nvarchar](400) | TAK |  |  |

**Ograniczenia w definicji tabeli (CREATE TABLE):**
- `CONSTRAINT [PK_ProductionOrders] PRIMARY KEY CLUSTERED ( [ProductionOrderID] ASC )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]`

**Dodatkowe ograniczenia (ALTER TABLE … ADD CONSTRAINT):**
- `ALTER TABLE [dbo].[ProductionOrders]  WITH CHECK ADD  CONSTRAINT [FK_ProductionOrders_Factories] FOREIGN KEY([FactoryID])`
- `ALTER TABLE [dbo].[ProductionOrders]  WITH CHECK ADD  CONSTRAINT [FK_ProductionOrders_Orders] FOREIGN KEY([OrderID])`
- `ALTER TABLE [dbo].[ProductionOrders]  WITH CHECK ADD  CONSTRAINT [FK_ProductionOrders_Products] FOREIGN KEY([ProductID])`
- `ALTER TABLE [dbo].[ProductionOrders]  WITH CHECK ADD  CONSTRAINT [CK_ProductionOrders_Dates] CHECK  (([PlannedStart] IS NULL OR [PlannedEnd] IS NULL OR [PlannedEnd]>=[PlannedStart]))`
- `ALTER TABLE [dbo].[ProductionOrders]  WITH CHECK ADD  CONSTRAINT [CK_ProductionOrders_Priority] CHECK  (([Priority]>=(1) AND [Priority]<=(5)))`
- `ALTER TABLE [dbo].[ProductionOrders]  WITH CHECK ADD  CONSTRAINT [CK_ProductionOrders_Quantity] CHECK  (([Quantity]>(0)))`
- `ALTER TABLE [dbo].[ProductionOrders]  WITH CHECK ADD  CONSTRAINT [CK_ProductionOrders_Status] CHECK  (([Status]=(5) OR [Status]=(4) OR [Status]=(3) OR [Status]=(2) OR [Status]=(1) OR [Status]=(0)))`

**Indeksy:**
- `IX_ProductionOrders_CreatedAt` na ([CreatedAt] ASC)
- `IX_ProductionOrders_FactoryID` na ([FactoryID] ASC)
- `IX_ProductionOrders_OrderID` na ([OrderID] ASC)
- `IX_ProductionOrders_PlannedStart` na ([PlannedStart] ASC)

<details><summary>DDL (kod tworzący tabelę + powiązane ograniczenia/indeksy)</summary>

```sql
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

-- ALTER TABLE constraints
ALTER TABLE [dbo].[ProductionOrders]  WITH CHECK ADD  CONSTRAINT [FK_ProductionOrders_Factories] FOREIGN KEY([FactoryID])
REFERENCES [dbo].[Factories] ([FactoryID])
ALTER TABLE [dbo].[ProductionOrders]  WITH CHECK ADD  CONSTRAINT [FK_ProductionOrders_Orders] FOREIGN KEY([OrderID])
REFERENCES [dbo].[Orders] ([OrderID])
ALTER TABLE [dbo].[ProductionOrders]  WITH CHECK ADD  CONSTRAINT [FK_ProductionOrders_Products] FOREIGN KEY([ProductID])
REFERENCES [dbo].[Products] ([ProductID])
ALTER TABLE [dbo].[ProductionOrders]  WITH CHECK ADD  CONSTRAINT [CK_ProductionOrders_Dates] CHECK  (([PlannedStart] IS NULL OR [PlannedEnd] IS NULL OR [PlannedEnd]>=[PlannedStart]))
ALTER TABLE [dbo].[ProductionOrders]  WITH CHECK ADD  CONSTRAINT [CK_ProductionOrders_Priority] CHECK  (([Priority]>=(1) AND [Priority]<=(5)))
ALTER TABLE [dbo].[ProductionOrders]  WITH CHECK ADD  CONSTRAINT [CK_ProductionOrders_Quantity] CHECK  (([Quantity]>(0)))
ALTER TABLE [dbo].[ProductionOrders]  WITH CHECK ADD  CONSTRAINT [CK_ProductionOrders_Status] CHECK  (([Status]=(5) OR [Status]=(4) OR [Status]=(3) OR [Status]=(2) OR [Status]=(1) OR [Status]=(0)))

-- Indexes
/****** Object:  Index [IX_ProductionOrders_CreatedAt]    Script Date: 27.01.2026 13:39:51 ******/
CREATE NONCLUSTERED INDEX [IX_ProductionOrders_CreatedAt] ON [dbo].[ProductionOrders]
(
	[CreatedAt] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
/****** Object:  Index [IX_ProductionOrders_FactoryID]    Script Date: 27.01.2026 13:39:51 ******/
CREATE NONCLUSTERED INDEX [IX_ProductionOrders_FactoryID] ON [dbo].[ProductionOrders]
(
	[FactoryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
/****** Object:  Index [IX_ProductionOrders_OrderID]    Script Date: 27.01.2026 13:39:51 ******/
CREATE NONCLUSTERED INDEX [IX_ProductionOrders_OrderID] ON [dbo].[ProductionOrders]
(
	[OrderID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
/****** Object:  Index [IX_ProductionOrders_PlannedStart]    Script Date: 27.01.2026 13:39:51 ******/
CREATE NONCLUSTERED INDEX [IX_ProductionOrders_PlannedStart] ON [dbo].[ProductionOrders]
(
	[PlannedStart] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
```
</details>

### 4.20. `dbo.Products`

| Kolumna | Typ | NULL | DEFAULT | CHECK |
|---|---|---:|---|---|
| `ProductID` | [int] | NIE |  |  |
| `ProductName` | [varchar](50) | NIE |  |  |
| `UnitsInStock` | [int] | NIE |  |  |
| `CategoryID` | [int] | NIE |  |  |
| `UnitPrice` | [int] | NIE |  |  |

**Ograniczenia w definicji tabeli (CREATE TABLE):**
- `CONSTRAINT [PK_Products] PRIMARY KEY CLUSTERED ( [ProductID] ASC )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]`

**Dodatkowe ograniczenia (ALTER TABLE … ADD CONSTRAINT):**
- `ALTER TABLE [dbo].[Products]  WITH CHECK ADD  CONSTRAINT [FK_Products_Categories] FOREIGN KEY([CategoryID])`

**Indeksy:**
- `IX_Products_CategoryID` na ([CategoryID] ASC)

<details><summary>DDL (kod tworzący tabelę + powiązane ograniczenia/indeksy)</summary>

```sql
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

-- ALTER TABLE constraints
ALTER TABLE [dbo].[Products]  WITH CHECK ADD  CONSTRAINT [FK_Products_Categories] FOREIGN KEY([CategoryID])
REFERENCES [dbo].[Categories] ([CategoryID])

-- Indexes
/****** Object:  Index [IX_Products_CategoryID]    Script Date: 27.01.2026 13:39:51 ******/
CREATE NONCLUSTERED INDEX [IX_Products_CategoryID] ON [dbo].[Products]
(
	[CategoryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
```
</details>

### 4.21. `dbo.Refunds`

| Kolumna | Typ | NULL | DEFAULT | CHECK |
|---|---|---:|---|---|
| `RefundID` | [int] | NIE |  |  |
| `OrderID` | [int] | NIE |  |  |
| `ProductID` | [int] | NIE |  |  |
| `Quantity` | [int] | NIE |  |  |
| `RefundApproved` | [bit] | NIE |  |  |

**Ograniczenia w definicji tabeli (CREATE TABLE):**
- `CONSTRAINT [PK_Refunds] PRIMARY KEY CLUSTERED ( [RefundID] ASC )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]`

**Dodatkowe ograniczenia (ALTER TABLE … ADD CONSTRAINT):**
- `ALTER TABLE [dbo].[Refunds]  WITH CHECK ADD  CONSTRAINT [FK_Refunds_Orders] FOREIGN KEY([OrderID])`
- `ALTER TABLE [dbo].[Refunds]  WITH CHECK ADD  CONSTRAINT [FK_Refunds_Products] FOREIGN KEY([ProductID])`

**Indeksy:**
- `IX_Refunds_OrderID` na ([OrderID] ASC)
- `IX_Refunds_ProductID` na ([ProductID] ASC)

<details><summary>DDL (kod tworzący tabelę + powiązane ograniczenia/indeksy)</summary>

```sql
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

-- ALTER TABLE constraints
ALTER TABLE [dbo].[Refunds]  WITH CHECK ADD  CONSTRAINT [FK_Refunds_Orders] FOREIGN KEY([OrderID])
REFERENCES [dbo].[Orders] ([OrderID])
ALTER TABLE [dbo].[Refunds]  WITH CHECK ADD  CONSTRAINT [FK_Refunds_Products] FOREIGN KEY([ProductID])
REFERENCES [dbo].[Products] ([ProductID])

-- Indexes
/****** Object:  Index [IX_Refunds_OrderID]    Script Date: 27.01.2026 13:39:51 ******/
CREATE NONCLUSTERED INDEX [IX_Refunds_OrderID] ON [dbo].[Refunds]
(
	[OrderID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
/****** Object:  Index [IX_Refunds_ProductID]    Script Date: 27.01.2026 13:39:51 ******/
CREATE NONCLUSTERED INDEX [IX_Refunds_ProductID] ON [dbo].[Refunds]
(
	[ProductID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
```
</details>

### 4.22. `dbo.Shippers`

| Kolumna | Typ | NULL | DEFAULT | CHECK |
|---|---|---:|---|---|
| `ShipperID` | [int] | NIE |  |  |
| `CompanyName` | [varchar](50) | NIE |  |  |
| `Phone` | [varchar](50) | NIE |  |  |
| `Address` | [varchar](50) | NIE |  |  |
| `EmailAddress` | [varchar](50) | NIE |  |  |

**Ograniczenia w definicji tabeli (CREATE TABLE):**
- `CONSTRAINT [PK_Shippers] PRIMARY KEY CLUSTERED ( [ShipperID] ASC )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]`

<details><summary>DDL (kod tworzący tabelę + powiązane ograniczenia/indeksy)</summary>

```sql
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
```
</details>

### 4.23. `dbo.Suppliers`

| Kolumna | Typ | NULL | DEFAULT | CHECK |
|---|---|---:|---|---|
| `SupplierID` | [int] | NIE |  |  |
| `CompanyName` | [varchar](50) | NIE |  |  |
| `Phone` | [varchar](50) | NIE |  |  |
| `Address` | [varchar](50) | NIE |  |  |
| `EmailAdress` | [varchar](50) | NIE |  |  |

**Ograniczenia w definicji tabeli (CREATE TABLE):**
- `CONSTRAINT [PK_Suppliers] PRIMARY KEY CLUSTERED ( [SupplierID] ASC )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]`

<details><summary>DDL (kod tworzący tabelę + powiązane ograniczenia/indeksy)</summary>

```sql
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
```
</details>

### 4.24. `dbo.Taxes`

| Kolumna | Typ | NULL | DEFAULT | CHECK |
|---|---|---:|---|---|
| `TaxID` | [int] | NIE |  |  |
| `TaxName` | [varchar](50) | NIE |  |  |
| `TaxValue` | [int] | NIE |  |  |

**Ograniczenia w definicji tabeli (CREATE TABLE):**
- `CONSTRAINT [PK_Taxes] PRIMARY KEY CLUSTERED ( [TaxID] ASC )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]`

<details><summary>DDL (kod tworzący tabelę + powiązane ograniczenia/indeksy)</summary>

```sql
CREATE TABLE [dbo].[Taxes](
	[TaxID] [int] NOT NULL,
	[TaxName] [varchar](50) NOT NULL,
	[TaxValue] [int] NOT NULL,
 CONSTRAINT [PK_Taxes] PRIMARY KEY CLUSTERED 
(
	[TaxID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
```
</details>

## 5. Typy użytkownika (UDTT)

### `dbo.OrderItemType`

**Opis:** Typ tabelaryczny używany do przekazywania listy pozycji zamówienia do procedur (np. składanie zamówienia).

```sql
/****** Object:  UserDefinedTableType [dbo].[OrderItemType]    Script Date: 27.01.2026 13:39:50 ******/
CREATE TYPE [dbo].[OrderItemType] AS TABLE(
	[ProductID] [int] NOT NULL,
	[Quantity] [int] NOT NULL,
	[UnitPrice] [int] NULL,
	[Discount] [int] NULL
)
```

## 6. Funkcje (UDF)

### `dbo.AvailableStock`

**Opis:** Zwraca dostępny stan magazynowy produktu (z uwzględnieniem rezerwacji/zużyć).

```sql
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
```

### `dbo.CalculateMaterialCostForProduct`

**Opis:** Liczy koszt materiałów potrzebnych do wytworzenia 1 sztuki produktu na podstawie BOM i cenników dostawców.

```sql
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
```

### `dbo.CalculatePartCostForProduct`

**Opis:** Liczy koszt części potrzebnych do wytworzenia 1 sztuki produktu na podstawie BOM i cenników dostawców.

```sql
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
```

### `dbo.CalculateProductionCost`

**Opis:** Liczy łączny koszt wytworzenia produktu (materiały + części + robocizna itp. zgodnie z modelem).

```sql
CREATE FUNCTION [dbo].[CalculateProductionCost]
(
    @ProductID INT
)
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @MaterialCost DECIMAL(18,2);
    DECLARE @PartCost DECIMAL(18,2);

    -- koszt materiałów
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

    -- koszt części
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
```

### `dbo.GetBestSupplierForMaterial`

**Opis:** Zwraca najlepszego dostawcę materiału (np. minimalna cena w aktualnym cenniku).

```sql
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
```

### `dbo.GetBestSupplierForPart`

**Opis:** Zwraca najlepszego dostawcę części (np. minimalna cena w aktualnym cenniku).

```sql
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
```

### `dbo.OrderDiscount`

**Opis:** Wylicza rabat dla zamówienia.

```sql
/* Suma rabatów (kwotowo): UnitPrice * Quantity * Discount% */
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
```

### `dbo.OrderSubtotal`

**Opis:** Wylicza wartość netto (suma pozycji) dla zamówienia.

```sql
/* Suma pozycji: UnitPrice * Quantity */
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
```

### `dbo.OrderTax`

**Opis:** Wylicza podatek dla zamówienia.

```sql
/* Podatek dla zamówienia na podstawie stawki z Taxes powiązanej z ostatnią płatnością.
   Jeśli brak płatności -> 0.
*/
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
```

### `dbo.OrderTotal`

**Opis:** Wylicza wartość brutto zamówienia (subtotal - rabat + tax).

```sql
/* Total: subtotal - discount + freight + tax */
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
```

## 7. Procedury składowane

### `dbo.AddPayment`

**Opis:** Rejestruje płatność do zamówienia i wykonuje walidacje spójności kwot/statusów.

```sql
/* AddPayment: dodaje płatność do zamówienia + walidacje */
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

        -- generacja PaymentID w transakcji
        SELECT @NewPaymentID = ISNULL(MAX(PaymentID), 0) + 1
        FROM dbo.Payments WITH (UPDLOCK, HOLDLOCK);

        -- walidacja
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
```

### `dbo.ApproveRefund`

**Opis:** Obsługa zatwierdzenia zwrotu/reklamacji (zmiana statusów i korekty).

```sql
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
```

### `dbo.PlaceOrder`

**Opis:** Składa zamówienie klienta (nagłówek + pozycje) w transakcji, z walidacją dat i kosztów; korzysta z `dbo.OrderItemType`.

```sql
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
```

### `dbo.ReceiveStock`

**Opis:** Przyjęcie towaru/produkcji na magazyn (aktualizacja stanów).

```sql
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
```

### `dbo.ScheduleProductionOrder`

**Opis:** Planowanie zleceń produkcyjnych w oparciu o moce przerobowe i kalendarz fabryk.

```sql
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

    -- pobierz dane zlecenia
    SELECT
        @FactoryID = FactoryID,
        @ProductID = ProductID,
        @Quantity  = Quantity
    FROM dbo.ProductionOrders WITH (UPDLOCK, HOLDLOCK)
    WHERE ProductionOrderID = @ProductionOrderID;

    IF @FactoryID IS NULL
        THROW 50001, 'ProductionOrder not found.', 1;

    -- spec produktu
    SELECT @HoursPerUnit = HoursPerUnit
    FROM dbo.ProductProductionSpec
    WHERE ProductID = @ProductID;

    IF @HoursPerUnit IS NULL
        THROW 50002, 'Missing ProductProductionSpec for this ProductID.', 1;

    SET @RequiredHours = CAST(@Quantity AS DECIMAL(12,4)) * CAST(@HoursPerUnit AS DECIMAL(12,4));
    SET @RemainingHours = @RequiredHours;

    BEGIN TRAN;

        -- replanowanie: usuń stare rezerwacje tego PO
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
```

### `dbo.SeedFactoryCapacityCalendar`

**Opis:** Zasila kalendarz mocy przerobowych fabryk (np. dni pracy i limity).

```sql
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
```

### `dbo.ShipOrder`

**Opis:** Oznacza zamówienie jako wysłane / realizuje etap wysyłki (logika statusów i dat).

```sql
/* ShipOrder: ustawia ShipDate + walidacje */
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
```

## 8. Widoki

### `dbo.vFactoriesCategories`

**Opis:** Powiązania fabryk z kategoriami produktów (kompetencje produkcyjne).

```sql
CREATE VIEW [dbo].[vFactoriesCategories]
AS
SELECT DISTINCT f.FactoryID, f.FactoryName, c.CategoryID, c.CategoryName
FROM     dbo.Factories AS f INNER JOIN
                  dbo.FactoriesAndCategories AS fc ON f.FactoryID = fc.CategoryID INNER JOIN
                  dbo.Categories AS c ON fc.CategoryID = c.CategoryID
```

### `dbo.vInventory_Status`

**Opis:** Bieżące stany magazynowe oraz sygnały o brakach / planach produkcji.

```sql
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
```

### `dbo.vLowStockProducts`

**Opis:** Produkty o niskim stanie magazynowym (alerty).

```sql
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
```

### `dbo.vOrderSummary`

**Opis:** Podsumowanie zamówienia (wartości, rabaty, podatki, statusy).

```sql
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
```

### `dbo.vPaymentsByOrder`

**Opis:** Płatności pogrupowane / powiązane z zamówieniami (do kontroli rozliczeń).

```sql
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
```

### `dbo.vProductBOM`

**Opis:** Bill of Materials – definicja z czego produkt się składa (części/materiały/ilości).

```sql
CREATE VIEW [dbo].[vProductBOM]
AS
SELECT p.ProductID, p.ProductName, pf.PartID, pf.QuantityNeeded AS PartQuantityNeeded, mf.MaterialID, mf.QuantityNeeded AS MaterialQuantityNeeded
FROM     dbo.Products AS p LEFT OUTER JOIN
                  dbo.PartsForOneUnit AS pf ON pf.ProductID = p.ProductID LEFT OUTER JOIN
                  dbo.MaterialsForOneUnit AS mf ON mf.ProductID = p.ProductID
```

### `dbo.vProductUnitCost`

**Opis:** Koszt jednostkowy produktu (wyliczenia kosztów produkcji).

```sql
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
```

### `dbo.vProductionCosts_ByCategory_Month`

**Opis:** Raport kosztów produkcji wg kategorii w ujęciu miesięcznym.

```sql
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
```

### `dbo.vProductionCosts_ByCategory_Quarter`

**Opis:** Raport kosztów produkcji wg kategorii w ujęciu kwartalnym.

```sql
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
```

### `dbo.vProductionCosts_ByCategory_Year`

**Opis:** Raport kosztów produkcji wg kategorii w ujęciu rocznym.

```sql
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
```

### `dbo.vProductionPlan_FactoryDailyLoad`

**Opis:** Obciążenie dzienne fabryk wynikające z planów produkcji.

```sql
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
```

### `dbo.vProductionPlan_Orders`

**Opis:** Zestawienie planu produkcji dla zamówień (co/ile/kiedy).

```sql
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
```

### `dbo.vRefundsWithOrderInfo`

**Opis:** Zwroty/reklamacje z danymi zamówienia.

```sql
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
```

### `dbo.vSalesLines`

**Opis:** Pozycje sprzedażowe (order details) jako baza do raportów sprzedaży.

```sql
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
```

### `dbo.vSales_ByCategory_Month`

**Opis:** Sprzedaż wg kategorii w ujęciu miesięcznym.

```sql
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
```

### `dbo.vSales_ByCategory_Week`

**Opis:** Sprzedaż wg kategorii w ujęciu tygodniowym.

```sql
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
```

### `dbo.vSupplierPriceList`

**Opis:** Ujednolicony cennik dostawców (materiały + części) do analiz kosztów.

```sql
CREATE VIEW [dbo].[vSupplierPriceList]
AS
SELECT s.SupplierID, s.CompanyName, ps.PartID, ps.UnitPrice AS ProductPrice, ms.MaterialID, ms.UnitPrice AS MaterialPrice, ms.Freight AS MaterialFreight, ps.Freight AS PartFreight
FROM     dbo.Suppliers AS s LEFT OUTER JOIN
                  dbo.PartSuppliers AS ps ON ps.SupplierID = s.SupplierID LEFT OUTER JOIN
                  dbo.MaterialSuppliers AS ms ON ms.SupplierID = s.SupplierID
```

## 9. Triggery

### `dbo.trg_OrderDetails_Stock`

**Opis:** Pilnuje spójności stanów magazynowych przy dodawaniu/edycji pozycji zamówienia (rezerwacje/zużycia).

```sql
CREATE   TRIGGER [dbo].[trg_OrderDetails_Stock]
ON [dbo].[OrderDetails]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    -- policz różnicę (inserted - deleted) po QuantityFromStock
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

    -- walidacja: nie schodzimy poniżej zera
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

    -- aktualizacja stanów
    UPDATE p
        SET p.UnitsInStock = p.UnitsInStock - dt.DeltaQty
    FROM dbo.Products p
    JOIN #Delta dt ON dt.ProductID = p.ProductID
    WHERE dt.DeltaQty <> 0;
END
```

### `dbo.trg_Payments_Validate`

**Opis:** Waliduje dane płatności (np. kwoty, powiązania z zamówieniem, statusy).

```sql
CREATE   TRIGGER [dbo].[trg_Payments_Validate]
ON [dbo].[Payments]
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- brak ujemnych / zerowych kwot
    IF EXISTS (SELECT 1 FROM inserted WHERE Amount <= 0)
    BEGIN
        RAISERROR('Amount musi być > 0.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- PaymentDate >= OrderDate
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

    -- spójność: suma płatności <= OrderTotal
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
```

### `dbo.trg_Products_MinPrice`

**Opis:** Pilnuje minimalnej ceny produktu (reguła biznesowa) przy insert/update.

```sql
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
```

### `dbo.trg_Refunds_Approve`

**Opis:** Obsługuje skutki zatwierdzania zwrotu (statusy, korekty, ewentualne zwroty na magazyn).

```sql
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
```

## 10. Indeksy

Indeksy zostały utworzone głównie pod klucze obce (FK) oraz pola dat używane w raportach (np. zamówienia/płatności/planowanie produkcji).

### `dbo.Employees`
- `IX_Employees_FactoryID`: ([FactoryID] ASC)
- `IX_Employees_OccupationID`: ([OccupationID] ASC)

### `dbo.FactoryCapacityCalendar`
- `IX_FactoryCapacityCalendar_WorkDate`: ([WorkDate] ASC)

### `dbo.FactoryCapacityReservations`
- `IX_FactoryCapacityReservations_POID`: ([ProductionOrderID] ASC)

### `dbo.MaterialSuppliers`
- `IX_MaterialSuppliers_MaterialID`: ([MaterialID] ASC)
- `IX_MaterialSuppliers_SupplierID`: ([SupplierID] ASC)

### `dbo.MaterialsForOneUnit`
- `IX_MaterialsForOneUnit_MaterialID`: ([MaterialID] ASC)
- `IX_MaterialsForOneUnit_ProductID`: ([ProductID] ASC)

### `dbo.OrderDetails`
- `IX_OrderDetails_OrderID`: ([OrderID] ASC)
- `IX_OrderDetails_ProductID`: ([ProductID] ASC)

### `dbo.Orders`
- `IX_Orders_CustomerID`: ([CustomerID] ASC)
- `IX_Orders_EmployeeID`: ([EmployeeID] ASC)
- `IX_Orders_OrderDate`: ([OrderDate] ASC)
- `IX_Orders_ShipperID`: ([ShipperID] ASC)

### `dbo.PartSuppliers`
- `IX_PartSuppliers_PartID`: ([PartID] ASC)
- `IX_PartSuppliers_SupplierID`: ([SupplierID] ASC)

### `dbo.PartsForOneUnit`
- `IX_PartsForOneUnit_PartID`: ([PartID] ASC)
- `IX_PartsForOneUnit_ProductID`: ([ProductID] ASC)

### `dbo.Payments`
- `IX_Payments_OrderID`: ([OrderID] ASC)
- `IX_Payments_PaymentDate`: ([PaymentDate] ASC)
- `IX_Payments_TaxID`: ([TaxID] ASC)

### `dbo.ProductionOrders`
- `IX_ProductionOrders_CreatedAt`: ([CreatedAt] ASC)
- `IX_ProductionOrders_FactoryID`: ([FactoryID] ASC)
- `IX_ProductionOrders_OrderID`: ([OrderID] ASC)
- `IX_ProductionOrders_PlannedStart`: ([PlannedStart] ASC)

### `dbo.Products`
- `IX_Products_CategoryID`: ([CategoryID] ASC)

### `dbo.Refunds`
- `IX_Refunds_OrderID`: ([OrderID] ASC)
- `IX_Refunds_ProductID`: ([ProductID] ASC)

## 11. Role i uprawnienia

W systemie zdefiniowano role aplikacyjne oraz nadano im uprawnienia głównie do **widoków** i **procedur/funkcji**, zgodnie z zaleceniem „enterprise” (unikać dostępu do gołych tabel). fileciteturn1file1

### 11.1. Zdefiniowane role
- `role_admin`
- `role_production`
- `role_reporting`
- `role_sales`

### 11.2. Uprawnienia per rola (GRANT)
#### `role_admin`
- `DATABASE`: CONTROL

#### `role_production`
- `dbo.Categories`: SELECT
- `dbo.Employees`: SELECT
- `dbo.Factories`: SELECT
- `dbo.FactoriesAndCategories`: SELECT
- `dbo.FactoryCapacityCalendar`: SELECT
- `dbo.FactoryCapacityReservations`: SELECT
- `dbo.MaterialSuppliers`: SELECT
- `dbo.Materials`: SELECT
- `dbo.MaterialsForOneUnit`: SELECT
- `dbo.Occupation`: SELECT
- `dbo.PartSuppliers`: SELECT
- `dbo.Parts`: SELECT
- `dbo.PartsForOneUnit`: SELECT
- `dbo.ProductProductionSpec`: SELECT
- `dbo.ProductionOrders`: SELECT
- `dbo.Products`: SELECT
- `dbo.ReceiveStock`: EXECUTE
- `dbo.ScheduleProductionOrder`: EXECUTE
- `dbo.SeedFactoryCapacityCalendar`: EXECUTE
- `dbo.Suppliers`: SELECT
- `dbo.vInventory_Status`: SELECT
- `dbo.vLowStockProducts`: SELECT
- `dbo.vProductionPlan_FactoryDailyLoad`: SELECT
- `dbo.vProductionPlan_Orders`: SELECT

#### `role_reporting`
- `dbo.AvailableStock`: EXECUTE
- `dbo.OrderDiscount`: EXECUTE
- `dbo.OrderSubtotal`: EXECUTE
- `dbo.OrderTax`: EXECUTE
- `dbo.OrderTotal`: EXECUTE
- `dbo.vInventory_Status`: SELECT
- `dbo.vLowStockProducts`: SELECT
- `dbo.vOrderSummary`: SELECT
- `dbo.vProductUnitCost`: SELECT
- `dbo.vProductionCosts_ByCategory_Month`: SELECT
- `dbo.vProductionCosts_ByCategory_Quarter`: SELECT
- `dbo.vProductionCosts_ByCategory_Year`: SELECT
- `dbo.vProductionPlan_FactoryDailyLoad`: SELECT
- `dbo.vProductionPlan_Orders`: SELECT
- `dbo.vSalesLines`: SELECT
- `dbo.vSales_ByCategory_Month`: SELECT
- `dbo.vSales_ByCategory_Week`: SELECT

#### `role_sales`
- `dbo.AddPayment`: EXECUTE
- `dbo.ApproveRefund`: EXECUTE
- `dbo.Categories`: SELECT
- `dbo.Customers`: SELECT
- `dbo.OrderDetails`: SELECT
- `dbo.Orders`: SELECT
- `dbo.Payments`: SELECT
- `dbo.PlaceOrder`: EXECUTE
- `dbo.Products`: SELECT
- `dbo.Refunds`: SELECT
- `dbo.ShipOrder`: EXECUTE
- `dbo.Shippers`: SELECT
- `dbo.Taxes`: SELECT
- `dbo.vOrderSummary`: SELECT
- `dbo.vSalesLines`: SELECT
- `dbo.vSales_ByCategory_Month`: SELECT
- `dbo.vSales_ByCategory_Week`: SELECT

## 12. Uwagi dot. danych testowych (seed)

Skrypt zawiera sekcje INSERT/seed służące do wygenerowania przykładowych danych (produkty, klienci, zamówienia, płatności itp.) zgodnie z wymaganiem posiadania danych historycznych do raportów. fileciteturn1file1

---
### Załączniki / pliki
- `msh_company_script.sql` – skrypt tworzący obiekty bazy danych
- `data_generator.py` - skrypt tworzący dane 
- `Projekt2025.pdf` – treść wymagań projektu fileciteturn1file0
