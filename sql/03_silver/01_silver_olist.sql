-- ============================================================
-- Script  : 01_silver_olist.sql
-- Purpose : Create Silver layer tables for Olist E-commerce.
--           Type casting, deduplication, null handling, trimming.
-- Author  : Mayuresh Prakash Badgujar
-- Date    : May 2026
-- Layer   : Silver (PRC)
-- Source  : STG_BRONZE.TBL_OLIST_*
-- Target  : PRC_SILVER.TBL_OLIST_*
-- Notes   : Safe to re-run (uses CREATE OR REPLACE).
--           No business logic — technical cleansing only.
-- ============================================================

USE DATABASE DB_DEMO_MAYURESH;
USE SCHEMA PRC_SILVER;
USE WAREHOUSE COMPUTE_WH;

-- ──────────────────────────────────────────────────────────────
-- 1. Olist Customers
-- ──────────────────────────────────────────────────────────────
CREATE OR REPLACE TABLE DB_DEMO_MAYURESH.PRC_SILVER.TBL_OLIST_CUSTOMERS
COMMENT = 'Silver - Olist customers. Deduped, typed, trimmed.'
AS
WITH DEDUP AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY CUSTOMER_ID ORDER BY _LOADED_AT DESC) AS _RN
    FROM DB_DEMO_MAYURESH.STG_BRONZE.TBL_OLIST_CUSTOMERS
)
SELECT
    TRIM(CUSTOMER_ID)                           AS CUSTOMER_ID,
    TRIM(CUSTOMER_UNIQUE_ID)                    AS CUSTOMER_UNIQUE_ID,
    TRIM(CUSTOMER_ZIP_CODE_PREFIX)              AS CUSTOMER_ZIP_CODE_PREFIX,
    INITCAP(TRIM(CUSTOMER_CITY))               AS CUSTOMER_CITY,
    UPPER(TRIM(CUSTOMER_STATE))                AS CUSTOMER_STATE
FROM DEDUP
WHERE _RN = 1;

-- ──────────────────────────────────────────────────────────────
-- 2. Olist Sellers
-- ──────────────────────────────────────────────────────────────
CREATE OR REPLACE TABLE DB_DEMO_MAYURESH.PRC_SILVER.TBL_OLIST_SELLERS
COMMENT = 'Silver - Olist sellers. Deduped, typed, trimmed.'
AS
WITH DEDUP AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY SELLER_ID ORDER BY _LOADED_AT DESC) AS _RN
    FROM DB_DEMO_MAYURESH.STG_BRONZE.TBL_OLIST_SELLERS
)
SELECT
    TRIM(SELLER_ID)                             AS SELLER_ID,
    TRIM(SELLER_ZIP_CODE_PREFIX)                AS SELLER_ZIP_CODE_PREFIX,
    INITCAP(TRIM(SELLER_CITY))                 AS SELLER_CITY,
    UPPER(TRIM(SELLER_STATE))                  AS SELLER_STATE
FROM DEDUP
WHERE _RN = 1;

-- ──────────────────────────────────────────────────────────────
-- 3. Olist Products
-- ──────────────────────────────────────────────────────────────
CREATE OR REPLACE TABLE DB_DEMO_MAYURESH.PRC_SILVER.TBL_OLIST_PRODUCTS
COMMENT = 'Silver - Olist products. Deduped, typed, trimmed.'
AS
WITH DEDUP AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY PRODUCT_ID ORDER BY _LOADED_AT DESC) AS _RN
    FROM DB_DEMO_MAYURESH.STG_BRONZE.TBL_OLIST_PRODUCTS
)
SELECT
    TRIM(PRODUCT_ID)                            AS PRODUCT_ID,
    LOWER(TRIM(PRODUCT_CATEGORY_NAME))         AS PRODUCT_CATEGORY_NAME,
    PRODUCT_NAME_LENGTH,
    PRODUCT_DESCRIPTION_LENGTH,
    PRODUCT_PHOTOS_QTY,
    PRODUCT_WEIGHT_G,
    PRODUCT_LENGTH_CM,
    PRODUCT_HEIGHT_CM,
    PRODUCT_WIDTH_CM
FROM DEDUP
WHERE _RN = 1;

-- ──────────────────────────────────────────────────────────────
-- 4. Olist Orders
-- ──────────────────────────────────────────────────────────────
CREATE OR REPLACE TABLE DB_DEMO_MAYURESH.PRC_SILVER.TBL_OLIST_ORDERS
COMMENT = 'Silver - Olist orders. Deduped, timestamps cast, trimmed.'
AS
WITH DEDUP AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY ORDER_ID ORDER BY _LOADED_AT DESC) AS _RN
    FROM DB_DEMO_MAYURESH.STG_BRONZE.TBL_OLIST_ORDERS
)
SELECT
    TRIM(ORDER_ID)                                              AS ORDER_ID,
    TRIM(CUSTOMER_ID)                                           AS CUSTOMER_ID,
    LOWER(TRIM(ORDER_STATUS))                                   AS ORDER_STATUS,
    TRY_TO_TIMESTAMP_NTZ(ORDER_PURCHASE_TIMESTAMP)              AS ORDER_PURCHASE_TIMESTAMP,
    TRY_TO_DATE(ORDER_APPROVED_AT)                              AS ORDER_APPROVED_AT,
    TRY_TO_DATE(ORDER_DELIVERED_CARRIER_DATE)                   AS ORDER_DELIVERED_CARRIER_DATE,
    TRY_TO_DATE(ORDER_DELIVERED_CUSTOMER_DATE)                  AS ORDER_DELIVERED_CUSTOMER_DATE,
    TRY_TO_DATE(ORDER_ESTIMATED_DELIVERY_DATE)                  AS ORDER_ESTIMATED_DELIVERY_DATE
