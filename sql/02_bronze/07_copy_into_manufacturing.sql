-- ============================================================
-- Script  : 07_copy_into_manufacturing.sql
-- Purpose : Load Manufacturing CSV data from internal stage
--           into Bronze tables using COPY INTO
-- Author  : Mayuresh Prakash Badgujar
-- Date    : May 2026
-- Layer   : Bronze (STG)
-- Notes   : Run AFTER 04_put_files_to_stage.sql.
--           Uses METADATA$FILENAME to track source file.
-- ============================================================

-- Set context
USE DATABASE DB_DEMO_MAYURESH;
USE SCHEMA STG_BRONZE;
USE WAREHOUSE COMPUTE_WH;

-- ──────────────────────────────────────────────────────────────
-- Manufacturing Machines
-- ──────────────────────────────────────────────────────────────
COPY INTO DB_DEMO_MAYURESH.STG_BRONZE.TBL_MFG_MACHINES
    (MACHINE_ID, MACHINE_NAME, MACHINE_TYPE, PLANT_LOCATION,
     INSTALLATION_DATE, LAST_MAINTENANCE_DATE, STATUS,
     CAPACITY_PER_HOUR, _LOADED_AT, _SOURCE_FILE)
FROM (
    SELECT
        $1, $2, $3, $4, $5, $6, $7, $8,
        CURRENT_TIMESTAMP(),
        METADATA$FILENAME
    FROM @DB_DEMO_MAYURESH.STG_BRONZE.STGINT_SMART_BI/manufacturing/machines.csv
)
FILE_FORMAT = (FORMAT_NAME = 'DB_DEMO_MAYURESH.STG_BRONZE.FF_CSV_STANDARD')
ON_ERROR = CONTINUE;

-- ──────────────────────────────────────────────────────────────
-- Manufacturing Inventory
-- ──────────────────────────────────────────────────────────────
COPY INTO DB_DEMO_MAYURESH.STG_BRONZE.TBL_MFG_INVENTORY
    (MATERIAL_ID, MATERIAL_NAME, UNIT_OF_MEASURE, CURRENT_STOCK,
     REORDER_POINT, UNIT_COST, SUPPLIER_ID, LAST_RESTOCKED_DATE,
     _LOADED_AT, _SOURCE_FILE)
FROM (
    SELECT
        $1, $2, $3, $4, $5, $6, $7, $8,
        CURRENT_TIMESTAMP(),
        METADATA$FILENAME
    FROM @DB_DEMO_MAYURESH.STG_BRONZE.STGINT_SMART_BI/manufacturing/inventory.csv
)
FILE_FORMAT = (FORMAT_NAME = 'DB_DEMO_MAYURESH.STG_BRONZE.FF_CSV_STANDARD')
ON_ERROR = CONTINUE;

-- ──────────────────────────────────────────────────────────────
-- Manufacturing Production Orders
-- ──────────────────────────────────────────────────────────────
COPY INTO DB_DEMO_MAYURESH.STG_BRONZE.TBL_MFG_PRODUCTION_ORDERS
    (PRODUCTION_ORDER_ID, PRODUCT_ID, MACHINE_ID, PLANT_LOCATION,
     SHIFT, PLANNED_QUANTITY, ACTUAL_QUANTITY, START_DATE,
     END_DATE, STATUS, OPERATOR_ID, PRODUCTION_COST,
     _LOADED_AT, _SOURCE_FILE)
FROM (
    SELECT
        $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12,
        CURRENT_TIMESTAMP(),
        METADATA$FILENAME
    FROM @DB_DEMO_MAYURESH.STG_BRONZE.STGINT_SMART_BI/manufacturing/production_orders.csv
)
FILE_FORMAT = (FORMAT_NAME = 'DB_DEMO_MAYURESH.STG_BRONZE.FF_CSV_STANDARD')
ON_ERROR = CONTINUE;

-- ──────────────────────────────────────────────────────────────
-- Manufacturing Defects
-- ──────────────────────────────────────────────────────────────
COPY INTO DB_DEMO_MAYURESH.STG_BRONZE.TBL_MFG_DEFECTS
    (DEFECT_ID, PRODUCTION_ORDER_ID, MACHINE_ID, DEFECT_TYPE,
     DEFECT_QUANTITY, INSPECTION_DATE, INSPECTOR_ID,
     CORRECTIVE_ACTION, _LOADED_AT, _SOURCE_FILE)
FROM (
    SELECT
        $1, $2, $3, $4, $5, $6, $7, $8,
        CURRENT_TIMESTAMP(),
        METADATA$FILENAME
    FROM @DB_DEMO_MAYURESH.STG_BRONZE.STGINT_SMART_BI/manufacturing/defects.csv
)
FILE_FORMAT = (FORMAT_NAME = 'DB_DEMO_MAYURESH.STG_BRONZE.FF_CSV_STANDARD')
ON_ERROR = CONTINUE;

-- ──────────────────────────────────────────────────────────────
-- Manufacturing Machine Downtime
-- ──────────────────────────────────────────────────────────────
COPY INTO DB_DEMO_MAYURESH.STG_BRONZE.TBL_MFG_MACHINE_DOWNTIME
    (DOWNTIME_ID, MACHINE_ID, DOWNTIME_START, DOWNTIME_END,
     REASON, DOWNTIME_HOURS, COST_IMPACT,
     _LOADED_AT, _SOURCE_FILE)
FROM (
    SELECT
        $1, $2, $3, $4, $5, $6, $7,
        CURRENT_TIMESTAMP(),
        METADATA$FILENAME
    FROM @DB_DEMO_MAYURESH.STG_BRONZE.STGINT_SMART_BI/manufacturing/machine_downtime.csv
)
FILE_FORMAT = (FORMAT_NAME = 'DB_DEMO_MAYURESH.STG_BRONZE.FF_CSV_STANDARD')
ON_ERROR = CONTINUE;

-- ──────────────────────────────────────────────────────────────
-- Verify row counts
-- ──────────────────────────────────────────────────────────────
SELECT 'TBL_MFG_MACHINES'            AS TABLE_NAME, COUNT(*) AS ROW_COUNT FROM DB_DEMO_MAYURESH.STG_BRONZE.TBL_MFG_MACHINES
UNION ALL
SELECT 'TBL_MFG_INVENTORY',          COUNT(*) FROM DB_DEMO_MAYURESH.STG_BRONZE.TBL_MFG_INVENTORY
UNION ALL
SELECT 'TBL_MFG_PRODUCTION_ORDERS',  COUNT(*) FROM DB_DEMO_MAYURESH.STG_BRONZE.TBL_MFG_PRODUCTION_ORDERS
UNION ALL
SELECT 'TBL_MFG_DEFECTS',            COUNT(*) FROM DB_DEMO_MAYURESH.STG_BRONZE.TBL_MFG_DEFECTS
UNION ALL
SELECT 'TBL_MFG_MACHINE_DOWNTIME',   COUNT(*) FROM DB_DEMO_MAYURESH.STG_BRONZE.TBL_MFG_MACHINE_DOWNTIME;
