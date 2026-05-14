-- ============================================================
-- Script  : 03_create_stage.sql
-- Purpose : Create internal stage for uploading raw CSV
--           files into STG_BRONZE layer
-- Author  : Mayuresh Prakash Badgujar
-- Date    : May 2026
-- Layer   : Setup
-- Notes   : Safe to re-run (uses IF NOT EXISTS).
--           STGINT_ prefix per naming convention.
--           Run 02_create_file_format.sql first.
-- ============================================================

-- Set context
USE DATABASE DB_DEMO_MAYURESH;
USE SCHEMA STG_BRONZE;
USE WAREHOUSE COMPUTE_WH;

-- Create internal stage for CSV uploads
CREATE STAGE IF NOT EXISTS DB_DEMO_MAYURESH.STG_BRONZE.STGINT_SMART_BI
    FILE_FORMAT = DB_DEMO_MAYURESH.STG_BRONZE.FF_CSV_STANDARD
    COMMENT     = 'STGINT - Internal stage for uploading raw CSV source files (Olist, Northwind, Manufacturing) into STG_BRONZE layer for Smart BI Agent project.';

-- Verify stage created
SHOW STAGES IN SCHEMA DB_DEMO_MAYURESH.STG_BRONZE;
