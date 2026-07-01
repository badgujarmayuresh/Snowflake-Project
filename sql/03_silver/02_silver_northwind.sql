-- ============================================================
-- Script  : 02_silver_northwind.sql
-- Purpose : Create Silver layer tables for Northwind B2B.
--           Type casting, deduplication, null handling, trimming.
-- Author  : Mayuresh Prakash Badgujar
-- Date    : May 2026
-- Layer   : Silver (PRC)
-- Source  : STG_BRONZE.TBL_NORTHWIND_*
-- Target  : PRC_SILVER.TBL_NW_*
-- Notes   : Safe to re-run (uses CREATE OR REPLACE).
--           No business logic — technical cleansing only.
-- ============================================================

USE DATABASE DB_DEMO_MAYURESH;
USE SCHEMA PRC_SILVER;
USE WAREHOUSE COMPUTE_WH;

-- ──────────────────────────────────────────────────────────────
-- 1. Northwind Categories
-- ──────────────────────────────────────────────────────────────
CREATE OR REPLACE TABLE DB_DEMO_MAYURESH.PRC_SILVER.TBL_NW_CATEGORIES
COMMENT = 'Silver - Northwind product categories. Deduped, trimmed.'
AS
WITH DEDUP AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY CATEGORY_ID ORDER BY _LOADED_AT DESC) AS _RN
    FROM DB_DEMO_MAYURESH.STG_BRONZE.TBL_NORTHWIND_CATEGORIES
)
SELECT
    CATEGORY_ID,
    INITCAP(TRIM(CATEGORY_NAME))                AS CATEGORY_NAME,
    TRIM(DESCRIPTION)                           AS DESCRIPTION
FROM DEDUP
WHERE _RN = 1;

-- ──────────────────────────────────────────────────────────────
-- 2. Northwind Suppliers
-- ──────────────────────────────────────────────────────────────
CREATE OR REPLACE TABLE DB_DEMO_MAYURESH.PRC_SILVER.TBL_NW_SUPPLIERS
COMMENT = 'Silver - Northwind suppliers. Deduped, trimmed.'
AS
WITH DEDUP AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY SUPPLIER_ID ORDER BY _LOADED_AT DESC) AS _RN
    FROM DB_DEMO_MAYURESH.STG_BRONZE.TBL_NORTHWIND_SUPPLIERS
)
SELECT
    SUPPLIER_ID,
    TRIM(COMPANY_NAME)                          AS COMPANY_NAME,
    TRIM(CONTACT_NAME)                          AS CONTACT_NAME,
    TRIM(CONTACT_TITLE)                         AS CONTACT_TITLE,
    UPPER(TRIM(COUNTRY))                        AS COUNTRY,
    TRIM(PHONE)                                 AS PHONE
FROM DEDUP
WHERE _RN = 1;

-- ──────────────────────────────────────────────────────────────
-- 3. Northwind Products
-- ──────────────────────────────────────────────────────────────
CREATE OR REPLACE TABLE DB_DEMO_MAYURESH.PRC_SILVER.TBL_NW_PRODUCTS
COMMENT = 'Silver - Northwind products. Deduped, typed, trimmed.'
AS
WITH DEDUP AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY PRODUCT_ID ORDER BY _LOADED_AT DESC) AS _RN
    FROM DB_DEMO_MAYURESH.STG_BRONZE.TBL_NORTHWIND_PRODUCTS
)
SELECT
    PRODUCT_ID,
    TRIM(PRODUCT_NAME)                          AS PRODUCT_NAME,
    SUPPLIER_ID,
    CATEGORY_ID,
    TRIM(QUANTITY_PER_UNIT)                     AS QUANTITY_PER_UNIT,
    UNIT_PRICE,
    UNITS_IN_STOCK,
    UNITS_ON_ORDER,
    REORDER_LEVEL,
    DISCONTINUED::BOOLEAN                       AS IS_DISCONTINUED
FROM DEDUP
WHERE _RN = 1;

