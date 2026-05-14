# Smart BI Agent — Technical Architecture

**Project:** Smart BI Agent — Retail + Manufacturing Analytics Platform  
**Author:** Mayuresh Prakash Badgujar  
**Date:** May 2026  
**Version:** 1.0  

---

## 1. Overview

This project builds an intelligent analytics platform for a company that **manufactures products and sells them online**. It combines traditional BI expertise (dimensional modelling, ETL) with modern AI capabilities (natural language queries, forecasting, anomaly detection) — all running natively on Snowflake.

---

## 2. Business Problem

Business users today face three core challenges:

| Challenge | Impact |
|---|---|
| Need SQL knowledge to get answers from data | Only analysts can query data — business waits |
| Insights buried in reports no one can find | Decisions made on gut feel, not data |
| No forward-looking intelligence | React to problems instead of preventing them |

**This platform solves all three.**

---

## 3. Domain & Data Sources

| Source | Domain | Key Entities |
|---|---|---|
| **Olist E-commerce** | Online retail / customer side | Orders, customers, payments, reviews, products |
| **Northwind** | B2B sales + supplier management | Products, suppliers, employees, wholesale orders |
| **Manufacturing (Synthetic)** | Factory / production side | Machines, production orders, defects, downtime, inventory |

Together they represent one unified company — **from factory floor to customer doorstep.**

---

## 4. Layered Architecture

```
┌─────────────────────────────────────────────────────┐
│                  SOURCE DATA                        │
│   CSV files (Olist + Northwind + Manufacturing)     │
└──────────────────────┬──────────────────────────────┘
                       │ Load as-is
┌──────────────────────▼──────────────────────────────┐
│               BRONZE LAYER                          │
│   Raw data — no transformations                     │
│   Schema: DB_DEMO_MAYURESH.BRONZE                   │
│   Tables: exact copy of CSV files                   │
│   Purpose: audit trail, replayability               │
└──────────────────────┬──────────────────────────────┘
                       │ Clean + Standardise
┌──────────────────────▼──────────────────────────────┐
│               SILVER LAYER                          │
│   Cleaned, typed, deduplicated, conformed           │
│   Schema: DB_DEMO_MAYURESH.SILVER                   │
│   Purpose: trusted, consistent, analysis-ready data │
└──────────────────────┬──────────────────────────────┘
                       │ Model into facts + dimensions
┌──────────────────────▼──────────────────────────────┐
│               GOLD LAYER                            │
│   Dimensional model — business ready                │
│   Schema: DB_DEMO_MAYURESH.GOLD                     │
│   Star schema: Fact tables + Dimension tables       │
│   Purpose: analytics, reporting, AI consumption     │
└──────────────────────┬──────────────────────────────┘
                       │
          ┌────────────┼────────────┐
          ▼            ▼            ▼
   Cortex Analyst  Cortex Search  Cortex ML
   (NL → SQL)     (Insight Search)(Forecast/Anomaly)
          │            │            │
          └────────────┼────────────┘
                       ▼
               Snowflake Agent
               (Orchestrator)
                       │
                       ▼
               Streamlit App
               (Business User Interface)
```

---

## 5. Layer Definitions

### Bronze Layer — Raw Ingestion
- Data loaded **as-is** from CSV files using Snowflake internal stages (COPY INTO)
- No transformations, no business logic
- Acts as the **system of record** — if anything breaks downstream, we replay from here
- Tables mirror source file structure exactly

### Silver Layer — Cleansing & Standardisation
Transformations applied at this layer:
- **Null handling** — replace or flag nulls with meaningful defaults
- **Type casting** — ensure dates are DATE, amounts are NUMBER, IDs are VARCHAR
- **Column renaming** — standard snake_case naming convention
- **Deduplication** — remove duplicate records using ROW_NUMBER()
- **Conforming** — align product IDs across Olist, Northwind, Manufacturing

### Gold Layer — Dimensional Model
Business-ready star schema optimised for analytics and AI:

```
                    ┌──────────────┐
                    │  DIM_DATE    │
                    └──────┬───────┘
                           │
┌──────────────┐    ┌──────▼───────┐    ┌──────────────┐
│ DIM_CUSTOMER ├────►  FACT_SALES  ◄────┤ DIM_PRODUCT  │
└──────────────┘    └──────┬───────┘    └──────────────┘
                           │
┌──────────────┐    ┌──────▼───────┐    ┌──────────────┐
│ DIM_SELLER   ├────► FACT_ORDERS  ◄────┤ DIM_LOCATION │
└──────────────┘    └──────────────┘    └──────────────┘

┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│ DIM_MACHINE  ├────►FACT_PRODUCTION◄───┤ DIM_PLANT    │
└──────────────┘    └──────┬───────┘    └──────────────┘
                           │
                    ┌──────▼───────┐
                    │ FACT_DEFECTS │
                    └──────────────┘
```

