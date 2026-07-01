-- ============================================================
-- Script  : 02_semantic_view_ml.sql
-- Purpose : Cortex Analyst semantic view over ML output tables.
--           Enables natural language queries on:
--             - Sales forecasts by product category
--             - Defect anomalies by plant
--             - Customer churn risk scores
-- Author  : Mayuresh Prakash Badgujar
-- Date    : May 2026
-- Layer   : AI (APP_CORTEX)
-- Notes   : Uses SYSTEM$CREATE_SEMANTIC_VIEW_FROM_YAML.
-- Prerequisites : 01_cortex_ml.sql must be run first
-- ============================================================

USE DATABASE DB_DEMO_MAYURESH;
USE SCHEMA APP_CORTEX;
USE WAREHOUSE COMPUTE_WH;

-- Create semantic view for Cortex ML outputs
CALL SYSTEM$CREATE_SEMANTIC_VIEW_FROM_YAML(
  'DB_DEMO_MAYURESH.APP_CORTEX',
  $$
name: SMART_BI_ML
description: "Semantic view for Cortex ML outputs — sales revenue forecasts by product category, defect anomaly detection by plant, and customer churn risk scores."

tables:
  - name: FORECAST
    synonyms:
      - "sales forecast"
      - "predicted revenue"
      - "future sales"
      - "revenue prediction"
    description: "Cortex ML Forecast — predicted monthly revenue per product category for the next 3 months."
    base_table:
      database: DB_DEMO_MAYURESH
      schema: APP_CORTEX
      table: TBL_ML_SALES_FORECAST
    primary_key:
      columns:
        - PRODUCT_CATEGORY
        - FORECAST_MONTH
    dimensions:
      - name: PRODUCT_CATEGORY
        synonyms:
          - "category"
          - "product type"
        description: "Product category name (e.g. Electronics, Garden, Furniture)"
        expr: PRODUCT_CATEGORY
        data_type: VARIANT
        sample_values:
          - "Electronics"
          - "Garden"
          - "Furniture"
          - "Fashion Bags"
          - "Office"
      - name: FORECAST_MONTH
        synonyms:
          - "predicted month"
          - "future month"
        description: "Month for which revenue is forecasted"
        expr: FORECAST_MONTH
        data_type: TIMESTAMP_NTZ
    facts:
      - name: PREDICTED_REVENUE
        synonyms:
          - "forecasted revenue"
          - "expected revenue"
          - "predicted sales"
        description: "Forecasted total revenue for the product category in that month"
        expr: PREDICTED_REVENUE
        data_type: FLOAT
      - name: LOWER_BOUND
        description: "Lower confidence bound of the forecast"
        expr: LOWER_BOUND
        data_type: FLOAT
      - name: UPPER_BOUND
        description: "Upper confidence bound of the forecast"
        expr: UPPER_BOUND
        data_type: FLOAT
    metrics:
      - name: TOTAL_FORECASTED_REVENUE
        synonyms:
          - "total predicted revenue"
          - "sum of forecasts"
        description: "Sum of all forecasted revenue across categories and months"
        expr: SUM(PREDICTED_REVENUE)
      - name: AVG_FORECASTED_REVENUE
        description: "Average forecasted monthly revenue per category"
        expr: AVG(PREDICTED_REVENUE)

  - name: ANOMALIES
    synonyms:
      - "defect anomalies"
      - "defect spikes"
      - "unusual defects"
      - "manufacturing anomalies"
    description: "Cortex ML Anomaly Detection — 2024 monthly defect counts per plant compared to 2021-2023 baseline. IS_ANOMALY = TRUE means an unusual spike was detected."
    base_table:
      database: DB_DEMO_MAYURESH
      schema: APP_CORTEX
      table: TBL_ML_DEFECT_ANOMALIES
    primary_key:
      columns:
        - PLANT_LOCATION
        - MONTH_TS
    dimensions:
      - name: PLANT_LOCATION
        synonyms:
          - "plant"
          - "factory"
          - "location"
        description: "Factory plant location"
        expr: PLANT_LOCATION
        data_type: VARIANT
        sample_values:
          - "Plant A - Sao Paulo"
          - "Plant B - Curitiba"
          - "Plant C - Manaus"
          - "Plant D - Recife"
      - name: MONTH_TS
        synonyms:
          - "month"
          - "observation month"
        description: "Month of the defect observation"
        expr: MONTH_TS
        data_type: TIMESTAMP_NTZ
      - name: IS_ANOMALY
        synonyms:
          - "anomaly flag"
          - "anomalous"
          - "spike detected"
        description: "TRUE if the defect count was anomalously high compared to the baseline period"
        expr: IS_ANOMALY
        data_type: BOOLEAN
    facts:
      - name: ACTUAL_DEFECT_COUNT
        synonyms:
          - "defect count"
          - "actual defects"
          - "observed defects"
        description: "Actual number of defects recorded that month"
        expr: ACTUAL_DEFECT_COUNT
        data_type: FLOAT
      - name: EXPECTED_DEFECT_COUNT
        synonyms:
          - "expected defects"
          - "normal defect count"
          - "baseline defects"
        description: "Model-expected defect count for that month based on historical baseline"
        expr: EXPECTED_DEFECT_COUNT
        data_type: FLOAT
      - name: ANOMALY_SCORE
        synonyms:
          - "severity"
          - "anomaly severity"
        description: "Anomaly score between 0 and 1 — higher means more anomalous"
        expr: ANOMALY_SCORE
        data_type: FLOAT
    metrics:
      - name: TOTAL_ANOMALIES
        synonyms:
          - "anomaly count"
          - "number of anomalies"
        description: "Total number of months flagged as anomalies per plant"
        expr: "SUM(IFF(IS_ANOMALY, 1, 0))"
      - name: AVG_ANOMALY_SCORE
        description: "Average anomaly score across all observations"
        expr: AVG(ANOMALY_SCORE)

  - name: CHURN
    synonyms:
      - "customer churn"
      - "churn risk"
      - "at risk customers"
      - "churned customers"
    description: "Cortex ML Classification — predicted churn risk per customer. CHURN_RISK_TIER: HIGH (>=70% churn probability), MEDIUM (40-70%), LOW (<40%)."
    base_table:
      database: DB_DEMO_MAYURESH
      schema: APP_CORTEX
      table: TBL_ML_CHURN_SCORES
    primary_key:
      columns:
        - CUSTOMER_ID
    dimensions:
      - name: CUSTOMER_ID
        description: "Unique customer identifier"
        expr: CUSTOMER_ID
        data_type: VARCHAR
      - name: CUSTOMER_STATE
        synonyms:
          - "state"
          - "region"
        description: "Brazilian state where the customer is located"
        expr: CUSTOMER_STATE
        data_type: VARCHAR
        sample_values:
          - "SP"
          - "RJ"
          - "MG"
          - "BA"
          - "RS"
      - name: PREDICTED_CHURN
        synonyms:
          - "churn prediction"
          - "will churn"
          - "churn status"
        description: "Model prediction: CHURNED or ACTIVE"
        expr: PREDICTED_CHURN
        data_type: VARCHAR
        sample_values:
          - "CHURNED"
          - "ACTIVE"
      - name: CHURN_RISK_TIER
        synonyms:
          - "risk tier"
          - "risk level"
          - "churn tier"
        description: "Risk tier based on churn probability: HIGH, MEDIUM, or LOW"
        expr: CHURN_RISK_TIER
        data_type: VARCHAR
        sample_values:
          - "HIGH"
          - "MEDIUM"
          - "LOW"
    facts:
      - name: PROB_ACTIVE
        description: "Probability the customer remains active (0 to 1)"
        expr: PROB_ACTIVE
        data_type: FLOAT
      - name: PROB_CHURNED
        synonyms:
          - "churn probability"
          - "probability of churn"
        description: "Probability the customer will churn (0 to 1)"
        expr: PROB_CHURNED
        data_type: FLOAT
    metrics:
      - name: TOTAL_CUSTOMERS
        description: "Total number of customers scored"
        expr: COUNT(CUSTOMER_ID)
      - name: HIGH_RISK_CUSTOMERS
        synonyms:
          - "high churn customers"
          - "at risk customers"
        description: "Number of customers with HIGH churn risk (probability >= 70%)"
        expr: "SUM(IFF(CHURN_RISK_TIER = 'HIGH', 1, 0))"
      - name: MEDIUM_RISK_CUSTOMERS
        description: "Number of customers with MEDIUM churn risk"
        expr: "SUM(IFF(CHURN_RISK_TIER = 'MEDIUM', 1, 0))"
      - name: LOW_RISK_CUSTOMERS
        description: "Number of customers with LOW churn risk"
        expr: "SUM(IFF(CHURN_RISK_TIER = 'LOW', 1, 0))"
      - name: AVG_CHURN_PROBABILITY
        synonyms:
          - "average churn rate"
          - "mean churn probability"
        description: "Average churn probability across all customers"
        expr: AVG(PROB_CHURNED)

verified_queries:
  - name: forecasted_revenue_by_category
    question: "What is the forecasted revenue by product category?"
    use_as_onboarding_question: true
    sql: |
      SELECT product_category, predicted_revenue, lower_bound, upper_bound
      FROM __FORECAST
      ORDER BY predicted_revenue DESC

  - name: plants_with_most_anomalies
    question: "Which plants had the most defect anomalies in 2024?"
    use_as_onboarding_question: true
    sql: |
      SELECT plant_location, SUM(IFF(is_anomaly, 1, 0)) AS anomaly_count
      FROM __ANOMALIES
      GROUP BY plant_location
      ORDER BY anomaly_count DESC

  - name: high_risk_churn_by_state
    question: "How many high risk churn customers are there by state?"
    use_as_onboarding_question: true
    sql: |
      SELECT customer_state, COUNT(*) AS high_risk_customers
      FROM __CHURN
      WHERE churn_risk_tier = 'HIGH'
      GROUP BY customer_state
      ORDER BY high_risk_customers DESC

  - name: total_forecasted_revenue
    question: "What is the total forecasted revenue for next 3 months?"
    sql: |
      SELECT SUM(predicted_revenue) AS total_forecasted_revenue
      FROM __FORECAST
  $$
);

-- ============================================================
-- VERIFICATION
-- ============================================================
SHOW SEMANTIC VIEWS IN SCHEMA DB_DEMO_MAYURESH.APP_CORTEX;