-- ──────────────────────────────────────────────────────────────
-- 4. Northwind Employees
-- ──────────────────────────────────────────────────────────────
CREATE OR REPLACE TABLE DB_DEMO_MAYURESH.PRC_SILVER.TBL_NW_EMPLOYEES
COMMENT = 'Silver - Northwind employees. Deduped, dates cast, trimmed.'
AS
WITH DEDUP AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY EMPLOYEE_ID ORDER BY _LOADED_AT DESC) AS _RN
    FROM DB_DEMO_MAYURESH.STG_BRONZE.TBL_NORTHWIND_EMPLOYEES
)
SELECT
    EMPLOYEE_ID,
    TRIM(LAST_NAME)                             AS LAST_NAME,
    TRIM(FIRST_NAME)                            AS FIRST_NAME,
    TRIM(TITLE)                                 AS TITLE,
    TRY_TO_DATE(BIRTH_DATE)                     AS BIRTH_DATE,
    TRY_TO_DATE(HIRE_DATE)                      AS HIRE_DATE,
    UPPER(TRIM(COUNTRY))                        AS COUNTRY,
    TRY_TO_NUMBER(REPORTS_TO)                   AS REPORTS_TO
FROM DEDUP
WHERE _RN = 1;

-- ──────────────────────────────────────────────────────────────
-- 5. Northwind Customers
-- ──────────────────────────────────────────────────────────────
CREATE OR REPLACE TABLE DB_DEMO_MAYURESH.PRC_SILVER.TBL_NW_CUSTOMERS
COMMENT = 'Silver - Northwind B2B customers. Deduped, trimmed.'
AS
WITH DEDUP AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY CUSTOMER_ID ORDER BY _LOADED_AT DESC) AS _RN
    FROM DB_DEMO_MAYURESH.STG_BRONZE.TBL_NORTHWIND_CUSTOMERS
)
SELECT
    TRIM(CUSTOMER_ID)                           AS CUSTOMER_ID,
    TRIM(COMPANY_NAME)                          AS COMPANY_NAME,
    TRIM(CONTACT_NAME)                          AS CONTACT_NAME,
    TRIM(CONTACT_TITLE)                         AS CONTACT_TITLE,
    UPPER(TRIM(COUNTRY))                        AS COUNTRY,
    INITCAP(TRIM(CITY))                        AS CITY
FROM DEDUP
WHERE _RN = 1;

-- ──────────────────────────────────────────────────────────────
-- 6. Northwind Orders
-- ──────────────────────────────────────────────────────────────
CREATE OR REPLACE TABLE DB_DEMO_MAYURESH.PRC_SILVER.TBL_NW_ORDERS
COMMENT = 'Silver - Northwind orders. Deduped, dates cast, trimmed.'
AS
WITH DEDUP AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY ORDER_ID ORDER BY _LOADED_AT DESC) AS _RN
    FROM DB_DEMO_MAYURESH.STG_BRONZE.TBL_NORTHWIND_ORDERS
)
SELECT
    ORDER_ID,
    TRIM(CUSTOMER_ID)                           AS CUSTOMER_ID,
    EMPLOYEE_ID,
    TRY_TO_DATE(ORDER_DATE)                     AS ORDER_DATE,
    TRY_TO_DATE(REQUIRED_DATE)                  AS REQUIRED_DATE,
    TRY_TO_DATE(SHIPPED_DATE)                   AS SHIPPED_DATE,
    UPPER(TRIM(SHIP_COUNTRY))                   AS SHIP_COUNTRY,
    FREIGHT
FROM DEDUP
WHERE _RN = 1;

-- ──────────────────────────────────────────────────────────────
-- 7. Northwind Order Details
-- ──────────────────────────────────────────────────────────────
CREATE OR REPLACE TABLE DB_DEMO_MAYURESH.PRC_SILVER.TBL_NW_ORDER_DETAILS
COMMENT = 'Silver - Northwind order details. Deduped, typed.'
AS
WITH DEDUP AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY ORDER_ID, PRODUCT_ID ORDER BY _LOADED_AT DESC) AS _RN
    FROM DB_DEMO_MAYURESH.STG_BRONZE.TBL_NORTHWIND_ORDER_DETAILS
)
SELECT
    ORDER_ID,
    PRODUCT_ID,
    UNIT_PRICE,
    QUANTITY,
    COALESCE(DISCOUNT, 0)                       AS DISCOUNT
FROM DEDUP
WHERE _RN = 1;
