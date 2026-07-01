-- ============================================================
-- Script  : 06_copy_into_northwind.sql
-- Purpose : Load Northwind CSV data from internal stage into
--           Bronze tables using COPY INTO
-- Author  : Mayuresh Prakash Badgujar
-- Date    : May 2026
-- Layer   : Bronze (STG)
-- Notes   : Run AFTER 04_put_files_to_stage.sql.
--           Uses METADATA$FILENAME to track source file.
-- ============================================================

-- Set context
USE DATABASE DB_DEMO_MAYURESH;
USE SCHEMA STG_BRONZE;
USE WAREHOUSE COMPUTE_WH;

-- ──────────────────────────────────────────────────────────────
-- Northwind Categories
-- ──────────────────────────────────────────────────────────────
COPY INTO DB_DEMO_MAYURESH.STG_BRONZE.TBL_NORTHWIND_CATEGORIES
    (CATEGORY_ID, CATEGORY_NAME, DESCRIPTION,
     _LOADED_AT, _SOURCE_FILE)
FROM (
    SELECT
        $1, $2, $3,
        CURRENT_TIMESTAMP(),
        METADATA$FILENAME
    FROM @DB_DEMO_MAYURESH.STG_BRONZE.STGINT_SMART_BI/northwind/categories.csv
)
FILE_FORMAT = (FORMAT_NAME = 'DB_DEMO_MAYURESH.STG_BRONZE.FF_CSV_STANDARD')
ON_ERROR = CONTINUE;

-- ──────────────────────────────────────────────────────────────
-- Northwind Suppliers
-- ──────────────────────────────────────────────────────────────
COPY INTO DB_DEMO_MAYURESH.STG_BRONZE.TBL_NORTHWIND_SUPPLIERS
    (SUPPLIER_ID, COMPANY_NAME, CONTACT_NAME,
     CONTACT_TITLE, COUNTRY, PHONE,
     _LOADED_AT, _SOURCE_FILE)
FROM (
    SELECT
        $1, $2, $3, $4, $5, $6,
        CURRENT_TIMESTAMP(),
        METADATA$FILENAME
    FROM @DB_DEMO_MAYURESH.STG_BRONZE.STGINT_SMART_BI/northwind/suppliers.csv
)
FILE_FORMAT = (FORMAT_NAME = 'DB_DEMO_MAYURESH.STG_BRONZE.FF_CSV_STANDARD')
ON_ERROR = CONTINUE;

-- ──────────────────────────────────────────────────────────────
-- Northwind Products
-- ──────────────────────────────────────────────────────────────
COPY INTO DB_DEMO_MAYURESH.STG_BRONZE.TBL_NORTHWIND_PRODUCTS
    (PRODUCT_ID, PRODUCT_NAME, SUPPLIER_ID, CATEGORY_ID,
     QUANTITY_PER_UNIT, UNIT_PRICE, UNITS_IN_STOCK,
     UNITS_ON_ORDER, REORDER_LEVEL, DISCONTINUED,
     _LOADED_AT, _SOURCE_FILE)
FROM (
    SELECT
        $1, $2, $3, $4, $5, $6, $7, $8, $9, $10,
        CURRENT_TIMESTAMP(),
        METADATA$FILENAME
    FROM @DB_DEMO_MAYURESH.STG_BRONZE.STGINT_SMART_BI/northwind/products.csv
)
FILE_FORMAT = (FORMAT_NAME = 'DB_DEMO_MAYURESH.STG_BRONZE.FF_CSV_STANDARD')
ON_ERROR = CONTINUE;

-- ──────────────────────────────────────────────────────────────
-- Northwind Employees
-- ──────────────────────────────────────────────────────────────
COPY INTO DB_DEMO_MAYURESH.STG_BRONZE.TBL_NORTHWIND_EMPLOYEES
    (EMPLOYEE_ID, LAST_NAME, FIRST_NAME, TITLE,
     BIRTH_DATE, HIRE_DATE, COUNTRY, REPORTS_TO,
     _LOADED_AT, _SOURCE_FILE)
FROM (
    SELECT
        $1, $2, $3, $4, $5, $6, $7, $8,
        CURRENT_TIMESTAMP(),
        METADATA$FILENAME
    FROM @DB_DEMO_MAYURESH.STG_BRONZE.STGINT_SMART_BI/northwind/employees.csv
)
FILE_FORMAT = (FORMAT_NAME = 'DB_DEMO_MAYURESH.STG_BRONZE.FF_CSV_STANDARD')
ON_ERROR = CONTINUE;

