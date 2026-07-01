"""
generate_bronze_data.py
Generates synthetic CSV files for the Bronze layer:
  - Olist E-commerce  (data/bronze/olist/)
  - Northwind B2B     (data/bronze/northwind/)
  - Manufacturing     (data/bronze/manufacturing/)

Column names match original public dataset structures
so real data can be swapped in later without any changes.
"""

import csv
import random
import uuid
from datetime import datetime, timedelta
from pathlib import Path

random.seed(42)

BASE = Path(__file__).parent.parent / "data" / "bronze"

# ── Helpers ────────────────────────────────────────────────────

def rand_date(start="2021-01-01", end="2024-12-31"):
    s = datetime.strptime(start, "%Y-%m-%d")
    e = datetime.strptime(end,   "%Y-%m-%d")
    return (s + timedelta(days=random.randint(0, (e - s).days))).strftime("%Y-%m-%d")

def write_csv(path, rows, headers):
    with open(path, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=headers)
        writer.writeheader()
        writer.writerows(rows)
    print(f"  OK  {path.name}  ({len(rows):,} rows)")

# ══════════════════════════════════════════════════════════════
# OLIST E-COMMERCE
# ══════════════════════════════════════════════════════════════

STATES     = ["SP","RJ","MG","BA","RS","PR","SC","GO","ES","PE","CE","AM","DF","MT","MS"]
CITIES     = ["Sao Paulo","Rio de Janeiro","Belo Horizonte","Salvador","Porto Alegre",
               "Curitiba","Florianopolis","Goiania","Vitoria","Recife","Fortaleza","Manaus"]
CATEGORIES = ["electronics","furniture","sports_leisure","health_beauty","toys",
               "computers","fashion_bags","food_drink","auto","books","office","garden"]
PAYMENT_TYPES = ["credit_card","boleto","voucher","debit_card"]

