# Cortex Search — Semantic Search Service Patterns

This skill defines patterns and rules for creating and maintaining Cortex Search services in the Smart BI Agent project.

---

## 1. Purpose

Cortex Search enables business users to search unstructured and semi-structured text using natural language. In this project it provides semantic search over customer feedback and manufacturing incidents, powering the AI Agent's "find similar issues" capability.

---

## 2. Architecture

```
Business User → Natural Language Query
                        ↓
              Cortex Search Service
              (semantic + keyword hybrid)
                        ↓
              Enriched Search Table (APP_CORTEX)
              (pre-joined text blob + filterable attributes)
                        ↓
              Source Tables (PRC_SILVER + REP_GOLD)
```

---

## 3. Search Services in This Project

| Service Name | Schema | Domain | Source Table | Records |
|---|---|---|---|---|
| `SVC_SEARCH_CUSTOMER_INSIGHTS` | `APP_CORTEX` | E-commerce reviews | `TBL_SEARCH_CUSTOMER_INSIGHTS` | ~5,991 |
| `SVC_SEARCH_MFG_INCIDENTS` | `APP_CORTEX` | Manufacturing downtime + defects | `TBL_SEARCH_MFG_INCIDENTS` | ~1,910 |

---

## 4. Enriched Search Table Pattern

Cortex Search indexes a **single text column** (`SEARCH_TEXT`). The source query must concatenate all relevant fields into this column. Keep additional columns as **ATTRIBUTES** for filtering.

```sql
CREATE OR REPLACE TABLE DB_DEMO_MAYURESH.APP_CORTEX.TBL_SEARCH_<DOMAIN>
COMMENT = 'Cortex Search - <description>.'
AS
SELECT
    <ID_COL>,
    <ATTRIBUTE_1>,
    <ATTRIBUTE_2>,
    -- Concatenate all searchable context into one column
    '<Label1>: ' || col1 ||
    ' | <Label2>: ' || col2 ||
    ' | <Label3>: ' || col3
    AS SEARCH_TEXT,
    <DATE_COL>
FROM <source_joins>;
```

### Key rules for SEARCH_TEXT:
- Use ` | ` as the field separator inside the text blob
- Include human-readable labels (`Reason: `, `Feedback: `, `Plant: `)
- Use `COALESCE(col, 'Unknown')` for nullable joins
- Use `QUALIFY ROW_NUMBER()` to deduplicate when joining one-to-many

---

## 5. CREATE CORTEX SEARCH SERVICE Syntax

```sql
CREATE OR REPLACE CORTEX SEARCH SERVICE DB_DEMO_MAYURESH.APP_CORTEX.<SERVICE_NAME>
ON <SEARCH_COLUMN>
ATTRIBUTES <attr1>, <attr2>, <attr3>
WAREHOUSE = COMPUTE_WH
TARGET_LAG = '1 hour'
AS (
    SELECT
        <id_col>,
        <search_text_col>,
        <attr1>, <attr2>, <attr3>,
        <date_col>
    FROM DB_DEMO_MAYURESH.APP_CORTEX.<SOURCE_TABLE>
);
```

| Parameter | Rule | Project Value |
|---|---|---|
| `ON` | The single searchable text column | `SEARCH_TEXT` |
| `ATTRIBUTES` | Filterable columns (low-cardinality) | score, category, state, type |
| `WAREHOUSE` | Warehouse for indexing + refresh | `COMPUTE_WH` |
| `TARGET_LAG` | How fresh the index must be | `'1 hour'` |
| Schema | Always deploy to `APP_CORTEX` | `DB_DEMO_MAYURESH.APP_CORTEX` |

---

## 6. Service Definitions

### SVC_SEARCH_CUSTOMER_INSIGHTS
```sql
CREATE OR REPLACE CORTEX SEARCH SERVICE DB_DEMO_MAYURESH.APP_CORTEX.SVC_SEARCH_CUSTOMER_INSIGHTS
ON SEARCH_TEXT
ATTRIBUTES REVIEW_SCORE, PRODUCT_CATEGORY, CUSTOMER_STATE, ORDER_STATUS
WAREHOUSE = COMPUTE_WH
TARGET_LAG = '1 hour'
AS (
    SELECT REVIEW_ID, ORDER_ID, SEARCH_TEXT,
           REVIEW_SCORE, PRODUCT_CATEGORY, CUSTOMER_STATE,
           ORDER_STATUS, REVIEW_CREATION_DATE
    FROM DB_DEMO_MAYURESH.APP_CORTEX.TBL_SEARCH_CUSTOMER_INSIGHTS
);
```

