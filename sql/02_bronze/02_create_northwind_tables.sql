-- ============================================================
-- Script  : 02_create_northwind_tables.sql
-- Purpose : Create Bronze layer tables for Northwind B2B
--           source data in STG_BRONZE schema
-- Author  : Mayuresh Prakash Badgujar
-- Date    : May 2026
-- Layer   : Bronze (STG)
-- Notes   : Safe to re-run (uses OR REPLACE).
--           TBL_ prefix per naming convention.
--           Columns match source CSV structure exactly.
-- ============================================================

-- Set context
USE DATABASE DB_DEMO_MAYURESH;
USE SCHEMA STG_BRONZE;
USE WAREHOUSE COMPUTE_WH;

-- ──────────────────────────────────────────────────────────────
-- Northwind Categories
-- ──────────────────────────────────────────────────────────────
CREATE OR REPLACE TABLE DB_DEMO_MAYURESH.STG_BRONZE.TBL_NORTHWIND_CATEGORIES (
    CATEGORY_ID                 NUMBER(10,0)    NOT NULL,
    CATEGORY_NAME               VARCHAR(100),
    DESCRIPTION                 VARCHAR(500),
    -- Metadata
    _LOADED_AT                  TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP(),
    _SOURCE_FILE                VARCHAR(500)
)
COMMENT = 'Bronze - Northwind product categories. Loaded as-is from source CSV.';

-- ──────────────────────────────────────────────────────────────
-- Northwind Suppliers
-- ──────────────────────────────────────────────────────────────
CREATE OR REPLACE TABLE DB_DEMO_MAYURESH.STG_BRONZE.TBL_NORTHWIND_SUPPLIERS (
    SUPPLIER_ID                 NUMBER(10,0)    NOT NULL,
    COMPANY_NAME                VARCHAR(200),
    CONTACT_NAME                VARCHAR(100),
    CONTACT_TITLE               VARCHAR(100),
    COUNTRY                     VARCHAR(50),
    PHONE                       VARCHAR(50),
    -- Metadata
    _LOADED_AT                  TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP(),
    _SOURCE_FILE                VARCHAR(500)
)
COMMENT = 'Bronze - Northwind supplier master data. Loaded as-is from source CSV.';

-- ──────────────────────────────────────────────────────────────
-- Northwind Products
-- ──────────────────────────────────────────────────────────────
CREATE OR REPLACE TABLE DB_DEMO_MAYURESH.STG_BRONZE.TBL_NORTHWIND_PRODUCTS (
    PRODUCT_ID                  NUMBER(10,0)    NOT NULL,
    PRODUCT_NAME                VARCHAR(200),
    SUPPLIER_ID                 NUMBER(10,0),
    CATEGORY_ID                 NUMBER(10,0),
    QUANTITY_PER_UNIT           VARCHAR(50),
    UNIT_PRICE                  NUMBER(12,2),
    UNITS_IN_STOCK              NUMBER(10,0),
    UNITS_ON_ORDER              NUMBER(10,0),
    REORDER_LEVEL               NUMBER(10,0),
    DISCONTINUED                NUMBER(1,0),
    -- Metadata
    _LOADED_AT                  TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP(),
    _SOURCE_FILE                VARCHAR(500)
)
COMMENT = 'Bronze - Northwind product catalogue. Loaded as-is from source CSV.';

-- ──────────────────────────────────────────────────────────────
-- Northwind Employees
-- ──────────────────────────────────────────────────────────────
CREATE OR REPLACE TABLE DB_DEMO_MAYURESH.STG_BRONZE.TBL_NORTHWIND_EMPLOYEES (
    EMPLOYEE_ID                 NUMBER(10,0)    NOT NULL,
    LAST_NAME                   VARCHAR(100),
    FIRST_NAME                  VARCHAR(100),
    TITLE                       VARCHAR(100),
    BIRTH_DATE                  VARCHAR(50),
    HIRE_DATE                   VARCHAR(50),
    COUNTRY                     VARCHAR(50),
    REPORTS_TO                  VARCHAR(10),
    -- Metadata
    _LOADED_AT                  TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP(),
    _SOURCE_FILE                VARCHAR(500)
)
COMMENT = 'Bronze - Northwind employee master data. Loaded as-is from source CSV.';

-- ──────────────────────────────────────────────────────────────
-- Northwind Customers
-- ──────────────────────────────────────────────────────────────
CREATE OR REPLACE TABLE DB_DEMO_MAYURESH.STG_BRONZE.TBL_NORTHWIND_CUSTOMERS (
    CUSTOMER_ID                 VARCHAR(50)     NOT NULL,
    COMPANY_NAME                VARCHAR(200),
    CONTACT_NAME                VARCHAR(100),
    CONTACT_TITLE               VARCHAR(100),
    COUNTRY                     VARCHAR(50),
    CITY                        VARCHAR(100),
    -- Metadata
    _LOADED_AT                  TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP(),
    _SOURCE_FILE                VARCHAR(500)
)
COMMENT = 'Bronze - Northwind B2B customer master data. Loaded as-is from source CSV.';

-- ──────────────────────────────────────────────────────────────
-- Northwind Orders
-- ──────────────────────────────────────────────────────────────
CREATE OR REPLACE TABLE DB_DEMO_MAYURESH.STG_BRONZE.TBL_NORTHWIND_ORDERS (
    ORDER_ID                    NUMBER(10,0)    NOT NULL,
    CUSTOMER_ID                 VARCHAR(50),
    EMPLOYEE_ID                 NUMBER(10,0),
    ORDER_DATE                  VARCHAR(50),
    REQUIRED_DATE               VARCHAR(50),
    SHIPPED_DATE                VARCHAR(50),
    SHIP_COUNTRY                VARCHAR(50),
    FREIGHT                     NUMBER(12,2),
    -- Metadata
    _LOADED_AT                  TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP(),
    _SOURCE_FILE                VARCHAR(500)
)
COMMENT = 'Bronze - Northwind B2B order headers. Loaded as-is from source CSV.';

-- ──────────────────────────────────────────────────────────────
-- Northwind Order Details
-- ──────────────────────────────────────────────────────────────
CREATE OR REPLACE TABLE DB_DEMO_MAYURESH.STG_BRONZE.TBL_NORTHWIND_ORDER_DETAILS (
    ORDER_ID                    NUMBER(10,0)    NOT NULL,
    PRODUCT_ID                  NUMBER(10,0),
    UNIT_PRICE                  NUMBER(12,2),
    QUANTITY                    NUMBER(10,0),
    DISCOUNT                    NUMBER(5,2),
    -- Metadata
    _LOADED_AT                  TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP(),
    _SOURCE_FILE                VARCHAR(500)
)
COMMENT = 'Bronze - Northwind B2B order line items. Loaded as-is from source CSV.';
