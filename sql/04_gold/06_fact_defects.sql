-- ============================================================
-- Script  : 06_fact_defects.sql
-- Purpose : Create FACT_DEFECTS table
-- Author  : Mayuresh Prakash Badgujar
-- Date    : May 2026
-- Layer   : Gold (REP)
-- Grain   : One row per defect record
-- Measures: Defect quantity, defect rate
-- Sources : MFG_DEFECTS + MFG_PRODUCTION_ORDERS (for rate calc)
-- ============================================================

USE DATABASE DB_DEMO_MAYURESH;
USE SCHEMA REP_GOLD;
USE WAREHOUSE COMPUTE_WH;

CREATE OR REPLACE TABLE DB_DEMO_MAYURESH.REP_GOLD.TBL_FACT_DEFECTS
COMMENT = 'Gold - Defects fact. Grain: one row per defect record. Measures: defect qty, defect rate.'
AS
SELECT
    -- Keys
    D.DEFECT_ID,
    D.PRODUCTION_ORDER_ID,
    D.MACHINE_ID,
    TO_NUMBER(TO_CHAR(D.INSPECTION_DATE, 'YYYYMMDD')) AS INSPECTION_DATE_KEY,

    -- Dimension context
    D.DEFECT_TYPE,
    D.INSPECTOR_ID,
    D.CORRECTIVE_ACTION,
    D.INSPECTION_DATE,

    -- Measures
    D.DEFECT_QUANTITY,

    -- Calculated: defect rate = defect_qty / actual_qty produced
    CASE
        WHEN PO.ACTUAL_QUANTITY > 0
        THEN ROUND((D.DEFECT_QUANTITY::FLOAT / PO.ACTUAL_QUANTITY) * 100, 4)
        ELSE NULL
    END                                         AS DEFECT_RATE_PCT,

    -- Production context for analysis
    PO.ACTUAL_QUANTITY                           AS PRODUCTION_ACTUAL_QTY,
    PO.PLANT_LOCATION,
    MD5(PO.PLANT_LOCATION)                      AS PLANT_KEY

FROM DB_DEMO_MAYURESH.PRC_SILVER.TBL_MFG_DEFECTS D
LEFT JOIN DB_DEMO_MAYURESH.PRC_SILVER.TBL_MFG_PRODUCTION_ORDERS PO
    ON D.PRODUCTION_ORDER_ID = PO.PRODUCTION_ORDER_ID;
