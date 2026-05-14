"""
Generates a single-page visual architecture overview:
  - architecture_overview.png
  - architecture_overview.pdf
"""

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.patches import FancyBboxPatch, FancyArrowPatch
from pathlib import Path

OUT_PNG = Path(__file__).parent.parent / "architecture_overview.png"
OUT_PDF = Path(__file__).parent.parent / "architecture_overview.pdf"

# ── Colours ────────────────────────────────────────────────────
C_BG       = "#0D1B2A"
C_BLUE     = "#29B5E8"
C_TEAL     = "#00C4B4"
C_GOLD     = "#FFD700"
C_SILVER   = "#AAAAAA"
C_BRONZE   = "#CD7F32"
C_WHITE    = "#FFFFFF"
C_LGREY    = "#1E2E40"
C_CARD     = "#162230"
C_RED      = "#E83A3A"
C_ORANGE   = "#FF8C00"
C_PURPLE   = "#8B5CF6"
C_GREEN    = "#22C55E"

fig, ax = plt.subplots(figsize=(22, 14))
fig.patch.set_facecolor(C_BG)
ax.set_facecolor(C_BG)
ax.set_xlim(0, 22)
ax.set_ylim(0, 14)
ax.axis("off")

# ── Helpers ────────────────────────────────────────────────────

def box(x, y, w, h, color, alpha=1.0, radius=0.35, lw=0, edgecolor=None):
    ec = edgecolor if edgecolor else color
    p  = FancyBboxPatch((x, y), w, h,
                         boxstyle=f"round,pad=0,rounding_size={radius}",
                         linewidth=lw, edgecolor=ec,
                         facecolor=color, alpha=alpha, zorder=3)
    ax.add_patch(p)

def txt(x, y, s, size=9, color=C_WHITE, bold=False, ha="center", va="center", zorder=5):
    w = "bold" if bold else "normal"
    ax.text(x, y, s, fontsize=size, color=color, fontweight=w,
            ha=ha, va=va, zorder=zorder,
            fontfamily="DejaVu Sans")

def arrow(x1, y1, x2, y2, color=C_BLUE, lw=2):
    ax.annotate("", xy=(x2, y2), xytext=(x1, y1),
                arrowprops=dict(arrowstyle="-|>", color=color,
                                lw=lw, mutation_scale=14),
                zorder=4)

def divider(y, color=C_BLUE, lw=1, alpha=0.4):
    ax.axhline(y=y, color=color, linewidth=lw, alpha=alpha, zorder=2)

# ══════════════════════════════════════════════════════════════
# TITLE BAR
# ══════════════════════════════════════════════════════════════
box(0, 13.2, 22, 0.8, C_BLUE)
txt(11, 13.62, "Smart BI Agent  —  Architecture Overview", size=16, bold=True, color=C_BG)
txt(19.5, 13.62, "Mayuresh Prakash Badgujar  |  May 2026", size=8, color=C_BG)

# ══════════════════════════════════════════════════════════════
# LEFT COLUMN — DATA PIPELINE (Source → Bronze → Silver → Gold)
# ══════════════════════════════════════════════════════════════
box(0.3, 0.3, 6.5, 12.7, C_LGREY, radius=0.4)
txt(3.55, 12.72, "DATA PIPELINE", size=10, bold=True, color=C_BLUE)

# --- SOURCE DATA ---
box(0.6, 11.3, 5.9, 1.15, C_CARD, radius=0.3)
box(0.6, 11.3, 5.9, 0.38, "#3A3A3A", radius=0.3)
txt(3.55, 11.49, "SOURCE DATA", size=9, bold=True, color=C_WHITE)
sources = ["Olist E-commerce", "Northwind B2B", "Manufacturing"]
cols    = [1.2, 3.3, 5.0]
for s, cx in zip(sources, cols):
    box(cx-0.55, 11.72, 1.55, 0.55, "#2A3A50", radius=0.2)
    txt(cx+0.23, 11.99, s, size=7, color=C_SILVER)

# arrow
arrow(3.55, 11.3, 3.55, 10.92, color=C_SILVER)

