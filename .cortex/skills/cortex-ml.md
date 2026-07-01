# Cortex ML — Forecasting, Anomaly Detection & Classification

This skill documents the Cortex ML layer of the Smart BI Agent project — three ML models built on top of the Gold layer.

---

## 1. Purpose

The Cortex ML layer adds predictive intelligence on top of the historical analytics stack:

| Capability | Snowflake API | Use Case |
|---|---|---|
| Forecasting | `SNOWFLAKE.ML.FORECAST` | Predict future monthly revenue per product category |
| Anomaly Detection | `SNOWFLAKE.ML.ANOMALY_DETECTION` | Flag unusual defect spikes per plant |
| Classification | `SNOWFLAKE.ML.CLASSIFICATION` | Predict customer churn risk (HIGH / MEDIUM / LOW) |

All ML output tables live in `APP_CORTEX`. A `SMART_BI_ML` semantic view exposes them to Cortex Analyst and the agent.

---

## 2. ML Objects in This Project

| Object | Type | Purpose |
|---|---|---|
| `VW_ML_SALES_TRAINING` | View | Monthly revenue per category — forecast training input |
| `VW_ML_DEFECTS_TRAINING` | View | Monthly defect count per plant — anomaly training input |
| `VW_ML_CHURN_TRAINING` | View | Customer features + CHURN_LABEL — classification training |
| `VW_ML_CHURN_SCORING` | View | Customer features (no label) — for running predictions |
| `FORECAST_MONTHLY_SALES` | ML Model | Trained forecast model (12 categories × 48 months) |
| `ANOMALY_DEFECTS` | ML Model | Trained anomaly model (4 plants × 44–46 months) |
| `CLASSIFY_CUSTOMER_CHURN` | ML Model | Trained classification model (2,892 customers, 60/40 split) |
| `TBL_ML_SALES_FORECAST` | Table | 36 rows — 3 months × 12 categories |
| `TBL_ML_DEFECT_ANOMALIES` | Table | Full history scan with IS_ANOMALY flag per plant/month |
| `TBL_ML_CHURN_SCORES` | Table | 2,892 rows — churn prediction + risk tier per customer |
| `SMART_BI_ML` | Semantic View | Cortex Analyst interface over all 3 ML output tables |

---

## 3. Model Patterns

### 3a. Forecasting — `SNOWFLAKE.ML.FORECAST`

**Training input requirements:**
- `TIMESTAMP_NTZ` column (not DATE, not DATE_KEY integer)
- Series column (optional) — groups multiple time series e.g. per product category
- Numeric target column

```sql
-- Step 1: Training view
CREATE OR REPLACE VIEW VW_ML_SALES_TRAINING AS
SELECT
    DATE_TRUNC('month', D.FULL_DATE)::TIMESTAMP_NTZ AS MONTH_TS,
    P.PRODUCT_CATEGORY                               AS SERIES,
    SUM(S.TOTAL_REVENUE)                             AS REVENUE
FROM ...
GROUP BY 1, 2;

-- Step 2: Train model
CREATE OR REPLACE SNOWFLAKE.ML.FORECAST FORECAST_MONTHLY_SALES(
    INPUT_DATA        => SYSTEM$REFERENCE('VIEW', 'DB_DEMO_MAYURESH.APP_CORTEX.VW_ML_SALES_TRAINING'),
    SERIES_COLNAME    => 'SERIES',
    TIMESTAMP_COLNAME => 'MONTH_TS',
    TARGET_COLNAME    => 'REVENUE'
);

-- Step 3: Run forecast and store
CREATE OR REPLACE TABLE TBL_ML_SALES_FORECAST AS
SELECT
    SERIES          AS PRODUCT_CATEGORY,
    TS              AS FORECAST_MONTH,
    ROUND(FORECAST, 2)     AS PREDICTED_REVENUE,
    ROUND(LOWER_BOUND, 2)  AS LOWER_BOUND,
    ROUND(UPPER_BOUND, 2)  AS UPPER_BOUND
FROM TABLE(FORECAST_MONTHLY_SALES!FORECAST(FORECASTING_PERIODS => 3));
```

**Key rules:**
- `FORECASTING_PERIODS` = number of periods ahead at the training data's granularity (3 = 3 months for monthly data)
- Output columns: `SERIES`, `TS` (forecast timestamp), `FORECAST`, `LOWER_BOUND`, `UPPER_BOUND`
- Always use `TIMESTAMP_NTZ` not `TIMESTAMP_TZ` for time column

