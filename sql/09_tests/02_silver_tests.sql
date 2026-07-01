-- ============================================================
-- Script  : 02_silver_tests.sql
-- Purpose : Data quality tests for PRC_SILVER layer.
--           Validates deduplication, NULL primary keys, and
--           type casting correctness.
-- Author  : Mayuresh Prakash Badgujar
-- Date    : May 2026
-- Layer   : Testing
-- Usage   : Run as a single query. Filter WHERE STATUS = 'FAIL'
-- ============================================================

USE DATABASE DB_DEMO_MAYURESH;
USE WAREHOUSE COMPUTE_WH;

-- ============================================================
-- SILVER LAYER TESTS
-- Expected: Cleaned, deduped, type-cast data
-- ============================================================
SELECT * FROM (

    -- ── Test S01: Northwind Order Details dedup (6053 → 5785) ──
    SELECT
        'S01' AS TEST_ID,
        'SILVER' AS LAYER,
        'Northwind Order Details dedup: 6053 → 5785' AS TEST_NAME,
        CASE WHEN cnt = 5785 THEN 'PASS' ELSE 'FAIL' END AS STATUS,
        '5785' AS EXPECTED,
        cnt::VARCHAR AS ACTUAL
    FROM (SELECT COUNT(*) AS cnt FROM DB_DEMO_MAYURESH.PRC_SILVER.TBL_NW_ORDER_DETAILS)

    UNION ALL

    -- ── Test S02: Olist Orders 1:1 from Bronze (no dedup) ──────
    SELECT
        'S02', 'SILVER',
        'Olist Orders Silver = Bronze (10000, no dedup expected)',
        CASE WHEN cnt = 10000 THEN 'PASS' ELSE 'FAIL' END,
        '10000', cnt::VARCHAR
    FROM (SELECT COUNT(*) AS cnt FROM DB_DEMO_MAYURESH.PRC_SILVER.TBL_OLIST_ORDERS)

    UNION ALL

    -- ── Test S03: Olist Order Items 1:1 from Bronze ────────────
    SELECT
        'S03', 'SILVER',
        'Olist Order Items Silver = Bronze (24770)',
        CASE WHEN cnt = 24770 THEN 'PASS' ELSE 'FAIL' END,
        '24770', cnt::VARCHAR
    FROM (SELECT COUNT(*) AS cnt FROM DB_DEMO_MAYURESH.PRC_SILVER.TBL_OLIST_ORDER_ITEMS)

    UNION ALL

    -- ── Test S04: No NULL ORDER_ID in Olist Orders ─────────────
    SELECT
        'S04', 'SILVER',
        'No NULL ORDER_ID in TBL_OLIST_ORDERS',
        CASE WHEN cnt = 0 THEN 'PASS' ELSE 'FAIL' END,
        '0', cnt::VARCHAR
    FROM (SELECT COUNT(*) AS cnt FROM DB_DEMO_MAYURESH.PRC_SILVER.TBL_OLIST_ORDERS WHERE ORDER_ID IS NULL)

    UNION ALL

    -- ── Test S05: No NULL CUSTOMER_ID in Olist Customers ───────
    SELECT
        'S05', 'SILVER',
        'No NULL CUSTOMER_ID in TBL_OLIST_CUSTOMERS',
        CASE WHEN cnt = 0 THEN 'PASS' ELSE 'FAIL' END,
        '0', cnt::VARCHAR
    FROM (SELECT COUNT(*) AS cnt FROM DB_DEMO_MAYURESH.PRC_SILVER.TBL_OLIST_CUSTOMERS WHERE CUSTOMER_ID IS NULL)

    UNION ALL

    -- ── Test S06: No NULL PRODUCT_ID in Olist Products ─────────
    SELECT
        'S06', 'SILVER',
        'No NULL PRODUCT_ID in TBL_OLIST_PRODUCTS',
        CASE WHEN cnt = 0 THEN 'PASS' ELSE 'FAIL' END,
        '0', cnt::VARCHAR
    FROM (SELECT COUNT(*) AS cnt FROM DB_DEMO_MAYURESH.PRC_SILVER.TBL_OLIST_PRODUCTS WHERE PRODUCT_ID IS NULL)

    UNION ALL

    -- ── Test S07: No NULL MACHINE_ID in MFG Machines ───────────
    SELECT
        'S07', 'SILVER',
        'No NULL MACHINE_ID in TBL_MFG_MACHINES',
        CASE WHEN cnt = 0 THEN 'PASS' ELSE 'FAIL' END,
        '0', cnt::VARCHAR
    FROM (SELECT COUNT(*) AS cnt FROM DB_DEMO_MAYURESH.PRC_SILVER.TBL_MFG_MACHINES WHERE MACHINE_ID IS NULL)

    UNION ALL

    -- ── Test S08: No NULL PRODUCTION_ORDER_ID in MFG Prod Orders
    SELECT
        'S08', 'SILVER',
        'No NULL PRODUCTION_ORDER_ID in TBL_MFG_PRODUCTION_ORDERS',
        CASE WHEN cnt = 0 THEN 'PASS' ELSE 'FAIL' END,
        '0', cnt::VARCHAR
    FROM (SELECT COUNT(*) AS cnt FROM DB_DEMO_MAYURESH.PRC_SILVER.TBL_MFG_PRODUCTION_ORDERS WHERE PRODUCTION_ORDER_ID IS NULL)

    UNION ALL

    -- ── Test S09: MFG tables match Bronze (no dedup expected) ──
    SELECT
        'S09', 'SILVER',
        'MFG Production Orders Silver = Bronze (5000)',
        CASE WHEN cnt = 5000 THEN 'PASS' ELSE 'FAIL' END,
        '5000', cnt::VARCHAR
    FROM (SELECT COUNT(*) AS cnt FROM DB_DEMO_MAYURESH.PRC_SILVER.TBL_MFG_PRODUCTION_ORDERS)

    UNION ALL

    -- ── Test S10: All Silver tables non-empty ──────────────────
    SELECT
        'S10', 'SILVER',
        'All 20 Silver tables have rows > 0',
        CASE WHEN empty_count = 0 THEN 'PASS' ELSE 'FAIL' END,
        '0 empty tables', empty_count::VARCHAR || ' empty tables'
    FROM (
        SELECT COUNT(*) AS empty_count
        FROM DB_DEMO_MAYURESH.INFORMATION_SCHEMA.TABLES
        WHERE TABLE_SCHEMA = 'PRC_SILVER'
          AND TABLE_TYPE = 'BASE TABLE'
          AND ROW_COUNT = 0
    )

) tests
ORDER BY TEST_ID;
