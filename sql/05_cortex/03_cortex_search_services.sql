-- ============================================================
-- Script  : 03_cortex_search_services.sql
-- Purpose : Create Cortex Search services for semantic search
--           over customer insights and manufacturing incidents
-- Author  : Mayuresh Prakash Badgujar
-- Date    : May 2026
-- Layer   : AI (APP_CORTEX)
-- Notes   : Creates enriched search tables then Cortex Search
--           services on top. Two domains:
--             1. Customer insights  (e-commerce reviews)
--             2. Manufacturing incidents (downtime + defects)
-- ============================================================

USE DATABASE DB_DEMO_MAYURESH;
USE SCHEMA APP_CORTEX;
USE WAREHOUSE COMPUTE_WH;

-- ============================================================
-- STEP 1: Create enriched search table — Customer Insights
-- Combines Olist reviews with order/product/customer context
-- into a single SEARCH_TEXT column for indexing.
-- ============================================================
CREATE OR REPLACE TABLE DB_DEMO_MAYURESH.APP_CORTEX.TBL_SEARCH_CUSTOMER_INSIGHTS
COMMENT = 'Cortex Search - Customer review insights enriched with order and product context. For semantic search on customer feedback.'
AS
SELECT
    r.REVIEW_ID,
    r.ORDER_ID,
    r.REVIEW_SCORE,
    COALESCE(p.PRODUCT_CATEGORY, 'Unknown') AS PRODUCT_CATEGORY,
    COALESCE(c.CUSTOMER_STATE, 'Unknown')   AS CUSTOMER_STATE,
    o.ORDER_STATUS,
    'Review Score: ' || r.REVIEW_SCORE || '/5' ||
    CASE WHEN r.REVIEW_COMMENT_TITLE IS NOT NULL AND r.REVIEW_COMMENT_TITLE != 'None'
         THEN ' | Title: ' || r.REVIEW_COMMENT_TITLE ELSE '' END ||
    CASE WHEN r.REVIEW_COMMENT_MESSAGE IS NOT NULL AND r.REVIEW_COMMENT_MESSAGE != 'None'
         THEN ' | Feedback: ' || r.REVIEW_COMMENT_MESSAGE ELSE '' END ||
    ' | Product Category: ' || COALESCE(p.PRODUCT_CATEGORY, 'Unknown') ||
    ' | Customer State: '   || COALESCE(c.CUSTOMER_STATE, 'Unknown') ||
    ' | Order Status: '     || COALESCE(o.ORDER_STATUS, 'Unknown') ||
    CASE WHEN o.DELIVERY_DAYS IS NOT NULL
         THEN ' | Delivered in ' || o.DELIVERY_DAYS || ' days' ELSE '' END ||
    CASE WHEN o.DELIVERY_VARIANCE_DAYS IS NOT NULL AND o.DELIVERY_VARIANCE_DAYS < 0
         THEN ' | Late by ' || ABS(o.DELIVERY_VARIANCE_DAYS) || ' days' ELSE '' END
    AS SEARCH_TEXT,
    r.REVIEW_CREATION_DATE
FROM DB_DEMO_MAYURESH.PRC_SILVER.TBL_OLIST_ORDER_REVIEWS r
LEFT JOIN DB_DEMO_MAYURESH.REP_GOLD.TBL_FACT_ORDERS  o ON r.ORDER_ID    = o.ORDER_ID
LEFT JOIN DB_DEMO_MAYURESH.REP_GOLD.TBL_FACT_SALES   s ON r.ORDER_ID    = s.ORDER_ID
LEFT JOIN DB_DEMO_MAYURESH.REP_GOLD.TBL_DIM_PRODUCT  p ON s.PRODUCT_ID  = p.PRODUCT_ID
LEFT JOIN DB_DEMO_MAYURESH.REP_GOLD.TBL_DIM_CUSTOMER c ON o.CUSTOMER_ID = c.CUSTOMER_ID
WHERE r.REVIEW_COMMENT_MESSAGE IS NOT NULL AND r.REVIEW_COMMENT_MESSAGE != 'None'
QUALIFY ROW_NUMBER() OVER (PARTITION BY r.REVIEW_ID ORDER BY s.ITEM_PRICE DESC) = 1;

-- ============================================================
-- STEP 2: Create enriched search table — Manufacturing Incidents
-- Unions machine downtime and quality defects into a single
-- SEARCH_TEXT column, enriched with machine/plant context.
-- ============================================================
CREATE OR REPLACE TABLE DB_DEMO_MAYURESH.APP_CORTEX.TBL_SEARCH_MFG_INCIDENTS
COMMENT = 'Cortex Search - Manufacturing incidents combining machine downtime and production defects. For semantic search on operational issues.'
AS
-- Downtime incidents
SELECT
    dt.DOWNTIME_ID                          AS INCIDENT_ID,
    'Downtime'                              AS INCIDENT_TYPE,
    m.MACHINE_NAME,
    m.MACHINE_TYPE,
    m.PLANT_LOCATION,
    'Machine Downtime: ' || m.MACHINE_NAME || ' (' || m.MACHINE_TYPE || ')' ||
    ' | Reason: '       || dt.REASON ||
    ' | Duration: '     || dt.DOWNTIME_HOURS || ' hours' ||
    ' | Cost Impact: $' || dt.COST_IMPACT ||
    ' | Plant: '        || m.PLANT_LOCATION ||
    ' | Date: '         || TO_CHAR(dt.DOWNTIME_START, 'YYYY-MM-DD')
    AS SEARCH_TEXT,
    dt.DOWNTIME_START::DATE                 AS INCIDENT_DATE
