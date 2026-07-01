-- ============================================================
-- Script  : 05_fact_production.sql
-- Purpose : Create FACT_PRODUCTION table
-- Author  : Mayuresh Prakash Badgujar
-- Date    : May 2026
-- Layer   : Gold (REP)
-- Grain   : One row per production order
-- Measures: Planned qty, actual qty, variance, cost
-- Sources : MFG_PRODUCTION_ORDERS
-- ============================================================

USE DATABASE DB_DEMO_MAYURESH;
USE SCHEMA REP_GOLD;
USE WAREHOUSE COMPUTE_WH;

CREATE OR REPLACE TABLE DB_DEMO_MAYURESH.REP_GOLD.TBL_FACT_PRODUCTION
COMMENT = 'Gold - Production fact. Grain: one row per production order. Measures: quantities, cost, variance.'
AS
SELECT
    -- Keys
    PO.PRODUCTION_ORDER_ID,
    PO.PRODUCT_ID,
    PO.MACHINE_ID,
    MD5(PO.PLANT_LOCATION)                      AS PLANT_KEY,
    TO_NUMBER(TO_CHAR(PO.START_DATE, 'YYYYMMDD')) AS START_DATE_KEY,
    TO_NUMBER(TO_CHAR(PO.END_DATE, 'YYYYMMDD'))   AS END_DATE_KEY,

    -- Dimension context
    PO.PLANT_LOCATION,
    PO.SHIFT,
    PO.STATUS,
    PO.OPERATOR_ID,
    PO.START_DATE,
    PO.END_DATE,

    -- Measures
    PO.PLANNED_QUANTITY,
    PO.ACTUAL_QUANTITY,
    PO.PRODUCTION_COST,

    -- Calculated measures
    PO.ACTUAL_QUANTITY - PO.PLANNED_QUANTITY     AS QUANTITY_VARIANCE,
    CASE
        WHEN PO.PLANNED_QUANTITY > 0
        THEN ROUND((PO.ACTUAL_QUANTITY::FLOAT / PO.PLANNED_QUANTITY) * 100, 2)
        ELSE NULL
    END                                         AS PRODUCTION_EFFICIENCY_PCT,
    DATEDIFF('day', PO.START_DATE, PO.END_DATE) AS PRODUCTION_DURATION_DAYS

FROM DB_DEMO_MAYURESH.PRC_SILVER.TBL_MFG_PRODUCTION_ORDERS PO;
