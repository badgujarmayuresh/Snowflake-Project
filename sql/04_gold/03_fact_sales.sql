-- ============================================================
-- Script  : 03_fact_sales.sql
-- Purpose : Create FACT_SALES table
-- Author  : Mayuresh Prakash Badgujar
-- Date    : May 2026
-- Layer   : Gold (REP)
-- Grain   : One row per order item (line item level)
-- Measures: Revenue (price), freight, quantity
-- Sources : OLIST_ORDER_ITEMS + OLIST_ORDERS
-- ============================================================

USE DATABASE DB_DEMO_MAYURESH;
USE SCHEMA REP_GOLD;
USE WAREHOUSE COMPUTE_WH;

CREATE OR REPLACE TABLE DB_DEMO_MAYURESH.REP_GOLD.TBL_FACT_SALES
COMMENT = 'Gold - Sales fact. Grain: one row per order line item. Measures: price, freight, total revenue.'
AS
SELECT
    -- Keys
    OI.ORDER_ID,
    OI.ORDER_ITEM_ID,
    OI.PRODUCT_ID,
    OI.SELLER_ID,
    O.CUSTOMER_ID,
    TO_NUMBER(TO_CHAR(O.ORDER_PURCHASE_TIMESTAMP::DATE, 'YYYYMMDD'))  AS ORDER_DATE_KEY,

    -- Dimensions context
    O.ORDER_STATUS,

    -- Measures
    OI.PRICE                                    AS ITEM_PRICE,
    OI.FREIGHT_VALUE,
    OI.PRICE + OI.FREIGHT_VALUE                 AS TOTAL_REVENUE,
    1                                           AS ITEM_COUNT

FROM DB_DEMO_MAYURESH.PRC_SILVER.TBL_OLIST_ORDER_ITEMS OI
INNER JOIN DB_DEMO_MAYURESH.PRC_SILVER.TBL_OLIST_ORDERS O
    ON OI.ORDER_ID = O.ORDER_ID;
