-- ============================================================
-- Script  : 01_deploy_streamlit.sql
-- Purpose : Create the internal stage and deploy the
--           SMART_BI_APP Streamlit app into APP_CORTEX.
-- Author  : Mayuresh Prakash Badgujar
-- Date    : May 2026
-- Layer   : AI (APP_CORTEX)
-- Prerequisites:
--   - SMART_BI_AGENT must exist (06_agent/01_create_agent.sql)
--   - streamlit/streamlit_app.py must exist locally
-- ============================================================

USE DATABASE DB_DEMO_MAYURESH;
USE SCHEMA APP_CORTEX;
USE WAREHOUSE COMPUTE_WH;

-- ============================================================
-- STEP 1: Create internal stage for Streamlit source files
-- ============================================================
CREATE STAGE IF NOT EXISTS DB_DEMO_MAYURESH.APP_CORTEX.STGINT_STREAMLIT
COMMENT = 'Internal stage for Smart BI Agent Streamlit app source files.';

-- ============================================================
-- STEP 2: Upload app file to stage
-- Run this PUT command from SnowSQL CLI or use Snowsight
-- Snowsight: Catalog → Stages → STGINT_STREAMLIT → + Files
-- SnowSQL:
--   PUT file:///path/to/learncoco/streamlit/streamlit_app.py
--       @DB_DEMO_MAYURESH.APP_CORTEX.STGINT_STREAMLIT
--       AUTO_COMPRESS=FALSE OVERWRITE=TRUE;
-- ============================================================

-- Verify file was uploaded:
-- LIST @DB_DEMO_MAYURESH.APP_CORTEX.STGINT_STREAMLIT;

-- ============================================================
-- STEP 3: Create the Streamlit app object
-- ============================================================
CREATE OR REPLACE STREAMLIT DB_DEMO_MAYURESH.APP_CORTEX.SMART_BI_APP
FROM '@DB_DEMO_MAYURESH.APP_CORTEX.STGINT_STREAMLIT'
MAIN_FILE = 'streamlit_app.py'
QUERY_WAREHOUSE = COMPUTE_WH
TITLE = 'Smart BI Agent'
COMMENT = 'Smart BI Agent chat interface. Uses SMART_BI_AGENT Cortex Agent with Cortex Analyst + Cortex Search tools.';

-- ============================================================
-- STEP 4: Activate the live version
-- ============================================================
ALTER STREAMLIT DB_DEMO_MAYURESH.APP_CORTEX.SMART_BI_APP
ADD LIVE VERSION FROM LAST;

-- ============================================================
-- VERIFICATION
-- ============================================================
SHOW STREAMLITS IN DB_DEMO_MAYURESH.APP_CORTEX;

DESCRIBE STREAMLIT DB_DEMO_MAYURESH.APP_CORTEX.SMART_BI_APP;
