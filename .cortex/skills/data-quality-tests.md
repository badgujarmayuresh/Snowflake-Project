# Data Quality Tests — Skill Reference

## Overview
Comprehensive test suite for `DB_DEMO_MAYURESH` covering all layers from Bronze ingestion through Cortex AI services. Tests validate data integrity after any pipeline change.

## File Structure
```
sql/09_tests/
├── 01_bronze_tests.sql          -- 8 tests: Row counts & completeness
├── 02_silver_tests.sql          -- 10 tests: Dedup, NULL PKs, type validation
├── 03_gold_tests.sql            -- 12 tests: Star schema integrity, FKs, aggregation
├── 04_cortex_search_tests.sql   -- 6 tests: Search tables, services, preview
├── 05_cortex_analyst_tests.sql  -- 5 tests: Semantic views exist & valid
├── 06_cortex_ml_tests.sql       -- 8 tests: ML output validity
├── 07_cortex_agent_tests.sql    -- 4 tests: Agent exists, 5 tools
└── 08_streamlit_tests.sql       -- 2 tests: App exists & accessible
```

**Total: 55 tests across 8 files**

## How to Run

### Run all tests (one layer at a time)
Execute each file in Snowflake worksheet or via SnowSQL. Each returns a table:
```
TEST_ID | LAYER | TEST_NAME | STATUS | EXPECTED | ACTUAL
```

### Check for failures
After running any test file, filter results:
```sql
-- Just run the test file, then:
SELECT * FROM TABLE(RESULT_SCAN(LAST_QUERY_ID())) WHERE STATUS = 'FAIL';
```

### Run all tests at once
Execute files 01 through 08 sequentially. Each is self-contained with its own USE statements.

## Test Categories

| Layer | What It Validates | When to Re-run |
|-------|-------------------|----------------|
| Bronze | Source data loaded correctly | After re-loading CSVs or changing COPY INTO |
| Silver | Dedup, NULLs, type casting | After modifying Silver transformations |
| Gold | FK integrity, aggregations match | After changing Gold layer logic |
| Cortex Search | Enrichment correct, services active | After modifying search tables or services |
| Cortex Analyst | Semantic views exist, base tables have data | After recreating semantic views |
| Cortex ML | Model outputs valid, ranges correct | After re-training ML models |
| Cortex Agent | Agent exists with 5 tools | After modifying agent spec |
| Streamlit | App deployed and accessible | After uploading new app version |

## Expected Values Baseline

### Row Counts
| Table | Expected |
|-------|----------|
| Bronze Olist Orders | 10,000 |
| Bronze Olist Order Items | 24,770 |
| Bronze Northwind Order Details | 6,053 |
| Silver Northwind Order Details (deduped) | 5,785 |
| Gold FACT_SALES | 24,770 |
| Gold FACT_ORDERS | 10,000 |
| Gold DIM_PRODUCT | 1,030 |
| Gold DIM_DATE | 1,826 |
| ML Forecast | 36 (12 cat × 3 months) |
| ML Anomalies | 48 (4 plants × 12 months) |
| ML Churn | 2,892 |
| Search Customer Insights | 5,991 |
| Search MFG Incidents | 1,910 |

### Aggregation Checks
| Metric | Expected Value |
|--------|---------------|
| Gold total revenue | 10,736,395.85 |
| Gold total payments | 10,069,276.06 |

## When to Update Expected Values

Update the test files if:
1. **New source data loaded** → Update Bronze row counts
2. **Dedup logic changed** → Update Silver expected counts
3. **Gold transformations modified** → Re-verify aggregation totals
4. **ML models retrained** → Update ML row counts and churn distribution
5. **Search enrichment logic changed** → Update search table counts

## Adding New Tests

Follow this pattern:
```sql
UNION ALL

SELECT
    'XX99', 'LAYER_NAME',
    'Description of what is being tested',
    CASE WHEN <condition> THEN 'PASS' ELSE 'FAIL' END,
    'expected_value',
    actual_value::VARCHAR
FROM (SELECT ... AS actual_value)
```

## Supplemental Tests (Manual)

Some tests cannot run in a UNION query and are commented at the bottom of their files:
- **Search Preview**: `SNOWFLAKE.CORTEX.SEARCH_PREVIEW(...)` — verifies search returns results
- **Agent Response**: `SNOWFLAKE.CORTEX.DATA_AGENT_RUN(...)` — verifies agent answers questions
- **Verified Queries**: Direct SQL from semantic view definitions — verifies data accessibility