---

### 3b. Anomaly Detection — `SNOWFLAKE.ML.ANOMALY_DETECTION`

**Training input:** Same shape as forecast (TIMESTAMP, SERIES, TARGET). Set `LABEL_COLNAME => NULL` for unsupervised detection.

```sql
-- Step 1: Train model (unsupervised)
CREATE OR REPLACE SNOWFLAKE.ML.ANOMALY_DETECTION ANOMALY_DEFECTS(
    INPUT_DATA        => SYSTEM$REFERENCE('VIEW', 'DB_DEMO_MAYURESH.APP_CORTEX.VW_ML_DEFECTS_TRAINING'),
    SERIES_COLNAME    => 'SERIES',
    TIMESTAMP_COLNAME => 'MONTH_TS',
    TARGET_COLNAME    => 'DEFECT_COUNT',
    LABEL_COLNAME     => NULL
);

-- Step 2: Detect anomalies over full history
CREATE OR REPLACE TABLE TBL_ML_DEFECT_ANOMALIES AS
SELECT
    SERIES        AS PLANT_LOCATION,
    TS            AS MONTH_TS,
    Y             AS ACTUAL_DEFECT_COUNT,
    ROUND(FORECAST, 2)     AS EXPECTED_DEFECT_COUNT,
    IS_ANOMALY,
    ROUND(PERCENTILE, 4)   AS ANOMALY_SCORE,
    ROUND(LOWER_BOUND, 2)  AS LOWER_BOUND,
    ROUND(UPPER_BOUND, 2)  AS UPPER_BOUND
FROM TABLE(
    ANOMALY_DEFECTS!DETECT_ANOMALIES(
        INPUT_DATA        => SYSTEM$REFERENCE('VIEW', 'DB_DEMO_MAYURESH.APP_CORTEX.VW_ML_DEFECTS_TRAINING'),
        SERIES_COLNAME    => 'SERIES',
        TIMESTAMP_COLNAME => 'MONTH_TS',
        TARGET_COLNAME    => 'DEFECT_COUNT'
    )
);
```

**Key rules:**
- `!DETECT_ANOMALIES` output columns: `SERIES`, `TS`, `Y` (actual), `FORECAST` (expected), `IS_ANOMALY`, `PERCENTILE` (anomaly score), `LOWER_BOUND`, `UPPER_BOUND`
- You can detect on the same view used for training (scans full history) or a new view with fresh data
- `IS_ANOMALY = TRUE` means the value was outside the model's normal range

---

### 3c. Classification — `SNOWFLAKE.ML.CLASSIFICATION`

**Training input:** Feature columns + one TARGET (label) column. No timestamp needed.

```sql
-- Step 1: Training view (features + label, NO customer ID)
CREATE OR REPLACE VIEW VW_ML_CHURN_TRAINING AS
SELECT
    ORDER_COUNT, TOTAL_SPEND, AVG_REVIEW_SCORE,
    AVG_DELIVERY_VARIANCE, DAYS_SINCE_LAST_ORDER,
    CASE WHEN last_order_date < '2024-01-01' THEN 'CHURNED' ELSE 'ACTIVE' END AS CHURN_LABEL
FROM ...;

-- Step 2: Train model
CREATE OR REPLACE SNOWFLAKE.ML.CLASSIFICATION CLASSIFY_CUSTOMER_CHURN(
    INPUT_DATA     => SYSTEM$REFERENCE('VIEW', 'DB_DEMO_MAYURESH.APP_CORTEX.VW_ML_CHURN_TRAINING'),
    TARGET_COLNAME => 'CHURN_LABEL'
);

-- Step 3: Score all customers
CREATE OR REPLACE TABLE TBL_ML_CHURN_SCORES AS
SELECT
    CUSTOMER_ID,
    CLASSIFY_CUSTOMER_CHURN!PREDICT(
        OBJECT_CONSTRUCT(
            'ORDER_COUNT',           ORDER_COUNT,
            'TOTAL_SPEND',           TOTAL_SPEND,
            'AVG_REVIEW_SCORE',      AVG_REVIEW_SCORE,
            'AVG_DELIVERY_VARIANCE', AVG_DELIVERY_VARIANCE,
            'DAYS_SINCE_LAST_ORDER', DAYS_SINCE_LAST_ORDER
        )
    ) AS PREDICTION
FROM VW_ML_CHURN_SCORING;

-- Step 4: Flatten VARIANT output
SELECT
    CUSTOMER_ID,
    PREDICTION:class::VARCHAR                       AS PREDICTED_CHURN,
    PREDICTION:probability:ACTIVE::FLOAT            AS PROB_ACTIVE,
    PREDICTION:probability:CHURNED::FLOAT           AS PROB_CHURNED,
    CASE
        WHEN PREDICTION:probability:CHURNED::FLOAT >= 0.70 THEN 'HIGH'
        WHEN PREDICTION:probability:CHURNED::FLOAT >= 0.40 THEN 'MEDIUM'
        ELSE 'LOW'
    END AS CHURN_RISK_TIER
FROM TBL_ML_CHURN_SCORES;
```

