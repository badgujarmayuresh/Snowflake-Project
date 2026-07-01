# Gold Layer — Star Schema Dimensional Model

This skill defines the star schema design, patterns, and rules for the Gold layer (REP_GOLD) in the Smart BI Agent project. Apply these when building, modifying, or querying dimensional model tables.

---

## 1. Purpose

The Gold layer is the **business logic layer** — a star schema dimensional model optimised for analytics, AI consumption (Cortex Analyst), and reporting. It joins Silver tables, calculates business measures, and produces clean fact + dimension tables.

---

## 2. Schema & Naming

| Property | Rule | Example |
|---|---|---|
| Schema | `REP_GOLD` | `DB_DEMO_MAYURESH.REP_GOLD` |
| Dimension prefix | `TBL_DIM_` | `TBL_DIM_CUSTOMER` |
| Fact prefix | `TBL_FACT_` | `TBL_FACT_SALES` |
| Surrogate keys | `<NAME>_KEY` (INTEGER or VARCHAR) | `DATE_KEY`, `PLANT_KEY`, `LOCATION_KEY` |

---

## 3. Dimensional Model Overview

```
                    ┌──────────────┐
                    │ TBL_DIM_DATE │
                    └──────┬───────┘
                           │
┌──────────────────┐ ┌─────▼──────┐ ┌──────────────────┐
│ TBL_DIM_CUSTOMER ├─► FACT_SALES ◄─┤ TBL_DIM_PRODUCT  │
└──────────────────┘ └─────┬──────┘ └──────────────────┘
                           │
┌──────────────────┐ ┌─────▼───────┐ ┌──────────────────┐
│ TBL_DIM_SELLER   ├─► FACT_ORDERS ◄─┤ TBL_DIM_LOCATION │
└──────────────────┘ └─────────────┘ └──────────────────┘

┌──────────────────┐ ┌──────────────────┐ ┌──────────────────┐
│ TBL_DIM_MACHINE  ├─► FACT_PRODUCTION  ◄─┤ TBL_DIM_PLANT    │
└──────────────────┘ └────────┬─────────┘ └──────────────────┘
                              │
                    ┌─────────▼────────┐
                    │  FACT_DEFECTS    │
                    └──────────────────┘
```

---

## 4. Fact Tables

| Table | Grain | Key Measures | Source Tables |
|---|---|---|---|
| `TBL_FACT_SALES` | One row per order line item | item_price, freight_value, total_revenue | OLIST_ORDER_ITEMS + OLIST_ORDERS |
| `TBL_FACT_ORDERS` | One row per order | total_payment_value, delivery_days, total_items | OLIST_ORDERS + PAYMENTS + ITEMS |
| `TBL_FACT_PRODUCTION` | One row per production order | planned_qty, actual_qty, cost, efficiency_pct | MFG_PRODUCTION_ORDERS |
| `TBL_FACT_DEFECTS` | One row per defect | defect_quantity, defect_rate_pct | MFG_DEFECTS + PRODUCTION_ORDERS |

---

## 5. Dimension Tables

| Table | Key Column | Source | Description |
|---|---|---|---|
| `TBL_DIM_DATE` | `DATE_KEY` (YYYYMMDD) | Generated | Calendar 2021-2025 |
| `TBL_DIM_CUSTOMER` | `CUSTOMER_ID` | Olist Customers | Customer city, state |
| `TBL_DIM_PRODUCT` | `PRODUCT_ID` | Olist + Northwind Products | Unified product catalogue |
| `TBL_DIM_SELLER` | `SELLER_ID` | Olist Sellers | Seller location |
| `TBL_DIM_LOCATION` | `LOCATION_KEY` (MD5) | Derived | City + State + Region |
| `TBL_DIM_MACHINE` | `MACHINE_ID` | MFG Machines | Type, plant, capacity |
| `TBL_DIM_PLANT` | `PLANT_KEY` (MD5) | Derived | Plant code, city, region |

---

## 6. Key Design Patterns

### Date Key Pattern
Facts reference DIM_DATE via integer surrogate key:
```sql
TO_NUMBER(TO_CHAR(date_column, 'YYYYMMDD')) AS <NAME>_DATE_KEY
```

### Derived Dimension Key Pattern
For dimensions without natural integer keys, use MD5 hash:
```sql
MD5(PLANT_LOCATION) AS PLANT_KEY
```

### Calculated Measures in Facts
Business calculations live in fact tables:
```sql
-- Variance
ACTUAL_QUANTITY - PLANNED_QUANTITY AS QUANTITY_VARIANCE

-- Efficiency percentage
ROUND((ACTUAL_QTY::FLOAT / PLANNED_QTY) * 100, 2) AS EFFICIENCY_PCT

-- Duration
DATEDIFF('day', START_DATE, END_DATE) AS DURATION_DAYS
```

### Aggregation in Facts (pre-joined)
When fact grain differs from source grain, pre-aggregate:
```sql
WITH PAYMENT_AGG AS (
    SELECT ORDER_ID, SUM(PAYMENT_VALUE) AS TOTAL_PAYMENT_VALUE
    FROM ... GROUP BY ORDER_ID
)
```

---

## 7. Rules — ALWAYS Follow

1. **Always use CTAS** (`CREATE OR REPLACE TABLE ... AS`) — Gold tables are fully refreshable
2. **Fact tables must have a clear grain** documented in the COMMENT
3. **All foreign keys to DIM_DATE use integer DATE_KEY** (YYYYMMDD format)
4. **Use LEFT JOIN for optional relationships** (e.g., payments may not exist for all orders)
5. **Use INNER JOIN for mandatory relationships** (e.g., every order item must have an order)
6. **COALESCE nullable measures to 0** in fact tables
7. **Calculated measures go in fact tables**, not dimensions
8. **Never store derived aggregates in dimensions** — keep them denormalised only for descriptive attributes
9. **Always add COMMENT** on every table describing grain and measures
10. **Always fully qualify** table names: `DB_DEMO_MAYURESH.REP_GOLD.TBL_...`
