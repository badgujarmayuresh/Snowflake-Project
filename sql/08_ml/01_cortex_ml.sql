-- ============================================================
-- Script  : 01_cortex_ml.sql
-- Purpose : Cortex ML layer — Forecasting, Anomaly Detection,
--           and Classification on Gold layer data.
--           Three models:
--             1. FORECAST_MONTHLY_SALES  — revenue per category
--             2. ANOMALY_DEFECTS         — defect spikes per plant
--             3. CLASSIFY_CUSTOMER_CHURN — churn risk per customer
-- Author  : Mayuresh Prakash Badgujar
-- Date    : May 2026
-- Layer   : AI (APP_CORTEX)
-- ============================================================

USE DATABASE DB_DEMO_MAYURESH;
USE SCHEMA APP_CORTEX;
USE WAREHOUSE COMPUTE_WH;

-- ============================================================
-- STEP 1: Training Views
-- ============================================================

-- ── 1a. Sales Forecast Training View ──────────────────────
-- Monthly revenue per product category (2021–2024, 48 months)
-- Cortex FORECAST expects: TIMESTAMP, SERIES (optional), TARGET
CREATE OR REPLACE VIEW DB_DEMO_MAYURESH.APP_CORTEX.VW_ML_SALES_TRAINING
COMMENT = 'Cortex ML Forecast training view — monthly revenue per product category.'
AS
SELECT
    DATE_TRUNC('month', D.FULL_DATE)::TIMESTAMP_NTZ  AS MONTH_TS,
    P.PRODUCT_CATEGORY                                AS SERIES,
    SUM(S.TOTAL_REVENUE)                              AS REVENUE
FROM DB_DEMO_MAYURESH.REP_GOLD.TBL_FACT_SALES S
JOIN DB_DEMO_MAYURESH.REP_GOLD.TBL_DIM_DATE    D ON S.ORDER_DATE_KEY = D.DATE_KEY
JOIN DB_DEMO_MAYURESH.REP_GOLD.TBL_DIM_PRODUCT P ON S.PRODUCT_ID    = P.PRODUCT_ID
GROUP BY DATE_TRUNC('month', D.FULL_DATE), P.PRODUCT_CATEGORY
ORDER BY MONTH_TS, SERIES;

-- ── 1b. Defect Anomaly Detection Training View ────────────
-- Monthly defect count per plant (2021–2024)
-- Cortex ANOMALY_DETECTION expects: TIMESTAMP, SERIES, TARGET
CREATE OR REPLACE VIEW DB_DEMO_MAYURESH.APP_CORTEX.VW_ML_DEFECTS_TRAINING
COMMENT = 'Cortex ML Anomaly Detection training view — monthly defect count per plant.'
AS
SELECT
    DATE_TRUNC('month', TRY_TO_DATE(D.INSPECTION_DATE))::TIMESTAMP_NTZ  AS MONTH_TS,
    M.PLANT_LOCATION                                                      AS SERIES,
    COUNT(*)                                                              AS DEFECT_COUNT
FROM DB_DEMO_MAYURESH.PRC_SILVER.TBL_MFG_DEFECTS D
LEFT JOIN DB_DEMO_MAYURESH.REP_GOLD.TBL_DIM_MACHINE M ON D.MACHINE_ID = M.MACHINE_ID
WHERE TRY_TO_DATE(D.INSPECTION_DATE) IS NOT NULL
  AND M.PLANT_LOCATION IS NOT NULL
GROUP BY DATE_TRUNC('month', TRY_TO_DATE(D.INSPECTION_DATE)), M.PLANT_LOCATION
ORDER BY MONTH_TS, SERIES;

