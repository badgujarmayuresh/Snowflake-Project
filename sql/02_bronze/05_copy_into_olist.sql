-- ============================================================
-- Script  : 05_copy_into_olist.sql
-- Purpose : Load Olist CSV data from internal stage into
--           Bronze tables using COPY INTO
-- Author  : Mayuresh Prakash Badgujar
-- Date    : May 2026
-- Layer   : Bronze (STG)
-- Notes   : Run AFTER 04_put_files_to_stage.sql.
--           Uses METADATA$FILENAME to track source file.
--           ON_ERROR = CONTINUE allows partial loads for debugging.
-- ============================================================

-- Set context
USE DATABASE DB_DEMO_MAYURESH;
USE SCHEMA STG_BRONZE;
USE WAREHOUSE COMPUTE_WH;

-- ──────────────────────────────────────────────────────────────
-- Olist Customers
-- ──────────────────────────────────────────────────────────────
COPY INTO DB_DEMO_MAYURESH.STG_BRONZE.TBL_OLIST_CUSTOMERS
    (CUSTOMER_ID, CUSTOMER_UNIQUE_ID, CUSTOMER_ZIP_CODE_PREFIX,
     CUSTOMER_CITY, CUSTOMER_STATE, _LOADED_AT, _SOURCE_FILE)
FROM (
    SELECT
        $1, $2, $3, $4, $5,
        CURRENT_TIMESTAMP(),
        METADATA$FILENAME
    FROM @DB_DEMO_MAYURESH.STG_BRONZE.STGINT_SMART_BI/olist/olist_customers_dataset.csv
)
FILE_FORMAT = (FORMAT_NAME = 'DB_DEMO_MAYURESH.STG_BRONZE.FF_CSV_STANDARD')
ON_ERROR = CONTINUE;

-- ──────────────────────────────────────────────────────────────
-- Olist Sellers
-- ──────────────────────────────────────────────────────────────
COPY INTO DB_DEMO_MAYURESH.STG_BRONZE.TBL_OLIST_SELLERS
    (SELLER_ID, SELLER_ZIP_CODE_PREFIX, SELLER_CITY,
     SELLER_STATE, _LOADED_AT, _SOURCE_FILE)
FROM (
    SELECT
        $1, $2, $3, $4,
        CURRENT_TIMESTAMP(),
        METADATA$FILENAME
    FROM @DB_DEMO_MAYURESH.STG_BRONZE.STGINT_SMART_BI/olist/olist_sellers_dataset.csv
)
FILE_FORMAT = (FORMAT_NAME = 'DB_DEMO_MAYURESH.STG_BRONZE.FF_CSV_STANDARD')
ON_ERROR = CONTINUE;

-- ──────────────────────────────────────────────────────────────
-- Olist Products
-- ──────────────────────────────────────────────────────────────
COPY INTO DB_DEMO_MAYURESH.STG_BRONZE.TBL_OLIST_PRODUCTS
    (PRODUCT_ID, PRODUCT_CATEGORY_NAME, PRODUCT_NAME_LENGTH,
     PRODUCT_DESCRIPTION_LENGTH, PRODUCT_PHOTOS_QTY,
     PRODUCT_WEIGHT_G, PRODUCT_LENGTH_CM, PRODUCT_HEIGHT_CM,
     PRODUCT_WIDTH_CM, _LOADED_AT, _SOURCE_FILE)
FROM (
    SELECT
        $1, $2, $3, $4, $5, $6, $7, $8, $9,
        CURRENT_TIMESTAMP(),
        METADATA$FILENAME
    FROM @DB_DEMO_MAYURESH.STG_BRONZE.STGINT_SMART_BI/olist/olist_products_dataset.csv
)
FILE_FORMAT = (FORMAT_NAME = 'DB_DEMO_MAYURESH.STG_BRONZE.FF_CSV_STANDARD')
ON_ERROR = CONTINUE;

-- ──────────────────────────────────────────────────────────────
-- Olist Orders
-- ──────────────────────────────────────────────────────────────
COPY INTO DB_DEMO_MAYURESH.STG_BRONZE.TBL_OLIST_ORDERS
    (ORDER_ID, CUSTOMER_ID, ORDER_STATUS, ORDER_PURCHASE_TIMESTAMP,
     ORDER_APPROVED_AT, ORDER_DELIVERED_CARRIER_DATE,
     ORDER_DELIVERED_CUSTOMER_DATE, ORDER_ESTIMATED_DELIVERY_DATE,
     _LOADED_AT, _SOURCE_FILE)
FROM (
    SELECT
        $1, $2, $3, $4, $5, $6, $7, $8,
        CURRENT_TIMESTAMP(),
        METADATA$FILENAME
    FROM @DB_DEMO_MAYURESH.STG_BRONZE.STGINT_SMART_BI/olist/olist_orders_dataset.csv
)
FILE_FORMAT = (FORMAT_NAME = 'DB_DEMO_MAYURESH.STG_BRONZE.FF_CSV_STANDARD')
ON_ERROR = CONTINUE;

-- ──────────────────────────────────────────────────────────────
-- Olist Order Items
-- ──────────────────────────────────────────────────────────────
COPY INTO DB_DEMO_MAYURESH.STG_BRONZE.TBL_OLIST_ORDER_ITEMS
    (ORDER_ID, ORDER_ITEM_ID, PRODUCT_ID, SELLER_ID,
     SHIPPING_LIMIT_DATE, PRICE, FREIGHT_VALUE,
     _LOADED_AT, _SOURCE_FILE)