# --- BRONZE ---
box(0.6, 9.7, 5.9, 1.4, C_CARD, radius=0.3)
box(0.6, 9.7, 5.9, 0.38, C_BRONZE, radius=0.3)
txt(3.55, 9.89, "BRONZE LAYER  —  Raw Ingestion", size=9, bold=True, color=C_WHITE)
txt(3.55, 10.30, "Raw CSV files loaded as-is via COPY INTO", size=8, color=C_SILVER)
txt(3.55, 10.58, "DB_DEMO_MAYURESH.BRONZE", size=7.5, color=C_BRONZE)
arrow(3.55, 9.7, 3.55, 9.32, color=C_BRONZE)

# --- SILVER ---
box(0.6, 8.1, 5.9, 1.4, C_CARD, radius=0.3)
box(0.6, 8.1, 5.9, 0.38, C_SILVER, radius=0.3)
txt(3.55, 8.29, "SILVER LAYER  —  Cleansing & Standardisation", size=9, bold=True, color=C_BG)
txt(3.55, 8.68, "Null handling | Type casting | Deduplication", size=8, color=C_SILVER)
txt(3.55, 8.96, "DB_DEMO_MAYURESH.SILVER", size=7.5, color=C_SILVER)
arrow(3.55, 8.1, 3.55, 7.72, color=C_SILVER)

# --- GOLD ---
box(0.6, 6.5, 5.9, 1.4, C_CARD, radius=0.3)
box(0.6, 6.5, 5.9, 0.38, C_GOLD, radius=0.3)
txt(3.55, 6.69, "GOLD LAYER  —  Dimensional Model", size=9, bold=True, color=C_BG)
txt(3.55, 7.08, "Star Schema: Facts + Dimensions", size=8, color=C_SILVER)
txt(3.55, 7.36, "DB_DEMO_MAYURESH.GOLD", size=7.5, color=C_GOLD)

# ══════════════════════════════════════════════════════════════
# MIDDLE COLUMN — DIMENSIONAL MODEL (Star Schema)
# ══════════════════════════════════════════════════════════════
box(7.1, 0.3, 7.5, 12.7, C_LGREY, radius=0.4)
txt(10.85, 12.72, "DIMENSIONAL MODEL  (Star Schema)", size=10, bold=True, color=C_GOLD)

# Central DIM_DATE
box(9.45, 11.2, 2.8, 1.0, C_GOLD, radius=0.3)
txt(10.85, 11.72, "DIM_DATE", size=9, bold=True, color=C_BG)
txt(10.85, 11.44, "Year | Quarter | Month | Week | Day", size=7, color=C_BG)

# FACT_SALES  (centre)
box(9.2, 8.8, 3.3, 1.6, "#1A3A20", radius=0.3, lw=1.5, edgecolor=C_GREEN)
txt(10.85, 9.82, "FACT_SALES", size=9, bold=True, color=C_GREEN)
txt(10.85, 9.55, "Revenue | Qty | Freight", size=7.5, color=C_SILVER)
txt(10.85, 9.3,  "Discount | Order Item Key", size=7.5, color=C_SILVER)
txt(10.85, 9.05, "FK: Customer | Product | Date", size=7, color=C_GREEN)

# FACT_ORDERS
box(7.3,  6.8, 3.0, 1.4, "#1A3A20", radius=0.3, lw=1.5, edgecolor=C_GREEN)
txt(8.8,  7.75, "FACT_ORDERS", size=9, bold=True, color=C_GREEN)
txt(8.8,  7.48, "Order Count | Payment", size=7.5, color=C_SILVER)
txt(8.8,  7.22, "Delivery Days", size=7.5, color=C_SILVER)

# FACT_PRODUCTION
box(11.3, 6.8, 3.1, 1.4, "#1A3A20", radius=0.3, lw=1.5, edgecolor=C_GREEN)
txt(12.85, 7.75, "FACT_PRODUCTION", size=9, bold=True, color=C_GREEN)
txt(12.85, 7.48, "Planned vs Actual Qty", size=7.5, color=C_SILVER)
txt(12.85, 7.22, "Production Cost", size=7.5, color=C_SILVER)

# FACT_DEFECTS
box(9.2,  4.9, 3.3, 1.4, "#1A3A20", radius=0.3, lw=1.5, edgecolor=C_GREEN)
txt(10.85, 5.85, "FACT_DEFECTS", size=9, bold=True, color=C_GREEN)
txt(10.85, 5.58, "Defect Qty | Defect Rate", size=7.5, color=C_SILVER)
txt(10.85, 5.32, "FK: Machine | Production", size=7, color=C_GREEN)

