-- ============================================================
-- Script  : 06_cortex_ml_tests.sql
-- Purpose : Data quality tests for Cortex ML output tables.
--           Validates forecast, anomaly detection, and churn
--           classification outputs are structurally correct.
-- Author  : Mayuresh Prakash Badgujar
-- Date    : May 2026
-- Layer   : Testing
-- Usage   : Run as a single query. Filter WHERE STATUS = 'FAIL'
-- ============================================================

USE DATABASE DB_DEMO_MAYURESH;
USE SCHEMA APP_CORTEX;
USE WAREHOUSE COMPUTE_WH;

-- ============================================================
-- CORTEX ML TESTS
-- Expected: Valid ML outputs with correct dimensions and ranges
-- ============================================================
SELECT * FROM (

    -- ── Test ML01: Forecast = 36 rows (12 categories × 3 months) 
    SELECT
        'ML01' AS TEST_ID,
        'CORTEX_ML' AS LAYER,
        'Sales Forecast = 36 rows (12 categories × 3 months)' AS TEST_NAME,
        CASE WHEN cnt = 36 THEN 'PASS' ELSE 'FAIL' END AS STATUS,
        '36' AS EXPECTED,
        cnt::VARCHAR AS ACTUAL
    FROM (SELECT COUNT(*) AS cnt FROM DB_DEMO_MAYURESH.APP_CORTEX.TBL_ML_SALES_FORECAST)

    UNION ALL

    -- ── Test ML02: Forecast — all PREDICTED_REVENUE > 0 ────────
    SELECT
        'ML02', 'CORTEX_ML',
        'All forecast PREDICTED_REVENUE > 0',
        CASE WHEN cnt = 0 THEN 'PASS' ELSE 'FAIL' END,
        '0 negative/zero', cnt::VARCHAR || ' negative/zero'
    FROM (SELECT COUNT(*) AS cnt FROM DB_DEMO_MAYURESH.APP_CORTEX.TBL_ML_SALES_FORECAST WHERE PREDICTED_REVENUE <= 0)

    UNION ALL

    -- ── Test ML03: Forecast — LOWER_BOUND < UPPER_BOUND ────────
    SELECT
        'ML03', 'CORTEX_ML',
        'Forecast LOWER_BOUND < UPPER_BOUND for all rows',
        CASE WHEN cnt = 0 THEN 'PASS' ELSE 'FAIL' END,
        '0 violations', cnt::VARCHAR || ' violations'
    FROM (SELECT COUNT(*) AS cnt FROM DB_DEMO_MAYURESH.APP_CORTEX.TBL_ML_SALES_FORECAST WHERE LOWER_BOUND >= UPPER_BOUND)

    UNION ALL

    -- ── Test ML04: Anomalies = 48 rows (4 plants × 12 months) ──
    SELECT
        'ML04', 'CORTEX_ML',
        'Defect Anomalies = 48 rows (4 plants × 12 months)',
        CASE WHEN cnt = 48 THEN 'PASS' ELSE 'FAIL' END,
        '48', cnt::VARCHAR
    FROM (SELECT COUNT(*) AS cnt FROM DB_DEMO_MAYURESH.APP_CORTEX.TBL_ML_DEFECT_ANOMALIES)

    UNION ALL

    -- ── Test ML05: Anomalies — ANOMALY_SCORE between 0 and 1 ───
    SELECT
        'ML05', 'CORTEX_ML',
        'All ANOMALY_SCORE between 0 and 1',
        CASE WHEN cnt = 0 THEN 'PASS' ELSE 'FAIL' END,
        '0 out-of-range', cnt::VARCHAR || ' out-of-range'
    FROM (SELECT COUNT(*) AS cnt FROM DB_DEMO_MAYURESH.APP_CORTEX.TBL_ML_DEFECT_ANOMALIES WHERE ANOMALY_SCORE < 0 OR ANOMALY_SCORE > 1)

    UNION ALL

    -- ── Test ML06: Churn Scores = 2892 customers ───────────────
    SELECT
        'ML06', 'CORTEX_ML',
        'Churn Scores total = 2892 customers',
        CASE WHEN cnt = 2892 THEN 'PASS' ELSE 'FAIL' END,
        '2892', cnt::VARCHAR
    FROM (SELECT COUNT(*) AS cnt FROM DB_DEMO_MAYURESH.APP_CORTEX.TBL_ML_CHURN_SCORES)

    UNION ALL

    -- ── Test ML07: Churn — valid CHURN_RISK_TIER values ────────
    SELECT
        'ML07', 'CORTEX_ML',
        'All CHURN_RISK_TIER in (HIGH, MEDIUM, LOW)',
        CASE WHEN cnt = 0 THEN 'PASS' ELSE 'FAIL' END,
        '0 invalid tiers', cnt::VARCHAR || ' invalid tiers'
    FROM (
        SELECT COUNT(*) AS cnt
        FROM DB_DEMO_MAYURESH.APP_CORTEX.TBL_ML_CHURN_SCORES
        WHERE CHURN_RISK_TIER NOT IN ('HIGH', 'MEDIUM', 'LOW')
    )

    UNION ALL

    -- ── Test ML08: Churn — PROB_ACTIVE + PROB_CHURNED ≈ 1.0 ────
    SELECT
        'ML08', 'CORTEX_ML',
        'PROB_ACTIVE + PROB_CHURNED ≈ 1.0 (tolerance 0.02)',
        CASE WHEN cnt = 0 THEN 'PASS' ELSE 'FAIL' END,
        '0 violations', cnt::VARCHAR || ' violations'
    FROM (
        SELECT COUNT(*) AS cnt
        FROM DB_DEMO_MAYURESH.APP_CORTEX.TBL_ML_CHURN_SCORES
        WHERE ABS((PROB_ACTIVE + PROB_CHURNED) - 1.0) > 0.02
    )

) tests
ORDER BY TEST_ID;
