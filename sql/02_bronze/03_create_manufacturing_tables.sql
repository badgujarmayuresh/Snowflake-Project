-- ============================================================
-- Script  : 03_create_manufacturing_tables.sql
-- Purpose : Create Bronze layer tables for Manufacturing
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
-- Machines
-- ──────────────────────────────────────────────────────────────
CREATE OR REPLACE TABLE DB_DEMO_MAYURESH.STG_BRONZE.TBL_MFG_MACHINES (
    MACHINE_ID                  VARCHAR(20)     NOT NULL,
    MACHINE_NAME                VARCHAR(100),
    MACHINE_TYPE                VARCHAR(50),
    PLANT_LOCATION              VARCHAR(100),
    INSTALLATION_DATE           VARCHAR(50),
    LAST_MAINTENANCE_DATE       VARCHAR(50),
    STATUS                      VARCHAR(30),
    CAPACITY_PER_HOUR           NUMBER(10,0),
    -- Metadata
    _LOADED_AT                  TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP(),
    _SOURCE_FILE                VARCHAR(500)
)
COMMENT = 'Bronze - Manufacturing machine master data. Loaded as-is from source CSV.';

-- ──────────────────────────────────────────────────────────────
-- Inventory (Raw Materials)
-- ──────────────────────────────────────────────────────────────
CREATE OR REPLACE TABLE DB_DEMO_MAYURESH.STG_BRONZE.TBL_MFG_INVENTORY (
    MATERIAL_ID                 VARCHAR(20)     NOT NULL,
    MATERIAL_NAME               VARCHAR(100),
    UNIT_OF_MEASURE             VARCHAR(20),
    CURRENT_STOCK               NUMBER(10,0),
    REORDER_POINT               NUMBER(10,0),
    UNIT_COST                   NUMBER(12,2),
    SUPPLIER_ID                 VARCHAR(50),
    LAST_RESTOCKED_DATE         VARCHAR(50),
    -- Metadata
    _LOADED_AT                  TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP(),
    _SOURCE_FILE                VARCHAR(500)
)
COMMENT = 'Bronze - Manufacturing raw materials inventory. Loaded as-is from source CSV.';

-- ──────────────────────────────────────────────────────────────
-- Production Orders
-- ──────────────────────────────────────────────────────────────
CREATE OR REPLACE TABLE DB_DEMO_MAYURESH.STG_BRONZE.TBL_MFG_PRODUCTION_ORDERS (
    PRODUCTION_ORDER_ID         VARCHAR(20)     NOT NULL,
    PRODUCT_ID                  VARCHAR(50),
    MACHINE_ID                  VARCHAR(20),
    PLANT_LOCATION              VARCHAR(100),
    SHIFT                       VARCHAR(20),
    PLANNED_QUANTITY            NUMBER(10,0),
    ACTUAL_QUANTITY             NUMBER(10,0),
    START_DATE                  VARCHAR(50),
    END_DATE                    VARCHAR(50),
    STATUS                      VARCHAR(30),
    OPERATOR_ID                 VARCHAR(20),
    PRODUCTION_COST             NUMBER(12,2),
    -- Metadata
    _LOADED_AT                  TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP(),
    _SOURCE_FILE                VARCHAR(500)
)
COMMENT = 'Bronze - Manufacturing production orders. Loaded as-is from source CSV.';

-- ──────────────────────────────────────────────────────────────
-- Defects
-- ──────────────────────────────────────────────────────────────
CREATE OR REPLACE TABLE DB_DEMO_MAYURESH.STG_BRONZE.TBL_MFG_DEFECTS (
    DEFECT_ID                   VARCHAR(20)     NOT NULL,
    PRODUCTION_ORDER_ID         VARCHAR(20),
    MACHINE_ID                  VARCHAR(20),
    DEFECT_TYPE                 VARCHAR(50),
    DEFECT_QUANTITY             NUMBER(10,0),
    INSPECTION_DATE             VARCHAR(50),
    INSPECTOR_ID                VARCHAR(20),
    CORRECTIVE_ACTION           VARCHAR(50),
    -- Metadata
    _LOADED_AT                  TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP(),
    _SOURCE_FILE                VARCHAR(500)
)
COMMENT = 'Bronze - Manufacturing quality defect records. Loaded as-is from source CSV.';

-- ──────────────────────────────────────────────────────────────
-- Machine Downtime
-- ──────────────────────────────────────────────────────────────
CREATE OR REPLACE TABLE DB_DEMO_MAYURESH.STG_BRONZE.TBL_MFG_MACHINE_DOWNTIME (
    DOWNTIME_ID                 VARCHAR(20)     NOT NULL,
    MACHINE_ID                  VARCHAR(20),
    DOWNTIME_START              VARCHAR(50),
    DOWNTIME_END                VARCHAR(50),
    REASON                      VARCHAR(100),
    DOWNTIME_HOURS              NUMBER(6,1),
    COST_IMPACT                 NUMBER(12,2),
    -- Metadata
    _LOADED_AT                  TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP(),
    _SOURCE_FILE                VARCHAR(500)
)
COMMENT = 'Bronze - Manufacturing machine downtime events. Loaded as-is from source CSV.';