# DIM boxes
dims = [
    (7.3,  10.3, "DIM_CUSTOMER", "City | State | Region"),
    (12.1, 10.3, "DIM_PRODUCT",  "Category | Translation"),
    (7.3,  4.9,  "DIM_SELLER",   "Location | City"),
    (12.1, 4.9,  "DIM_MACHINE",  "Type | Plant | Status"),
    (9.2,  3.1,  "DIM_LOCATION", "Geographic Hierarchy"),
]
for dx, dy, dname, ddesc in dims:
    box(dx, dy, 2.7, 0.95, "#1E2A50", radius=0.3, lw=1.5, edgecolor=C_BLUE)
    txt(dx+1.35, dy+0.62, dname, size=8.5, bold=True, color=C_BLUE)
    txt(dx+1.35, dy+0.28, ddesc, size=7,   color=C_SILVER)

# connector arrows (dim → fact)
arrow(10.85, 11.2,  10.85, 10.4,  color=C_GOLD, lw=1.5)   # date→sales
arrow(8.65,  11.25, 8.65,  11.25, color=C_BLUE, lw=1)
arrow(8.65,  10.3+0.95, 9.2+0.5,  9.8+0.6, color=C_BLUE, lw=1)   # customer→sales
arrow(12.85, 10.3+0.95, 12.85, 9.8+0.6, color=C_BLUE, lw=1)   # product→sales
arrow(10.85, 8.8,  10.85, 8.2,  color=C_GREEN, lw=1)   # sales→orders
arrow(10.85, 6.8,  10.85, 6.3,  color=C_GREEN, lw=1)   # orders→prod
arrow(12.85, 6.8,  11.85, 6.3,  color=C_GREEN, lw=1)
arrow(10.85, 4.9,  10.85, 4.05, color=C_GREEN, lw=1)   # defects→location
arrow(8.65,  4.9+0.95, 9.5, 6.3, color=C_BLUE, lw=1)   # seller
arrow(12.85, 4.9+0.95, 12.5, 6.3, color=C_BLUE, lw=1)  # machine

# ══════════════════════════════════════════════════════════════
# RIGHT COLUMN — AI LAYER + APP
# ══════════════════════════════════════════════════════════════
box(14.9, 0.3, 6.8, 12.7, C_LGREY, radius=0.4)
txt(18.3, 12.72, "AI LAYER  +  APP", size=10, bold=True, color=C_TEAL)

# Cortex Analyst
box(15.2, 11.0, 6.2, 1.5, C_CARD, radius=0.3, lw=1.5, edgecolor=C_BLUE)
box(15.2, 11.0, 6.2, 0.38, C_BLUE, radius=0.3)
txt(18.3, 11.19, "CORTEX ANALYST", size=9, bold=True, color=C_WHITE)
txt(18.3, 11.65, "Natural Language to SQL", size=8.5, color=C_BLUE, bold=True)
txt(18.3, 11.38, '"What were top products last quarter?"', size=7.5, color=C_SILVER)

# Cortex Search
box(15.2, 9.2, 6.2, 1.5, C_CARD, radius=0.3, lw=1.5, edgecolor=C_TEAL)
box(15.2, 9.2, 6.2, 0.38, C_TEAL, radius=0.3)
txt(18.3, 9.39, "CORTEX SEARCH", size=9, bold=True, color=C_WHITE)
txt(18.3, 9.85, "Semantic Insight Discovery", size=8.5, color=C_TEAL, bold=True)
txt(18.3, 9.58, '"Find reports about sales decline"', size=7.5, color=C_SILVER)

# Cortex ML
box(15.2, 7.4, 6.2, 1.5, C_CARD, radius=0.3, lw=1.5, edgecolor=C_ORANGE)
box(15.2, 7.4, 6.2, 0.38, C_ORANGE, radius=0.3)
txt(18.3, 7.59, "CORTEX ML FUNCTIONS", size=9, bold=True, color=C_WHITE)
txt(18.3, 8.05, "Forecasting  +  Anomaly Detection", size=8.5, color=C_ORANGE, bold=True)
txt(18.3, 7.78, "Predict demand | Detect anomalies", size=7.5, color=C_SILVER)