-- ── 1c. Customer Churn Classification Training View ───────
-- One row per customer — features + CHURN_LABEL
-- Cortex CLASSIFICATION expects: feature cols + TARGET col
CREATE OR REPLACE VIEW DB_DEMO_MAYURESH.APP_CORTEX.VW_ML_CHURN_TRAINING
COMMENT = 'Cortex ML Classification training view — customer churn features and label.'
AS
SELECT
    COUNT(DISTINCT O.ORDER_ID)                                           AS ORDER_COUNT,
    ROUND(SUM(O.TOTAL_PAYMENT_VALUE), 2)                                 AS TOTAL_SPEND,
    ROUND(COALESCE(AVG(R.REVIEW_SCORE), 3.0), 2)                        AS AVG_REVIEW_SCORE,
    ROUND(COALESCE(AVG(O.DELIVERY_VARIANCE_DAYS), 0), 2)                AS AVG_DELIVERY_VARIANCE,
    DATEDIFF('day', MAX(D.FULL_DATE), '2024-12-31')                     AS DAYS_SINCE_LAST_ORDER,
    CASE WHEN MAX(D.FULL_DATE) < '2024-01-01' THEN 'CHURNED'
         ELSE 'ACTIVE' END                                               AS CHURN_LABEL
FROM DB_DEMO_MAYURESH.REP_GOLD.TBL_FACT_ORDERS O
JOIN DB_DEMO_MAYURESH.REP_GOLD.TBL_DIM_CUSTOMER C  ON O.CUSTOMER_ID   = C.CUSTOMER_ID
JOIN DB_DEMO_MAYURESH.REP_GOLD.TBL_DIM_DATE D      ON O.ORDER_DATE_KEY = D.DATE_KEY
LEFT JOIN DB_DEMO_MAYURESH.PRC_SILVER.TBL_OLIST_ORDER_REVIEWS R ON O.ORDER_ID = R.ORDER_ID
GROUP BY C.CUSTOMER_ID;

-- ── 1d. Customer Churn Scoring View (for prediction) ─────
-- Same features as training + CUSTOMER_ID for joining results
CREATE OR REPLACE VIEW DB_DEMO_MAYURESH.APP_CORTEX.VW_ML_CHURN_SCORING
COMMENT = 'Cortex ML Classification scoring view — all customers with features for churn prediction.'
AS
SELECT
    C.CUSTOMER_ID,
    COUNT(DISTINCT O.ORDER_ID)                                           AS ORDER_COUNT,
    ROUND(SUM(O.TOTAL_PAYMENT_VALUE), 2)                                 AS TOTAL_SPEND,
    ROUND(COALESCE(AVG(R.REVIEW_SCORE), 3.0), 2)                        AS AVG_REVIEW_SCORE,
    ROUND(COALESCE(AVG(O.DELIVERY_VARIANCE_DAYS), 0), 2)                AS AVG_DELIVERY_VARIANCE,
    DATEDIFF('day', MAX(D.FULL_DATE), '2024-12-31')                     AS DAYS_SINCE_LAST_ORDER
FROM DB_DEMO_MAYURESH.REP_GOLD.TBL_FACT_ORDERS O
JOIN DB_DEMO_MAYURESH.REP_GOLD.TBL_DIM_CUSTOMER C  ON O.CUSTOMER_ID   = C.CUSTOMER_ID
JOIN DB_DEMO_MAYURESH.REP_GOLD.TBL_DIM_DATE D      ON O.ORDER_DATE_KEY = D.DATE_KEY
LEFT JOIN DB_DEMO_MAYURESH.PRC_SILVER.TBL_OLIST_ORDER_REVIEWS R ON O.ORDER_ID = R.ORDER_ID
GROUP BY C.CUSTOMER_ID;

-- ============================================================
-- STEP 2: Create & Train ML Models
-- ============================================================

-- ── 2a. Sales Forecast Model ──────────────────────────────
CREATE OR REPLACE SNOWFLAKE.ML.FORECAST FORECAST_MONTHLY_SALES(
    INPUT_DATA     => SYSTEM$REFERENCE('VIEW', 'DB_DEMO_MAYURESH.APP_CORTEX.VW_ML_SALES_TRAINING'),
    SERIES_COLNAME => 'SERIES',
    TIMESTAMP_COLNAME => 'MONTH_TS',
    TARGET_COLNAME => 'REVENUE'
);

