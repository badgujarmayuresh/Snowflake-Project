# Cortex Analyst — Semantic View Patterns

This skill defines patterns and rules for creating and maintaining Cortex Analyst semantic views in the Smart BI Agent project.

---

## 1. Purpose

Cortex Analyst enables business users to ask questions in plain English and get SQL-powered answers. Semantic views define the mapping between business language and physical Gold layer tables.

---

## 2. Architecture

```
Business User → Natural Language Question
                        ↓
              Cortex Analyst API
                        ↓
              Semantic View (YAML)
              (dimensions, facts, metrics, relationships)
                        ↓
              SQL Generation → Gold Layer Tables
                        ↓
              Results returned to user
```

---

## 3. Semantic Views in This Project

| View Name | Schema | Domain | Tables Covered |
|---|---|---|---|
| `SMART_BI_ECOMMERCE` | `APP_CORTEX` | E-commerce & Retail | FACT_SALES, FACT_ORDERS, DIM_CUSTOMER, DIM_PRODUCT, DIM_SELLER, DIM_DATE |
| `SMART_BI_MANUFACTURING` | `APP_CORTEX` | Manufacturing | FACT_PRODUCTION, FACT_DEFECTS, DIM_MACHINE, DIM_PLANT |

---

## 4. YAML Structure

```yaml
name: <SEMANTIC_VIEW_NAME>
description: "<business description>"

tables:
  - name: <LOGICAL_TABLE_NAME>
    description: "<what this table represents>"
    base_table:
      database: DB_DEMO_MAYURESH
      schema: REP_GOLD
      table: <PHYSICAL_TABLE_NAME>
    primary_key:
      columns:
        - <PK_COLUMN>
    dimensions:
      - name: <COL_NAME>
        synonyms: ["alias1", "alias2"]
        description: "<business meaning>"
        expr: <SQL_EXPR>
        data_type: <TYPE>
        is_enum: true/false
        sample_values: ["val1", "val2"]
    time_dimensions:
      - name: <DATE_COL>
        expr: <SQL_EXPR>
        data_type: DATE
    facts:
      - name: <MEASURE_COL>
        synonyms: ["alias"]
        description: "<what it measures>"
        expr: <SQL_EXPR>
        data_type: NUMBER
    metrics:
      - name: <AGG_METRIC>
        description: "<business meaning>"
        expr: SUM(<fact_col>) / AVG(<fact_col>) / COUNT(*)

relationships:
  - name: <REL_NAME>
    left_table: <FACT_TABLE>
    right_table: <DIM_TABLE>
    relationship_columns:
      - left_column: <FK_COL>
        right_column: <PK_COL>

verified_queries:
  - name: <query_name>
    question: "<NL question>"
    use_as_onboarding_question: true
    sql: |
      SELECT ... FROM __<TABLE> AS <ALIAS> ...
```

---

## 5. Key Concepts

| Concept | Definition | Example |
|---|---|---|
| **Dimension** | Categorical attribute (who/what/where) | customer_state, product_category |
| **Time Dimension** | Date/timestamp for time-based analysis | order_date, start_date |
| **Fact** | Row-level numeric value | item_price, defect_quantity |
| **Metric** | Aggregated measure (SUM/AVG/COUNT) | total_revenue = SUM(price) |
| **Relationship** | Join between logical tables | sales → products via product_id |
| **Verified Query** | Example Q&A pair to train Analyst | "Top 10 by revenue?" → SQL |

---

## 6. Creation Method

```sql
-- Validate first
CALL SYSTEM$CREATE_SEMANTIC_VIEW_FROM_YAML(
  'DB_DEMO_MAYURESH.APP_CORTEX',
  $$<yaml>$$,
  TRUE  -- verify_only
);

-- Then create
CALL SYSTEM$CREATE_SEMANTIC_VIEW_FROM_YAML(
  'DB_DEMO_MAYURESH.APP_CORTEX',
  $$<yaml>$$
);
```

---

## 7. Verified Queries — Rules

- Use `__<TABLE_NAME>` (double underscore prefix) to reference logical tables in SQL
- Use logical column names (from YAML), NOT physical column names
- Keep queries simple — they teach Analyst the pattern
- Mark 2-3 as `use_as_onboarding_question: true` for UI suggestions

---

## 8. Rules — ALWAYS Follow

1. **Deploy to `APP_CORTEX` schema** — all Cortex AI objects live here
2. **Use semantic views** (not legacy YAML on stages) — native Snowflake objects
3. **Add synonyms** on every dimension/fact — users may use different terms
4. **Mark enum dimensions** with `is_enum: true` + `sample_values` — improves accuracy
5. **Include verified queries** — at least 3-4 per view for training
6. **Validate before creating** — always run with `verify_only = TRUE` first
7. **One view per domain** — keep e-commerce and manufacturing separate
8. **Metrics use aggregation functions** — SUM, AVG, COUNT, MIN, MAX
9. **Facts are raw row-level values** — no aggregation in expr
10. **Relationships auto-infer join type** — no need to specify many_to_one etc.