#### Fact Tables
| Table | Grain | Key Measures |
|---|---|---|
| FACT_SALES | One row per order item | Revenue, freight, discount, quantity |
| FACT_ORDERS | One row per order | Order count, payment value, delivery days |
| FACT_PRODUCTION | One row per production order | Planned vs actual qty, production cost |
| FACT_DEFECTS | One row per defect record | Defect qty, defect rate |

#### Dimension Tables
| Table | Description |
|---|---|
| DIM_DATE | Calendar table with year, quarter, month, week, day |
| DIM_CUSTOMER | Customer details, city, state, region |
| DIM_PRODUCT | Product, category, translated category |
| DIM_SELLER | Seller details and location |
| DIM_LOCATION | Geographic hierarchy |
| DIM_MACHINE | Machine type, plant, status, capacity |
| DIM_PLANT | Plant location, region |

---

## 6. AI Layer

### Cortex Analyst
- Semantic YAML model built on top of Gold layer
- Maps business terms to SQL columns
- Enables natural language questions like: *"What were top 5 products last quarter?"*
- Returns SQL + results + chart

### Cortex Search
- Indexes key business insights, report summaries, anomaly descriptions
- Enables semantic search across historical context
- Example: *"Find all reports about sales decline in 2023"*

### Cortex ML Functions
- **Forecasting** — predict future sales and production demand
- **Anomaly Detection** — flag unusual patterns in sales, defects, downtime
- **Classification** — classify customer churn risk, product quality

### Snowflake Agent
- Orchestrates Cortex Analyst + Cortex Search + Cortex ML
- Decides which tool to use based on user question
- Combines results into a single intelligent response

---

## 7. Tech Stack

| Layer | Technology | Why |
|---|---|---|
| Cloud Platform | Snowflake | Single platform — storage, compute, AI, app |
| Raw Storage | Snowflake Internal Stage | Secure, scalable file staging |
| Transformation | Snowflake SQL (Views + CTAS) | Native, no extra tools needed |
| Semantic Layer | Cortex Analyst YAML | Business-friendly NL interface |
| Search | Cortex Search Service | Semantic search on unstructured insights |
| ML | Cortex ML Functions | Built-in forecasting + anomaly detection |
| Agent | Snowflake Cortex Agent | AI orchestration layer |
| App | Streamlit in Snowflake | Native app, no infrastructure required |

---

## 8. Build Sequence

| Step | What | Layer |
|---|---|---|
| 1 | Create Snowflake schemas (BRONZE, SILVER, GOLD) | Setup |
| 2 | Create internal stage, upload CSVs, COPY INTO | Bronze |
| 3 | Clean + standardise with SQL | Silver |
| 4 | Build dimensional model (facts + dims) | Gold |
| 5 | Build Cortex Analyst semantic YAML | AI |
| 6 | Set up Cortex Search service | AI |
| 7 | Add Cortex ML forecasting + anomaly detection | AI |
| 8 | Configure Snowflake Agent | AI |
| 9 | Build Streamlit app | App |

---

## 9. Snowflake Object Naming Convention

```
Database  : DB_DEMO_MAYURESH
Schemas   : BRONZE | SILVER | GOLD | COCO (app schema)

Tables    : <LAYER>_<SOURCE>_<ENTITY>
            e.g. BRONZE_OLIST_ORDERS
                 SILVER_ORDERS
                 GOLD_FACT_SALES
                 GOLD_DIM_CUSTOMER

Stage     : STG_SMART_BI_AGENT
```

---

## 10. Folder Structure (Local)

```
learncoco/
├── architecture.md          <- This document
├── project_proposal.md      <- Client presentation
├── data/
│   └── bronze/              <- Raw CSV files
│       ├── olist/
│       ├── northwind/
│       └── manufacturing/
├── sql/
│   ├── 01_setup/            <- Schema, stage creation
│   ├── 02_bronze/           <- COPY INTO statements
│   ├── 03_silver/           <- Cleansing SQL
│   └── 04_gold/             <- Dimensional model SQL
├── cortex/
│   ├── semantic_model.yaml  <- Cortex Analyst model
│   └── agent_config.yaml    <- Agent configuration
└── streamlit/
    └── app.py               <- Streamlit application
```
