-- ============================================================
-- Script  : 04_put_files_to_stage.sql
-- Purpose : Upload local CSV files to Snowflake internal stage
--           STGINT_SMART_BI using PUT command
-- Author  : Mayuresh Prakash Badgujar
-- Date    : May 2026
-- Layer   : Bronze (STG)
-- Notes   : PUT command only works from SnowSQL or Snowflake
--           connectors (not from Snowsight UI).
--           Run from the project root directory.
--           Files are organised into sub-paths on the stage.
-- ============================================================

-- Set context
USE DATABASE DB_DEMO_MAYURESH;
USE SCHEMA STG_BRONZE;
USE WAREHOUSE COMPUTE_WH;

-- ──────────────────────────────────────────────────────────────
-- OLIST FILES
-- ──────────────────────────────────────────────────────────────
PUT file://data/bronze/olist/olist_customers_dataset.csv
    @DB_DEMO_MAYURESH.STG_BRONZE.STGINT_SMART_BI/olist/
    AUTO_COMPRESS = TRUE
    OVERWRITE = TRUE;

PUT file://data/bronze/olist/olist_sellers_dataset.csv
    @DB_DEMO_MAYURESH.STG_BRONZE.STGINT_SMART_BI/olist/
    AUTO_COMPRESS = TRUE
    OVERWRITE = TRUE;

PUT file://data/bronze/olist/olist_products_dataset.csv
    @DB_DEMO_MAYURESH.STG_BRONZE.STGINT_SMART_BI/olist/
    AUTO_COMPRESS = TRUE
    OVERWRITE = TRUE;

PUT file://data/bronze/olist/olist_orders_dataset.csv
    @DB_DEMO_MAYURESH.STG_BRONZE.STGINT_SMART_BI/olist/
    AUTO_COMPRESS = TRUE
    OVERWRITE = TRUE;

PUT file://data/bronze/olist/olist_order_items_dataset.csv
    @DB_DEMO_MAYURESH.STG_BRONZE.STGINT_SMART_BI/olist/
    AUTO_COMPRESS = TRUE
    OVERWRITE = TRUE;

PUT file://data/bronze/olist/olist_order_payments_dataset.csv
    @DB_DEMO_MAYURESH.STG_BRONZE.STGINT_SMART_BI/olist/
    AUTO_COMPRESS = TRUE
    OVERWRITE = TRUE;

PUT file://data/bronze/olist/olist_order_reviews_dataset.csv
    @DB_DEMO_MAYURESH.STG_BRONZE.STGINT_SMART_BI/olist/
    AUTO_COMPRESS = TRUE
    OVERWRITE = TRUE;

PUT file://data/bronze/olist/product_category_name_translation.csv
    @DB_DEMO_MAYURESH.STG_BRONZE.STGINT_SMART_BI/olist/
    AUTO_COMPRESS = TRUE
    OVERWRITE = TRUE;

-- ──────────────────────────────────────────────────────────────
-- NORTHWIND FILES
-- ──────────────────────────────────────────────────────────────
PUT file://data/bronze/northwind/categories.csv
    @DB_DEMO_MAYURESH.STG_BRONZE.STGINT_SMART_BI/northwind/
    AUTO_COMPRESS = TRUE
    OVERWRITE = TRUE;

PUT file://data/bronze/northwind/suppliers.csv
    @DB_DEMO_MAYURESH.STG_BRONZE.STGINT_SMART_BI/northwind/
    AUTO_COMPRESS = TRUE
    OVERWRITE = TRUE;

PUT file://data/bronze/northwind/products.csv
    @DB_DEMO_MAYURESH.STG_BRONZE.STGINT_SMART_BI/northwind/
    AUTO_COMPRESS = TRUE
    OVERWRITE = TRUE;

PUT file://data/bronze/northwind/employees.csv
    @DB_DEMO_MAYURESH.STG_BRONZE.STGINT_SMART_BI/northwind/
    AUTO_COMPRESS = TRUE
    OVERWRITE = TRUE;

PUT file://data/bronze/northwind/customers.csv
    @DB_DEMO_MAYURESH.STG_BRONZE.STGINT_SMART_BI/northwind/
    AUTO_COMPRESS = TRUE
    OVERWRITE = TRUE;

PUT file://data/bronze/northwind/orders.csv
    @DB_DEMO_MAYURESH.STG_BRONZE.STGINT_SMART_BI/northwind/
    AUTO_COMPRESS = TRUE
    OVERWRITE = TRUE;

PUT file://data/bronze/northwind/order_details.csv
    @DB_DEMO_MAYURESH.STG_BRONZE.STGINT_SMART_BI/northwind/
    AUTO_COMPRESS = TRUE
    OVERWRITE = TRUE;

-- ──────────────────────────────────────────────────────────────
-- MANUFACTURING FILES
-- ──────────────────────────────────────────────────────────────
PUT file://data/bronze/manufacturing/machines.csv
    @DB_DEMO_MAYURESH.STG_BRONZE.STGINT_SMART_BI/manufacturing/
    AUTO_COMPRESS = TRUE
    OVERWRITE = TRUE;

PUT file://data/bronze/manufacturing/inventory.csv
    @DB_DEMO_MAYURESH.STG_BRONZE.STGINT_SMART_BI/manufacturing/
    AUTO_COMPRESS = TRUE
    OVERWRITE = TRUE;

PUT file://data/bronze/manufacturing/production_orders.csv
    @DB_DEMO_MAYURESH.STG_BRONZE.STGINT_SMART_BI/manufacturing/
    AUTO_COMPRESS = TRUE
    OVERWRITE = TRUE;

PUT file://data/bronze/manufacturing/defects.csv
    @DB_DEMO_MAYURESH.STG_BRONZE.STGINT_SMART_BI/manufacturing/
    AUTO_COMPRESS = TRUE
    OVERWRITE = TRUE;

PUT file://data/bronze/manufacturing/machine_downtime.csv
    @DB_DEMO_MAYURESH.STG_BRONZE.STGINT_SMART_BI/manufacturing/
    AUTO_COMPRESS = TRUE
    OVERWRITE = TRUE;

-- ──────────────────────────────────────────────────────────────
-- Verify files uploaded
-- ──────────────────────────────────────────────────────────────
LIST @DB_DEMO_MAYURESH.STG_BRONZE.STGINT_SMART_BI/olist/;
LIST @DB_DEMO_MAYURESH.STG_BRONZE.STGINT_SMART_BI/northwind/;
LIST @DB_DEMO_MAYURESH.STG_BRONZE.STGINT_SMART_BI/manufacturing/;