### SVC_SEARCH_MFG_INCIDENTS
```sql
CREATE OR REPLACE CORTEX SEARCH SERVICE DB_DEMO_MAYURESH.APP_CORTEX.SVC_SEARCH_MFG_INCIDENTS
ON SEARCH_TEXT
ATTRIBUTES INCIDENT_TYPE, MACHINE_TYPE, PLANT_LOCATION
WAREHOUSE = COMPUTE_WH
TARGET_LAG = '1 hour'
AS (
    SELECT INCIDENT_ID, INCIDENT_TYPE, SEARCH_TEXT,
           MACHINE_NAME, MACHINE_TYPE, PLANT_LOCATION, INCIDENT_DATE
    FROM DB_DEMO_MAYURESH.APP_CORTEX.TBL_SEARCH_MFG_INCIDENTS
);
```

---

## 7. Querying — SEARCH_PREVIEW (SQL)

Use `SNOWFLAKE.CORTEX.SEARCH_PREVIEW` to test from a SQL worksheet:

```sql
SELECT SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
    'DB_DEMO_MAYURESH.APP_CORTEX.<SERVICE_NAME>',
    '{
        "query": "<natural language question>",
        "columns": ["SEARCH_TEXT", "<attr1>", "<attr2>"],
        "filter": {"@eq": {"<ATTR>": "<value>"}},
        "limit": 5
    }'
);
```

**Example — find negative reviews about electronics:**
```sql
SELECT SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
    'DB_DEMO_MAYURESH.APP_CORTEX.SVC_SEARCH_CUSTOMER_INSIGHTS',
    '{"query": "broken product not working", "columns": ["SEARCH_TEXT", "REVIEW_SCORE", "PRODUCT_CATEGORY"],
      "filter": {"@eq": {"PRODUCT_CATEGORY": "Electronics"}}, "limit": 5}'
);
```

**Example — find mechanical failures at a specific plant:**
```sql
SELECT SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
    'DB_DEMO_MAYURESH.APP_CORTEX.SVC_SEARCH_MFG_INCIDENTS',
    '{"query": "mechanical failure breakdown", "columns": ["SEARCH_TEXT", "PLANT_LOCATION"],
      "filter": {"@eq": {"INCIDENT_TYPE": "Downtime"}}, "limit": 5}'
);
```

---

## 8. Querying — Python SDK (Streamlit)

```python
from snowflake.core import Root
from snowflake.snowpark.context import get_active_session

session = get_active_session()
root = Root(session)

svc = root.databases["DB_DEMO_MAYURESH"].schemas["APP_CORTEX"] \
          .cortex_search_services["SVC_SEARCH_CUSTOMER_INSIGHTS"]

results = svc.search(
    query="packaging damaged",
    columns=["SEARCH_TEXT", "REVIEW_SCORE", "PRODUCT_CATEGORY", "CUSTOMER_STATE"],
    filter={"@eq": {"ORDER_STATUS": "delivered"}},
    limit=5
)
for r in results.results:
    print(r["SEARCH_TEXT"])
```

---

## 9. Filter Syntax Reference

| Operation | Syntax | Example |
|---|---|---|
| Equal | `{"@eq": {"COL": "val"}}` | `{"@eq": {"INCIDENT_TYPE": "Defect"}}` |
| Not equal | `{"@ne": {"COL": "val"}}` | `{"@ne": {"ORDER_STATUS": "canceled"}}` |
| AND | `{"@and": [{...}, {...}]}` | Combine two filters |
| OR | `{"@or": [{...}, {...}]}` | Either condition |
| Contains (array) | `{"@contains": {"COL": "val"}}` | For ARRAY-type attributes |

---

## 10. Monitoring

```sql
-- List all services and their status
SHOW CORTEX SEARCH SERVICES IN DB_DEMO_MAYURESH.APP_CORTEX;

-- Describe a specific service (see columns, attributes, state)
DESC CORTEX SEARCH SERVICE DB_DEMO_MAYURESH.APP_CORTEX.SVC_SEARCH_CUSTOMER_INSIGHTS;
```

Key fields to check: `indexing_state`, `serving_state` — both should be `ACTIVE`.

---

## 11. Rules — ALWAYS Follow

1. **Deploy to `APP_CORTEX` schema** — all Cortex AI objects live here
2. **Always create the enriched source table first** — never point a service directly at raw Silver/Gold tables
3. **SEARCH_TEXT must be a single VARCHAR column** — concatenate all context fields into it
4. **Use `ATTRIBUTES` for filterable low-cardinality columns** — score, category, state, type, status
5. **Always set `TARGET_LAG = '1 hour'`** — keeps index fresh without over-spending
6. **Always use `COMPUTE_WH`** for indexing — matches project warehouse standard
7. **Use `QUALIFY ROW_NUMBER()`** when joining one-to-many to prevent duplicate rows
8. **Test with `SEARCH_PREVIEW`** before wiring into Streamlit or Agent
9. **Name services with `SVC_SEARCH_` prefix** — consistent with APP_CORTEX naming
10. **Name source tables with `TBL_SEARCH_` prefix** — clearly marks them as search-optimised
