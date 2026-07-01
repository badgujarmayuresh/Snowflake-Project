-- ============================================================
-- Script  : 02_dimensions.sql
-- Purpose : Create all business dimension tables for Gold layer
-- Author  : Mayuresh Prakash Badgujar
-- Date    : May 2026
-- Layer   : Gold (REP)
-- Notes   : DIM_CUSTOMER, DIM_PRODUCT, DIM_SELLER,
--           DIM_LOCATION, DIM_MACHINE, DIM_PLANT
-- ============================================================

USE DATABASE DB_DEMO_MAYURESH;
USE SCHEMA REP_GOLD;
USE WAREHOUSE COMPUTE_WH;

-- ──────────────────────────────────────────────────────────────
-- DIM_CUSTOMER
-- Source: Olist Customers
-- Grain: One row per customer
-- ──────────────────────────────────────────────────────────────
CREATE OR REPLACE TABLE DB_DEMO_MAYURESH.REP_GOLD.TBL_DIM_CUSTOMER
COMMENT = 'Gold - Customer dimension. Source: Olist e-commerce customers.'
AS
SELECT
    CUSTOMER_ID,
    CUSTOMER_UNIQUE_ID,
    CUSTOMER_ZIP_CODE_PREFIX,
    CUSTOMER_CITY,
    CUSTOMER_STATE
FROM DB_DEMO_MAYURESH.PRC_SILVER.TBL_OLIST_CUSTOMERS;

-- ──────────────────────────────────────────────────────────────
-- DIM_PRODUCT
-- Source: Olist Products + Category Translation + Northwind Products
-- Grain: One row per product (unified across sources)
-- ──────────────────────────────────────────────────────────────
CREATE OR REPLACE TABLE DB_DEMO_MAYURESH.REP_GOLD.TBL_DIM_PRODUCT
COMMENT = 'Gold - Product dimension. Unified from Olist + Northwind products.'
AS
-- Olist products with English category name
SELECT
    P.PRODUCT_ID,
    'OLIST'                                     AS SOURCE_SYSTEM,
    COALESCE(CT.PRODUCT_CATEGORY_NAME_ENGLISH,
             INITCAP(REPLACE(P.PRODUCT_CATEGORY_NAME, '_', ' ')))
                                                AS PRODUCT_CATEGORY,
    P.PRODUCT_CATEGORY_NAME                     AS PRODUCT_CATEGORY_ORIGINAL,
    NULL                                        AS PRODUCT_NAME,
    P.PRODUCT_WEIGHT_G,
    P.PRODUCT_LENGTH_CM,
    P.PRODUCT_HEIGHT_CM,
    P.PRODUCT_WIDTH_CM
FROM DB_DEMO_MAYURESH.PRC_SILVER.TBL_OLIST_PRODUCTS P
LEFT JOIN DB_DEMO_MAYURESH.PRC_SILVER.TBL_OLIST_CATEGORY_TRANSLATION CT
    ON P.PRODUCT_CATEGORY_NAME = CT.PRODUCT_CATEGORY_NAME

UNION ALL

-- Northwind products with category
SELECT
    'NW_' || P.PRODUCT_ID::VARCHAR              AS PRODUCT_ID,
    'NORTHWIND'                                 AS SOURCE_SYSTEM,
    C.CATEGORY_NAME                             AS PRODUCT_CATEGORY,
    C.CATEGORY_NAME                             AS PRODUCT_CATEGORY_ORIGINAL,
    P.PRODUCT_NAME,
    NULL                                        AS PRODUCT_WEIGHT_G,
    NULL                                        AS PRODUCT_LENGTH_CM,
    NULL                                        AS PRODUCT_HEIGHT_CM,
    NULL                                        AS PRODUCT_WIDTH_CM
FROM DB_DEMO_MAYURESH.PRC_SILVER.TBL_NW_PRODUCTS P
LEFT JOIN DB_DEMO_MAYURESH.PRC_SILVER.TBL_NW_CATEGORIES C
    ON P.CATEGORY_ID = C.CATEGORY_ID;

-- ──────────────────────────────────────────────────────────────
-- DIM_SELLER
-- Source: Olist Sellers
-- Grain: One row per seller
-- ──────────────────────────────────────────────────────────────
CREATE OR REPLACE TABLE DB_DEMO_MAYURESH.REP_GOLD.TBL_DIM_SELLER
COMMENT = 'Gold - Seller dimension. Source: Olist e-commerce sellers.'
AS
SELECT
    SELLER_ID,
    SELLER_ZIP_CODE_PREFIX,
    SELLER_CITY,
    SELLER_STATE