def gen_olist():
    out = BASE / "olist"
    print("\n[ Olist E-commerce ]")

    # Customers
    customers = []
    for i in range(1, 3001):
        customers.append({
            "customer_id":               f"CUST{i:05d}",
            "customer_unique_id":        str(uuid.uuid4()),
            "customer_zip_code_prefix":  str(random.randint(10000, 99999)),
            "customer_city":             random.choice(CITIES),
            "customer_state":            random.choice(STATES),
        })
    write_csv(out / "olist_customers_dataset.csv", customers,
              ["customer_id","customer_unique_id","customer_zip_code_prefix",
               "customer_city","customer_state"])

    # Sellers
    sellers = []
    for i in range(1, 501):
        sellers.append({
            "seller_id":                f"SELL{i:04d}",
            "seller_zip_code_prefix":   str(random.randint(10000, 99999)),
            "seller_city":              random.choice(CITIES),
            "seller_state":             random.choice(STATES),
        })
    write_csv(out / "olist_sellers_dataset.csv", sellers,
              ["seller_id","seller_zip_code_prefix","seller_city","seller_state"])

    # Products
    products = []
    for i in range(1, 1001):
        products.append({
            "product_id":                  f"PROD{i:05d}",
            "product_category_name":       random.choice(CATEGORIES),
            "product_name_length":         random.randint(20, 60),
            "product_description_length":  random.randint(100, 1000),
            "product_photos_qty":          random.randint(1, 5),
            "product_weight_g":            random.randint(100, 5000),
            "product_length_cm":           random.randint(10, 80),
            "product_height_cm":           random.randint(5, 50),
            "product_width_cm":            random.randint(5, 60),
        })
    write_csv(out / "olist_products_dataset.csv", products,
              ["product_id","product_category_name","product_name_length",
               "product_description_length","product_photos_qty",
               "product_weight_g","product_length_cm","product_height_cm","product_width_cm"])

    # Orders
    orders = []
    statuses = ["delivered","shipped","canceled","processing","invoiced"]
    for i in range(1, 10001):
        od = rand_date()
        orders.append({
            "order_id":                       f"ORD{i:07d}",
            "customer_id":                    random.choice(customers)["customer_id"],
            "order_status":                   random.choices(statuses, weights=[70,15,5,5,5])[0],
            "order_purchase_timestamp":       od + f" {random.randint(0,23):02d}:{random.randint(0,59):02d}:00",
            "order_approved_at":              od,
            "order_delivered_carrier_date":   rand_date(od, "2024-12-31"),
            "order_delivered_customer_date":  rand_date(od, "2024-12-31"),
            "order_estimated_delivery_date":  rand_date(od, "2024-12-31"),
        })
    write_csv(out / "olist_orders_dataset.csv", orders,
              ["order_id","customer_id","order_status","order_purchase_timestamp",
               "order_approved_at","order_delivered_carrier_date",
               "order_delivered_customer_date","order_estimated_delivery_date"])

    # Order Items
    items = []
    for order in orders:
        for item_num in range(1, random.randint(2, 5)):
            prod = random.choice(products)
            items.append({
                "order_id":           order["order_id"],
                "order_item_id":      item_num,
                "product_id":         prod["product_id"],
                "seller_id":          random.choice(sellers)["seller_id"],
                "shipping_limit_date":order["order_approved_at"],
                "price":              round(random.uniform(10, 800), 2),
                "freight_value":      round(random.uniform(5, 50), 2),
            })
    write_csv(out / "olist_order_items_dataset.csv", items,
              ["order_id","order_item_id","product_id","seller_id",
               "shipping_limit_date","price","freight_value"])

    # Payments
    payments = []
    for order in orders:
        payments.append({
            "order_id":             order["order_id"],
            "payment_sequential":   1,
            "payment_type":         random.choice(PAYMENT_TYPES),
            "payment_installments": random.randint(1, 12),
            "payment_value":        round(random.uniform(20, 2000), 2),
        })
    write_csv(out / "olist_order_payments_dataset.csv", payments,
              ["order_id","payment_sequential","payment_type",
               "payment_installments","payment_value"])

    # Reviews
    reviews = []
    for order in random.sample(orders, 7000):
        reviews.append({
            "review_id":               str(uuid.uuid4()),
            "order_id":                order["order_id"],
            "review_score":            random.choices([1,2,3,4,5], weights=[5,5,10,30,50])[0],
            "review_comment_title":    random.choice(["Great!","Good","OK","Bad","",""]),
            "review_comment_message":  random.choice([
                "Product as described.","Fast delivery!","Not satisfied.",
                "Excellent quality!","Would buy again.","Packaging damaged.",""
            ]),
            "review_creation_date":    order["order_purchase_timestamp"][:10],
            "review_answer_timestamp": order["order_purchase_timestamp"],
        })
    write_csv(out / "olist_order_reviews_dataset.csv", reviews,
              ["review_id","order_id","review_score","review_comment_title",
               "review_comment_message","review_creation_date","review_answer_timestamp"])

    # Category translation
    translations = [{"product_category_name": c,
                     "product_category_name_english": c.replace("_"," ").title()}
                    for c in CATEGORIES]
    write_csv(out / "product_category_name_translation.csv", translations,
              ["product_category_name","product_category_name_english"])

    print("  Olist complete.")


# ══════════════════════════════════════════════════════════════
# NORTHWIND B2B
# ══════════════════════════════════════════════════════════════