**Key rules:**
- `!PREDICT` takes `OBJECT_CONSTRUCT('col', val, ...)` — pass feature columns explicitly by name
- Output is a VARIANT: `{"class": "CHURNED", "probability": {"ACTIVE": 0.3, "CHURNED": 0.7}}`
- Flatten with `:class::VARCHAR` and `:probability:LABEL::FLOAT`
- Do NOT include ID or label columns inside `OBJECT_CONSTRUCT` — features only
- Create a separate scoring view (no label column) for prediction; keep training view (with label) for training only

---

## 4. Semantic View — SMART_BI_ML

The ML outputs are exposed via a Cortex Analyst semantic view with three logical tables:

| Table Alias | Backed By | Key Dimensions | Key Metrics |
|---|---|---|---|
| `forecast` | `TBL_ML_SALES_FORECAST` | PRODUCT_CATEGORY, FORECAST_MONTH | PREDICTED_REVENUE, LOWER/UPPER_BOUND |
| `anomalies` | `TBL_ML_DEFECT_ANOMALIES` | PLANT_LOCATION, MONTH_TS, IS_ANOMALY | ACTUAL vs EXPECTED DEFECTS, ANOMALY_SCORE |
| `churn` | `TBL_ML_CHURN_SCORES` | CUSTOMER_ID, CUSTOMER_STATE, CHURN_RISK_TIER | PROB_CHURNED, high_risk_customers |

---

## 5. Agent Tool

The agent tool `query_ml_insights` is a `cortex_analyst_text_to_sql` tool backed by `SMART_BI_ML`:

```json
{
  "tool_spec": {
    "type": "cortex_analyst_text_to_sql",
    "name": "query_ml_insights",
    "description": "Query Cortex ML outputs: sales forecasts, defect anomalies, and customer churn risk scores."
  }
}
```

Trigger phrases for the agent to route to this tool:
- "forecast", "predicted", "next month", "expected revenue"
- "anomaly", "anomalies", "unusual spike", "defect pattern"
- "churn", "at-risk customers", "churn risk", "likely to leave"

---

## 6. SQL Files

| File | Purpose |
|---|---|
| `sql/08_ml/01_cortex_ml.sql` | Training views + ML models + prediction output tables |
| `sql/08_ml/02_semantic_view_ml.sql` | SMART_BI_ML semantic view |
| `sql/08_ml/03_update_agent.sql` | ALTER AGENT to add query_ml_insights tool |

---

## 7. Monitoring & Refresh

```sql
-- Check models exist
SHOW SNOWFLAKE.ML.FORECAST IN SCHEMA DB_DEMO_MAYURESH.APP_CORTEX;
SHOW SNOWFLAKE.ML.ANOMALY_DETECTION IN SCHEMA DB_DEMO_MAYURESH.APP_CORTEX;
SHOW SNOWFLAKE.ML.CLASSIFICATION IN SCHEMA DB_DEMO_MAYURESH.APP_CORTEX;

-- Re-run predictions when new data arrives (re-execute CTAS blocks in 01_cortex_ml.sql)
-- Models do NOT auto-refresh — re-train periodically or schedule via Tasks
```

**When to retrain:**
- New month of sales data available → re-run `!FORECAST` output table
- New defect data → re-run `!DETECT_ANOMALIES` output table
- Significant customer behaviour change (quarterly) → `CREATE OR REPLACE` the classification model
