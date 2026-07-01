-- ============================================================
-- Script  : 01_bronze_tests.sql
-- Purpose : Data quality tests for STG_BRONZE layer.
--           Validates row counts and completeness of raw data.
-- Author  : Mayuresh Prakash Badgujar
-- Date    : May 2026
-- Layer   : Testing
-- Usage   : Run as a single query. Filter WHERE STATUS = 'FAIL'
-- ============================================================

USE DATABASE DB_DEMO_MAYURESH;
USE WAREHOUSE COMPUTE_WH;

-- ============================================================
-- BRONZE LAYER TESTS
-- Expected: All source CSV data loaded with correct row counts
-- ============================================================
SELECT * FROM (

    -- ── Test B01: Olist Customers row count ────────────────────
    SELECT
        'B01' AS TEST_ID,
        'BRONZE' AS LAYER,
        'Olist Customers row count = 3000' AS TEST_NAME,
        CASE WHEN cnt = 3000 THEN 'PASS' ELSE 'FAIL' END AS STATUS,
        '3000' AS EXPECTED,
        cnt::VARCHAR AS ACTUAL
    FROM (SELECT COUNT(*) AS cnt FROM DB_DEMO_MAYURESH.STG_BRONZE.TBL_OLIST_CUSTOMERS)

    UNION ALL

    -- ── Test B02: Olist Orders row count ───────────────────────
    SELECT
        'B02', 'BRONZE',
        'Olist Orders row count = 10000',
        CASE WHEN cnt = 10000 THEN 'PASS' ELSE 'FAIL' END,
        '10000', cnt::VARCHAR
    FROM (SELECT COUNT(*) AS cnt FROM DB_DEMO_MAYURESH.STG_BRONZE.TBL_OLIST_ORDERS)

    UNION ALL

    -- ── Test B03: Olist Order Items row count ──────────────────
    SELECT
        'B03', 'BRONZE',
        'Olist Order Items row count = 24770',
        CASE WHEN cnt = 24770 THEN 'PASS' ELSE 'FAIL' END,
        '24770', cnt::VARCHAR
    FROM (SELECT COUNT(*) AS cnt FROM DB_DEMO_MAYURESH.STG_BRONZE.TBL_OLIST_ORDER_ITEMS)

    UNION ALL

    -- ── Test B04: Olist Order Reviews row count ────────────────
    SELECT
        'B04', 'BRONZE',
        'Olist Order Reviews row count = 7000',
        CASE WHEN cnt = 7000 THEN 'PASS' ELSE 'FAIL' END,
        '7000', cnt::VARCHAR
    FROM (SELECT COUNT(*) AS cnt FROM DB_DEMO_MAYURESH.STG_BRONZE.TBL_OLIST_ORDER_REVIEWS)

    UNION ALL

    -- ── Test B05: Northwind Orders row count ───────────────────
    SELECT
        'B05', 'BRONZE',
        'Northwind Orders row count = 2000',
        CASE WHEN cnt = 2000 THEN 'PASS' ELSE 'FAIL' END,
        '2000', cnt::VARCHAR
    FROM (SELECT COUNT(*) AS cnt FROM DB_DEMO_MAYURESH.STG_BRONZE.TBL_NORTHWIND_ORDERS)

    UNION ALL

    -- ── Test B06: Northwind Order Details row count ────────────
    SELECT
        'B06', 'BRONZE',
        'Northwind Order Details row count = 6053',
        CASE WHEN cnt = 6053 THEN 'PASS' ELSE 'FAIL' END,
        '6053', cnt::VARCHAR
    FROM (SELECT COUNT(*) AS cnt FROM DB_DEMO_MAYURESH.STG_BRONZE.TBL_NORTHWIND_ORDER_DETAILS)

    UNION ALL

    -- ── Test B07: Manufacturing Production Orders row count ────
    SELECT
        'B07', 'BRONZE',
        'MFG Production Orders row count = 5000',
        CASE WHEN cnt = 5000 THEN 'PASS' ELSE 'FAIL' END,
        '5000', cnt::VARCHAR
    FROM (SELECT COUNT(*) AS cnt FROM DB_DEMO_MAYURESH.STG_BRONZE.TBL_MFG_PRODUCTION_ORDERS)

    UNION ALL

    -- ── Test B08: All Bronze tables non-empty ──────────────────
    SELECT
        'B08', 'BRONZE',
        'All 20 Bronze tables have rows > 0',
        CASE WHEN empty_count = 0 THEN 'PASS' ELSE 'FAIL' END,
        '0 empty tables', empty_count::VARCHAR || ' empty tables'
    FROM (
        SELECT COUNT(*) AS empty_count
        FROM DB_DEMO_MAYURESH.INFORMATION_SCHEMA.TABLES
        WHERE TABLE_SCHEMA = 'STG_BRONZE'
          AND TABLE_TYPE = 'BASE TABLE'
          AND ROW_COUNT = 0
    )

) tests
ORDER BY TEST_ID;
