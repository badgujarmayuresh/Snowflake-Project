-- ============================================================
-- Script  : 03_gold_tests.sql
-- Purpose : Data quality tests for REP_GOLD layer.
--           Validates star schema integrity, FK relationships,
--           aggregation accuracy, and dimension correctness.
-- Author  : Mayuresh Prakash Badgujar
-- Date    : May 2026
-- Layer   : Testing
-- Usage   : Run as a single query. Filter WHERE STATUS = 'FAIL'
-- ============================================================

USE DATABASE DB_DEMO_MAYURESH;
USE WAREHOUSE COMPUTE_WH;

-- ============================================================
-- GOLD LAYER TESTS
-- Expected: Star schema with valid FKs, correct aggregations
-- ============================================================
SELECT * FROM (

    -- ── Test G01: DIM_DATE row count = 1826 days ───────────────
    SELECT
        'G01' AS TEST_ID,
        'GOLD' AS LAYER,
        'DIM_DATE has 1826 rows (2021-01-01 to 2025-12-31)' AS TEST_NAME,
        CASE WHEN cnt = 1826 THEN 'PASS' ELSE 'FAIL' END AS STATUS,
        '1826' AS EXPECTED,
        cnt::VARCHAR AS ACTUAL
    FROM (SELECT COUNT(*) AS cnt FROM DB_DEMO_MAYURESH.REP_GOLD.TBL_DIM_DATE)

    UNION ALL

    -- ── Test G02: DIM_DATE range correct ───────────────────────
    SELECT
        'G02', 'GOLD',
        'DIM_DATE range: 2021-01-01 to 2025-12-31',
        CASE WHEN min_d = '2021-01-01' AND max_d = '2025-12-31' THEN 'PASS' ELSE 'FAIL' END,
        '2021-01-01 to 2025-12-31',
        min_d || ' to ' || max_d
    FROM (SELECT MIN(FULL_DATE)::VARCHAR AS min_d, MAX(FULL_DATE)::VARCHAR AS max_d FROM DB_DEMO_MAYURESH.REP_GOLD.TBL_DIM_DATE)

    UNION ALL

    -- ── Test G03: DIM_PRODUCT = Olist(1000) + Northwind(30) ────
    SELECT
        'G03', 'GOLD',
        'DIM_PRODUCT = 1030 (1000 Olist + 30 Northwind)',
        CASE WHEN cnt = 1030 THEN 'PASS' ELSE 'FAIL' END,
        '1030', cnt::VARCHAR
    FROM (SELECT COUNT(*) AS cnt FROM DB_DEMO_MAYURESH.REP_GOLD.TBL_DIM_PRODUCT)

    UNION ALL

    -- ── Test G04: DIM_PLANT = 4 plants ─────────────────────────
    SELECT
        'G04', 'GOLD',
        'DIM_PLANT = 4 plants',
        CASE WHEN cnt = 4 THEN 'PASS' ELSE 'FAIL' END,
        '4', cnt::VARCHAR
    FROM (SELECT COUNT(*) AS cnt FROM DB_DEMO_MAYURESH.REP_GOLD.TBL_DIM_PLANT)

    UNION ALL

    -- ── Test G05: FK integrity — FACT_SALES → DIM_DATE ─────────
    SELECT
        'G05', 'GOLD',
        'FK: FACT_SALES → DIM_DATE (0 orphans)',
        CASE WHEN cnt = 0 THEN 'PASS' ELSE 'FAIL' END,
        '0', cnt::VARCHAR
    FROM (
        SELECT COUNT(*) AS cnt
        FROM DB_DEMO_MAYURESH.REP_GOLD.TBL_FACT_SALES s
        LEFT JOIN DB_DEMO_MAYURESH.REP_GOLD.TBL_DIM_DATE d ON s.ORDER_DATE_KEY = d.DATE_KEY
        WHERE d.DATE_KEY IS NULL
    )

    UNION ALL

    -- ── Test G06: FK integrity — FACT_SALES → DIM_PRODUCT ──────
    SELECT
        'G06', 'GOLD',
        'FK: FACT_SALES → DIM_PRODUCT (0 orphans)',
        CASE WHEN cnt = 0 THEN 'PASS' ELSE 'FAIL' END,
        '0', cnt::VARCHAR
    FROM (
        SELECT COUNT(*) AS cnt
        FROM DB_DEMO_MAYURESH.REP_GOLD.TBL_FACT_SALES s
        LEFT JOIN DB_DEMO_MAYURESH.REP_GOLD.TBL_DIM_PRODUCT p ON s.PRODUCT_ID = p.PRODUCT_ID
        WHERE p.PRODUCT_ID IS NULL
    )

    UNION ALL

    -- ── Test G07: FK integrity — FACT_ORDERS → DIM_CUSTOMER ────
    SELECT
        'G07', 'GOLD',
        'FK: FACT_ORDERS → DIM_CUSTOMER (0 orphans)',
        CASE WHEN cnt = 0 THEN 'PASS' ELSE 'FAIL' END,
        '0', cnt::VARCHAR
    FROM (
        SELECT COUNT(*) AS cnt
        FROM DB_DEMO_MAYURESH.REP_GOLD.TBL_FACT_ORDERS o
        LEFT JOIN DB_DEMO_MAYURESH.REP_GOLD.TBL_DIM_CUSTOMER c ON o.CUSTOMER_ID = c.CUSTOMER_ID
        WHERE c.CUSTOMER_ID IS NULL
    )

    UNION ALL

    -- ── Test G08: Revenue consistency — Gold = Silver ───────────
    SELECT
        'G08', 'GOLD',
        'FACT_SALES total revenue = Silver Olist items (price + freight)',
        CASE WHEN ABS(gold_rev - silver_rev) < 0.01 THEN 'PASS' ELSE 'FAIL' END,
        '10736395.85',
        gold_rev::VARCHAR || ' vs ' || silver_rev::VARCHAR
    FROM (
        SELECT
            (SELECT SUM(TOTAL_REVENUE) FROM DB_DEMO_MAYURESH.REP_GOLD.TBL_FACT_SALES) AS gold_rev,
            (SELECT SUM(PRICE + FREIGHT_VALUE) FROM DB_DEMO_MAYURESH.PRC_SILVER.TBL_OLIST_ORDER_ITEMS) AS silver_rev
    )

    UNION ALL

    -- ── Test G09: Payment consistency — Gold = Silver ───────────
    SELECT
        'G09', 'GOLD',
        'FACT_ORDERS total payment = Silver Olist payments',
        CASE WHEN ABS(gold_pay - silver_pay) < 0.01 THEN 'PASS' ELSE 'FAIL' END,
        '10069276.06',
        gold_pay::VARCHAR || ' vs ' || silver_pay::VARCHAR
    FROM (
        SELECT
            (SELECT SUM(TOTAL_PAYMENT_VALUE) FROM DB_DEMO_MAYURESH.REP_GOLD.TBL_FACT_ORDERS) AS gold_pay,
            (SELECT SUM(PAYMENT_VALUE) FROM DB_DEMO_MAYURESH.PRC_SILVER.TBL_OLIST_ORDER_PAYMENTS) AS silver_pay
    )

    UNION ALL

    -- ── Test G10: FACT_SALES row count = 24770 ─────────────────
    SELECT
        'G10', 'GOLD',
        'FACT_SALES row count = 24770 (matches Silver order items)',
        CASE WHEN cnt = 24770 THEN 'PASS' ELSE 'FAIL' END,
        '24770', cnt::VARCHAR
    FROM (SELECT COUNT(*) AS cnt FROM DB_DEMO_MAYURESH.REP_GOLD.TBL_FACT_SALES)

    UNION ALL

    -- ── Test G11: FACT_ORDERS row count = 10000 ────────────────
    SELECT
        'G11', 'GOLD',
        'FACT_ORDERS row count = 10000',
        CASE WHEN cnt = 10000 THEN 'PASS' ELSE 'FAIL' END,
        '10000', cnt::VARCHAR
    FROM (SELECT COUNT(*) AS cnt FROM DB_DEMO_MAYURESH.REP_GOLD.TBL_FACT_ORDERS)

    UNION ALL

    -- ── Test G12: FACT_PRODUCTION & FACT_DEFECTS row counts ────
    SELECT
        'G12', 'GOLD',
        'FACT_PRODUCTION=5000 and FACT_DEFECTS=2000',
        CASE WHEN prod = 5000 AND def = 2000 THEN 'PASS' ELSE 'FAIL' END,
        '5000 / 2000',
        prod::VARCHAR || ' / ' || def::VARCHAR
    FROM (
        SELECT
            (SELECT COUNT(*) FROM DB_DEMO_MAYURESH.REP_GOLD.TBL_FACT_PRODUCTION) AS prod,
            (SELECT COUNT(*) FROM DB_DEMO_MAYURESH.REP_GOLD.TBL_FACT_DEFECTS) AS def
    )

) tests
ORDER BY TEST_ID;
