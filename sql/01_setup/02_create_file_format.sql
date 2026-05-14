-- ============================================================
-- Script  : 02_create_file_format.sql
-- Purpose : Create standard CSV file format for loading
--           raw CSV files into STG_BRONZE schema
-- Author  : Mayuresh Prakash Badgujar
-- Date    : May 2026
-- Layer   : Setup
-- Notes   : Safe to re-run (uses IF NOT EXISTS).
--           FF_ prefix per naming convention.
-- ============================================================

-- Set context
USE DATABASE DB_DEMO_MAYURESH;
USE SCHEMA STG_BRONZE;
USE WAREHOUSE COMPUTE_WH;

-- Create standard CSV file format
CREATE FILE FORMAT IF NOT EXISTS DB_DEMO_MAYURESH.STG_BRONZE.FF_CSV_STANDARD
    TYPE                = 'CSV'
    FIELD_DELIMITER     = ','
    RECORD_DELIMITER    = '\n'
    SKIP_HEADER         = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    NULL_IF             = ('NULL', 'null', 'N/A', '', 'NA')
    EMPTY_FIELD_AS_NULL = TRUE
    TRIM_SPACE          = TRUE
    DATE_FORMAT         = 'AUTO'
    TIMESTAMP_FORMAT    = 'AUTO'
    ENCODING            = 'UTF-8'
    COMMENT             = 'FF - Standard CSV file format for loading raw source CSV files into STG_BRONZE layer. Handles quoted fields, nulls and auto date parsing.';

-- Verify file format created
SHOW FILE FORMATS IN SCHEMA DB_DEMO_MAYURESH.STG_BRONZE;