def gen_northwind():
    out = BASE / "northwind"
    print("\n[ Northwind B2B ]")

    categories = [
        {"category_id":1,"category_name":"Beverages",      "description":"Soft drinks, coffees, teas, beers"},
        {"category_id":2,"category_name":"Condiments",     "description":"Sweet and savory sauces"},
        {"category_id":3,"category_name":"Confections",    "description":"Desserts, candies, sweet breads"},
        {"category_id":4,"category_name":"Dairy Products", "description":"Cheeses"},
        {"category_id":5,"category_name":"Grains/Cereals", "description":"Breads, crackers, pasta, cereal"},
        {"category_id":6,"category_name":"Meat/Poultry",   "description":"Prepared meats"},
        {"category_id":7,"category_name":"Produce",        "description":"Dried fruit and bean curd"},
        {"category_id":8,"category_name":"Seafood",        "description":"Seaweed and fish"},
    ]
    write_csv(out / "categories.csv", categories,
              ["category_id","category_name","description"])

    supplier_names = ["Exotic Liquids","New Orleans Cajun Delights","Grandma Kelly's Homestead",
                      "Tokyo Traders","Cooperativa de Quesos","Mayumi's","Pavlova Ltd.",
                      "Specialty Biscuits Ltd.","PB Knackebrod AB","Refrescos Americanas"]
    countries = ["UK","USA","USA","Japan","Spain","Japan","Australia","UK","Sweden","Brazil"]
    suppliers = []
    for i,(name,country) in enumerate(zip(supplier_names,countries),1):
        suppliers.append({
            "supplier_id":   i,
            "company_name":  name,
            "contact_name":  f"Contact {i}",
            "contact_title": random.choice(["Sales Manager","Owner","Marketing Manager"]),
            "country":       country,
            "phone":         f"+1-{random.randint(200,999)}-{random.randint(1000000,9999999)}",
        })
    write_csv(out / "suppliers.csv", suppliers,
              ["supplier_id","company_name","contact_name","contact_title","country","phone"])

    product_names = [
        "Chai","Chang","Aniseed Syrup","Chef Antons Cajun Seasoning","Chef Antons Gumbo Mix",
        "Grandmas Boysenberry Spread","Uncle Bobs Organic Dried Pears","Northwoods Cranberry Sauce",
        "Mishi Kobe Niku","Ikura","Queso Cabrales","Queso Manchego La Pastora","Konbu",
        "Tofu","Genen Shouyu","Pavlova","Alice Mutton","Carnarvon Tigers",
        "Teatime Chocolate Biscuits","Sir Rodneys Marmalade","Sir Rodneys Scones",
        "Gustafs Knackebrod","Tunnbrod","Guarana Fantastica","NuNuCa Nougat Creme",
        "Gumbar Gummibarcheen","Schoggi Schokolade","Rossle Sauerkraut",
        "Thuringer Rostbratwurst","Nord-Ost Matjeshering"
    ]
    products = []
    for i,name in enumerate(product_names,1):
        products.append({
            "product_id":         i,
            "product_name":       name,
            "supplier_id":        random.randint(1,len(suppliers)),
            "category_id":        random.randint(1,8),
            "quantity_per_unit":  random.choice(["10 boxes","24 bottles","12 jars","1 kg","500 g"]),
            "unit_price":         round(random.uniform(5,150),2),
            "units_in_stock":     random.randint(0,200),
            "units_on_order":     random.randint(0,100),
            "reorder_level":      random.randint(5,30),
            "discontinued":       random.choice([0,0,0,1]),
        })
    write_csv(out / "products.csv", products,
              ["product_id","product_name","supplier_id","category_id","quantity_per_unit",
               "unit_price","units_in_stock","units_on_order","reorder_level","discontinued"])

    emp_names = [("Nancy","Davolio"),("Andrew","Fuller"),("Janet","Leverling"),
                 ("Margaret","Peacock"),("Steven","Buchanan"),("Michael","Suyama"),
                 ("Robert","King"),("Laura","Callahan"),("Anne","Dodsworth")]
    titles = ["Sales Representative","Vice President Sales","Sales Representative",
              "Sales Representative","Sales Manager","Sales Representative",
              "Sales Representative","Inside Sales Coordinator","Sales Representative"]
    employees = []
    for i,((first,last),title) in enumerate(zip(emp_names,titles),1):
        employees.append({
            "employee_id": i,
            "last_name":   last,
            "first_name":  first,
            "title":       title,
            "birth_date":  rand_date("1960-01-01","1985-12-31"),
            "hire_date":   rand_date("2015-01-01","2022-12-31"),
            "country":     "USA",
            "reports_to":  2 if i != 2 else "",
        })
    write_csv(out / "employees.csv", employees,
              ["employee_id","last_name","first_name","title",
               "birth_date","hire_date","country","reports_to"])

    nw_companies = ["Alfreds Futterkiste","Ana Trujillo Emparedados","Antonio Moreno Taqueria",
                    "Around the Horn","Berglunds snabbkop","Blauer See Delikatessen",
                    "Blondesddsl pere et fils","Bolido Comidas preparadas","Bon app","Bottom-Dollar Markets"]
    nw_countries  = ["Germany","Mexico","Mexico","UK","Sweden","Germany","France","Spain","France","Canada"]
    nw_customers  = []
    for i,(company,country) in enumerate(zip(nw_companies,nw_countries),1):
        nw_customers.append({
            "customer_id":   f"NW{i:04d}",
            "company_name":  company,
            "contact_name":  f"Contact {i}",
            "contact_title": random.choice(["Owner","Sales Agent","Marketing Manager"]),
            "country":       country,
            "city":          random.choice(CITIES[:5]),
        })
    write_csv(out / "customers.csv", nw_customers,
              ["customer_id","company_name","contact_name","contact_title","country","city"])

    nw_orders = []
    for i in range(1, 2001):
        nw_orders.append({
            "order_id":      10000 + i,
            "customer_id":   random.choice(nw_customers)["customer_id"],
            "employee_id":   random.randint(1,len(employees)),
            "order_date":    rand_date(),
            "required_date": rand_date(),
            "shipped_date":  rand_date(),
            "ship_country":  random.choice(nw_countries),
            "freight":       round(random.uniform(2,200),2),
        })
    write_csv(out / "orders.csv", nw_orders,
              ["order_id","customer_id","employee_id","order_date",
               "required_date","shipped_date","ship_country","freight"])

    order_details = []
    for order in nw_orders:
        for _ in range(random.randint(1,5)):
            prod = random.choice(products)
            order_details.append({
                "order_id":   order["order_id"],
                "product_id": prod["product_id"],
                "unit_price": prod["unit_price"],
                "quantity":   random.randint(1,30),
                "discount":   random.choice([0,0,0,0.05,0.10,0.15,0.20]),
            })
    write_csv(out / "order_details.csv", order_details,
              ["order_id","product_id","unit_price","quantity","discount"])

    print("  Northwind complete.")


