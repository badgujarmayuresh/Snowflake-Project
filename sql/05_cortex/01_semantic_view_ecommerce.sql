-- ============================================================
-- Script  : 01_semantic_view_ecommerce.sql
-- Purpose : Create Cortex Analyst semantic view for E-commerce
--           analytics (Sales, Orders, Customers, Products)
-- Author  : Mayuresh Prakash Badgujar
-- Date    : May 2026
-- Layer   : AI (APP_CORTEX)
-- Notes   : Uses SYSTEM$CREATE_SEMANTIC_VIEW_FROM_YAML.
--           Covers Olist e-commerce Gold layer tables.
-- ============================================================

USE DATABASE DB_DEMO_MAYURESH;
USE SCHEMA APP_CORTEX;
USE WAREHOUSE COMPUTE_WH;

-- Create semantic view for e-commerce analytics
CALL SYSTEM$CREATE_SEMANTIC_VIEW_FROM_YAML(
  'DB_DEMO_MAYURESH.APP_CORTEX',
  $$
name: SMART_BI_ECOMMERCE
description: "Semantic view for e-commerce and retail analytics. Covers sales revenue, orders, customers, products, and sellers."

tables:
  - name: SALES
    synonyms:
      - "sales data"
      - "order items"
      - "revenue"
      - "line items"
    description: "Sales transactions at line item level. Each row is one product sold in an order."
    base_table:
      database: DB_DEMO_MAYURESH
      schema: REP_GOLD
      table: TBL_FACT_SALES
    primary_key:
      columns:
        - ORDER_ID
        - ORDER_ITEM_ID
    dimensions:
      - name: ORDER_ID
        description: "Unique order identifier"
        expr: ORDER_ID
        data_type: VARCHAR
      - name: ORDER_STATUS
        synonyms:
          - "status"
          - "order state"
        description: "Current status of the order (delivered, shipped, canceled, etc.)"
        expr: ORDER_STATUS
        data_type: VARCHAR
        is_enum: true
        sample_values:
          - "delivered"
          - "shipped"
          - "canceled"
          - "processing"
          - "invoiced"
    time_dimensions:
      - name: ORDER_DATE_KEY
        synonyms:
          - "order date"
          - "sale date"
          - "purchase date"
        description: "Date key (YYYYMMDD) when the order was placed"
        expr: ORDER_DATE_KEY
        data_type: NUMBER
    facts:
      - name: ITEM_PRICE
        synonyms:
          - "price"
          - "product price"
          - "sale amount"
        description: "Price of the individual product item"
        expr: ITEM_PRICE
        data_type: "NUMBER(12,2)"
      - name: FREIGHT_VALUE
        synonyms:
          - "shipping cost"
          - "freight"
          - "delivery cost"
        description: "Freight/shipping cost for this item"
        expr: FREIGHT_VALUE
        data_type: "NUMBER(12,2)"
      - name: TOTAL_REVENUE
        synonyms:
          - "revenue"
          - "total sale"
          - "line total"
        description: "Total revenue for this item (price + freight)"
        expr: TOTAL_REVENUE
        data_type: "NUMBER(13,2)"
    metrics:
      - name: TOTAL_REVENUE_SUM
        synonyms:
          - "total revenue"
          - "total sales"
          - "gross revenue"
        description: "Sum of all revenue (price + freight)"
        expr: SUM(TOTAL_REVENUE)
      - name: TOTAL_ITEMS_SOLD
        synonyms:
          - "items sold"
          - "units sold"
          - "quantity sold"
        description: "Total number of items sold"
        expr: COUNT(*)
      - name: AVERAGE_ITEM_PRICE
        synonyms:
          - "average price"
          - "avg price"
        description: "Average price per item"
        expr: AVG(ITEM_PRICE)
      - name: TOTAL_FREIGHT_SUM
        synonyms:
          - "total shipping"
          - "total freight"
        description: "Total freight/shipping costs"
        expr: SUM(FREIGHT_VALUE)

  - name: ORDERS
    synonyms:
      - "order data"
      - "customer orders"
    description: "Order-level aggregated data. Each row is one customer order with payment and delivery metrics."
    base_table:
      database: DB_DEMO_MAYURESH
      schema: REP_GOLD
      table: TBL_FACT_ORDERS
    primary_key:
      columns:
        - ORDER_ID
    dimensions:
      - name: ORDER_ID
        description: "Unique order identifier"
        expr: ORDER_ID
        data_type: VARCHAR
        unique: true
      - name: ORDER_STATUS
        synonyms:
          - "status"
        description: "Current status of the order"
        expr: ORDER_STATUS
        data_type: VARCHAR
        is_enum: true
        sample_values:
          - "delivered"
          - "shipped"
          - "canceled"
    time_dimensions:
      - name: ORDER_DATE_KEY
        synonyms:
          - "order date"
          - "purchase date"
        description: "Date key when order was placed"
        expr: ORDER_DATE_KEY
        data_type: NUMBER
      - name: ORDER_PURCHASE_TIMESTAMP
        synonyms:
          - "order time"
          - "purchase time"
        description: "Exact timestamp when the order was placed"
        expr: ORDER_PURCHASE_TIMESTAMP
        data_type: TIMESTAMP_NTZ
    facts:
      - name: TOTAL_PAYMENT_VALUE
        synonyms:
          - "payment"
          - "payment amount"
          - "order value"
        description: "Total payment value for the order"
        expr: TOTAL_PAYMENT_VALUE
        data_type: "NUMBER(24,2)"
      - name: TOTAL_ITEMS
        synonyms:
          - "items in order"
          - "item count"
        description: "Number of items in the order"
        expr: TOTAL_ITEMS
        data_type: NUMBER
      - name: DELIVERY_DAYS
        synonyms:
          - "delivery time"
          - "days to deliver"
          - "shipping time"
        description: "Number of days from order to delivery"
        expr: DELIVERY_DAYS
        data_type: NUMBER
      - name: DELIVERY_VARIANCE_DAYS
        synonyms:
          - "delivery delay"
          - "late days"
        description: "Difference between actual and estimated delivery (negative = late)"
        expr: DELIVERY_VARIANCE_DAYS
        data_type: NUMBER
    metrics:
      - name: TOTAL_ORDERS_COUNT
        synonyms:
          - "total orders"
          - "number of orders"
          - "order count"
        description: "Total number of orders"
        expr: COUNT(*)
      - name: AVERAGE_ORDER_VALUE
        synonyms:
          - "avg order value"
          - "AOV"
        description: "Average payment value per order"
        expr: AVG(TOTAL_PAYMENT_VALUE)
      - name: AVERAGE_DELIVERY_DAYS
        synonyms:
          - "avg delivery time"
          - "average shipping time"
        description: "Average days to deliver an order"
        expr: AVG(DELIVERY_DAYS)
      - name: TOTAL_PAYMENT_SUM
        synonyms:
          - "total payments"
          - "gross payments"
        description: "Sum of all payment values"
        expr: SUM(TOTAL_PAYMENT_VALUE)

  - name: CUSTOMERS
    synonyms:
      - "customer data"
      - "buyers"
    description: "Customer dimension with location details"
    base_table:
      database: DB_DEMO_MAYURESH
      schema: REP_GOLD
      table: TBL_DIM_CUSTOMER
    primary_key:
      columns:
        - CUSTOMER_ID
    dimensions:
      - name: CUSTOMER_ID
        description: "Unique customer identifier"
        expr: CUSTOMER_ID
        data_type: VARCHAR
        unique: true
      - name: CUSTOMER_CITY
        synonyms:
          - "city"
          - "customer location"
        description: "City where the customer is located"
        expr: CUSTOMER_CITY
        data_type: VARCHAR
      - name: CUSTOMER_STATE
        synonyms:
          - "state"
          - "customer state"
        description: "State where the customer is located (Brazilian state code)"
        expr: CUSTOMER_STATE
        data_type: VARCHAR
        is_enum: true
        sample_values:
          - "SP"
          - "RJ"
          - "MG"
          - "BA"
          - "RS"
    metrics:
      - name: CUSTOMER_COUNT
        synonyms:
          - "number of customers"
          - "total customers"
        description: "Count of distinct customers"
        expr: COUNT(DISTINCT CUSTOMER_ID)

  - name: PRODUCTS
    synonyms:
      - "product data"
      - "product catalog"
    description: "Product dimension with category information"
    base_table:
      database: DB_DEMO_MAYURESH
      schema: REP_GOLD
      table: TBL_DIM_PRODUCT
    primary_key:
      columns:
        - PRODUCT_ID
    dimensions:
      - name: PRODUCT_ID
        description: "Unique product identifier"
        expr: PRODUCT_ID
        data_type: VARCHAR
        unique: true
      - name: PRODUCT_CATEGORY
        synonyms:
          - "category"
          - "product type"
        description: "English product category name"
        expr: PRODUCT_CATEGORY
        data_type: VARCHAR
      - name: SOURCE_SYSTEM
        description: "Source system (OLIST or NORTHWIND)"
        expr: SOURCE_SYSTEM
        data_type: VARCHAR
        is_enum: true
        sample_values:
          - "OLIST"
          - "NORTHWIND"

  - name: SELLERS
    synonyms:
      - "seller data"
      - "vendors"
    description: "Seller/vendor dimension with location"
    base_table:
      database: DB_DEMO_MAYURESH
      schema: REP_GOLD
      table: TBL_DIM_SELLER
    primary_key:
      columns:
        - SELLER_ID
    dimensions:
      - name: SELLER_ID
        description: "Unique seller identifier"
        expr: SELLER_ID
        data_type: VARCHAR
        unique: true
      - name: SELLER_CITY
        synonyms:
          - "seller location"
        description: "City where seller is located"
        expr: SELLER_CITY
        data_type: VARCHAR
      - name: SELLER_STATE
        synonyms:
          - "seller state"
        description: "State where seller is located"
        expr: SELLER_STATE
        data_type: VARCHAR

  - name: DATES
    synonyms:
      - "calendar"
      - "date dimension"
    description: "Calendar dimension for time-based analysis"
    base_table:
      database: DB_DEMO_MAYURESH
      schema: REP_GOLD
      table: TBL_DIM_DATE
    primary_key:
      columns:
        - DATE_KEY
    dimensions:
      - name: DATE_KEY
        description: "Date surrogate key in YYYYMMDD format"
        expr: DATE_KEY
        data_type: NUMBER
        unique: true
      - name: YEAR
        synonyms:
          - "calendar year"
        description: "Calendar year"
        expr: YEAR
        data_type: NUMBER
      - name: QUARTER
        synonyms:
          - "fiscal quarter"
        description: "Quarter number (1-4)"
        expr: QUARTER
        data_type: NUMBER
      - name: MONTH_NAME
        synonyms:
          - "month"
        description: "Month name (Jan, Feb, etc.)"
        expr: MONTH_NAME
        data_type: VARCHAR
      - name: YEAR_QUARTER
        description: "Year and quarter combined (e.g., 2023-Q1)"
        expr: YEAR_QUARTER
        data_type: VARCHAR
      - name: YEAR_MONTH
        description: "Year and month combined (e.g., 2023-01)"
        expr: YEAR_MONTH
        data_type: VARCHAR
      - name: DAY_NAME
        description: "Day of the week name"
        expr: DAY_NAME
        data_type: VARCHAR
      - name: IS_WEEKEND
        description: "Whether the date is a weekend"
        expr: IS_WEEKEND
        data_type: BOOLEAN
    time_dimensions:
      - name: FULL_DATE
        synonyms:
          - "date"
          - "calendar date"
        description: "The full calendar date"
        expr: FULL_DATE
        data_type: DATE
        unique: true

relationships:
  - name: SALES_TO_ORDERS
    left_table: SALES
    right_table: ORDERS
    relationship_columns:
      - left_column: ORDER_ID
        right_column: ORDER_ID
  - name: SALES_TO_PRODUCTS
    left_table: SALES
    right_table: PRODUCTS
    relationship_columns:
      - left_column: PRODUCT_ID
        right_column: PRODUCT_ID
  - name: SALES_TO_SELLERS
    left_table: SALES
    right_table: SELLERS
    relationship_columns:
      - left_column: SELLER_ID
        right_column: SELLER_ID
  - name: SALES_TO_DATES
    left_table: SALES
    right_table: DATES
    relationship_columns:
      - left_column: ORDER_DATE_KEY
        right_column: DATE_KEY
  - name: ORDERS_TO_CUSTOMERS
    left_table: ORDERS
    right_table: CUSTOMERS
    relationship_columns:
      - left_column: CUSTOMER_ID
        right_column: CUSTOMER_ID
  - name: ORDERS_TO_DATES
    left_table: ORDERS
    right_table: DATES
    relationship_columns:
      - left_column: ORDER_DATE_KEY
        right_column: DATE_KEY

verified_queries:
  - name: top_10_products_by_revenue
    question: "What are the top 10 products by revenue?"
    use_as_onboarding_question: true
    sql: |
      SELECT
        PRODUCTS.PRODUCT_CATEGORY,
        SUM(SALES.TOTAL_REVENUE) AS total_revenue
      FROM __SALES AS SALES
      JOIN __PRODUCTS AS PRODUCTS ON SALES.PRODUCT_ID = PRODUCTS.PRODUCT_ID
      GROUP BY PRODUCTS.PRODUCT_CATEGORY
      ORDER BY total_revenue DESC
      LIMIT 10

  - name: monthly_sales_trend
    question: "Show me monthly sales trend for the last year"
    use_as_onboarding_question: true
    sql: |
      SELECT
        DATES.YEAR_MONTH,
        SUM(SALES.TOTAL_REVENUE) AS total_revenue,
        COUNT(*) AS items_sold
      FROM __SALES AS SALES
      JOIN __DATES AS DATES ON SALES.ORDER_DATE_KEY = DATES.DATE_KEY
      WHERE DATES.YEAR = 2024
      GROUP BY DATES.YEAR_MONTH
      ORDER BY DATES.YEAR_MONTH

  - name: revenue_by_state
    question: "What is the revenue breakdown by customer state?"
    use_as_onboarding_question: true
    sql: |
      SELECT
        CUSTOMERS.CUSTOMER_STATE,
        SUM(ORDERS.TOTAL_PAYMENT_VALUE) AS total_revenue,
        COUNT(*) AS order_count
      FROM __ORDERS AS ORDERS
      JOIN __CUSTOMERS AS CUSTOMERS ON ORDERS.CUSTOMER_ID = CUSTOMERS.CUSTOMER_ID
      GROUP BY CUSTOMERS.CUSTOMER_STATE
      ORDER BY total_revenue DESC

  - name: avg_delivery_time
    question: "What is the average delivery time by state?"
    sql: |
      SELECT
        CUSTOMERS.CUSTOMER_STATE,
        AVG(ORDERS.DELIVERY_DAYS) AS avg_delivery_days
      FROM __ORDERS AS ORDERS
      JOIN __CUSTOMERS AS CUSTOMERS ON ORDERS.CUSTOMER_ID = CUSTOMERS.CUSTOMER_ID
      WHERE ORDERS.ORDER_STATUS = 'delivered'
      GROUP BY CUSTOMERS.CUSTOMER_STATE
      ORDER BY avg_delivery_days DESC
  $$
);