-- ── 2b. Defect Anomaly Detection Model ───────────────────
CREATE OR REPLACE SNOWFLAKE.ML.ANOMALY_DETECTION ANOMALY_DEFECTS(
    INPUT_DATA        => SYSTEM$REFERENCE('VIEW', 'DB_DEMO_MAYURESH.APP_CORTEX.VW_ML_DEFECTS_TRAINING'),
    SERIES_COLNAME    => 'SERIES',
    TIMESTAMP_COLNAME => 'MONTH_TS',
    TARGET_COLNAME    => 'DEFECT_COUNT',
    LABEL_COLNAME     => NULL
);

-- ── 2c. Customer Churn Classification Model ───────────────
CREATE OR REPLACE SNOWFLAKE.ML.CLASSIFICATION CLASSIFY_CUSTOMER_CHURN(
    INPUT_DATA     => SYSTEM$REFERENCE('VIEW', 'DB_DEMO_MAYURESH.APP_CORTEX.VW_ML_CHURN_TRAINING'),
    TARGET_COLNAME => 'CHURN_LABEL'
);

-- ============================================================
-- STEP 3: Run Predictions → Store Output Tables
-- ============================================================

-- ── 3a. Sales Forecast — next 3 months per category ──────
CREATE OR REPLACE TABLE DB_DEMO_MAYURESH.APP_CORTEX.TBL_ML_SALES_FORECAST
COMMENT = 'Cortex ML Forecast — predicted monthly revenue per product category for next 3 months.'
AS
SELECT
    SERIES          AS PRODUCT_CATEGORY,
    TS              AS FORECAST_MONTH,
    ROUND(FORECAST, 2)          AS PREDICTED_REVENUE,
    ROUND(LOWER_BOUND, 2)       AS LOWER_BOUND,
    ROUND(UPPER_BOUND, 2)       AS UPPER_BOUND
FROM TABLE(FORECAST_MONTHLY_SALES!FORECAST(FORECASTING_PERIODS => 3));

-- ── 3b. Defect Anomalies — full history scan ─────────────
CREATE OR REPLACE TABLE DB_DEMO_MAYURESH.APP_CORTEX.TBL_ML_DEFECT_ANOMALIES
COMMENT = 'Cortex ML Anomaly Detection — monthly defect anomalies per plant.'
AS
SELECT
    SERIES          AS PLANT_LOCATION,
    TS              AS MONTH_TS,
    Y               AS ACTUAL_DEFECT_COUNT,
    ROUND(FORECAST, 2)          AS EXPECTED_DEFECT_COUNT,
    IS_ANOMALY,
    ROUND(PERCENTILE, 4)        AS ANOMALY_SCORE,
    ROUND(LOWER_BOUND, 2)       AS LOWER_BOUND,
    ROUND(UPPER_BOUND, 2)       AS UPPER_BOUND
FROM TABLE(
    ANOMALY_DEFECTS!DETECT_ANOMALIES(
        INPUT_DATA        => SYSTEM$REFERENCE('VIEW', 'DB_DEMO_MAYURESH.APP_CORTEX.VW_ML_DEFECTS_TRAINING'),
        SERIES_COLNAME    => 'SERIES',
        TIMESTAMP_COLNAME => 'MONTH_TS',
        TARGET_COLNAME    => 'DEFECT_COUNT'
    )
);