FROM DEDUP
WHERE _RN = 1;

-- ──────────────────────────────────────────────────────────────
-- 5. Olist Order Items
-- ──────────────────────────────────────────────────────────────
CREATE OR REPLACE TABLE DB_DEMO_MAYURESH.PRC_SILVER.TBL_OLIST_ORDER_ITEMS
COMMENT = 'Silver - Olist order items. Deduped, typed, trimmed.'
AS
WITH DEDUP AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY ORDER_ID, ORDER_ITEM_ID ORDER BY _LOADED_AT DESC) AS _RN
    FROM DB_DEMO_MAYURESH.STG_BRONZE.TBL_OLIST_ORDER_ITEMS
)
SELECT
    TRIM(ORDER_ID)                              AS ORDER_ID,
    ORDER_ITEM_ID,
    TRIM(PRODUCT_ID)                            AS PRODUCT_ID,
    TRIM(SELLER_ID)                             AS SELLER_ID,
    TRY_TO_DATE(SHIPPING_LIMIT_DATE)            AS SHIPPING_LIMIT_DATE,
    PRICE,
    FREIGHT_VALUE
FROM DEDUP
WHERE _RN = 1;

-- ──────────────────────────────────────────────────────────────
-- 6. Olist Order Payments
-- ──────────────────────────────────────────────────────────────
CREATE OR REPLACE TABLE DB_DEMO_MAYURESH.PRC_SILVER.TBL_OLIST_ORDER_PAYMENTS
COMMENT = 'Silver - Olist payments. Deduped, typed, trimmed.'
AS
WITH DEDUP AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY ORDER_ID, PAYMENT_SEQUENTIAL ORDER BY _LOADED_AT DESC) AS _RN
    FROM DB_DEMO_MAYURESH.STG_BRONZE.TBL_OLIST_ORDER_PAYMENTS
)
SELECT
    TRIM(ORDER_ID)                              AS ORDER_ID,
    PAYMENT_SEQUENTIAL,
    LOWER(TRIM(PAYMENT_TYPE))                   AS PAYMENT_TYPE,
    PAYMENT_INSTALLMENTS,
    PAYMENT_VALUE
FROM DEDUP
WHERE _RN = 1;

-- ──────────────────────────────────────────────────────────────
-- 7. Olist Order Reviews
-- ──────────────────────────────────────────────────────────────
CREATE OR REPLACE TABLE DB_DEMO_MAYURESH.PRC_SILVER.TBL_OLIST_ORDER_REVIEWS
COMMENT = 'Silver - Olist reviews. Deduped, typed, trimmed.'
AS
WITH DEDUP AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY REVIEW_ID ORDER BY _LOADED_AT DESC) AS _RN
    FROM DB_DEMO_MAYURESH.STG_BRONZE.TBL_OLIST_ORDER_REVIEWS
)
SELECT
    TRIM(REVIEW_ID)                             AS REVIEW_ID,
    TRIM(ORDER_ID)                              AS ORDER_ID,
    REVIEW_SCORE,
    TRIM(REVIEW_COMMENT_TITLE)                  AS REVIEW_COMMENT_TITLE,
    TRIM(REVIEW_COMMENT_MESSAGE)                AS REVIEW_COMMENT_MESSAGE,
    TRY_TO_DATE(REVIEW_CREATION_DATE)           AS REVIEW_CREATION_DATE,
    TRY_TO_TIMESTAMP_NTZ(REVIEW_ANSWER_TIMESTAMP) AS REVIEW_ANSWER_TIMESTAMP
FROM DEDUP
WHERE _RN = 1;

-- ──────────────────────────────────────────────────────────────
-- 8. Olist Category Translation
-- ──────────────────────────────────────────────────────────────
CREATE OR REPLACE TABLE DB_DEMO_MAYURESH.PRC_SILVER.TBL_OLIST_CATEGORY_TRANSLATION
COMMENT = 'Silver - Olist category translations. Trimmed, lowercased.'
AS
WITH DEDUP AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY PRODUCT_CATEGORY_NAME ORDER BY _LOADED_AT DESC) AS _RN
    FROM DB_DEMO_MAYURESH.STG_BRONZE.TBL_OLIST_CATEGORY_TRANSLATION
)
SELECT
    LOWER(TRIM(PRODUCT_CATEGORY_NAME))          AS PRODUCT_CATEGORY_NAME,
    INITCAP(TRIM(PRODUCT_CATEGORY_NAME_ENGLISH)) AS PRODUCT_CATEGORY_NAME_ENGLISH
FROM DEDUP
WHERE _RN = 1;
