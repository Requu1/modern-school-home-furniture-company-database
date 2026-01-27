from __future__ import annotations

import random
import datetime as dt
import sys
from dataclasses import dataclass
from decimal import Decimal, ROUND_HALF_UP
from typing import Dict, List, Tuple, Optional

import pyodbc
from faker import Faker


def build_connection_string_from_args() -> str:
    if len(sys.argv) < 3:
        raise SystemExit('Użycie: py data_generator.py <USER> <PASSWORD>')

    user = sys.argv[1]
    password = sys.argv[2]

    return (
        "DRIVER={ODBC Driver 17 for SQL Server};"
        "SERVER=dbmanage.lab.ii.agh.edu.pl;"
        f"DATABASE={user};"
        f"UID={user};"
        f"PWD={password};"
        "TrustServerCertificate=yes;"
    )


SEED = 2026
CLEAN_DB = True

N_CATEGORIES = 8
N_PRODUCTS = 18
N_CUSTOMERS = 16
N_FACTORIES = 3
N_OCCUPATIONS = 6
N_EMPLOYEES = 22
N_SHIPPERS = 5
N_TAXES = 3
N_SUPPLIERS = 10
N_MATERIALS = 20
N_PARTS = 30
N_ORDERS = 120

HISTORY_MONTHS_BACK = 18

fake = Faker("pl_PL")


def daterange(d0: dt.date, d1: dt.date):
    cur = d0
    while cur <= d1:
        yield cur
        cur += dt.timedelta(days=1)


def is_weekend(d: dt.date) -> bool:
    return d.weekday() >= 5


def pick_some(population: List[int], k_min: int, k_max: int) -> List[int]:
    k = random.randint(k_min, min(k_max, len(population)))
    return random.sample(population, k)


def connect() -> pyodbc.Connection:
    conn_str = build_connection_string_from_args()
    cn = pyodbc.connect(conn_str, autocommit=False)
    cn.timeout = 60
    return cn


def exec_many(cur: pyodbc.Cursor, sql: str, rows: List[Tuple]):
    if not rows:
        return
    cur.fast_executemany = True
    cur.executemany(sql, rows)


def get_decimal_scale(cur: pyodbc.Cursor, table: str, column: str, schema: str = "dbo") -> int:
    cur.execute("""
        SELECT COALESCE(NUMERIC_SCALE, 2)
        FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA = ? AND TABLE_NAME = ? AND COLUMN_NAME = ?
    """, (schema, table, column))
    row = cur.fetchone()
    if not row or row[0] is None:
        return 2
    return int(row[0])


def qdec(value: Decimal, scale: int) -> Decimal:
    if value is None:
        return value
    quant = Decimal("1").scaleb(-scale)
    return Decimal(value).quantize(quant, rounding=ROUND_HALF_UP)


def clean_database(cur: pyodbc.Cursor):
    order = [
        "FactoryCapacityReservations",
        "FactoryCapacityCalendar",
        "Refunds",
        "Payments",
        "OrderDetails",
        "ProductionOrders",
        "Orders",
        "Employees",
        "FactoriesAndCategories",
        "MaterialSuppliers",
        "PartSuppliers",
        "MaterialsForOneUnit",
        "PartsForOneUnit",
        "ProductProductionSpec",
        "Products",
        "Customers",
        "Shippers",
        "Taxes",
        "Materials",
        "Parts",
        "Suppliers",
        "Factories",
        "Occupation",
        "Categories",
    ]
    for t in order:
        cur.execute(f"DELETE FROM dbo.{t};")


@dataclass(frozen=True)
class OrderLine:
    product_id: int
    unit_price: int
    qty: int
    discount: int
    qty_from_stock: int


