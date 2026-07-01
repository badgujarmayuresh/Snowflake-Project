-- ============================================================
-- Script  : 01_create_agent.sql
-- Purpose : Create the SMART_BI_AGENT Cortex Agent with all
--           four tools: 2 Cortex Analyst (semantic views) +
--           2 Cortex Search (search services)
-- Author  : Mayuresh Prakash Badgujar
-- Date    : May 2026
-- Layer   : AI (APP_CORTEX)
-- Prerequisites:
--   - SMART_BI_ECOMMERCE semantic view     (05_cortex/01)
--   - SMART_BI_MANUFACTURING semantic view (05_cortex/02)
--   - SVC_SEARCH_CUSTOMER_INSIGHTS         (05_cortex/03)
--   - SVC_SEARCH_MFG_INCIDENTS             (05_cortex/03)
-- ============================================================

USE DATABASE DB_DEMO_MAYURESH;
USE SCHEMA APP_CORTEX;
USE WAREHOUSE COMPUTE_WH;

-- ============================================================
-- CREATE SMART_BI_AGENT
-- Tools:
--   1. query_ecommerce          → SMART_BI_ECOMMERCE (Cortex Analyst)
--   2. query_manufacturing      → SMART_BI_MANUFACTURING (Cortex Analyst)
--   3. search_customer_feedback → SVC_SEARCH_CUSTOMER_INSIGHTS (Cortex Search)
--   4. search_manufacturing_incidents → SVC_SEARCH_MFG_INCIDENTS (Cortex Search)
-- ============================================================
CREATE OR REPLACE AGENT DB_DEMO_MAYURESH.APP_CORTEX.SMART_BI_AGENT
FROM SPECIFICATION $$
{
  "models": {
    "orchestration": "auto"
  },
  "orchestration": {
    "budget": {
      "seconds": 900,
      "tokens": 400000
    }
  },
  "instructions": {
    "orchestration": "You are a Smart BI Agent for a company that manufactures products and sells them online. You have access to four tools:\n\n1. query_ecommerce: Use for questions about sales revenue, orders, customers, products, sellers, and delivery performance.\n\n2. query_manufacturing: Use for questions about production orders, defects, machine efficiency, plant performance, and production costs.\n\n3. search_customer_feedback: Use for semantic search over customer reviews, complaints, and feedback themes.\n\n4. search_manufacturing_incidents: Use for semantic search over machine downtime and quality defect incident records.\n\nAlways choose the most appropriate tool(s). For broad business questions, combine results from multiple tools.",
    "response": "Present answers clearly and concisely. Use tables where appropriate. Always mention the data source used. If combining multiple sources, label each section."
  },
  "tools": [
    {
      "tool_spec": {
        "type": "cortex_analyst_text_to_sql",
        "name": "query_ecommerce",
        "description": "Query e-commerce and retail analytics data. Use for questions about sales revenue, order counts, customer locations, product categories, seller performance, delivery times, and payment values."
      }
    },
    {
      "tool_spec": {
        "type": "cortex_analyst_text_to_sql",
        "name": "query_manufacturing",
        "description": "Query manufacturing analytics data. Use for questions about production orders, efficiency, defect rates, machine performance, plant output, and production costs."
      }
    },
    {
      "tool_spec": {
        "type": "cortex_search",
        "name": "search_customer_feedback",
        "description": "Semantic search over customer review text. Use for finding feedback themes, complaints, sentiments, or review patterns. Filterable by review score, product category, customer state, and order status."
      }
    },
    {
      "tool_spec": {
        "type": "cortex_search",
        "name": "search_manufacturing_incidents",
        "description": "Semantic search over manufacturing incidents including machine downtime and quality defects. Use for finding failure patterns, operational issues, or incident history. Filterable by incident type, machine type, and plant location."
      }
    }
  ],
  "tool_resources": {
    "query_ecommerce": {
      "execution_environment": {
        "query_timeout": 299,
        "type": "warehouse",
        "warehouse": "COMPUTE_WH"
      },
      "semantic_view": "DB_DEMO_MAYURESH.APP_CORTEX.SMART_BI_ECOMMERCE"
    },
    "query_manufacturing": {
      "execution_environment": {
        "query_timeout": 299,
        "type": "warehouse",
        "warehouse": "COMPUTE_WH"
      },
      "semantic_view": "DB_DEMO_MAYURESH.APP_CORTEX.SMART_BI_MANUFACTURING"
    },
    "search_customer_feedback": {
      "execution_environment": {
        "query_timeout": 299,
        "type": "warehouse",
        "warehouse": "COMPUTE_WH"
      },
      "search_service": "DB_DEMO_MAYURESH.APP_CORTEX.SVC_SEARCH_CUSTOMER_INSIGHTS"
    },
    "search_manufacturing_incidents": {
      "execution_environment": {
        "query_timeout": 299,
        "type": "warehouse",
        "warehouse": "COMPUTE_WH"
      },
      "search_service": "DB_DEMO_MAYURESH.APP_CORTEX.SVC_SEARCH_MFG_INCIDENTS"
    }
  }
}
$$;

-- ============================================================
-- VERIFICATION
-- ============================================================
-- Check agent exists
SHOW AGENTS LIKE 'SMART_BI_AGENT' IN SCHEMA DB_DEMO_MAYURESH.APP_CORTEX;

-- Inspect full spec
DESCRIBE AGENT DB_DEMO_MAYURESH.APP_CORTEX.SMART_BI_AGENT;
