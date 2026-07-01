-- ============================================================
-- Script  : 02_semantic_view_manufacturing.sql
-- Purpose : Create Cortex Analyst semantic view for Manufacturing
--           analytics (Production, Defects, Machines, Plants)
-- Author  : Mayuresh Prakash Badgujar
-- Date    : May 2026
-- Layer   : AI (APP_CORTEX)
-- Notes   : Uses SYSTEM$CREATE_SEMANTIC_VIEW_FROM_YAML.
--           Covers Manufacturing Gold layer tables.
-- ============================================================

USE DATABASE DB_DEMO_MAYURESH;
USE SCHEMA APP_CORTEX;
USE WAREHOUSE COMPUTE_WH;

-- Create semantic view for manufacturing analytics
CALL SYSTEM$CREATE_SEMANTIC_VIEW_FROM_YAML(
  'DB_DEMO_MAYURESH.APP_CORTEX',
  $$
name: SMART_BI_MANUFACTURING
description: "Semantic view for manufacturing analytics. Covers production orders, defects, machines, and plant performance."

tables:
  - name: PRODUCTION
    synonyms:
      - "production data"
      - "production orders"
      - "manufacturing orders"
    description: "Production orders at the order level. Each row is one production order with quantities, cost, and efficiency."
    base_table:
      database: DB_DEMO_MAYURESH
      schema: REP_GOLD
      table: TBL_FACT_PRODUCTION
    primary_key:
      columns:
        - PRODUCTION_ORDER_ID
    dimensions:
      - name: PRODUCTION_ORDER_ID
        description: "Unique production order identifier"
        expr: PRODUCTION_ORDER_ID
        data_type: VARCHAR
        unique: true
      - name: SHIFT
        synonyms:
          - "work shift"
          - "production shift"
        description: "Production shift (Morning, Afternoon, Night)"
        expr: SHIFT
        data_type: VARCHAR
        is_enum: true
        sample_values:
          - "Morning"
          - "Afternoon"
          - "Night"
      - name: STATUS
        synonyms:
          - "production status"
          - "order status"
        description: "Status of the production order"
        expr: STATUS
        data_type: VARCHAR
        is_enum: true
        sample_values:
          - "Completed"
          - "In Progress"
          - "Cancelled"
      - name: PLANT_LOCATION
        synonyms:
          - "plant"
          - "factory"
          - "production site"
        description: "Plant where production took place"
        expr: PLANT_LOCATION
        data_type: VARCHAR
      - name: OPERATOR_ID
        synonyms:
          - "operator"
          - "worker"
        description: "ID of the machine operator"
        expr: OPERATOR_ID
        data_type: VARCHAR
    time_dimensions:
      - name: START_DATE
        synonyms:
          - "production start"
          - "start date"
        description: "Date when production order started"
        expr: START_DATE
        data_type: DATE
      - name: END_DATE
        synonyms:
          - "production end"
          - "completion date"
        description: "Date when production order ended"
        expr: END_DATE
        data_type: DATE
    facts:
      - name: PLANNED_QUANTITY
        synonyms:
          - "planned qty"
          - "target quantity"
        description: "Planned production quantity"
        expr: PLANNED_QUANTITY
        data_type: NUMBER
      - name: ACTUAL_QUANTITY
        synonyms:
          - "actual qty"
          - "produced quantity"
        description: "Actual quantity produced"
        expr: ACTUAL_QUANTITY
        data_type: NUMBER
      - name: PRODUCTION_COST
        synonyms:
          - "cost"
          - "manufacturing cost"
        description: "Total cost of the production order"
        expr: PRODUCTION_COST
        data_type: "NUMBER(12,2)"
      - name: QUANTITY_VARIANCE
        synonyms:
          - "variance"
          - "production gap"
        description: "Difference between actual and planned quantity (actual - planned)"
        expr: QUANTITY_VARIANCE
        data_type: NUMBER
      - name: PRODUCTION_EFFICIENCY_PCT
        synonyms:
          - "efficiency"
          - "yield"
          - "production rate"
        description: "Production efficiency as percentage (actual/planned * 100)"
        expr: PRODUCTION_EFFICIENCY_PCT
        data_type: FLOAT
      - name: PRODUCTION_DURATION_DAYS
        synonyms:
          - "production time"
          - "lead time"
          - "duration"
        description: "Number of days to complete the production order"
        expr: PRODUCTION_DURATION_DAYS
        data_type: NUMBER
    metrics:
      - name: TOTAL_PRODUCTION_COST
        synonyms:
          - "total cost"
          - "total manufacturing cost"
        description: "Sum of all production costs"
        expr: SUM(PRODUCTION_COST)
      - name: TOTAL_PLANNED_QTY
        synonyms:
          - "total planned"
        description: "Sum of all planned quantities"
        expr: SUM(PLANNED_QUANTITY)
      - name: TOTAL_ACTUAL_QTY
        synonyms:
          - "total produced"
          - "total output"
        description: "Sum of all actual quantities produced"
        expr: SUM(ACTUAL_QUANTITY)
      - name: AVG_EFFICIENCY
        synonyms:
          - "average efficiency"
          - "mean efficiency"
        description: "Average production efficiency percentage"
        expr: AVG(PRODUCTION_EFFICIENCY_PCT)
      - name: PRODUCTION_ORDER_COUNT
        synonyms:
          - "total production orders"
          - "order count"
        description: "Total number of production orders"
        expr: COUNT(*)
      - name: AVG_PRODUCTION_DURATION
        synonyms:
          - "average lead time"
          - "avg duration"
        description: "Average days to complete a production order"
        expr: AVG(PRODUCTION_DURATION_DAYS)

  - name: DEFECTS
    synonyms:
      - "defect data"
      - "quality defects"
      - "quality issues"
    description: "Quality defect records. Each row is one defect event linked to a production order."
    base_table:
      database: DB_DEMO_MAYURESH
      schema: REP_GOLD
      table: TBL_FACT_DEFECTS
    primary_key:
      columns:
        - DEFECT_ID
    dimensions:
      - name: DEFECT_ID
        description: "Unique defect identifier"
        expr: DEFECT_ID
        data_type: VARCHAR
        unique: true
      - name: DEFECT_TYPE
        synonyms:
          - "type of defect"
          - "defect category"
        description: "Classification of the defect"
        expr: DEFECT_TYPE
        data_type: VARCHAR
        is_enum: true
        sample_values:
          - "Surface Scratch"
          - "Dimensional Error"
          - "Assembly Fault"
          - "Color Mismatch"
          - "Material Defect"
          - "None"
      - name: CORRECTIVE_ACTION
        synonyms:
          - "action taken"
          - "resolution"
        description: "Corrective action taken for the defect"
        expr: CORRECTIVE_ACTION
        data_type: VARCHAR
        is_enum: true
        sample_values:
          - "Rework"
          - "Scrap"
          - "Accept"
          - "Pending"
      - name: PLANT_LOCATION
        synonyms:
          - "plant"
          - "factory"
        description: "Plant where defect was found"
        expr: PLANT_LOCATION
        data_type: VARCHAR
      - name: INSPECTOR_ID
        synonyms:
          - "inspector"
          - "quality inspector"
        description: "ID of the quality inspector"
        expr: INSPECTOR_ID
        data_type: VARCHAR
    time_dimensions:
      - name: INSPECTION_DATE
        synonyms:
          - "defect date"
          - "found date"
        description: "Date when defect was inspected/found"
        expr: INSPECTION_DATE
        data_type: DATE
    facts:
      - name: DEFECT_QUANTITY
        synonyms:
          - "defect count"
          - "defective units"
          - "bad units"
        description: "Number of defective units"
        expr: DEFECT_QUANTITY
        data_type: NUMBER
      - name: DEFECT_RATE_PCT
        synonyms:
          - "defect rate"
          - "failure rate"
        description: "Defect rate as percentage of actual production quantity"
        expr: DEFECT_RATE_PCT
        data_type: FLOAT
    metrics:
      - name: TOTAL_DEFECT_QTY
        synonyms:
          - "total defects"
          - "total defective units"
        description: "Sum of all defective units"
        expr: SUM(DEFECT_QUANTITY)
      - name: AVG_DEFECT_RATE
        synonyms:
          - "average defect rate"
          - "mean defect rate"
        description: "Average defect rate percentage"
        expr: AVG(DEFECT_RATE_PCT)
      - name: DEFECT_RECORD_COUNT
        synonyms:
          - "defect incidents"
          - "number of defects"
        description: "Total number of defect records"
        expr: COUNT(*)

  - name: MACHINES
    synonyms:
      - "machine data"
      - "equipment"
    description: "Machine dimension with type, plant, and capacity details"
    base_table:
      database: DB_DEMO_MAYURESH
      schema: REP_GOLD
      table: TBL_DIM_MACHINE
    primary_key:
      columns:
        - MACHINE_ID
    dimensions:
      - name: MACHINE_ID
        description: "Unique machine identifier"
        expr: MACHINE_ID
        data_type: VARCHAR
        unique: true
      - name: MACHINE_NAME
        synonyms:
          - "machine"
          - "equipment name"
        description: "Descriptive name of the machine"
        expr: MACHINE_NAME
        data_type: VARCHAR
      - name: MACHINE_TYPE
        synonyms:
          - "type"
          - "equipment type"
        description: "Type/category of the machine"
        expr: MACHINE_TYPE
        data_type: VARCHAR
        is_enum: true
        sample_values:
          - "CNC Lathe"
          - "Injection Molder"
          - "Assembly Robot"
          - "Packaging Unit"
          - "Press Machine"
          - "Welding Robot"
      - name: STATUS
        synonyms:
          - "machine status"
        description: "Current operational status of the machine"
        expr: STATUS
        data_type: VARCHAR
        is_enum: true
        sample_values:
          - "Active"
          - "Maintenance"
          - "Idle"
      - name: PLANT_LOCATION
        description: "Plant where machine is located"
        expr: PLANT_LOCATION
        data_type: VARCHAR
    facts:
      - name: CAPACITY_PER_HOUR
        synonyms:
          - "capacity"
          - "hourly capacity"
          - "throughput"
        description: "Machine capacity in units per hour"
        expr: CAPACITY_PER_HOUR
        data_type: NUMBER

  - name: PLANTS
    synonyms:
      - "plant data"
      - "factories"
      - "manufacturing sites"
    description: "Plant/factory dimension with location and region"
    base_table:
      database: DB_DEMO_MAYURESH
      schema: REP_GOLD
      table: TBL_DIM_PLANT
    primary_key:
      columns:
        - PLANT_KEY
    dimensions:
      - name: PLANT_KEY
        description: "Surrogate key for the plant"
        expr: PLANT_KEY
        data_type: VARCHAR
        unique: true
      - name: PLANT_LOCATION
        synonyms:
          - "plant name"
          - "factory name"
        description: "Full plant location name"
        expr: PLANT_LOCATION
        data_type: VARCHAR
      - name: PLANT_CODE
        synonyms:
          - "plant id"
        description: "Short plant code (Plant A, B, C, D)"
        expr: PLANT_CODE
        data_type: VARCHAR
      - name: PLANT_CITY
        synonyms:
          - "factory city"
        description: "City where the plant is located"
        expr: PLANT_CITY
        data_type: VARCHAR
      - name: PLANT_REGION
        synonyms:
          - "region"
        description: "Geographic region of the plant"
        expr: PLANT_REGION
        data_type: VARCHAR
        is_enum: true
        sample_values:
          - "Southeast"
          - "South"
          - "North"
          - "Northeast"

relationships:
  - name: PRODUCTION_TO_MACHINES
    left_table: PRODUCTION
    right_table: MACHINES
    relationship_columns:
      - left_column: MACHINE_ID
        right_column: MACHINE_ID
  - name: PRODUCTION_TO_PLANTS
    left_table: PRODUCTION
    right_table: PLANTS
    relationship_columns:
      - left_column: PLANT_KEY
        right_column: PLANT_KEY
  - name: DEFECTS_TO_MACHINES
    left_table: DEFECTS
    right_table: MACHINES
    relationship_columns:
      - left_column: MACHINE_ID
        right_column: MACHINE_ID
  - name: DEFECTS_TO_PLANTS
    left_table: DEFECTS
    right_table: PLANTS
    relationship_columns:
      - left_column: PLANT_KEY
        right_column: PLANT_KEY

verified_queries:
  - name: production_by_plant
    question: "What is the total production output by plant?"
    use_as_onboarding_question: true
    sql: |
      SELECT
        PRODUCTION.PLANT_LOCATION,
        SUM(PRODUCTION.ACTUAL_QUANTITY) AS total_output,
        SUM(PRODUCTION.PRODUCTION_COST) AS total_cost,
        AVG(PRODUCTION.PRODUCTION_EFFICIENCY_PCT) AS avg_efficiency
      FROM __PRODUCTION AS PRODUCTION
      GROUP BY PRODUCTION.PLANT_LOCATION
      ORDER BY total_output DESC

  - name: defects_by_type
    question: "What are the most common defect types?"
    use_as_onboarding_question: true
    sql: |
      SELECT
        DEFECTS.DEFECT_TYPE,
        SUM(DEFECTS.DEFECT_QUANTITY) AS total_defects,
        AVG(DEFECTS.DEFECT_RATE_PCT) AS avg_defect_rate
      FROM __DEFECTS AS DEFECTS
      WHERE DEFECTS.DEFECT_TYPE != 'None'
      GROUP BY DEFECTS.DEFECT_TYPE
      ORDER BY total_defects DESC

  - name: machine_efficiency
    question: "Which machines have the lowest production efficiency?"
    use_as_onboarding_question: true
    sql: |
      SELECT
        MACHINES.MACHINE_NAME,
        MACHINES.MACHINE_TYPE,
        AVG(PRODUCTION.PRODUCTION_EFFICIENCY_PCT) AS avg_efficiency,
        COUNT(*) AS order_count
      FROM __PRODUCTION AS PRODUCTION
      JOIN __MACHINES AS MACHINES ON PRODUCTION.MACHINE_ID = MACHINES.MACHINE_ID
      GROUP BY MACHINES.MACHINE_NAME, MACHINES.MACHINE_TYPE
      ORDER BY avg_efficiency ASC
      LIMIT 10

  - name: defect_rate_by_plant
    question: "What is the defect rate by plant?"
    sql: |
      SELECT
        PLANTS.PLANT_LOCATION,
        PLANTS.PLANT_REGION,
        AVG(DEFECTS.DEFECT_RATE_PCT) AS avg_defect_rate,
        SUM(DEFECTS.DEFECT_QUANTITY) AS total_defects
      FROM __DEFECTS AS DEFECTS
      JOIN __PLANTS AS PLANTS ON DEFECTS.PLANT_KEY = PLANTS.PLANT_KEY
      GROUP BY PLANTS.PLANT_LOCATION, PLANTS.PLANT_REGION
      ORDER BY avg_defect_rate DESC
  $$
);