def reprice_products_to_cover_costs(cur: pyodbc.Cursor):
    cur.execute("""
        SELECT MaterialID, AVG(CAST(UnitPrice AS float)) AS AvgPrice
        FROM dbo.MaterialSuppliers
        GROUP BY MaterialID
    """)
    mat_avg = {int(mid): float(p) for mid, p in cur.fetchall()}

    cur.execute("""
        SELECT PartID, AVG(CAST(UnitPrice AS float)) AS AvgPrice
        FROM dbo.PartSuppliers
        GROUP BY PartID
    """)
    part_avg = {int(pid): float(p) for pid, p in cur.fetchall()}

    cur.execute("SELECT ProductID, CategoryID FROM dbo.Products")
    prod_cat = {int(pid): int(cid) for pid, cid in cur.fetchall()}

    cur.execute("""
        SELECT CategoryID, MIN(CAST(ProductionCost AS float)) AS MinCost
        FROM dbo.FactoriesAndCategories
        GROUP BY CategoryID
    """)
    prod_cost_by_cat = {int(cid): float(c) for cid, c in cur.fetchall()}

    cur.execute("SELECT ProductID, MaterialID, QuantityNeeded FROM dbo.MaterialsForOneUnit")
    mats_for_prod: Dict[int, List[Tuple[int, int]]] = {}
    for pid, mid, qty in cur.fetchall():
        mats_for_prod.setdefault(int(pid), []).append((int(mid), int(qty)))

    cur.execute("SELECT ProductID, PartID, QuantityNeeded FROM dbo.PartsForOneUnit")
    parts_for_prod: Dict[int, List[Tuple[int, int]]] = {}
    for pid, partid, qty in cur.fetchall():
        parts_for_prod.setdefault(int(pid), []).append((int(partid), int(qty)))

    updates: List[Tuple[int, int]] = []
    for pid, cid in prod_cat.items():
        material_cost = sum(qty * mat_avg.get(mid, 50.0) for mid, qty in mats_for_prod.get(pid, []))
        parts_cost = sum(qty * part_avg.get(partid, 10.0) for partid, qty in parts_for_prod.get(pid, []))
        production_cost = prod_cost_by_cat.get(cid, 100.0)
        base_cost = material_cost + parts_cost + production_cost

        margin = random.uniform(1.35, 1.70)
        selling = int((base_cost * margin) + 0.9999)
        selling = max(selling, 100)
        updates.append((selling, pid))

    cur.fast_executemany = True
    cur.executemany("UPDATE dbo.Products SET UnitPrice=? WHERE ProductID=?", updates)