# arrows into agent
arrow(18.3, 7.4,  18.3, 7.05, color=C_ORANGE, lw=1.5)
arrow(18.3, 9.2,  18.3, 7.05, color=C_TEAL,   lw=1.5)
arrow(18.3, 11.0, 18.3, 7.05, color=C_BLUE,   lw=1.5)

# Snowflake Agent
box(15.2, 5.6, 6.2, 1.4, "#2A1A50", radius=0.3, lw=2, edgecolor=C_PURPLE)
box(15.2, 5.6, 6.2, 0.38, C_PURPLE, radius=0.3)
txt(18.3, 5.79, "SNOWFLAKE AGENT", size=9, bold=True, color=C_WHITE)
txt(18.3, 6.22, "AI Orchestrator", size=8.5, color=C_PURPLE, bold=True)
txt(18.3, 5.98, "Routes questions to the right AI tool", size=7.5, color=C_SILVER)

arrow(18.3, 5.6, 18.3, 5.2, color=C_PURPLE, lw=2)

# Streamlit App
box(15.2, 3.8, 6.2, 1.4, "#001A1A", radius=0.3, lw=2, edgecolor=C_TEAL)
box(15.2, 3.8, 6.2, 0.38, C_TEAL, radius=0.3)
txt(18.3, 3.99, "STREAMLIT APP", size=9, bold=True, color=C_WHITE)
txt(18.3, 4.42, "Business User Interface", size=8.5, color=C_TEAL, bold=True)
txt(18.3, 4.16, "Ask anything  |  Get answers + charts", size=7.5, color=C_SILVER)

# User box
box(15.8, 2.3, 5.0, 1.1, C_CARD, radius=0.3, lw=1, edgecolor=C_WHITE)
txt(18.3, 2.62, "BUSINESS USER", size=9, bold=True, color=C_WHITE)
txt(18.3, 2.38, "No SQL needed  |  Plain English questions", size=7.5, color=C_SILVER)

arrow(18.3, 3.8, 18.3, 3.4, color=C_TEAL, lw=2)

# ══════════════════════════════════════════════════════════════
# CROSS ARROWS — Gold → AI
# ══════════════════════════════════════════════════════════════
# Gold layer feeds AI
ax.annotate("", xy=(15.2, 11.75), xytext=(6.5, 7.2),
            arrowprops=dict(arrowstyle="-|>", color=C_GOLD,
                            lw=1.5, mutation_scale=12,
                            connectionstyle="arc3,rad=-0.15"),
            zorder=4)
txt(11.0, 8.1, "Gold feeds AI", size=7, color=C_GOLD, bold=False)

# ══════════════════════════════════════════════════════════════
# BOTTOM LEGEND
# ══════════════════════════════════════════════════════════════
box(0.3, 0.3, 21.4, 0.6, "#0A1520", radius=0.2)
legend = [
    (0.7,  C_BRONZE,  "Bronze — Raw"),
    (3.2,  C_SILVER,  "Silver — Cleaned"),
    (6.1,  C_GOLD,    "Gold — Dimensional"),
    (9.2,  C_GREEN,   "Fact Tables"),
    (11.7, C_BLUE,    "Dimension Tables"),
    (14.2, C_BLUE,    "Cortex Analyst"),
    (16.4, C_TEAL,    "Cortex Search"),
    (18.4, C_ORANGE,  "Cortex ML"),
    (20.2, C_PURPLE,  "Agent"),
]
for lx, lc, lbl in legend:
    box(lx, 0.44, 0.22, 0.22, lc, radius=0.05)
    txt(lx+0.55, 0.55, lbl, size=7, color=C_SILVER, ha="left")

# ══════════════════════════════════════════════════════════════
# SAVE
# ══════════════════════════════════════════════════════════════
plt.tight_layout(pad=0)
fig.savefig(str(OUT_PNG), dpi=150, bbox_inches="tight", facecolor=C_BG)
fig.savefig(str(OUT_PDF), bbox_inches="tight", facecolor=C_BG)
print(f"Saved PNG: {OUT_PNG}")
print(f"Saved PDF: {OUT_PDF}")
plt.close()
