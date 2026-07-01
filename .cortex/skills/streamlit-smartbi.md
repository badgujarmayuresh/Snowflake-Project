# Streamlit — SMART_BI_APP

This skill documents the architecture, deployment pattern, and key rules for the SMART_BI_APP Streamlit app in the Smart BI Agent project.

---

## 1. Purpose

SMART_BI_APP is a chat interface for the SMART_BI_AGENT Cortex Agent. It lets business users ask plain-English questions about e-commerce and manufacturing data. Responses are powered by Cortex Analyst (SQL) and Cortex Search (semantic search).

---

## 2. Object Details

| Property | Value |
|---|---|
| Object FQN | `DB_DEMO_MAYURESH.APP_CORTEX.SMART_BI_APP` |
| Stage | `DB_DEMO_MAYURESH.APP_CORTEX.STGINT_STREAMLIT` |
| Main file | `streamlit_app.py` (at root of stage) |
| Warehouse | `COMPUTE_WH` |
| Agent | `DB_DEMO_MAYURESH.APP_CORTEX.SMART_BI_AGENT` |

---

## 3. How the Agent Is Called

The app uses `SNOWFLAKE.CORTEX.DATA_AGENT_RUN` — a SQL function that wraps the Cortex Agent REST API and works inside SiS warehouse runtime (no compute pool or container needed).

```python
session.sql(
    f"SELECT SNOWFLAKE.CORTEX.DATA_AGENT_RUN('{AGENT_FQN}', $${request_body}$$)"
).collect()[0][0]
```

Key rules:
- `stream: false` in the request body — non-streaming, returns full JSON
- Use `$$...$$` dollar-quoting for the JSON body — avoids single-quote escaping issues
- Parse response as JSON: `choices[0].message.content[]` for text blocks

---

## 4. Deployment Steps

### Step 1 — Create stage (SQL)
```sql
CREATE STAGE IF NOT EXISTS DB_DEMO_MAYURESH.APP_CORTEX.STGINT_STREAMLIT
COMMENT = 'Internal stage for Smart BI Agent Streamlit app source files.';
```

### Step 2 — Upload file (Python connector)
```python
# scripts/upload_streamlit.py
import snowflake.connector
conn = snowflake.connector.connect(connection_name='MX60297')
cur = conn.cursor()
cur.execute(
    "PUT file://C:/path/to/streamlit/streamlit_app.py"
    " @DB_DEMO_MAYURESH.APP_CORTEX.STGINT_STREAMLIT"
    " AUTO_COMPRESS=FALSE OVERWRITE=TRUE"
)
```

> **Note:** Do NOT use `cortex artifact create` — it targets Snowflake Workspaces, not internal stages. Use the Python connector PUT or SnowSQL PUT.
> **Note:** Do NOT run PUT inline in PowerShell — `@` is the PS splatting operator. Write to a `.py` file and run it.

### Step 3 — Create Streamlit object (SQL)
```sql
CREATE OR REPLACE STREAMLIT DB_DEMO_MAYURESH.APP_CORTEX.SMART_BI_APP
FROM '@DB_DEMO_MAYURESH.APP_CORTEX.STGINT_STREAMLIT'
MAIN_FILE = 'streamlit_app.py'
QUERY_WAREHOUSE = COMPUTE_WH
TITLE = 'Smart BI Agent';

ALTER STREAMLIT DB_DEMO_MAYURESH.APP_CORTEX.SMART_BI_APP ADD LIVE VERSION FROM LAST;
```

### Step 4 — After updating the app code
Re-run the Python PUT script (OVERWRITE=TRUE), then:
```sql
ALTER STREAMLIT DB_DEMO_MAYURESH.APP_CORTEX.SMART_BI_APP ADD LIVE VERSION FROM LAST;
```

---

## 5. Key Files

| File | Purpose |
|---|---|
| `streamlit/streamlit_app.py` | App source code |
| `scripts/upload_streamlit.py` | Python PUT script to upload to stage |
| `sql/07_streamlit/01_deploy_streamlit.sql` | Full deploy SQL (stage + create + activate) |

---

## 6. Management SQL

```sql
-- Check app exists
SHOW STREAMLITS IN SCHEMA DB_DEMO_MAYURESH.APP_CORTEX;

-- Describe app
DESCRIBE STREAMLIT DB_DEMO_MAYURESH.APP_CORTEX.SMART_BI_APP;

-- Verify stage contents
LIST @DB_DEMO_MAYURESH.APP_CORTEX.STGINT_STREAMLIT;

-- Drop app
DROP STREAMLIT DB_DEMO_MAYURESH.APP_CORTEX.SMART_BI_APP;
```

---

## 7. Response Parsing

```python
# Full text extraction
choices[0]["message"]["content"]  # list of content blocks
# Filter for type == "text", join .text fields

# Tool steps (for transparency expander)
# Look for type == "tool_use" or "tool_result" blocks
```

---

## 8. Next Step (Step 8 — Cortex ML)

Add a Cortex ML layer with forecasting (sales) and anomaly detection (production/defects). Then:
- Create a new semantic view over ML output tables
- Add a `query_ml_forecasts` tool to SMART_BI_AGENT
- Update the agent spec with the new tool
