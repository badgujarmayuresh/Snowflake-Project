-- ============================================================
-- Script  : 07_cortex_agent_tests.sql
-- Purpose : Tests for Cortex Agent (SMART_BI_AGENT).
--           Validates agent exists, has correct tools, and
--           responds to a test question.
-- Author  : Mayuresh Prakash Badgujar
-- Date    : May 2026
-- Layer   : Testing
-- Usage   : Run as a single query. Filter WHERE STATUS = 'FAIL'
--           The supplemental agent response test must run separately.
-- ============================================================

USE DATABASE DB_DEMO_MAYURESH;
USE SCHEMA APP_CORTEX;
USE WAREHOUSE COMPUTE_WH;

-- ============================================================
-- CORTEX AGENT TESTS
-- Note: Agents do NOT appear in INFORMATION_SCHEMA.
--       Use SHOW AGENTS or DESCRIBE AGENT to verify.
-- Expected: Agent exists with 5 tools, responds correctly
-- ============================================================

-- Step 1: Run this to verify agent exists (manual check)
-- SHOW AGENTS IN SCHEMA DB_DEMO_MAYURESH.APP_CORTEX;
-- Expected: SMART_BI_AGENT listed

-- Step 2: Run this to verify agent has 5 tools
-- DESCRIBE AGENT DB_DEMO_MAYURESH.APP_CORTEX.SMART_BI_AGENT;
-- Expected: AGENT_SPEC JSON contains 5 entries in "tools" array

-- Step 3: Run automated tests for tool_resources validity
SELECT * FROM (

    -- ── Test AG01: E-commerce semantic view (tool resource) accessible
    SELECT
        'AG01' AS TEST_ID,
        'CORTEX_AGENT' AS LAYER,
        'Tool resource: SMART_BI_ECOMMERCE base tables have data' AS TEST_NAME,
        CASE WHEN cnt > 0 THEN 'PASS' ELSE 'FAIL' END AS STATUS,
        '> 0' AS EXPECTED,
        cnt::VARCHAR AS ACTUAL
    FROM (SELECT COUNT(*) AS cnt FROM DB_DEMO_MAYURESH.REP_GOLD.TBL_FACT_SALES)

    UNION ALL

    -- ── Test AG02: Manufacturing semantic view base data accessible
    SELECT
        'AG02', 'CORTEX_AGENT',
        'Tool resource: SMART_BI_MANUFACTURING base tables have data',
        CASE WHEN cnt > 0 THEN 'PASS' ELSE 'FAIL' END,
        '> 0', cnt::VARCHAR
    FROM (SELECT COUNT(*) AS cnt FROM DB_DEMO_MAYURESH.REP_GOLD.TBL_FACT_PRODUCTION)

    UNION ALL

    -- ── Test AG03: ML semantic view base data accessible
    SELECT
        'AG03', 'CORTEX_AGENT',
        'Tool resource: SMART_BI_ML base tables have data',
        CASE WHEN cnt > 0 THEN 'PASS' ELSE 'FAIL' END,
        '> 0', cnt::VARCHAR
    FROM (SELECT COUNT(*) AS cnt FROM DB_DEMO_MAYURESH.APP_CORTEX.TBL_ML_SALES_FORECAST)

    UNION ALL

    -- ── Test AG04: Search services have source data
    SELECT
        'AG04', 'CORTEX_AGENT',
        'Tool resource: Both search source tables have data',
        CASE WHEN ci > 0 AND mi > 0 THEN 'PASS' ELSE 'FAIL' END,
        'Both > 0',
        'Customer=' || ci::VARCHAR || ', MFG=' || mi::VARCHAR
    FROM (
        SELECT
            (SELECT COUNT(*) FROM DB_DEMO_MAYURESH.APP_CORTEX.TBL_SEARCH_CUSTOMER_INSIGHTS) AS ci,
            (SELECT COUNT(*) FROM DB_DEMO_MAYURESH.APP_CORTEX.TBL_SEARCH_MFG_INCIDENTS) AS mi
    )

) tests
ORDER BY TEST_ID;

-- ============================================================
-- SUPPLEMENTAL: Verify agent tool count (run after DESCRIBE)
-- ============================================================
-- DESCRIBE AGENT DB_DEMO_MAYURESH.APP_CORTEX.SMART_BI_AGENT;
-- Then verify AGENT_SPEC JSON contains 5 entries in "tools" array

-- ============================================================
-- SUPPLEMENTAL: Test agent responds to a question
-- (Requires warehouse credits — run manually)
-- ============================================================
-- SELECT SNOWFLAKE.CORTEX.DATA_AGENT_RUN(
--     'DB_DEMO_MAYURESH.APP_CORTEX.SMART_BI_AGENT',
--     $${"stream": false, "messages": [{"role": "user", "content": [{"type": "text", "text": "What is the total forecasted revenue?"}]}]}$$
-- );
-- Expected: JSON response with "content" array containing text block
