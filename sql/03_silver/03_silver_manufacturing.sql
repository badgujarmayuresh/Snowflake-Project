-- ============================================================
-- Script  : 03_silver_manufacturing.sql
-- Purpose : Create Silver layer tables for Manufacturing.
--           Type casting, deduplication, null handling, trimming.
-- Author  : Mayuresh Prakash Badgujar
-- Date    : May 2026
-- Layer   : Silver (PRC)
-- Source  : STG_BRONZE.TBL_MFG_*
-- Target  : PRC_SILVER.TBL_MFG_*
-- Notes   : Safe to re-run (uses CREATE OR REPLACE).
--           No business logic — technical cleansing only.
-- ============================================================

USE DATABASE DB_DEMO_MAYURESH;
USE SCHEMA PRC_SILVER;
USE WAREHOUSE COMPUTE_WH;

-- ──────────────────────────────────────────────────────────────
-- 1. Manufacturing Machines
-- ──────────────────────────────────────────────────────────────
CREATE OR REPLACE TABLE DB_DEMO_MAYURESH.PRC_SILVER.TBL_MFG_MACHINES
COMMENT = 'Silver - Manufacturing machines. Deduped, dates cast, trimmed.'
AS
WITH DEDUP AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY MACHINE_ID ORDER BY _LOADED_AT DESC) AS _RN
    FROM DB_DEMO_MAYURESH.STG_BRONZE.TBL_MFG_MACHINES
)
SELECT
    TRIM(MACHINE_ID)                            AS MACHINE_ID,
    TRIM(MACHINE_NAME)                          AS MACHINE_NAME,
    TRIM(MACHINE_TYPE)                          AS MACHINE_TYPE,
    TRIM(PLANT_LOCATION)                        AS PLANT_LOCATION,
    TRY_TO_DATE(INSTALLATION_DATE)              AS INSTALLATION_DATE,
    TRY_TO_DATE(LAST_MAINTENANCE_DATE)          AS LAST_MAINTENANCE_DATE,
    INITCAP(TRIM(STATUS))                       AS STATUS,
    CAPACITY_PER_HOUR
FROM DEDUP
WHERE _RN = 1;

-- ──────────────────────────────────────────────────────────────
-- 2. Manufacturing Inventory
-- ──────────────────────────────────────────────────────────────
CREATE OR REPLACE TABLE DB_DEMO_MAYURESH.PRC_SILVER.TBL_MFG_INVENTORY
COMMENT = 'Silver - Manufacturing inventory. Deduped, dates cast, trimmed.'
AS
WITH DEDUP AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY MATERIAL_ID ORDER BY _LOADED_AT DESC) AS _RN
    FROM DB_DEMO_MAYURESH.STG_BRONZE.TBL_MFG_INVENTORY
)
SELECT
    TRIM(MATERIAL_ID)                           AS MATERIAL_ID,
    INITCAP(TRIM(MATERIAL_NAME))               AS MATERIAL_NAME,
    LOWER(TRIM(UNIT_OF_MEASURE))               AS UNIT_OF_MEASURE,
    CURRENT_STOCK,
    REORDER_POINT,
    UNIT_COST,
    TRIM(SUPPLIER_ID)                           AS SUPPLIER_ID,
    TRY_TO_DATE(LAST_RESTOCKED_DATE)            AS LAST_RESTOCKED_DATE
FROM DEDUP
WHERE _RN = 1;

-- ──────────────────────────────────────────────────────────────
-- 3. Manufacturing Production Orders
-- ──────────────────────────────────────────────────────────────
CREATE OR REPLACE TABLE DB_DEMO_MAYURESH.PRC_SILVER.TBL_MFG_PRODUCTION_ORDERS
COMMENT = 'Silver - Manufacturing production orders. Deduped, dates cast, trimmed.'
AS
WITH DEDUP AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY PRODUCTION_ORDER_ID ORDER BY _LOADED_AT DESC) AS _RN
    FROM DB_DEMO_MAYURESH.STG_BRONZE.TBL_MFG_PRODUCTION_ORDERS
)
SELECT
    TRIM(PRODUCTION_ORDER_ID)                   AS PRODUCTION_ORDER_ID,
    TRIM(PRODUCT_ID)                            AS PRODUCT_ID,
    TRIM(MACHINE_ID)                            AS MACHINE_ID,
    TRIM(PLANT_LOCATION)                        AS PLANT_LOCATION,
    INITCAP(TRIM(SHIFT))                        AS SHIFT,
    PLANNED_QUANTITY,
    ACTUAL_QUANTITY,
    TRY_TO_DATE(START_DATE)                     AS START_DATE,
    TRY_TO_DATE(END_DATE)                       AS END_DATE,
    INITCAP(TRIM(STATUS))                       AS STATUS,
    TRIM(OPERATOR_ID)                           AS OPERATOR_ID,
    PRODUCTION_COST
FROM DEDUP
WHERE _RN = 1;

-- ──────────────────────────────────────────────────────────────
-- 4. Manufacturing Defects
-- ──────────────────────────────────────────────────────────────
CREATE OR REPLACE TABLE DB_DEMO_MAYURESH.PRC_SILVER.TBL_MFG_DEFECTS
COMMENT = 'Silver - Manufacturing defects. Deduped, dates cast, trimmed.'
AS
WITH DEDUP AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY DEFECT_ID ORDER BY _LOADED_AT DESC) AS _RN
    FROM DB_DEMO_MAYURESH.STG_BRONZE.TBL_MFG_DEFECTS
)
SELECT
    TRIM(DEFECT_ID)                             AS DEFECT_ID,
    TRIM(PRODUCTION_ORDER_ID)                   AS PRODUCTION_ORDER_ID,
    TRIM(MACHINE_ID)                            AS MACHINE_ID,
    INITCAP(TRIM(DEFECT_TYPE))                  AS DEFECT_TYPE,
    COALESCE(DEFECT_QUANTITY, 0)                AS DEFECT_QUANTITY,
    TRY_TO_DATE(INSPECTION_DATE)                AS INSPECTION_DATE,
    TRIM(INSPECTOR_ID)                          AS INSPECTOR_ID,
    INITCAP(TRIM(CORRECTIVE_ACTION))            AS CORRECTIVE_ACTION
FROM DEDUP
WHERE _RN = 1;

-- ──────────────────────────────────────────────────────────────
-- 5. Manufacturing Machine Downtime
-- ──────────────────────────────────────────────────────────────
CREATE OR REPLACE TABLE DB_DEMO_MAYURESH.PRC_SILVER.TBL_MFG_MACHINE_DOWNTIME
COMMENT = 'Silver - Manufacturing downtime. Deduped, timestamps cast, trimmed.'
AS
WITH DEDUP AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY DOWNTIME_ID ORDER BY _LOADED_AT DESC) AS _RN
    FROM DB_DEMO_MAYURESH.STG_BRONZE.TBL_MFG_MACHINE_DOWNTIME
)
SELECT
    TRIM(DOWNTIME_ID)                           AS DOWNTIME_ID,
    TRIM(MACHINE_ID)                            AS MACHINE_ID,
    TRY_TO_TIMESTAMP_NTZ(DOWNTIME_START)        AS DOWNTIME_START,
    TRY_TO_TIMESTAMP_NTZ(DOWNTIME_END)          AS DOWNTIME_END,
    INITCAP(TRIM(REASON))                       AS REASON,
    DOWNTIME_HOURS,
    COST_IMPACT
FROM DEDUP
WHERE _RN = 1;
