# Silver Layer — Technical Cleansing Patterns

This skill defines the standard patterns and rules for creating Silver layer tables in the Smart BI Agent project. Apply these patterns whenever building or modifying PRC_SILVER tables.

---

## 1. Purpose

The Silver layer is a **technical cleansing layer** — no business logic, no joins across sources, no aggregations. It produces typed, clean, deduplicated copies of Bronze data that downstream layers (Gold) can trust.

---

## 2. Transformations Applied

| Transformation | Pattern | Example |
|---|---|---|
| **Deduplication** | `ROW_NUMBER() OVER (PARTITION BY <PK> ORDER BY _LOADED_AT DESC)` then `WHERE _RN = 1` | Pick latest load of each record |
| **Type casting (dates)** | `TRY_TO_DATE(column)` | `'2022-01-27'` → `DATE` |
| **Type casting (timestamps)** | `TRY_TO_TIMESTAMP_NTZ(column)` | `'2022-01-27 23:42:00'` → `TIMESTAMP_NTZ` |
| **Type casting (numbers)** | `TRY_TO_NUMBER(column)` | `'2'` → `NUMBER` |
| **Null handling** | `COALESCE(column, default)` | `NULL` → `0` for quantities |
| **String trimming** | `TRIM(column)` | Remove whitespace |
| **Case standardisation** | `UPPER()` for codes, `LOWER()` for categories, `INITCAP()` for names | Consistent casing |
| **Drop metadata** | Exclude `_LOADED_AT` and `_SOURCE_FILE` columns | Audit stays in Bronze |

---

## 3. Naming Convention

| Property | Rule | Example |
|---|---|---|
| Schema | `PRC_SILVER` | `DB_DEMO_MAYURESH.PRC_SILVER` |
| Table prefix | `TBL_` | Always |
| Source prefix | `OLIST_`, `NW_`, `MFG_` | Maps to source system |
| Full format | `TBL_<SOURCE>_<ENTITY>` | `TBL_OLIST_ORDERS`, `TBL_NW_PRODUCTS`, `TBL_MFG_MACHINES` |

---

## 4. Table Inventory (Bronze → Silver)

### Olist E-commerce
| Bronze Table | Silver Table |
|---|---|
| `STG_BRONZE.TBL_OLIST_CUSTOMERS` | `PRC_SILVER.TBL_OLIST_CUSTOMERS` |
| `STG_BRONZE.TBL_OLIST_SELLERS` | `PRC_SILVER.TBL_OLIST_SELLERS` |
| `STG_BRONZE.TBL_OLIST_PRODUCTS` | `PRC_SILVER.TBL_OLIST_PRODUCTS` |
| `STG_BRONZE.TBL_OLIST_ORDERS` | `PRC_SILVER.TBL_OLIST_ORDERS` |
| `STG_BRONZE.TBL_OLIST_ORDER_ITEMS` | `PRC_SILVER.TBL_OLIST_ORDER_ITEMS` |
| `STG_BRONZE.TBL_OLIST_ORDER_PAYMENTS` | `PRC_SILVER.TBL_OLIST_ORDER_PAYMENTS` |
| `STG_BRONZE.TBL_OLIST_ORDER_REVIEWS` | `PRC_SILVER.TBL_OLIST_ORDER_REVIEWS` |
| `STG_BRONZE.TBL_OLIST_CATEGORY_TRANSLATION` | `PRC_SILVER.TBL_OLIST_CATEGORY_TRANSLATION` |

### Northwind B2B
| Bronze Table | Silver Table |
|---|---|
| `STG_BRONZE.TBL_NORTHWIND_CATEGORIES` | `PRC_SILVER.TBL_NW_CATEGORIES` |
| `STG_BRONZE.TBL_NORTHWIND_SUPPLIERS` | `PRC_SILVER.TBL_NW_SUPPLIERS` |
| `STG_BRONZE.TBL_NORTHWIND_PRODUCTS` | `PRC_SILVER.TBL_NW_PRODUCTS` |
| `STG_BRONZE.TBL_NORTHWIND_EMPLOYEES` | `PRC_SILVER.TBL_NW_EMPLOYEES` |
| `STG_BRONZE.TBL_NORTHWIND_CUSTOMERS` | `PRC_SILVER.TBL_NW_CUSTOMERS` |
| `STG_BRONZE.TBL_NORTHWIND_ORDERS` | `PRC_SILVER.TBL_NW_ORDERS` |
| `STG_BRONZE.TBL_NORTHWIND_ORDER_DETAILS` | `PRC_SILVER.TBL_NW_ORDER_DETAILS` |

### Manufacturing
| Bronze Table | Silver Table |
|---|---|
| `STG_BRONZE.TBL_MFG_MACHINES` | `PRC_SILVER.TBL_MFG_MACHINES` |
| `STG_BRONZE.TBL_MFG_INVENTORY` | `PRC_SILVER.TBL_MFG_INVENTORY` |
| `STG_BRONZE.TBL_MFG_PRODUCTION_ORDERS` | `PRC_SILVER.TBL_MFG_PRODUCTION_ORDERS` |
| `STG_BRONZE.TBL_MFG_DEFECTS` | `PRC_SILVER.TBL_MFG_DEFECTS` |
| `STG_BRONZE.TBL_MFG_MACHINE_DOWNTIME` | `PRC_SILVER.TBL_MFG_MACHINE_DOWNTIME` |

---

## 5. SQL Template

```sql
CREATE OR REPLACE TABLE DB_DEMO_MAYURESH.PRC_SILVER.TBL_<SOURCE>_<ENTITY>
COMMENT = 'Silver - <Description>. Deduped, typed, trimmed.'
AS
WITH DEDUP AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY <PRIMARY_KEY> ORDER BY _LOADED_AT DESC) AS _RN
    FROM DB_DEMO_MAYURESH.STG_BRONZE.TBL_<BRONZE_TABLE>
)
SELECT
    TRIM(<ID_COL>)                              AS <ID_COL>,
    TRY_TO_DATE(<DATE_COL>)                     AS <DATE_COL>,
    TRY_TO_TIMESTAMP_NTZ(<TS_COL>)             AS <TS_COL>,
    COALESCE(<NULLABLE_NUM>, 0)                AS <NULLABLE_NUM>,
    INITCAP(TRIM(<NAME_COL>))                  AS <NAME_COL>,
    UPPER(TRIM(<CODE_COL>))                    AS <CODE_COL>
FROM DEDUP
WHERE _RN = 1;
```

---

## 6. Rules — ALWAYS Follow

1. **Always use CTAS** (`CREATE OR REPLACE TABLE ... AS`) — Silver tables are fully refreshable
2. **Always deduplicate** using ROW_NUMBER on the primary key, ordered by `_LOADED_AT DESC`
3. **Always use TRY_TO_*** functions for type casting — never hard CAST (avoids runtime errors)
4. **Never include business logic** — no calculated fields, no cross-source joins
5. **Never include `_LOADED_AT` or `_SOURCE_FILE`** in Silver output — audit stays in Bronze
6. **Always add COMMENT** on every table
7. **Always fully qualify** table names: `DB_DEMO_MAYURESH.PRC_SILVER.TBL_...`
