# Cortex Agent — SMART_BI_AGENT

This skill documents the configuration, tools, and patterns for the SMART_BI_AGENT Cortex Agent in the Smart BI Agent project.

---

## 1. Purpose

The SMART_BI_AGENT is the AI orchestration layer that routes business questions to the correct tool — structured analytics (Cortex Analyst), semantic search (Cortex Search), or both. It enables business users to ask questions in plain English and get answers from both e-commerce and manufacturing data without any SQL knowledge.

---

## 2. Agent Details

| Property | Value |
|---|---|
| Agent FQN | `DB_DEMO_MAYURESH.APP_CORTEX.SMART_BI_AGENT` |
| Schema | `APP_CORTEX` |
| Model | `auto` (Snowflake selects best model) |
| Budget | 900 seconds / 400,000 tokens per request |
| Tools | 4 (2 Cortex Analyst + 2 Cortex Search) |

---

## 3. Tools

| Tool Name | Type | Backed By | Use For |
|---|---|---|---|
| `query_ecommerce` | `cortex_analyst_text_to_sql` | `SMART_BI_ECOMMERCE` semantic view | Sales, orders, customers, products, delivery |
| `query_manufacturing` | `cortex_analyst_text_to_sql` | `SMART_BI_MANUFACTURING` semantic view | Production, defects, machines, plants |
| `search_customer_feedback` | `cortex_search` | `SVC_SEARCH_CUSTOMER_INSIGHTS` | Customer reviews, feedback themes, sentiment |
| `search_manufacturing_incidents` | `cortex_search` | `SVC_SEARCH_MFG_INCIDENTS` | Downtime incidents, defect history |

---

## 4. Agent Spec Structure

```sql
CREATE OR REPLACE AGENT DB_DEMO_MAYURESH.APP_CORTEX.<AGENT_NAME>
FROM SPECIFICATION $$
{
  "models": { "orchestration": "auto" },
  "orchestration": { "budget": { "seconds": 900, "tokens": 400000 } },
  "instructions": {
    "orchestration": "<when to use which tool>",
    "response": "<how to format responses>"
  },
  "tools": [
    { "tool_spec": { "type": "cortex_analyst_text_to_sql", "name": "<name>", "description": "<when to use>" } },
    { "tool_spec": { "type": "cortex_search", "name": "<name>", "description": "<when to use>" } }
  ],
  "tool_resources": {
    "<name>": {
      "execution_environment": { "query_timeout": 299, "type": "warehouse", "warehouse": "COMPUTE_WH" },
      "semantic_view": "<DB.SCHEMA.VIEW>"
    },
    "<name>": {
      "execution_environment": { "query_timeout": 299, "type": "warehouse", "warehouse": "COMPUTE_WH" },
      "search_service": "<DB.SCHEMA.SERVICE>"
    }
  }
}
$$;
```

---

## 5. Key Rules — ALWAYS Follow

1. **Use `$$` as the dollar-quote delimiter** — not `$spec$` (causes syntax errors in Snowflake SQL)
2. **`tool_resources` is a top-level object** — never nest it inside `tools`
3. **`models` must be an object** with `"orchestration": "auto"` — not an array
4. **Tool names in `tools` and `tool_resources` must match exactly**
5. **Always specify warehouse** in `execution_environment` — use `COMPUTE_WH`
6. **Use `cortex_analyst_text_to_sql`** for semantic views, **`cortex_search`** for search services
7. **orchestration instructions** should clearly tell the agent which tool to pick for which type of question
8. **Deploy to `APP_CORTEX` schema** — all AI objects live here

---

## 6. Management SQL

```sql
-- List agents
SHOW AGENTS IN SCHEMA DB_DEMO_MAYURESH.APP_CORTEX;

-- Inspect full spec
DESCRIBE AGENT DB_DEMO_MAYURESH.APP_CORTEX.SMART_BI_AGENT;

-- Drop agent
DROP AGENT DB_DEMO_MAYURESH.APP_CORTEX.SMART_BI_AGENT;

-- Alter agent (update spec)
ALTER AGENT DB_DEMO_MAYURESH.APP_CORTEX.SMART_BI_AGENT
FROM SPECIFICATION $$ { ... } $$;
```

---

## 7. Adding Cortex ML as a Tool (Step 7)

When Cortex ML forecasting/anomaly tables are ready, add a new `cortex_analyst_text_to_sql` tool pointing to a new semantic view over the ML output tables, or a `generic` tool backed by a stored procedure.

Example addition to spec:
```json
{
  "tool_spec": {
    "type": "cortex_analyst_text_to_sql",
    "name": "query_ml_forecasts",
    "description": "Query Cortex ML forecasts and anomaly detection results for sales and production."
  }
}
```
