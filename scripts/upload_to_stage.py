"""
Upload CSV files to Snowflake internal stage using PUT command.
Requires snowflake-connector-python installed.
"""
import snowflake.connector
import os

# Connect using default connection
conn = snowflake.connector.connect(connection_name='MX60297')
cur = conn.cursor()
cur.execute('USE DATABASE DB_DEMO_MAYURESH')
cur.execute('USE SCHEMA STG_BRONZE')
cur.execute('USE WAREHOUSE COMPUTE_WH')

base = r'C:\Users\MayureshPrakashBadgu\learning\snowflake\learncoco\data\bronze'

# Olist files
olist_files = [
    'olist_customers_dataset.csv',
    'olist_sellers_dataset.csv',
    'olist_products_dataset.csv',
    'olist_orders_dataset.csv',
    'olist_order_items_dataset.csv',
    'olist_order_payments_dataset.csv',
    'olist_order_reviews_dataset.csv',
    'product_category_name_translation.csv'
]
for f in olist_files:
    path = os.path.join(base, 'olist', f).replace('\\', '/')
    sql = f"PUT 'file://{path}' @STGINT_SMART_BI/olist/ AUTO_COMPRESS=TRUE OVERWRITE=TRUE"
    cur.execute(sql)
    print(f'PUT olist/{f} - OK')

# Northwind files
nw_files = ['categories.csv', 'suppliers.csv', 'products.csv', 'employees.csv',
            'customers.csv', 'orders.csv', 'order_details.csv']
for f in nw_files:
    path = os.path.join(base, 'northwind', f).replace('\\', '/')
    sql = f"PUT 'file://{path}' @STGINT_SMART_BI/northwind/ AUTO_COMPRESS=TRUE OVERWRITE=TRUE"
    cur.execute(sql)
    print(f'PUT northwind/{f} - OK')

# Manufacturing files
mfg_files = ['machines.csv', 'inventory.csv', 'production_orders.csv',
             'defects.csv', 'machine_downtime.csv']
for f in mfg_files:
    path = os.path.join(base, 'manufacturing', f).replace('\\', '/')
    sql = f"PUT 'file://{path}' @STGINT_SMART_BI/manufacturing/ AUTO_COMPRESS=TRUE OVERWRITE=TRUE"
    cur.execute(sql)
    print(f'PUT manufacturing/{f} - OK')

print('\nAll 20 files uploaded successfully!')
cur.close()
conn.close()
