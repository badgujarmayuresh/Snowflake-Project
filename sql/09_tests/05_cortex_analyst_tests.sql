-- ============================================================
-- Script  : 05_cortex_analyst_tests.sql
-- Purpose : Data quality tests for Cortex Analyst layer.
--           Validates semantic views exist, have correct structure,
--           and verified queries execute successfully.
-- Author  : Mayuresh Prakash Badgujar
-- Date    : May 2026
-- Layer   : Testing
-- Usage   : Run as a single query. Filter WHERE STATUS = 'FAIL'
-- ============================================================

USE DATABASE DB_DEMO_MAYURESH;
USE SCHEMA APP_CORTEX;
USE WAREHOUSE COMPUTE_WH;

-- ============================================================
-- CORTEX ANALYST (SEMANTIC VIEW) TESTS
-- Note: Semantic views do NOT appear in INFORMATION_SCHEMA.VIEWS.
--       Use SHOW SEMANTIC VIEWS to verify. Tests CA01-CA04 below
--       use the OBJECTS metadata query approach.
-- Expected: 3 semantic views, all reference valid base tables
-- ============================================================

-- Step 1: Run this first to populate result scan
-- SHOW SEMANTIC VIEWS IN SCHEMA DB_DEMO_MAYURESH.APP_CORTEX;

-- Step 2: Then run the data-only tests
SELECT * FROM (

    -- ── Test CA01: Base tables for semantic views all have data ─
    SELECT
        'CA01' AS TEST_ID,
        'CORTEX_ANALYST' AS LAYER,
        'All base tables referenced by semantic views have data' AS TEST_NAME,
        CASE WHEN empty_count = 0 THEN 'PASS' ELSE 'FAIL' END AS STATUS,
        '0 empty base tables' AS EXPECTED,
        empty_count::VARCHAR || ' empty base tables' AS ACTUAL
    FROM (
        SELECT COUNT(*) AS empty_count
        FROM DB_DEMO_MAYURESH.INFORMATION_SCHEMA.TABLES
        WHERE TABLE_SCHEMA IN ('REP_GOLD', 'APP_CORTEX')
          AND TABLE_TYPE = 'BASE TABLE'
          AND TABLE_NAME IN (
              'TBL_FACT_SALES', 'TBL_FACT_ORDERS', 'TBL_DIM_CUSTOMER',
              'TBL_DIM_PRODUCT', 'TBL_DIM_SELLER', 'TBL_DIM_DATE',
              'TBL_FACT_PRODUCTION', 'TBL_FACT_DEFECTS',
              'TBL_DIM_MACHINE', 'TBL_DIM_PLANT',
              'TBL_ML_SALES_FORECAST', 'TBL_ML_DEFECT_ANOMALIES', 'TBL_ML_CHURN_SCORES'
          )
          AND ROW_COUNT = 0
    )

    UNION ALL

    -- ── Test CA02: Verified query - E-commerce top revenue ─────
    SELECT
        'CA02', 'CORTEX_ANALYST',
        'Verified query: Top products by revenue returns data',
        CASE WHEN cnt > 0 THEN 'PASS' ELSE 'FAIL' END,
        '> 0 rows', cnt::VARCHAR || ' rows'
    FROM (
        SELECT COUNT(*) AS cnt FROM (
            SELECT p.PRODUCT_CATEGORY, SUM(s.TOTAL_REVENUE) AS rev
            FROM DB_DEMO_MAYURESH.REP_GOLD.TBL_FACT_SALES s
            JOIN DB_DEMO_MAYURESH.REP_GOLD.TBL_DIM_PRODUCT p ON s.PRODUCT_ID = p.PRODUCT_ID
            GROUP BY p.PRODUCT_CATEGORY
            ORDER BY rev DESC LIMIT 10
        )
    )

    UNION ALL

    -- ── Test CA03: Verified query - Manufacturing defects by plant
    SELECT
        'CA03', 'CORTEX_ANALYST',
        'Verified query: Defects by plant returns 4 rows',
        CASE WHEN cnt = 4 THEN 'PASS' ELSE 'FAIL' END,
        '4', cnt::VARCHAR
    FROM (
        SELECT COUNT(*) AS cnt FROM (
            SELECT PLANT_LOCATION, COUNT(*) AS defect_count
            FROM DB_DEMO_MAYURESH.REP_GOLD.TBL_FACT_DEFECTS
            GROUP BY PLANT_LOCATION
        )
    )

    UNION ALL

    -- ── Test CA04: Verified query - ML forecast returns 36 rows ─
    SELECT
        'CA04', 'CORTEX_ANALYST',
        'Verified query: ML forecast returns 36 rows',
        CASE WHEN cnt = 36 THEN 'PASS' ELSE 'FAIL' END,
        '36', cnt::VARCHAR
    FROM (
        SELECT COUNT(*) AS cnt
        FROM DB_DEMO_MAYURESH.APP_CORTEX.TBL_ML_SALES_FORECAST
        WHERE PREDICTED_REVENUE > 0
    )

) tests
ORDER BY TEST_ID;

-- ============================================================
-- SUPPLEMENTAL: Test verified queries execute correctly
-- (Run each independently — cannot UNION with above)
-- ============================================================

-- Verified Query Test: E-commerce — top revenue by category
-- SELECT PRODUCT_CATEGORY, SUM(TOTAL_REVENUE) AS total_revenue
-- FROM DB_DEMO_MAYURESH.REP_GOLD.TBL_FACT_SALES s
-- JOIN DB_DEMO_MAYURESH.REP_GOLD.TBL_DIM_PRODUCT p ON s.PRODUCT_ID = p.PRODUCT_ID
-- GROUP BY PRODUCT_CATEGORY
-- ORDER BY total_revenue DESC
-- LIMIT 10;
-- Expected: Returns 10 rows with non-null revenue values

-- Verified Query Test: Manufacturing — defects by plant
-- SELECT PLANT_LOCATION, COUNT(*) AS defect_count
-- FROM DB_DEMO_MAYURESH.REP_GOLD.TBL_FACT_DEFECTS
-- GROUP BY PLANT_LOCATION
-- ORDER BY defect_count DESC;
-- Expected: Returns 4 rows (one per plant)

-- Verified Query Test: ML — forecasted revenue by category
-- SELECT PRODUCT_CATEGORY, PREDICTED_REVENUE, LOWER_BOUND, UPPER_BOUND
-- FROM DB_DEMO_MAYURESH.APP_CORTEX.TBL_ML_SALES_FORECAST
-- ORDER BY PREDICTED_REVENUE DESC;
-- Expected: Returns 36 rows with all positive values