FROM DB_DEMO_MAYURESH.PRC_SILVER.TBL_MFG_MACHINE_DOWNTIME dt
LEFT JOIN DB_DEMO_MAYURESH.REP_GOLD.TBL_DIM_MACHINE m ON dt.MACHINE_ID = m.MACHINE_ID

UNION ALL

-- Defect incidents
SELECT
    d.DEFECT_ID                             AS INCIDENT_ID,
    'Defect'                                AS INCIDENT_TYPE,
    m.MACHINE_NAME,
    m.MACHINE_TYPE,
    COALESCE(m.PLANT_LOCATION, 'Unknown')   AS PLANT_LOCATION,
    'Quality Defect: '      || d.DEFECT_TYPE ||
    ' | Machine: '          || COALESCE(m.MACHINE_NAME, 'Unknown') || ' (' || COALESCE(m.MACHINE_TYPE, 'Unknown') || ')' ||
    ' | Defective Units: '  || d.DEFECT_QUANTITY ||
    ' | Action: '           || d.CORRECTIVE_ACTION ||
    ' | Inspector: '        || d.INSPECTOR_ID ||
    ' | Plant: '            || COALESCE(m.PLANT_LOCATION, 'Unknown') ||
    ' | Date: '             || TO_CHAR(TRY_TO_DATE(d.INSPECTION_DATE), 'YYYY-MM-DD')
    AS SEARCH_TEXT,
    TRY_TO_DATE(d.INSPECTION_DATE)          AS INCIDENT_DATE
FROM DB_DEMO_MAYURESH.PRC_SILVER.TBL_MFG_DEFECTS d
LEFT JOIN DB_DEMO_MAYURESH.REP_GOLD.TBL_DIM_MACHINE m ON d.MACHINE_ID = m.MACHINE_ID
WHERE d.DEFECT_TYPE != 'None';

-- ============================================================
-- STEP 3: Create Cortex Search Service — Customer Insights
-- Semantic + keyword search over 5,991 enriched review records.
-- Filterable by: REVIEW_SCORE, PRODUCT_CATEGORY, CUSTOMER_STATE, ORDER_STATUS
-- ============================================================
CREATE OR REPLACE CORTEX SEARCH SERVICE DB_DEMO_MAYURESH.APP_CORTEX.SVC_SEARCH_CUSTOMER_INSIGHTS
ON SEARCH_TEXT
ATTRIBUTES REVIEW_SCORE, PRODUCT_CATEGORY, CUSTOMER_STATE, ORDER_STATUS
WAREHOUSE = COMPUTE_WH
TARGET_LAG = '1 hour'
AS (
    SELECT
        REVIEW_ID,
        ORDER_ID,
        SEARCH_TEXT,
        REVIEW_SCORE,
        PRODUCT_CATEGORY,
        CUSTOMER_STATE,
        ORDER_STATUS,
        REVIEW_CREATION_DATE
    FROM DB_DEMO_MAYURESH.APP_CORTEX.TBL_SEARCH_CUSTOMER_INSIGHTS
);

-- ============================================================
-- STEP 4: Create Cortex Search Service — Manufacturing Incidents
-- Semantic + keyword search over 1,910 downtime + defect records.
-- Filterable by: INCIDENT_TYPE, MACHINE_TYPE, PLANT_LOCATION
-- ============================================================
CREATE OR REPLACE CORTEX SEARCH SERVICE DB_DEMO_MAYURESH.APP_CORTEX.SVC_SEARCH_MFG_INCIDENTS
ON SEARCH_TEXT
ATTRIBUTES INCIDENT_TYPE, MACHINE_TYPE, PLANT_LOCATION
WAREHOUSE = COMPUTE_WH
TARGET_LAG = '1 hour'
AS (
    SELECT
        INCIDENT_ID,
        INCIDENT_TYPE,
        SEARCH_TEXT,
        MACHINE_NAME,
        MACHINE_TYPE,
        PLANT_LOCATION,
        INCIDENT_DATE
    FROM DB_DEMO_MAYURESH.APP_CORTEX.TBL_SEARCH_MFG_INCIDENTS
);

-- ============================================================
-- VERIFICATION
-- ============================================================
SHOW CORTEX SEARCH SERVICES IN DB_DEMO_MAYURESH.APP_CORTEX;

-- Test customer insights search
SELECT SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
    'DB_DEMO_MAYURESH.APP_CORTEX.SVC_SEARCH_CUSTOMER_INSIGHTS',
    '{"query": "packaging damaged late delivery", "columns": ["SEARCH_TEXT", "REVIEW_SCORE", "PRODUCT_CATEGORY", "CUSTOMER_STATE"], "limit": 3}'
);

-- Test manufacturing incidents search
SELECT SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
    'DB_DEMO_MAYURESH.APP_CORTEX.SVC_SEARCH_MFG_INCIDENTS',
    '{"query": "mechanical failure high cost", "columns": ["SEARCH_TEXT", "INCIDENT_TYPE", "PLANT_LOCATION"], "limit": 3}'
);
