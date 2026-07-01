Smart BI Agent
Intelligent Analytics Platform for Retail & Manufacturing

An end-to-end data analytics platform built entirely on Snowflake, combining traditional BI engineering (dimensional modelling, medallion architecture) with modern AI capabilities (natural language queries, semantic search, forecasting, anomaly detection).

Overview
Smart BI Agent enables business users to ask questions in plain English and receive instant, data-driven answers — no SQL knowledge required. It covers a unified business domain spanning e-commerce, B2B wholesale, and manufacturing operations.

Core Capabilities:

Natural language to SQL via Cortex Analyst
Semantic search across historical insights via Cortex Search
Demand forecasting and anomaly detection via Cortex ML
Intelligent query routing via Snowflake Agent
Single Streamlit interface for all interactions
Architecture
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
        │  Analyst  │ │ Search  │ │ Forecast  │
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
              │   Cleaned & Standardised   │
              └─────────────┬──────────────┘
                            |
              ┌─────────────▼──────────────┐
              │        BRONZE LAYER        │
              │   Raw Data (Audit Trail)   │
              └─────────────┬──────────────┘
                            |
              ┌─────────────▼──────────────┐
              │        DATA SOURCES        │
              │ E-commerce + Manufacturing │
              └────────────────────────────┘
Data Sources
Source	Domain	Key Entities
Olist E-commerce	Online retail	Orders, customers, payments, reviews, products
Northwind	B2B / wholesale	Products, suppliers, employees, wholesale orders
Manufacturing (Synthetic)	Factory operations	Machines, production orders, defects, downtime, inventory
Technology Stack
Component	Technology
Cloud Platform	Snowflake
Data Pipeline	Bronze / Silver / Gold (Medallion Architecture)
Dimensional Model	Star Schema
Natural Language	Cortex Analyst
Semantic Search	Cortex Search Service
Predictive AI	Cortex ML Functions
AI Orchestration	Snowflake Agent
Application	Streamlit in Snowflake
Project Structure
learncoco/
├── README.md
├── architecture.md
├── project_proposal.md
├── data/
│   └── bronze/
│       ├── olist/                  # E-commerce CSV files
│       ├── northwind/              # B2B wholesale CSV files
│       └── manufacturing/          # Factory operations CSV files
├── sql/
│   ├── 01_setup/                   # Schema, file format, stage creation
│   ├── 02_bronze/                  # Table creation & COPY INTO
│   ├── 03_silver/                  # Cleansing & standardisation
│   ├── 04_gold/                    # Dimensional model (facts + dims)
│   ├── 05_cortex/                  # Semantic views & search services
│   ├── 06_agent/                   # Snowflake Agent configuration
│   ├── 07_streamlit/               # Streamlit deployment
│   ├── 08_ml/                      # Cortex ML forecasting & anomaly detection
│   └── 09_tests/                   # Data quality & integration tests
├── scripts/                        # Python utilities (data gen, uploads)
└── streamlit/
    └── streamlit_app.py            # Business user application
Snowflake Objects
Database  : DB_DEMO_MAYURESH
Schemas   : BRONZE | SILVER | GOLD | COCO
Stage     : STG_SMART_BI_AGENT
Warehouse : COMPUTE_WH
Gold Layer — Dimensional Model
Fact Tables:

Table	Grain	Key Measures
FACT_SALES	Order item	Revenue, freight, discount, quantity
FACT_ORDERS	Order	Order count, payment value, delivery days
FACT_PRODUCTION	Production order	Planned vs actual qty, production cost
FACT_DEFECTS	Defect record	Defect qty, defect rate
Dimension Tables: DIM_DATE, DIM_CUSTOMER, DIM_PRODUCT, DIM_SELLER, DIM_LOCATION, DIM_MACHINE, DIM_PLANT

Getting Started
Prerequisites
Snowflake account with SYSADMIN role access
Warehouse: COMPUTE_WH
Database: DB_DEMO_MAYURESH
Deployment Sequence
Setup — Run sql/01_setup/ scripts to create schemas, file formats, and stages
Bronze — Run sql/02_bronze/ scripts to create tables and load raw CSV data
Silver — Run sql/03_silver/ scripts to clean and standardise data
Gold — Run sql/04_gold/ scripts to build the dimensional model
Cortex AI — Run sql/05_cortex/ scripts for semantic views and search services
Agent — Run sql/06_agent/ scripts to configure the Snowflake Agent
Streamlit — Run sql/07_streamlit/ to deploy the application
ML — Run sql/08_ml/ scripts for forecasting and anomaly detection
Tests — Run sql/09_tests/ to validate all layers
Author
Mayuresh Prakash Badgujar

Built with Snowflake Cortex AI | Streamlit | Star Schema Dimensional Modelling
