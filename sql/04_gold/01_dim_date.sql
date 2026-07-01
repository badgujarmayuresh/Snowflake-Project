-- ============================================================
-- Script  : 01_dim_date.sql
-- Purpose : Generate DIM_DATE calendar dimension (2021-2025)
-- Author  : Mayuresh Prakash Badgujar
-- Date    : May 2026
-- Layer   : Gold (REP)
-- Notes   : Self-contained generation using GENERATOR.
--           DATE_KEY is INTEGER surrogate key (YYYYMMDD).
-- ============================================================

USE DATABASE DB_DEMO_MAYURESH;
USE SCHEMA REP_GOLD;
USE WAREHOUSE COMPUTE_WH;

CREATE OR REPLACE TABLE DB_DEMO_MAYURESH.REP_GOLD.TBL_DIM_DATE
COMMENT = 'Gold - Calendar dimension. Date range 2021-01-01 to 2025-12-31. Grain: one row per day.'
AS
WITH DATE_SPINE AS (
    SELECT
        DATEADD(DAY, SEQ4(), '2021-01-01'::DATE) AS FULL_DATE
    FROM TABLE(GENERATOR(ROWCOUNT => 1827))  -- 5 years = ~1827 days
)
SELECT
    TO_NUMBER(TO_CHAR(FULL_DATE, 'YYYYMMDD'))       AS DATE_KEY,
    FULL_DATE                                        AS FULL_DATE,
    YEAR(FULL_DATE)                                  AS YEAR,
    QUARTER(FULL_DATE)                               AS QUARTER,
    MONTH(FULL_DATE)                                 AS MONTH,
    MONTHNAME(FULL_DATE)                             AS MONTH_NAME,
    WEEKOFYEAR(FULL_DATE)                            AS WEEK_OF_YEAR,
    DAYOFWEEK(FULL_DATE)                             AS DAY_OF_WEEK,
    DAYNAME(FULL_DATE)                               AS DAY_NAME,
    DAYOFMONTH(FULL_DATE)                            AS DAY_OF_MONTH,
    DAYOFYEAR(FULL_DATE)                             AS DAY_OF_YEAR,
    CASE WHEN DAYOFWEEK(FULL_DATE) IN (0, 6) THEN TRUE ELSE FALSE END AS IS_WEEKEND,
    YEAR(FULL_DATE) || '-Q' || QUARTER(FULL_DATE)   AS YEAR_QUARTER,
    TO_CHAR(FULL_DATE, 'YYYY-MM')                   AS YEAR_MONTH
FROM DATE_SPINE
WHERE FULL_DATE <= '2025-12-31'::DATE;