def generate() -> None:
    random.seed(SEED)
    Faker.seed(SEED)

    today = dt.date.today()
    start_date = today - dt.timedelta(days=HISTORY_MONTHS_BACK * 30)

    cn = connect()
    cur = cn.cursor()

    try:
        if CLEAN_DB:
            clean_database(cur)

        categories = [(i, name) for i, name in enumerate([
            "Biurka",
            "Biurka gamingowe",
            "Krzesła",
            "Fotele biurowe",
            "Fotele gamingowe",
            "Stoły",
            "Stojaki na projektory",
            "Tablice interaktywne",
        ], start=1)]
        categories = categories[:N_CATEGORIES]
        exec_many(cur, "INSERT INTO dbo.Categories(CategoryID, CategoryName) VALUES (?,?)", categories)

        occupations = [(i, name) for i, name in enumerate([
            "Monter",
            "Spawacz",
            "Lakiernik",
            "Kontroler jakości",
            "Magazynier",
            "Kierownik zmiany",
        ], start=1)]
        occupations = occupations[:N_OCCUPATIONS]
        exec_many(cur, "INSERT INTO dbo.Occupation(OccupationID, OccupationName) VALUES (?,?)", occupations)

        factories = []
        for i in range(1, N_FACTORIES + 1):
            factories.append((
                i,
                f"Fabryka {i}",
                fake.street_address()[:50],
                fake.phone_number()[:50],
                fake.company_email()[:50],
                fake.url()[:50],
            ))
        exec_many(cur, """
            INSERT INTO dbo.Factories(FactoryID, FactoryName, Address, Phone, EmailAddress, Website)
            VALUES (?,?,?,?,?,?)
        """, factories)

        shippers = []
        for i in range(1, N_SHIPPERS + 1):
            shippers.append((
                i,
                f"Kurier {fake.last_name()}",
                fake.phone_number()[:50],
                fake.street_address()[:50],
                fake.company_email()[:50],
            ))
        exec_many(cur, """
            INSERT INTO dbo.Shippers(ShipperID, CompanyName, Phone, Address, EmailAddress)
            VALUES (?,?,?,?,?)
        """, shippers)

        taxes = [
            (1, "VAT 23%", 23),
            (2, "VAT 8%", 8),
            (3, "VAT 0%", 0),
        ][:N_TAXES]
        exec_many(cur, "INSERT INTO dbo.Taxes(TaxID, TaxName, TaxValue) VALUES (?,?,?)", taxes)

        suppliers = []
        for i in range(1, N_SUPPLIERS + 1):
            suppliers.append((
                i,
                f"{fake.company()[:40]}",
                fake.phone_number()[:50],
                fake.street_address()[:50],
                fake.company_email()[:50],
            ))
        exec_many(cur, """
            INSERT INTO dbo.Suppliers(SupplierID, CompanyName, Phone, Address, EmailAdress)
            VALUES (?,?,?,?,?)
        """, suppliers)

        materials = []
        for i in range(1, N_MATERIALS + 1):
            materials.append((
                i,
                f"Materiał {i} - {random.choice(['stal', 'aluminium', 'tworzywo', 'lakier', 'pianka'])}",
                random.randint(200, 1500)
            ))
        exec_many(cur, "INSERT INTO dbo.Materials(MaterialID, MaterialName, UnitsInStock) VALUES (?,?,?)", materials)

        parts = []
        for i in range(1, N_PARTS + 1):
            parts.append((
                i,
                f"Część {i} - {random.choice(['śruba', 'profil', 'blat', 'nóżka', 'podłokietnik', 'łącznik'])}",
                random.randint(300, 3000)
            ))
        exec_many(cur, "INSERT INTO dbo.Parts(PartID, PartName, UnitsInStock) VALUES (?,?,?)", parts)

        cat_ids = [c[0] for c in categories]
        products = []
        for i in range(1, N_PRODUCTS + 1):
            cat = random.choice(cat_ids)
            name = f"{random.choice(['Ergo', 'Pro', 'Gamer', 'Office', 'Smart'])} {random.choice(['Desk', 'Chair', 'Table', 'Stand', 'Board'])} {i}"
            stock = random.randint(1, 40)
            price = random.randint(250, 3500)
            products.append((i, name[:50], stock, cat, price))

        exec_many(cur, """
            INSERT INTO dbo.Products(ProductID, ProductName, UnitsInStock, CategoryID, UnitPrice)
            VALUES (?,?,?,?,?)
        """, products)

        hpp_scale = get_decimal_scale(cur, "ProductProductionSpec", "HoursPerUnit")
        pps = []
        for (pid, *_rest) in products:
            hours = qdec(Decimal(str(random.uniform(0.5, 6.0))), hpp_scale)
            pps.append((pid, hours))
        exec_many(cur, "INSERT INTO dbo.ProductProductionSpec(ProductID, HoursPerUnit) VALUES (?,?)", pps)

        fac_ids = [f[0] for f in factories]
        fac_cat = []
        for fid in fac_ids:
            for cid in pick_some(cat_ids, 3, len(cat_ids)):
                fac_cat.append((cid, fid, random.randint(40, 250)))
        exec_many(cur, """
            INSERT INTO dbo.FactoriesAndCategories(CategoryID, FactoryID, ProductionCost)
            VALUES (?,?,?)
        """, fac_cat)

        occ_ids = [o[0] for o in occupations]
        employees = []
        for i in range(1, N_EMPLOYEES + 1):
            fid = random.choice(fac_ids)
            oid = random.choice(occ_ids)
            gender = random.choice(["M", "K"])
            birth = fake.date_of_birth(minimum_age=20, maximum_age=60)
            hire = fake.date_between(start_date=start_date, end_date=today)
            employees.append((
                i, fid, oid,
                fake.first_name_male()[:50] if gender == "M" else fake.first_name_female()[:50],
                fake.last_name()[:50],
                birth, gender,
                fake.phone_number()[:50],
                float(round(random.uniform(4200, 12000), 2)),
                hire,
                random.choice(["Polska", "Ukraina", "Czechy", "Słowacja", "Niemcy"])[:50],
                fake.email()[:50],
                random.choice([0, 0, 0, 1]),
            ))
        exec_many(cur, """
            INSERT INTO dbo.Employees(EmployeeID, FactoryID, OccupationID, FirstName, LastName,
                                      BirthDate, Gender, Phone, Salary, HireDate, Nationality,
                                      EmailAddress, DisabilityStatement)
            VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)
        """, employees)

        customers = []
        for i in range(1, N_CUSTOMERS + 1):
            anonymous = 0 if random.random() < 0.85 else 1
            if anonymous:
                customers.append((i, None, None, None, None, None, 1))
            else:
                is_company = random.random() < 0.4
                name = fake.company() if is_company else f"{fake.first_name()} {fake.last_name()}"
                nip = random.randint(10_000_000, 99_999_999) if is_company else None
                customers.append((
                    i, name[:50],
                    fake.street_address()[:50],
                    fake.phone_number()[:50],
                    nip,
                    fake.email()[:50],
                    0,
                ))
        exec_many(cur, """
            INSERT INTO dbo.Customers(CustomerID, CustomerName, Address, Phone, NIP, EmailAddress, Anonymous)
            VALUES (?,?,?,?,?,?,?)
        """, customers)

        sup_ids = [s[0] for s in suppliers]
        mat_ids = [m[0] for m in materials]
        part_ids = [p[0] for p in parts]

        material_suppliers = []
        for mid in mat_ids:
            for sid in pick_some(sup_ids, 1, 3):
                material_suppliers.append((mid, sid, random.randint(10, 250), random.randint(0, 40)))
        exec_many(cur, """
            INSERT INTO dbo.MaterialSuppliers(MaterialID, SupplierID, UnitPrice, Freight)
            VALUES (?,?,?,?)
        """, material_suppliers)

        part_suppliers = []
        for partid in part_ids:
            for sid in pick_some(sup_ids, 1, 3):
                part_suppliers.append((sid, partid, random.randint(2, 120), random.randint(0, 30)))
        exec_many(cur, """
            INSERT INTO dbo.PartSuppliers(SupplierID, PartID, UnitPrice, Freight)
            VALUES (?,?,?,?)
        """, part_suppliers)

        materials_for_unit = []
        parts_for_unit = []
        for (prod_id, *_rest) in products:
            for mid in pick_some(mat_ids, 1, 3):
                materials_for_unit.append((prod_id, mid, random.randint(1, 6)))
            for part_id in pick_some(part_ids, 2, 7):
                parts_for_unit.append((prod_id, part_id, random.randint(1, 12)))

        exec_many(cur, """
            INSERT INTO dbo.MaterialsForOneUnit(ProductID, MaterialID, QuantityNeeded)
            VALUES (?,?,?)
        """, materials_for_unit)

        exec_many(cur, """
            INSERT INTO dbo.PartsForOneUnit(ProductID, PartID, QuantityNeeded)
            VALUES (?,?,?)
        """, parts_for_unit)

        reprice_products_to_cover_costs(cur)

        cur.execute("SELECT ProductID, UnitPrice FROM dbo.Products")
        db_prices = {int(pid): int(float(price)) for pid, price in cur.fetchall()}

        horizon_start = start_date - dt.timedelta(days=30)
        horizon_end = today + dt.timedelta(days=90)

        cap_scale = get_decimal_scale(cur, "FactoryCapacityCalendar", "CapacityHours")
        cal_rows = []
        for fid in fac_ids:
            for d in daterange(horizon_start, horizon_end):
                cap = Decimal("0") if is_weekend(d) else Decimal(str(random.uniform(14.0, 18.0)))
                cap = qdec(cap, cap_scale)
                cal_rows.append((fid, d, cap))

        exec_many(cur, """
            INSERT INTO dbo.FactoryCapacityCalendar(FactoryID, WorkDate, CapacityHours)
            VALUES (?,?,?)
        """, cal_rows)

        stock: Dict[int, int] = {pid: units for (pid, _name, units, _cat, _price) in products}
        prod_hours: Dict[int, Decimal] = {pid: hours for (pid, hours) in pps}

        fac_by_cat: Dict[int, List[int]] = {}
        for cid, fid, _cost in fac_cat:
            fac_by_cat.setdefault(cid, []).append(fid)

        prod_cat: Dict[int, int] = {pid: cat for (pid, _name, _st, cat, _price) in products}
        prod_price: Dict[int, int] = db_prices

        orders_rows = []
        details_rows = []
        refunds_rows = []
        reservations_rows: List[Tuple[int, dt.date, int, Decimal]] = []

        cur.execute("SELECT COALESCE(MAX(RefundID), 0) FROM dbo.Refunds")
        refund_id = int(cur.fetchone()[0]) + 1

        staged_prod_orders: List[
            Tuple[Optional[int], int, int, int, dt.datetime, Optional[dt.datetime], Optional[dt.datetime],
                  Optional[dt.datetime], int, int, Optional[str]]
        ] = []

        for oid in range(1, N_ORDERS + 1):
            customer_id = random.randint(1, N_CUSTOMERS)
            shipper_id = random.randint(1, N_SHIPPERS)
            employee_id = random.randint(1, N_EMPLOYEES)

            order_date = fake.date_between(start_date=start_date, end_date=today)
            requested = order_date + dt.timedelta(days=random.randint(7, 21))
            ship_date = order_date + dt.timedelta(days=random.randint(2, 10)) if random.random() < 0.92 else None
            freight = random.randint(0, 200)

            orders_rows.append((oid, employee_id, customer_id, shipper_id, order_date, ship_date, freight, requested))

            line_count = random.randint(1, 5)
            chosen_products = random.sample([p[0] for p in products], k=line_count)
            lines: List[OrderLine] = []
            for pid in chosen_products:
                qty = random.randint(1, 10)
                discount = random.choice([0, 0, 0, 5, 10, 15, 20])
                unit_price = int(prod_price.get(pid, 1000))
                from_stock = min(qty, stock.get(pid, 0))
                stock[pid] = stock.get(pid, 0) - from_stock
                lines.append(OrderLine(pid, unit_price, qty, discount, from_stock))

            for ln in lines:
                details_rows.append((oid, ln.product_id, ln.unit_price, ln.qty, ln.discount, ln.qty_from_stock))

                deficit = ln.qty - ln.qty_from_stock
                if deficit > 0:
                    cid = prod_cat[ln.product_id]
                    fid = random.choice(fac_by_cat.get(cid, fac_ids))
                    created_at = dt.datetime.combine(order_date, dt.time(hour=random.randint(8, 16)))
                    due_dt = dt.datetime.combine(requested, dt.time(hour=17))
                    status = random.choice([0, 1])
                    priority = random.choice([1, 2, 3])
                    staged_prod_orders.append((
                        oid, ln.product_id, fid, deficit, created_at,
                        None, None, due_dt, status, priority,
                        f"Auto: deficit {deficit} szt. dla zamówienia {oid}"
                    ))

            if random.random() < 0.10:
                ln = random.choice(lines)
                qty_ref = random.randint(1, max(1, ln.qty))
                approved = 1 if random.random() < 0.6 else 0
                refunds_rows.append((refund_id, oid, ln.product_id, qty_ref, approved))
                refund_id += 1

        exec_many(cur, """
            INSERT INTO dbo.Orders(OrderID, EmployeeID, CustomerID, ShipperID, OrderDate, ShipDate, Freight, RequestedDeliveryDate)
            VALUES (?,?,?,?,?,?,?,?)
        """, orders_rows)

        exec_many(cur, """
            INSERT INTO dbo.OrderDetails(OrderID, ProductID, UnitPrice, Quantity, Discount, QuantityFromStock)
            VALUES (?,?,?,?,?,?)
        """, details_rows)

        cur.execute("SELECT COALESCE(MAX(PaymentID), 0) FROM dbo.Payments")
        payment_id = int(cur.fetchone()[0]) + 1

        cur.execute("SELECT TaxID FROM dbo.Taxes")
        tax_ids = [int(r[0]) for r in cur.fetchall()]
        if not tax_ids:
            raise RuntimeError("No rows in dbo.Taxes (cannot create payments).")

        cur.execute("SELECT OrderID, OrderDate, Freight FROM dbo.Orders")
        order_meta = {int(oid): (od, int(fr or 0)) for oid, od, fr in cur.fetchall()}

        payments_rows = []
        for oid, (od, freight) in order_meta.items():
            tax_id = random.choice(tax_ids)
            cur.execute("""
                SELECT COALESCE(SUM(CAST(UnitPrice AS float) * Quantity * (1 - Discount / 100.0)), 0)
                FROM dbo.OrderDetails
                WHERE OrderID = ?
            """, oid)
            lines_total = float(cur.fetchone()[0] or 0.0)
            total = lines_total + float(freight)
            amount = int(total)
            if amount < 0:
                amount = 0
            pay_date = od + dt.timedelta(days=random.randint(0, 5))
            payments_rows.append((payment_id, tax_id, oid, amount, pay_date))
            payment_id += 1

        exec_many(cur, """
            INSERT INTO dbo.Payments(PaymentID, TaxID, OrderID, Amount, PaymentDate)
            VALUES (?,?,?,?,?)
        """, payments_rows)

        if refunds_rows:
            exec_many(cur, """
                INSERT INTO dbo.Refunds(RefundID, OrderID, ProductID, Quantity, RefundApproved)
                VALUES (?,?,?,?,?)
            """, refunds_rows)

        if staged_prod_orders:
            exec_many(cur, """
                INSERT INTO dbo.ProductionOrders(OrderID, ProductID, FactoryID, Quantity, CreatedAt,
                                                PlannedStart, PlannedEnd, DueDate, Status, Priority, Notes)
                VALUES (?,?,?,?,?,?,?,?,?,?,?)
            """, staged_prod_orders)

            cur.execute("""
                SELECT ProductionOrderID, ProductID, FactoryID, Quantity, CreatedAt, DueDate
                FROM dbo.ProductionOrders
                WHERE OrderID IS NOT NULL
            """)
            prod_rows = cur.fetchall()

            cap_remaining: Dict[Tuple[int, dt.date], Decimal] = {}
            cur.execute("SELECT FactoryID, WorkDate, CapacityHours FROM dbo.FactoryCapacityCalendar")
            for fid, wdate, cap in cur.fetchall():
                cap_remaining[(int(fid), wdate)] = Decimal(str(cap))

            res_scale = get_decimal_scale(cur, "FactoryCapacityReservations", "ReservedHours")
            eps = qdec(Decimal("1").scaleb(-res_scale), res_scale)

            for poid, prod_id, fid, qty, created_at, due_date in prod_rows:
                hours_total = Decimal(str(prod_hours[int(prod_id)])) * Decimal(int(qty))
                due = due_date.date() if due_date else created_at.date() + dt.timedelta(days=14)

                start_res = max(horizon_start, due - dt.timedelta(days=30))
                days = [d for d in daterange(start_res, due - dt.timedelta(days=1)) if not is_weekend(d)]
                if not days:
                    days = [due]

                remaining = hours_total

                for d in reversed(days):
                    if remaining <= 0:
                        break

                    key = (int(fid), d)
                    available = cap_remaining.get(key, Decimal("0"))
                    if available <= 0:
                        continue

                    take = min(available, remaining)
                    take = qdec(take, res_scale)

                    if take <= 0:
                        continue

                    cap_remaining[key] = available - take
                    reservations_rows.append((int(fid), d, int(poid), take))
                    remaining -= take


        if reservations_rows:
            exec_many(cur, """
                INSERT INTO dbo.FactoryCapacityReservations(FactoryID, WorkDate, ProductionOrderID, ReservedHours)
                VALUES (?,?,?,?)
            """, reservations_rows)

        cn.commit()

        print("DONE ✅")
        print(f"Orders: {len(orders_rows)}; OrderDetails: {len(details_rows)}; Payments: {len(payments_rows)}")
        print(f"ProductionOrders: {len(staged_prod_orders)}; Reservations: {len(reservations_rows)}; Refunds: {len(refunds_rows)}")

    except Exception:
        cn.rollback()
        raise
    finally:
        cur.close()
        cn.close()


if __name__ == "__main__":
    generate()