# ══════════════════════════════════════════════════════════════
# MANUFACTURING
# ══════════════════════════════════════════════════════════════

MACHINE_TYPES   = ["CNC Lathe","Injection Molder","Assembly Robot",
                   "Packaging Unit","Press Machine","Welding Robot"]
SHIFT_TYPES     = ["Morning","Afternoon","Night"]
DEFECT_TYPES    = ["Surface Scratch","Dimensional Error","Assembly Fault",
                   "Color Mismatch","Material Defect","None"]
PLANT_LOCATIONS = ["Plant A - Sao Paulo","Plant B - Curitiba",
                   "Plant C - Manaus","Plant D - Recife"]

def gen_manufacturing():
    out = BASE / "manufacturing"
    print("\n[ Manufacturing ]")

    # Machines
    machines = []
    for i in range(1, 51):
        machines.append({
            "machine_id":           f"MCH{i:03d}",
            "machine_name":         f"{random.choice(MACHINE_TYPES)} {i}",
            "machine_type":         random.choice(MACHINE_TYPES),
            "plant_location":       random.choice(PLANT_LOCATIONS),
            "installation_date":    rand_date("2015-01-01","2022-12-31"),
            "last_maintenance_date":rand_date("2023-01-01","2024-12-31"),
            "status":               random.choices(["Active","Maintenance","Idle"],weights=[80,10,10])[0],
            "capacity_per_hour":    random.randint(50,500),
        })
    write_csv(out / "machines.csv", machines,
              ["machine_id","machine_name","machine_type","plant_location",
               "installation_date","last_maintenance_date","status","capacity_per_hour"])

    # Inventory / raw materials
    materials = ["Steel Coil","Plastic Pellets","Aluminum Sheet","Rubber Seal",
                 "Electronic Component","Copper Wire","Glass Panel",
                 "Foam Padding","Cardboard Box","Paint Coat"]
    inventory = []
    for i,mat in enumerate(materials,1):
        inventory.append({
            "material_id":        f"MAT{i:03d}",
            "material_name":      mat,
            "unit_of_measure":    random.choice(["kg","units","meters","liters"]),
            "current_stock":      random.randint(100,10000),
            "reorder_point":      random.randint(200,1000),
            "unit_cost":          round(random.uniform(1,50),2),
            "supplier_id":        f"SELL{random.randint(1,100):04d}",
            "last_restocked_date":rand_date("2024-01-01","2024-12-31"),
        })
    write_csv(out / "inventory.csv", inventory,
              ["material_id","material_name","unit_of_measure","current_stock",
               "reorder_point","unit_cost","supplier_id","last_restocked_date"])

    # Production Orders
    prod_orders = []
    for i in range(1, 5001):
        start = rand_date("2021-01-01","2024-12-31")
        prod_orders.append({
            "production_order_id": f"PO{i:07d}",
            "product_id":          f"PROD{random.randint(1,1000):05d}",
            "machine_id":          random.choice(machines)["machine_id"],
            "plant_location":      random.choice(PLANT_LOCATIONS),
            "shift":               random.choice(SHIFT_TYPES),
            "planned_quantity":    random.randint(100,5000),
            "actual_quantity":     random.randint(80,5000),
            "start_date":          start,
            "end_date":            rand_date(start,"2024-12-31"),
            "status":              random.choices(["Completed","In Progress","Cancelled"],weights=[75,20,5])[0],
            "operator_id":         f"EMP{random.randint(1,50):03d}",
            "production_cost":     round(random.uniform(500,50000),2),
        })
    write_csv(out / "production_orders.csv", prod_orders,
              ["production_order_id","product_id","machine_id","plant_location","shift",
               "planned_quantity","actual_quantity","start_date","end_date",
               "status","operator_id","production_cost"])

    # Defects
    defects = []
    for i,order in enumerate(random.sample(prod_orders,2000),1):
        defects.append({
            "defect_id":             f"DEF{i:06d}",
            "production_order_id":   order["production_order_id"],
            "machine_id":            order["machine_id"],
            "defect_type":           random.choices(DEFECT_TYPES,weights=[20,15,15,10,10,30])[0],
            "defect_quantity":       random.randint(0,50),
            "inspection_date":       order["end_date"],
            "inspector_id":          f"INS{random.randint(1,10):02d}",
            "corrective_action":     random.choice(["Rework","Scrap","Accept","Pending",""]),
        })
    write_csv(out / "defects.csv", defects,
              ["defect_id","production_order_id","machine_id","defect_type",
               "defect_quantity","inspection_date","inspector_id","corrective_action"])

    # Machine Downtime
    downtime = []
    for i in range(1,501):
        machine = random.choice(machines)
        downtime.append({
            "downtime_id":     f"DT{i:05d}",
            "machine_id":      machine["machine_id"],
            "downtime_start":  rand_date() + f" {random.randint(0,23):02d}:00:00",
            "downtime_end":    rand_date() + f" {random.randint(0,23):02d}:00:00",
            "reason":          random.choice(["Mechanical Failure","Scheduled Maintenance",
                                              "Power Outage","Material Shortage","Operator Error"]),
            "downtime_hours":  round(random.uniform(0.5,24),1),
            "cost_impact":     round(random.uniform(100,5000),2),
        })
    write_csv(out / "machine_downtime.csv", downtime,
              ["downtime_id","machine_id","downtime_start","downtime_end",
               "reason","downtime_hours","cost_impact"])

    print("  Manufacturing complete.")


# ══════════════════════════════════════════════════════════════
# MAIN
# ══════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("Generating Bronze layer datasets...")
    gen_olist()
    gen_northwind()
    gen_manufacturing()
    print("\nAll datasets generated successfully!")
    print(f"Location: {BASE}")