-- ──────────────────────────────────────────────────────────────
-- Northwind Customers
-- ──────────────────────────────────────────────────────────────
COPY INTO DB_DEMO_MAYURESH.STG_BRONZE.TBL_NORTHWIND_CUSTOMERS
    (CUSTOMER_ID, COMPANY_NAME, CONTACT_NAME,
     CONTACT_TITLE, COUNTRY, CITY,
     _LOADED_AT, _SOURCE_FILE)
FROM (
    SELECT
        $1, $2, $3, $4, $5, $6,
        CURRENT_TIMESTAMP(),
        METADATA$FILENAME
    FROM @DB_DEMO_MAYURESH.STG_BRONZE.STGINT_SMART_BI/northwind/customers.csv
)
FILE_FORMAT = (FORMAT_NAME = 'DB_DEMO_MAYURESH.STG_BRONZE.FF_CSV_STANDARD')
ON_ERROR = CONTINUE;

-- ──────────────────────────────────────────────────────────────
-- Northwind Orders
-- ──────────────────────────────────────────────────────────────
COPY INTO DB_DEMO_MAYURESH.STG_BRONZE.TBL_NORTHWIND_ORDERS
    (ORDER_ID, CUSTOMER_ID, EMPLOYEE_ID, ORDER_DATE,
     REQUIRED_DATE, SHIPPED_DATE, SHIP_COUNTRY, FREIGHT,
     _LOADED_AT, _SOURCE_FILE)
FROM (
    SELECT
        $1, $2, $3, $4, $5, $6, $7, $8,
        CURRENT_TIMESTAMP(),
        METADATA$FILENAME
    FROM @DB_DEMO_MAYURESH.STG_BRONZE.STGINT_SMART_BI/northwind/orders.csv
)
FILE_FORMAT = (FORMAT_NAME = 'DB_DEMO_MAYURESH.STG_BRONZE.FF_CSV_STANDARD')
ON_ERROR = CONTINUE;

-- ──────────────────────────────────────────────────────────────
-- Northwind Order Details
-- ──────────────────────────────────────────────────────────────
COPY INTO DB_DEMO_MAYURESH.STG_BRONZE.TBL_NORTHWIND_ORDER_DETAILS
    (ORDER_ID, PRODUCT_ID, UNIT_PRICE, QUANTITY, DISCOUNT,
     _LOADED_AT, _SOURCE_FILE)
FROM (
    SELECT
        $1, $2, $3, $4, $5,
        CURRENT_TIMESTAMP(),
        METADATA$FILENAME
    FROM @DB_DEMO_MAYURESH.STG_BRONZE.STGINT_SMART_BI/northwind/order_details.csv
)
FILE_FORMAT = (FORMAT_NAME = 'DB_DEMO_MAYURESH.STG_BRONZE.FF_CSV_STANDARD')
ON_ERROR = CONTINUE;

-- ──────────────────────────────────────────────────────────────
-- Verify row counts
-- ──────────────────────────────────────────────────────────────
SELECT 'TBL_NORTHWIND_CATEGORIES'    AS TABLE_NAME, COUNT(*) AS ROW_COUNT FROM DB_DEMO_MAYURESH.STG_BRONZE.TBL_NORTHWIND_CATEGORIES
UNION ALL
SELECT 'TBL_NORTHWIND_SUPPLIERS',    COUNT(*) FROM DB_DEMO_MAYURESH.STG_BRONZE.TBL_NORTHWIND_SUPPLIERS
UNION ALL
SELECT 'TBL_NORTHWIND_PRODUCTS',     COUNT(*) FROM DB_DEMO_MAYURESH.STG_BRONZE.TBL_NORTHWIND_PRODUCTS
UNION ALL
SELECT 'TBL_NORTHWIND_EMPLOYEES',    COUNT(*) FROM DB_DEMO_MAYURESH.STG_BRONZE.TBL_NORTHWIND_EMPLOYEES
UNION ALL
SELECT 'TBL_NORTHWIND_CUSTOMERS',    COUNT(*) FROM DB_DEMO_MAYURESH.STG_BRONZE.TBL_NORTHWIND_CUSTOMERS
UNION ALL
SELECT 'TBL_NORTHWIND_ORDERS',       COUNT(*) FROM DB_DEMO_MAYURESH.STG_BRONZE.TBL_NORTHWIND_ORDERS
UNION ALL
SELECT 'TBL_NORTHWIND_ORDER_DETAILS', COUNT(*) FROM DB_DEMO_MAYURESH.STG_BRONZE.TBL_NORTHWIND_ORDER_DETAILS;
