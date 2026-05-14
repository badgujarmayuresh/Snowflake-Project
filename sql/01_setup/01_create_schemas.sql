-- ============================================================
-- Script  : 01_create_schemas.sql
-- Purpose : Create STG_BRONZE, PRC_SILVER, REP_GOLD and
--           APP_CORTEX schemas under DB_DEMO_MAYURESH
-- Author  : Mayuresh Prakash Badgujar
-- Date    : May 2026
-- Layer   : Setup
-- Notes   : Safe to re-run (uses IF NOT EXISTS).
--           Follow naming convention: <LayerPrefix>_<SchemaName>
-- ============================================================

-- Step 1: Set context
USE DATABASE DB_DEMO_MAYURESH;
USE WAREHOUSE COMPUTE_WH;

-- Step 2: Create BRONZE schema (STG layer - raw ingestion)
CREATE SCHEMA IF NOT EXISTS DB_DEMO_MAYURESH.STG_BRONZE
    COMMENT = 'STG Layer - Bronze. Raw data loaded as-is from source CSV files via COPY INTO. No transformations applied. Acts as system of record.';

-- Step 3: Create SILVER schema (PRC layer - cleansing & standardisation)
CREATE SCHEMA IF NOT EXISTS DB_DEMO_MAYURESH.PRC_SILVER
    COMMENT = 'PRC Layer - Silver. Cleaned, type-cast, deduplicated and standardised data. Trusted source for Gold layer.';

-- Step 4: Create GOLD schema (REP layer - dimensional model)
CREATE SCHEMA IF NOT EXISTS DB_DEMO_MAYURESH.REP_GOLD
    COMMENT = 'REP Layer - Gold. Star schema dimensional model with Fact and Dimension tables. Ready for analytics and AI consumption.';

-- Step 5: Create APP schema (APP layer - Streamlit and AI objects)
CREATE SCHEMA IF NOT EXISTS DB_DEMO_MAYURESH.APP_CORTEX
    COMMENT = 'APP Layer - Application. Cortex AI objects, Semantic Models, Streamlit apps and Agent configurations.';

-- Step 6: Verify all schemas created
SHOW SCHEMAS IN DATABASE DB_DEMO_MAYURESH;