-- ── 3c. Customer Churn Scores ─────────────────────────────
CREATE OR REPLACE TABLE DB_DEMO_MAYURESH.APP_CORTEX.TBL_ML_CHURN_SCORES
COMMENT = 'Cortex ML Classification — predicted churn risk per customer.'
AS
SELECT
    CUSTOMER_ID,
    CLASSIFY_CUSTOMER_CHURN!PREDICT(
        OBJECT_CONSTRUCT(
            'ORDER_COUNT',             ORDER_COUNT,
            'TOTAL_SPEND',             TOTAL_SPEND,
            'AVG_REVIEW_SCORE',        AVG_REVIEW_SCORE,
            'AVG_DELIVERY_VARIANCE',   AVG_DELIVERY_VARIANCE,
            'DAYS_SINCE_LAST_ORDER',   DAYS_SINCE_LAST_ORDER
        )
    ) AS PREDICTION
FROM DB_DEMO_MAYURESH.APP_CORTEX.VW_ML_CHURN_SCORING;

-- Flatten prediction VARIANT into clean columns
CREATE OR REPLACE TABLE DB_DEMO_MAYURESH.APP_CORTEX.TBL_ML_CHURN_SCORES
COMMENT = 'Cortex ML Classification — predicted churn risk per customer with probabilities.'
AS
SELECT
    S.CUSTOMER_ID,
    C.CUSTOMER_STATE,
    RAW.PREDICTION:class::VARCHAR                       AS PREDICTED_CHURN,
    ROUND(RAW.PREDICTION:probability:ACTIVE::FLOAT, 4)  AS PROB_ACTIVE,
    ROUND(RAW.PREDICTION:probability:CHURNED::FLOAT, 4) AS PROB_CHURNED,
    CASE
        WHEN RAW.PREDICTION:probability:CHURNED::FLOAT >= 0.70 THEN 'HIGH'
        WHEN RAW.PREDICTION:probability:CHURNED::FLOAT >= 0.40 THEN 'MEDIUM'
        ELSE 'LOW'
    END                                                  AS CHURN_RISK_TIER
FROM (
    SELECT
        CUSTOMER_ID,
        CLASSIFY_CUSTOMER_CHURN!PREDICT(
            OBJECT_CONSTRUCT(
                'ORDER_COUNT',             ORDER_COUNT,
                'TOTAL_SPEND',             TOTAL_SPEND,
                'AVG_REVIEW_SCORE',        AVG_REVIEW_SCORE,
                'AVG_DELIVERY_VARIANCE',   AVG_DELIVERY_VARIANCE,
                'DAYS_SINCE_LAST_ORDER',   DAYS_SINCE_LAST_ORDER
            )
        ) AS PREDICTION
    FROM DB_DEMO_MAYURESH.APP_CORTEX.VW_ML_CHURN_SCORING
) RAW
JOIN DB_DEMO_MAYURESH.APP_CORTEX.VW_ML_CHURN_SCORING S ON RAW.CUSTOMER_ID = S.CUSTOMER_ID
JOIN DB_DEMO_MAYURESH.REP_GOLD.TBL_DIM_CUSTOMER C ON S.CUSTOMER_ID = C.CUSTOMER_ID;

-- ============================================================
-- VERIFICATION
-- ============================================================

-- Check forecast output (3 months × 12 categories = 36 rows)
SELECT * FROM DB_DEMO_MAYURESH.APP_CORTEX.TBL_ML_SALES_FORECAST ORDER BY PRODUCT_CATEGORY, FORECAST_MONTH;

-- Check anomaly output (flag IS_ANOMALY = TRUE rows)
SELECT * FROM DB_DEMO_MAYURESH.APP_CORTEX.TBL_ML_DEFECT_ANOMALIES WHERE IS_ANOMALY = TRUE ORDER BY ANOMALY_SCORE DESC;

-- Check churn scores distribution
SELECT CHURN_RISK_TIER, PREDICTED_CHURN, COUNT(*) AS CUSTOMERS
FROM DB_DEMO_MAYURESH.APP_CORTEX.TBL_ML_CHURN_SCORES
GROUP BY CHURN_RISK_TIER, PREDICTED_CHURN
ORDER BY CHURN_RISK_TIER;
