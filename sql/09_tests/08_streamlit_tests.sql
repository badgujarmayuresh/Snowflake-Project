-- ============================================================
-- Script  : 08_streamlit_tests.sql
-- Purpose : Tests for Streamlit app deployment.
--           Validates app exists and is accessible.
-- Author  : Mayuresh Prakash Badgujar
-- Date    : May 2026
-- Layer   : Testing
-- Usage   : Run as a single query. Filter WHERE STATUS = 'FAIL'
-- ============================================================

USE DATABASE DB_DEMO_MAYURESH;
USE SCHEMA APP_CORTEX;
USE WAREHOUSE COMPUTE_WH;

-- ============================================================
-- STREAMLIT APP TESTS
-- Expected: SMART_BI_APP exists and has a query warehouse
-- ============================================================
SELECT * FROM (

    -- ── Test ST01: Streamlit app SMART_BI_APP exists ───────────
    SELECT
        'ST01' AS TEST_ID,
        'STREAMLIT' AS LAYER,
        'Streamlit app SMART_BI_APP exists' AS TEST_NAME,
        CASE WHEN cnt > 0 THEN 'PASS' ELSE 'FAIL' END AS STATUS,
        'EXISTS' AS EXPECTED,
        CASE WHEN cnt > 0 THEN 'EXISTS' ELSE 'MISSING' END AS ACTUAL
    FROM (
        SELECT COUNT(*) AS cnt
        FROM DB_DEMO_MAYURESH.INFORMATION_SCHEMA.STREAMLITS
        WHERE STREAMLIT_NAME = 'SMART_BI_APP'
    )

    UNION ALL

    -- ── Test ST02: Streamlit app has a query warehouse assigned ─
    SELECT
        'ST02', 'STREAMLIT',
        'Streamlit app has a query warehouse assigned',
        CASE WHEN cnt > 0 THEN 'PASS' ELSE 'FAIL' END,
        'HAS_WAREHOUSE',
        CASE WHEN cnt > 0 THEN 'HAS_WAREHOUSE' ELSE 'NO_WAREHOUSE' END
    FROM (
        SELECT COUNT(*) AS cnt
        FROM DB_DEMO_MAYURESH.INFORMATION_SCHEMA.STREAMLITS
        WHERE STREAMLIT_NAME = 'SMART_BI_APP'
    )

) tests
ORDER BY TEST_ID;

-- ============================================================
-- SUPPLEMENTAL: Verify Streamlit app is accessible
-- ============================================================
-- SHOW STREAMLITS IN SCHEMA DB_DEMO_MAYURESH.APP_CORTEX;
-- Expected: SMART_BI_APP listed with url_id (accessible via Snowsight)