FROM DB_DEMO_MAYURESH.PRC_SILVER.TBL_OLIST_SELLERS;

-- ──────────────────────────────────────────────────────────────
-- DIM_LOCATION
-- Source: Derived from customers and sellers (distinct cities/states)
-- Grain: One row per unique city+state combination
-- ──────────────────────────────────────────────────────────────
CREATE OR REPLACE TABLE DB_DEMO_MAYURESH.REP_GOLD.TBL_DIM_LOCATION
COMMENT = 'Gold - Location dimension. Geographic hierarchy derived from customers and sellers.'
AS
WITH ALL_LOCATIONS AS (
    SELECT CUSTOMER_CITY AS CITY, CUSTOMER_STATE AS STATE FROM DB_DEMO_MAYURESH.PRC_SILVER.TBL_OLIST_CUSTOMERS
    UNION
    SELECT SELLER_CITY, SELLER_STATE FROM DB_DEMO_MAYURESH.PRC_SILVER.TBL_OLIST_SELLERS
)
SELECT
    MD5(CITY || '|' || STATE)                   AS LOCATION_KEY,
    CITY,
    STATE,
    CASE
        WHEN STATE IN ('SP','RJ','MG','ES') THEN 'Southeast'
        WHEN STATE IN ('RS','SC','PR') THEN 'South'
        WHEN STATE IN ('BA','PE','CE','SE','AL','PB','RN','PI','MA') THEN 'Northeast'
        WHEN STATE IN ('AM','PA','AP','RO','RR','AC','TO') THEN 'North'
        WHEN STATE IN ('GO','MT','MS','DF') THEN 'Central-West'
        ELSE 'Other'
    END                                         AS REGION
FROM ALL_LOCATIONS;

-- ──────────────────────────────────────────────────────────────
-- DIM_MACHINE
-- Source: Manufacturing Machines
-- Grain: One row per machine
-- ──────────────────────────────────────────────────────────────
CREATE OR REPLACE TABLE DB_DEMO_MAYURESH.REP_GOLD.TBL_DIM_MACHINE
COMMENT = 'Gold - Machine dimension. Source: Manufacturing machines.'
AS
SELECT
    MACHINE_ID,
    MACHINE_NAME,
    MACHINE_TYPE,
    PLANT_LOCATION,
    INSTALLATION_DATE,
    LAST_MAINTENANCE_DATE,
    STATUS,
    CAPACITY_PER_HOUR
FROM DB_DEMO_MAYURESH.PRC_SILVER.TBL_MFG_MACHINES;

-- ──────────────────────────────────────────────────────────────
-- DIM_PLANT
-- Source: Derived from manufacturing plant locations
-- Grain: One row per plant
-- ──────────────────────────────────────────────────────────────
CREATE OR REPLACE TABLE DB_DEMO_MAYURESH.REP_GOLD.TBL_DIM_PLANT
COMMENT = 'Gold - Plant dimension. Derived from manufacturing plant locations.'
AS
WITH PLANTS AS (
    SELECT DISTINCT PLANT_LOCATION FROM DB_DEMO_MAYURESH.PRC_SILVER.TBL_MFG_MACHINES
    UNION
    SELECT DISTINCT PLANT_LOCATION FROM DB_DEMO_MAYURESH.PRC_SILVER.TBL_MFG_PRODUCTION_ORDERS
)
SELECT
    MD5(PLANT_LOCATION)                         AS PLANT_KEY,
    PLANT_LOCATION,
    SPLIT_PART(PLANT_LOCATION, ' - ', 1)        AS PLANT_CODE,
    SPLIT_PART(PLANT_LOCATION, ' - ', 2)        AS PLANT_CITY,
    CASE
        WHEN PLANT_LOCATION ILIKE '%Sao Paulo%' THEN 'Southeast'
        WHEN PLANT_LOCATION ILIKE '%Curitiba%' THEN 'South'
        WHEN PLANT_LOCATION ILIKE '%Manaus%' THEN 'North'
        WHEN PLANT_LOCATION ILIKE '%Recife%' THEN 'Northeast'
        ELSE 'Other'
    END                                         AS PLANT_REGION
FROM PLANTS;
