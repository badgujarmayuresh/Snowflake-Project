-- ============================================================
-- Script  : 04_fact_orders.sql
-- Purpose : Create FACT_ORDERS table
-- Author  : Mayuresh Prakash Badgujar
-- Date    : May 2026
-- Layer   : Gold (REP)
-- Grain   : One row per order
-- Measures: Payment value, delivery days, item count
-- Sources : OLIST_ORDERS + OLIST_ORDER_PAYMENTS + OLIST_ORDER_ITEMS
-- ============================================================

USE DATABASE DB_DEMO_MAYURESH;
USE SCHEMA REP_GOLD;
USE WAREHOUSE COMPUTE_WH;

CREATE OR REPLACE TABLE DB_DEMO_MAYURESH.REP_GOLD.TBL_FACT_ORDERS
COMMENT = 'Gold - Orders fact. Grain: one row per order. Measures: payment value, delivery days, item count.'
AS
WITH PAYMENT_AGG AS (
    SELECT
        ORDER_ID,
        SUM(PAYMENT_VALUE)                      AS TOTAL_PAYMENT_VALUE,
        MAX(PAYMENT_INSTALLMENTS)               AS MAX_INSTALLMENTS,
        COUNT(*)                                AS PAYMENT_COUNT
    FROM DB_DEMO_MAYURESH.PRC_SILVER.TBL_OLIST_ORDER_PAYMENTS
    GROUP BY ORDER_ID
),
ITEM_AGG AS (
    SELECT
        ORDER_ID,
        COUNT(*)                                AS TOTAL_ITEMS,
        SUM(PRICE)                              AS TOTAL_ITEM_VALUE,
        SUM(FREIGHT_VALUE)                      AS TOTAL_FREIGHT
    FROM DB_DEMO_MAYURESH.PRC_SILVER.TBL_OLIST_ORDER_ITEMS
    GROUP BY ORDER_ID
)
SELECT
    -- Keys
    O.ORDER_ID,
    O.CUSTOMER_ID,
    TO_NUMBER(TO_CHAR(O.ORDER_PURCHASE_TIMESTAMP::DATE, 'YYYYMMDD'))  AS ORDER_DATE_KEY,

    -- Dimension context
    O.ORDER_STATUS,
    O.ORDER_PURCHASE_TIMESTAMP,
    O.ORDER_APPROVED_AT,
    O.ORDER_DELIVERED_CARRIER_DATE,
    O.ORDER_DELIVERED_CUSTOMER_DATE,
    O.ORDER_ESTIMATED_DELIVERY_DATE,

    -- Measures from payments
    COALESCE(P.TOTAL_PAYMENT_VALUE, 0)          AS TOTAL_PAYMENT_VALUE,
    COALESCE(P.MAX_INSTALLMENTS, 0)             AS MAX_INSTALLMENTS,
    COALESCE(P.PAYMENT_COUNT, 0)                AS PAYMENT_COUNT,

    -- Measures from items
    COALESCE(I.TOTAL_ITEMS, 0)                  AS TOTAL_ITEMS,
    COALESCE(I.TOTAL_ITEM_VALUE, 0)             AS TOTAL_ITEM_VALUE,
    COALESCE(I.TOTAL_FREIGHT, 0)                AS TOTAL_FREIGHT,

    -- Calculated measures
    DATEDIFF('day', O.ORDER_PURCHASE_TIMESTAMP::DATE,
             O.ORDER_DELIVERED_CUSTOMER_DATE)   AS DELIVERY_DAYS,
    DATEDIFF('day', O.ORDER_PURCHASE_TIMESTAMP::DATE,
             O.ORDER_ESTIMATED_DELIVERY_DATE)   AS ESTIMATED_DELIVERY_DAYS,
    DATEDIFF('day', O.ORDER_DELIVERED_CUSTOMER_DATE,
             O.ORDER_ESTIMATED_DELIVERY_DATE)   AS DELIVERY_VARIANCE_DAYS

FROM DB_DEMO_MAYURESH.PRC_SILVER.TBL_OLIST_ORDERS O
LEFT JOIN PAYMENT_AGG P ON O.ORDER_ID = P.ORDER_ID
LEFT JOIN ITEM_AGG I ON O.ORDER_ID = I.ORDER_ID;
