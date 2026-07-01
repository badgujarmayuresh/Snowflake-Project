# ============================================================
# Smart BI Agent — Streamlit App
# Author  : Mayuresh Prakash Badgujar
# Date    : May 2026
# Purpose : Chat interface for SMART_BI_AGENT Cortex Agent.
#           Routes business questions to e-commerce analytics,
#           manufacturing analytics, customer feedback search,
#           and manufacturing incident search.
# Notes   : Uses SNOWFLAKE.CORTEX.DATA_AGENT_RUN SQL function
#           (compatible with SiS warehouse runtime).
# ============================================================

import streamlit as st
import json
from snowflake.snowpark.context import get_active_session

# ─── Constants ───────────────────────────────────────────────
AGENT_FQN   = "DB_DEMO_MAYURESH.APP_CORTEX.SMART_BI_AGENT"
APP_TITLE   = "Smart BI Agent"
APP_ICON    = "❄️"

EXAMPLE_QUESTIONS = [
    "What are the top 10 products by revenue?",
    "Which plant has the highest production efficiency?",
    "Show me monthly sales trend for 2024",
    "What are the most common defect types?",
    "Find customer complaints about damaged packaging",
    "Which machines had the most mechanical failures?",
    "What is the average delivery time by customer state?",
    "What is the total production cost by plant?",
    "What is the forecasted revenue by product category?",
    "Which plants had defect anomalies in 2024?",
    "How many high risk churn customers are in SP state?",
]

# ─── Page Config ─────────────────────────────────────────────
st.set_page_config(
    page_title=APP_TITLE,
    page_icon=APP_ICON,
    layout="wide",
)

# ─── Session ─────────────────────────────────────────────────
session = get_active_session()

# ─── State Init ──────────────────────────────────────────────
if "messages" not in st.session_state:
    st.session_state.messages = []


# ─── Helpers ─────────────────────────────────────────────────
def call_agent(question: str, history: list) -> dict:
    """
    Call SMART_BI_AGENT via SNOWFLAKE.CORTEX.DATA_AGENT_RUN.
    Works in SiS warehouse runtime — no REST API required.
    """
    messages = history + [
        {"role": "user", "content": [{"type": "text", "text": question}]}
    ]
    request_body = json.dumps({"stream": False, "messages": messages})
    # Escape single quotes in the JSON for safe SQL injection
    safe_body = request_body.replace("'", "''")
    result = session.sql(
        f"SELECT SNOWFLAKE.CORTEX.DATA_AGENT_RUN('{AGENT_FQN}', $${safe_body}$$)"
    ).collect()[0][0]
    return json.loads(result)


def extract_text(response: dict) -> str:
    """Extract the assistant's final text from the agent response.

    Response schema (schema_version v2):
      {"role": "assistant", "content": [...blocks...], ...}
    Each text block: {"type": "text", "text": "..."}
    """
    try:
        content = response.get("content", [])
        if not content:
            return "_No response received._"
        text_parts = [
            block.get("text", "")
            for block in content
            if isinstance(block, dict) and block.get("type") == "text"
        ]
        return "\n\n".join(text_parts) or "_Agent returned no text._"
    except Exception as e:
        return f"_Error parsing response: {e}_"


def extract_thinking(response: dict) -> list:
    """Extract tool-use steps for the transparency expander."""
    steps = []
    try:
        for block in response.get("content", []):
            if not isinstance(block, dict):
                continue
            btype = block.get("type")
            if btype == "tool_use":
                name = block.get("tool_use", {}).get("name", "tool")
                steps.append(f"**Tool called:** `{name}`")
            elif btype == "tool_result":
                name = block.get("tool_result", {}).get("name", "tool")
                steps.append(f"**Tool result:** `{name}`")
    except Exception:
        pass
    return steps


def format_history_for_agent(messages: list) -> list:
    """Convert Streamlit message history to agent API format."""
    history = []
    for msg in messages:
        role = msg["role"]
        text = msg["content"]
        history.append({
            "role": role,
            "content": [{"type": "text", "text": text}]
        })
    return history


# ─── Sidebar ─────────────────────────────────────────────────
with st.sidebar:
    st.title(f"{APP_ICON} {APP_TITLE}")
    st.caption("Powered by Snowflake Cortex Agents")
    st.divider()

    st.subheader("Example Questions")
    for q in EXAMPLE_QUESTIONS:
        if st.button(q, use_container_width=True, key=f"btn_{q[:20]}"):
            st.session_state["prefill"] = q

    st.divider()
    st.subheader("Data Sources")
    st.markdown("""
**E-commerce (Olist + Northwind)**
- Sales & revenue
- Orders & payments
- Customers & sellers
- Delivery performance

**Manufacturing**
- Production orders
- Machine efficiency
- Quality defects
- Plant performance

**Cortex ML Predictions**
- Revenue forecasts by category
- Defect anomaly detection by plant
- Customer churn risk scores
""")

    st.divider()
    if st.button("Clear conversation", use_container_width=True):
        st.session_state.messages = []
        st.rerun()

    st.caption("DB: DB_DEMO_MAYURESH | Agent: SMART_BI_AGENT")


# ─── Main ─────────────────────────────────────────────────────
st.title(f"{APP_ICON} {APP_TITLE}")
st.caption(
    "Ask me anything about e-commerce sales, manufacturing performance, "
    "customer feedback, operational incidents, revenue forecasts, defect anomalies, or churn risk."
)

# ─── Input form (SiS-compatible — no st.chat_input) ──────────
with st.form(key="chat_form", clear_on_submit=True):
    user_input = st.text_input(
        "Your question",
        placeholder="Ask a business question...",
        label_visibility="collapsed",
    )
    submitted = st.form_submit_button("Send", use_container_width=True)

# Sidebar button click auto-fires without needing Send
prefill = st.session_state.pop("prefill", None)
active_question = user_input.strip() if submitted else (prefill or "")

# ─── Process submission ───────────────────────────────────────
if active_question:
    st.session_state.messages.append({"role": "user", "content": active_question})

    with st.spinner("Thinking..."):
        try:
            history = format_history_for_agent(st.session_state.messages[:-1])
            response = call_agent(active_question, history)

            steps = extract_thinking(response)
            answer = extract_text(response)

            st.session_state.messages.append({"role": "assistant", "content": answer})
            if steps:
                st.session_state["last_tools"] = steps
            else:
                st.session_state.pop("last_tools", None)

        except Exception as e:
            err = f"An error occurred: {str(e)}"
            st.session_state.messages.append({"role": "assistant", "content": err})
            st.session_state.pop("last_tools", None)

# ─── Render chat history ──────────────────────────────────────
for i, msg in enumerate(st.session_state.messages):
    is_user = msg["role"] == "user"
    label = "You" if is_user else APP_TITLE
    with st.container():
        st.markdown(f"**{label}**")
        st.markdown(msg["content"])
        # Show tool steps expander under the last assistant message
        if not is_user and i == len(st.session_state.messages) - 1:
            tools = st.session_state.get("last_tools")
            if tools:
                with st.expander("Tools used", expanded=False):
                    for step in tools:
                        st.markdown(step)
        st.divider()
