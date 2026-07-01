-- ============================================================
-- Script  : 01_create_olist_tables.sql
-- Purpose : Create Bronze layer tables for Olist E-commerce
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
-- Olist Customers
-- ──────────────────────────────────────────────────────────────
CREATE OR REPLACE TABLE DB_DEMO_MAYURESH.STG_BRONZE.TBL_OLIST_CUSTOMERS (
    CUSTOMER_ID                 VARCHAR(50)     NOT NULL,
    CUSTOMER_UNIQUE_ID          VARCHAR(100),
    CUSTOMER_ZIP_CODE_PREFIX    VARCHAR(10),
    CUSTOMER_CITY               VARCHAR(100),
    CUSTOMER_STATE              VARCHAR(10),
    -- Metadata
    _LOADED_AT                  TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP(),
    _SOURCE_FILE                VARCHAR(500)
)
COMMENT = 'Bronze - Olist e-commerce customer master data. Loaded as-is from source CSV.';

-- ──────────────────────────────────────────────────────────────
-- Olist Sellers
-- ──────────────────────────────────────────────────────────────
CREATE OR REPLACE TABLE DB_DEMO_MAYURESH.STG_BRONZE.TBL_OLIST_SELLERS (
    SELLER_ID                   VARCHAR(50)     NOT NULL,
    SELLER_ZIP_CODE_PREFIX      VARCHAR(10),
    SELLER_CITY                 VARCHAR(100),
    SELLER_STATE                VARCHAR(10),
    -- Metadata
    _LOADED_AT                  TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP(),
    _SOURCE_FILE                VARCHAR(500)
)
COMMENT = 'Bronze - Olist e-commerce seller master data. Loaded as-is from source CSV.';

-- ──────────────────────────────────────────────────────────────
-- Olist Products
-- ──────────────────────────────────────────────────────────────
CREATE OR REPLACE TABLE DB_DEMO_MAYURESH.STG_BRONZE.TBL_OLIST_PRODUCTS (
    PRODUCT_ID                  VARCHAR(50)     NOT NULL,
    PRODUCT_CATEGORY_NAME       VARCHAR(100),
    PRODUCT_NAME_LENGTH         NUMBER(10,0),
    PRODUCT_DESCRIPTION_LENGTH  NUMBER(10,0),
    PRODUCT_PHOTOS_QTY          NUMBER(10,0),
    PRODUCT_WEIGHT_G            NUMBER(10,0),
    PRODUCT_LENGTH_CM           NUMBER(10,0),
    PRODUCT_HEIGHT_CM           NUMBER(10,0),
    PRODUCT_WIDTH_CM            NUMBER(10,0),
    -- Metadata
    _LOADED_AT                  TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP(),
    _SOURCE_FILE                VARCHAR(500)
)
COMMENT = 'Bronze - Olist e-commerce product catalogue. Loaded as-is from source CSV.';

-- ──────────────────────────────────────────────────────────────
-- Olist Orders
-- ──────────────────────────────────────────────────────────────
CREATE OR REPLACE TABLE DB_DEMO_MAYURESH.STG_BRONZE.TBL_OLIST_ORDERS (
    ORDER_ID                        VARCHAR(50)     NOT NULL,
    CUSTOMER_ID                     VARCHAR(50),
    ORDER_STATUS                    VARCHAR(30),
    ORDER_PURCHASE_TIMESTAMP        VARCHAR(50),
    ORDER_APPROVED_AT               VARCHAR(50),
    ORDER_DELIVERED_CARRIER_DATE    VARCHAR(50),
    ORDER_DELIVERED_CUSTOMER_DATE   VARCHAR(50),
    ORDER_ESTIMATED_DELIVERY_DATE   VARCHAR(50),
    -- Metadata
    _LOADED_AT                      TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP(),
    _SOURCE_FILE                    VARCHAR(500)
)
COMMENT = 'Bronze - Olist e-commerce order headers. Loaded as-is from source CSV.';

-- ──────────────────────────────────────────────────────────────
-- Olist Order Items
-- ──────────────────────────────────────────────────────────────
CREATE OR REPLACE TABLE DB_DEMO_MAYURESH.STG_BRONZE.TBL_OLIST_ORDER_ITEMS (
    ORDER_ID                    VARCHAR(50)     NOT NULL,
    ORDER_ITEM_ID               NUMBER(10,0),
    PRODUCT_ID                  VARCHAR(50),
    SELLER_ID                   VARCHAR(50),
    SHIPPING_LIMIT_DATE         VARCHAR(50),
    PRICE                       NUMBER(12,2),
    FREIGHT_VALUE               NUMBER(12,2),
    -- Metadata
    _LOADED_AT                  TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP(),
    _SOURCE_FILE                VARCHAR(500)
)
COMMENT = 'Bronze - Olist e-commerce order line items. Loaded as-is from source CSV.';

-- ──────────────────────────────────────────────────────────────
-- Olist Order Payments
-- ──────────────────────────────────────────────────────────────
CREATE OR REPLACE TABLE DB_DEMO_MAYURESH.STG_BRONZE.TBL_OLIST_ORDER_PAYMENTS (
    ORDER_ID                    VARCHAR(50)     NOT NULL,
    PAYMENT_SEQUENTIAL          NUMBER(10,0),
    PAYMENT_TYPE                VARCHAR(30),
    PAYMENT_INSTALLMENTS        NUMBER(10,0),
    PAYMENT_VALUE               NUMBER(12,2),
    -- Metadata
    _LOADED_AT                  TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP(),
    _SOURCE_FILE                VARCHAR(500)
)
COMMENT = 'Bronze - Olist e-commerce payment transactions. Loaded as-is from source CSV.';

-- ──────────────────────────────────────────────────────────────
-- Olist Order Reviews
-- ──────────────────────────────────────────────────────────────
CREATE OR REPLACE TABLE DB_DEMO_MAYURESH.STG_BRONZE.TBL_OLIST_ORDER_REVIEWS (
    REVIEW_ID                   VARCHAR(100)    NOT NULL,
    ORDER_ID                    VARCHAR(50),
    REVIEW_SCORE                NUMBER(1,0),
    REVIEW_COMMENT_TITLE        VARCHAR(500),
    REVIEW_COMMENT_MESSAGE      VARCHAR(2000),
    REVIEW_CREATION_DATE        VARCHAR(50),
    REVIEW_ANSWER_TIMESTAMP     VARCHAR(50),
    -- Metadata
    _LOADED_AT                  TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP(),
    _SOURCE_FILE                VARCHAR(500)
)
COMMENT = 'Bronze - Olist e-commerce customer reviews. Loaded as-is from source CSV.';

-- ──────────────────────────────────────────────────────────────
-- Product Category Name Translation
-- ──────────────────────────────────────────────────────────────
CREATE OR REPLACE TABLE DB_DEMO_MAYURESH.STG_BRONZE.TBL_OLIST_CATEGORY_TRANSLATION (
    PRODUCT_CATEGORY_NAME           VARCHAR(100),
    PRODUCT_CATEGORY_NAME_ENGLISH   VARCHAR(100),
    -- Metadata
    _LOADED_AT                      TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP(),
    _SOURCE_FILE                    VARCHAR(500)
)
COMMENT = 'Bronze - Olist product category name translations (Portuguese to English). Loaded as-is from source CSV.';
