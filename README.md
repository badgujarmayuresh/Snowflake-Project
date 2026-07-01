# 🚀 Smart BI Agent

**Intelligent Analytics Platform for Retail & Manufacturing**

An end-to-end analytics platform built entirely on **Snowflake**, combining traditional Business Intelligence engineering with modern AI capabilities such as natural language querying, semantic search, forecasting, and anomaly detection.

---

## Overview

Smart BI Agent enables business users to ask questions in plain English and receive instant, data-driven answers—without writing SQL.

The platform combines multiple business domains into a unified analytical model:

- 🛒 E-commerce
- 🏭 Manufacturing
- 📦 B2B Wholesale

### Core Capabilities

- Natural Language to SQL using **Snowflake Cortex Analyst**
- Semantic Search using **Snowflake Cortex Search**
- Demand Forecasting using **Snowflake Cortex ML**
- Anomaly Detection using **Snowflake Cortex ML**
- Intelligent Query Routing using **Snowflake Agent**
- Unified Streamlit Application
- Medallion Data Architecture
- Star Schema Dimensional Model

---

# Architecture

```text
                     BUSINESS USER
                          |
              ┌───────────▼────────────┐
              │     STREAMLIT APP      │
              └───────────┬────────────┘
                          |
              ┌───────────▼────────────┐
              │   SNOWFLAKE AI AGENT   │
              └──┬──────────┬──────┬───┘
                 |          |      |
        ┌────────▼──┐ ┌────▼────┐ ┌▼──────────┐
        │  Cortex   │ │ Cortex  │ │ Cortex ML │
        │ Analyst   │ │ Search  │ │ Forecast  │
        └─────┬─────┘ └────┬────┘ └┬──────────┘
              └─────────────┼───────┘
                            |
              ┌─────────────▼──────────────┐
              │         GOLD LAYER         │
              │   Star Schema (Facts/Dims) │
              └─────────────┬──────────────┘
                            |
              ┌─────────────▼──────────────┐
              │        SILVER LAYER        │
              │ Cleaned & Standardised     │
              └─────────────┬──────────────┘
                            |
              ┌─────────────▼──────────────┐
              │        BRONZE LAYER        │
              │ Raw Data (Audit Trail)     │
              └─────────────┬──────────────┘
                            |
              ┌─────────────▼──────────────┐
              │        DATA SOURCES        │
              │ E-commerce + Manufacturing │
              └────────────────────────────┘
```

---

# Data Sources

| Source | Domain | Key Entities |
|---------|--------|--------------|
| Olist | E-commerce | Orders, Customers, Products, Payments, Reviews |
| Northwind | B2B Wholesale | Products, Suppliers, Employees, Orders |
| Manufacturing (Synthetic) | Factory Operations | Machines, Production Orders, Downtime, Defects, Inventory |

---

# Technology Stack

| Component | Technology |
|------------|------------|
| Cloud Platform | Snowflake |
| Data Pipeline | Bronze / Silver / Gold |
| Data Architecture | Medallion Architecture |
| Dimensional Model | Star Schema |
| Natural Language AI | Cortex Analyst |
| Semantic Search | Cortex Search |
| Predictive Analytics | Cortex ML |
| AI Orchestration | Snowflake Agent |
| Frontend | Streamlit in Snowflake |

---

# Project Structure

```text
learncoco/
│
├── README.md
├── architecture.md
├── project_proposal.md
│
├── data/
│   └── bronze/
│       ├── olist/
│       ├── northwind/
│       └── manufacturing/
│
├── sql/
│   ├── 01_setup/
│   ├── 02_bronze/
│   ├── 03_silver/
│   ├── 04_gold/
│   ├── 05_cortex/
│   ├── 06_agent/
│   ├── 07_streamlit/
│   ├── 08_ml/
│   └── 09_tests/
│
├── scripts/
│
└── streamlit/
    └── streamlit_app.py
```

---

# Snowflake Objects

| Object | Name |
|---------|------|
| Database | DB_DEMO_MAYURESH |
| Schemas | BRONZE, SILVER, GOLD, COCO |
| Stage | STG_SMART_BI_AGENT |
| Warehouse | COMPUTE_WH |

---

# Gold Layer – Dimensional Model

## Fact Tables

| Table | Grain | Measures |
|--------|-------|----------|
| FACT_SALES | Order Item | Revenue, Freight, Discount, Quantity |
| FACT_ORDERS | Order | Payment Value, Delivery Days |
| FACT_PRODUCTION | Production Order | Planned Qty, Actual Qty, Production Cost |
| FACT_DEFECTS | Defect Record | Defect Quantity, Defect Rate |

## Dimension Tables

- DIM_DATE
- DIM_CUSTOMER
- DIM_PRODUCT
- DIM_SELLER
- DIM_LOCATION
- DIM_MACHINE
- DIM_PLANT

---

# Getting Started

## Prerequisites

- Snowflake Account
- SYSADMIN Role
- Warehouse: `COMPUTE_WH`
- Database: `DB_DEMO_MAYURESH`

---

# Deployment Sequence

| Step | Description |
|------|-------------|
| 1 | Execute `sql/01_setup/` |
| 2 | Execute `sql/02_bronze/` |
| 3 | Execute `sql/03_silver/` |
| 4 | Execute `sql/04_gold/` |
| 5 | Execute `sql/05_cortex/` |
| 6 | Execute `sql/06_agent/` |
| 7 | Execute `sql/07_streamlit/` |
| 8 | Execute `sql/08_ml/` |
| 9 | Execute `sql/09_tests/` |

---

# Features

- End-to-End Data Engineering
- Medallion Architecture
- Star Schema Modelling
- AI-powered Analytics
- Natural Language SQL
- Semantic Search
- Forecasting
- Anomaly Detection
- Interactive Streamlit Dashboard

---

# Future Enhancements

- Role-Based Security
- Multi-Agent Architecture
- RAG Knowledge Base
- Chat History
- Dashboard Generation
- PDF Report Generation
- Automated Alerts
- Voice-based Analytics

---

# Author

**Mayuresh Prakash Badgujar**

Managing Consultant | Data Engineering | Business Intelligence | AI | Snowflake

---

## Built With

- Snowflake
- Cortex AI
- Cortex Analyst
- Cortex Search
- Cortex ML
- Snowflake Agent
- Streamlit
- Python
- SQL
- Star Schema
- Medallion Architecture

---

If you find this project useful, consider giving it a star.
