# Snowflake Naming Convention & Standards

This skill defines the mandatory naming conventions and standards for all Snowflake objects in this project. You MUST follow these rules every time you write SQL, create objects, or name any Snowflake artifact.

---

## 1. Environment Prefixes

| Environment | Prefix | Description |
|---|---|---|
| Development | `DEV_` | Development environment for testing and building |
| QA | `QAS_` | Quality assurance environment for validation |
| Production | `PRD_` | Production environment for live data |

**Rule:** Always prefix database names with the environment prefix.

---

## 2. Layer Prefixes

| Layer | Prefix | Description |
|---|---|---|
| Staging | `STG` | Raw data from source systems |
| Processing | `PRC` | Data transformation and cleansing layer |
| Reporting | `REP` | Curated data for analytics and reporting |
| Application | `APP` | GenAI application objects, models and Streamlit apps |

**Rule:** Always prefix schema names with the layer prefix.

---

## 3. Object Naming Conventions

| Object Type | Prefix | Format | Example |
|---|---|---|---|
| Database | `DB_` | `<ENV>_DB_<DatabaseName>` | `DEV_DB_SMARTBI` |
| Schema | _(none)_ | `<LayerPrefix>_<SchemaName>` | `STG_ECOMMERCE` |
| Table | `TBL_` | `TBL_<TableName>` | `TBL_ORDERS` |
| View | `VW_` | `VW_<ViewName>` | `VW_SALES_SUMMARY` |
| External Stage | `STGEXT_` | `STGEXT_<StageName>` | `STGEXT_S3_ORDERS` |
| Internal Stage | `STGINT_` | `STGINT_<StageName>` | `STGINT_CSV_UPLOAD` |
| File Format | `FF_` | `FF_<Type>_<Name>` | `FF_CSV_STANDARD` |
| Stored Procedure | `SP_` | `SP_<ProcedureName>` | `SP_LOAD_ORDERS` |
| Function | `FN_` | `FN_<FunctionName>` | `FN_CALC_REVENUE` |
| Task | `TASK_` | `TASK_<Frequency>_<TaskName>` | `TASK_DAILY_LOAD` |
| Stream | `STM_` | `STM_<StreamName>` | `STM_ORDERS_CDC` |

---

## 4. Database Naming

Format: `<ENV>_DB_<DatabaseName>`

Examples:
- `DEV_DB_SMARTBI`
- `QAS_DB_SMARTBI`
- `PRD_DB_SMARTBI`

**Current project database:** `DB_DEMO_MAYURESH` (demo/learning environment)

---

## 5. Schema Naming

Format: `<LayerPrefix>_<SchemaName>`

Examples:
- `STG_ECOMMERCE` — staging schema for e-commerce data
- `STG_MANUFACTURING` — staging schema for manufacturing data
- `PRC_CLEANSED` — processing/cleansing schema
- `REP_GOLD` — reporting/dimensional model schema
- `APP_CORTEX` — application schema for Streamlit and AI objects

---

## 6. Table Naming

Format: `TBL_<TableName>` — all UPPERCASE, words separated by underscore.

Examples:
- `TBL_ORDERS`
- `TBL_CUSTOMERS`
- `TBL_PRODUCTION_ORDERS`
- `TBL_FACT_SALES`
- `TBL_DIM_DATE`

---

## 7. Column Naming

- All column names in **UPPERCASE**
- Words separated by **underscore** (`_`)
- Descriptive and self-explanatory

Examples:
- `ORDER_ID`
- `CUSTOMER_NAME`
- `ORDER_DATE`
- `TOTAL_REVENUE`

---

## 8. Data Types Reference

### Numeric
| Type | Usage |
|---|---|
| `NUMBER` | Default precision (38,0) |
| `DECIMAL`, `NUMERIC` | Synonymous with NUMBER |
| `INT`, `INTEGER`, `BIGINT` | Whole numbers |
| `FLOAT`, `DOUBLE` | Floating point numbers |

### String & Binary
| Type | Usage |
|---|---|
| `VARCHAR` | Default max 16,777,216 bytes |
| `CHAR`, `CHARACTER` | Fixed length, default VARCHAR(1) |
| `STRING`, `TEXT` | Synonymous with VARCHAR |
| `BINARY`, `VARBINARY` | Binary data |

### Logical
| Type | Usage |
|---|---|
| `BOOLEAN` | True/False values |

### Date & Time
| Type | Usage |
|---|---|
| `DATE` | Date only |
| `TIME` | Time only HH:MI:SS |
| `TIMESTAMP_NTZ` | Timestamp without timezone (preferred) |
| `TIMESTAMP_TZ` | Timestamp with timezone (use for multi-timezone data) |
| `TIMESTAMP_LTZ` | Timestamp with local timezone |

### Semi-Structured
| Type | Usage |
|---|---|
| `VARIANT` | JSON, XML, semi-structured data |
| `OBJECT` | Key-value pairs |
| `ARRAY` | Arrays |

---

## 9. General Rules — ALWAYS Follow

- All object names must be **UPPERCASE**
- Always use **`IF NOT EXISTS`** when creating objects
- Always add a **`COMMENT`** on every object describing its purpose
- Never use spaces in object names — use underscore `_`
- Never use reserved SQL keywords as object names
- Always qualify object names fully: `DATABASE.SCHEMA.OBJECT`
- Use `TIMESTAMP_NTZ` as the default timestamp type unless timezone is required

---

## 10. Current Project Context

| Property | Value |
|---|---|
| Database | `DB_DEMO_MAYURESH` |
| Warehouse | `COMPUTE_WH` |
| Staging Schema | `STG_RAW` |
| Processing Schema | `PRC_CLEANSED` |
| Reporting Schema | `REP_GOLD` |
| Application Schema | `APP_CORTEX` |
| Internal Stage | `STGINT_SMART_BI` |
| File Format | `FF_CSV_STANDARD` |