FROM (
    SELECT
        $1, $2, $3, $4, $5, $6, $7,
        CURRENT_TIMESTAMP(),
        METADATA$FILENAME
    FROM @DB_DEMO_MAYURESH.STG_BRONZE.STGINT_SMART_BI/olist/olist_order_items_dataset.csv
)
FILE_FORMAT = (FORMAT_NAME = 'DB_DEMO_MAYURESH.STG_BRONZE.FF_CSV_STANDARD')
ON_ERROR = CONTINUE;

-- ──────────────────────────────────────────────────────────────
-- Olist Order Payments
-- ──────────────────────────────────────────────────────────────
COPY INTO DB_DEMO_MAYURESH.STG_BRONZE.TBL_OLIST_ORDER_PAYMENTS
    (ORDER_ID, PAYMENT_SEQUENTIAL, PAYMENT_TYPE,
     PAYMENT_INSTALLMENTS, PAYMENT_VALUE,
     _LOADED_AT, _SOURCE_FILE)
FROM (
    SELECT
        $1, $2, $3, $4, $5,
        CURRENT_TIMESTAMP(),
        METADATA$FILENAME
    FROM @DB_DEMO_MAYURESH.STG_BRONZE.STGINT_SMART_BI/olist/olist_order_payments_dataset.csv
)
FILE_FORMAT = (FORMAT_NAME = 'DB_DEMO_MAYURESH.STG_BRONZE.FF_CSV_STANDARD')
ON_ERROR = CONTINUE;

-- ──────────────────────────────────────────────────────────────
-- Olist Order Reviews
-- ──────────────────────────────────────────────────────────────
COPY INTO DB_DEMO_MAYURESH.STG_BRONZE.TBL_OLIST_ORDER_REVIEWS
    (REVIEW_ID, ORDER_ID, REVIEW_SCORE, REVIEW_COMMENT_TITLE,
     REVIEW_COMMENT_MESSAGE, REVIEW_CREATION_DATE,
     REVIEW_ANSWER_TIMESTAMP, _LOADED_AT, _SOURCE_FILE)
FROM (
    SELECT
        $1, $2, $3, $4, $5, $6, $7,
        CURRENT_TIMESTAMP(),
        METADATA$FILENAME
    FROM @DB_DEMO_MAYURESH.STG_BRONZE.STGINT_SMART_BI/olist/olist_order_reviews_dataset.csv
)
FILE_FORMAT = (FORMAT_NAME = 'DB_DEMO_MAYURESH.STG_BRONZE.FF_CSV_STANDARD')
ON_ERROR = CONTINUE;

-- ──────────────────────────────────────────────────────────────
-- Product Category Translation
-- ──────────────────────────────────────────────────────────────
COPY INTO DB_DEMO_MAYURESH.STG_BRONZE.TBL_OLIST_CATEGORY_TRANSLATION
    (PRODUCT_CATEGORY_NAME, PRODUCT_CATEGORY_NAME_ENGLISH,
     _LOADED_AT, _SOURCE_FILE)
FROM (
    SELECT
        $1, $2,
        CURRENT_TIMESTAMP(),
        METADATA$FILENAME
    FROM @DB_DEMO_MAYURESH.STG_BRONZE.STGINT_SMART_BI/olist/product_category_name_translation.csv
)
FILE_FORMAT = (FORMAT_NAME = 'DB_DEMO_MAYURESH.STG_BRONZE.FF_CSV_STANDARD')
ON_ERROR = CONTINUE;

-- ──────────────────────────────────────────────────────────────
-- Verify row counts
-- ──────────────────────────────────────────────────────────────
SELECT 'TBL_OLIST_CUSTOMERS'         AS TABLE_NAME, COUNT(*) AS ROW_COUNT FROM DB_DEMO_MAYURESH.STG_BRONZE.TBL_OLIST_CUSTOMERS
UNION ALL
SELECT 'TBL_OLIST_SELLERS',          COUNT(*) FROM DB_DEMO_MAYURESH.STG_BRONZE.TBL_OLIST_SELLERS
UNION ALL
SELECT 'TBL_OLIST_PRODUCTS',         COUNT(*) FROM DB_DEMO_MAYURESH.STG_BRONZE.TBL_OLIST_PRODUCTS
UNION ALL
SELECT 'TBL_OLIST_ORDERS',           COUNT(*) FROM DB_DEMO_MAYURESH.STG_BRONZE.TBL_OLIST_ORDERS
UNION ALL
SELECT 'TBL_OLIST_ORDER_ITEMS',      COUNT(*) FROM DB_DEMO_MAYURESH.STG_BRONZE.TBL_OLIST_ORDER_ITEMS
UNION ALL
SELECT 'TBL_OLIST_ORDER_PAYMENTS',   COUNT(*) FROM DB_DEMO_MAYURESH.STG_BRONZE.TBL_OLIST_ORDER_PAYMENTS
UNION ALL
SELECT 'TBL_OLIST_ORDER_REVIEWS',    COUNT(*) FROM DB_DEMO_MAYURESH.STG_BRONZE.TBL_OLIST_ORDER_REVIEWS
UNION ALL
SELECT 'TBL_OLIST_CATEGORY_TRANSLATION', COUNT(*) FROM DB_DEMO_MAYURESH.STG_BRONZE.TBL_OLIST_CATEGORY_TRANSLATION;
