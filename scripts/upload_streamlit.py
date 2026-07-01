import snowflake.connector

conn = snowflake.connector.connect(connection_name='MX60297')
cur = conn.cursor()

put_sql = (
    "PUT file://C:/Users/MayureshPrakashBadgu/learning/snowflake/learncoco/streamlit/streamlit_app.py"
    " @DB_DEMO_MAYURESH.APP_CORTEX.STGINT_STREAMLIT"
    " AUTO_COMPRESS=FALSE OVERWRITE=TRUE"
)

rows = cur.execute(put_sql).fetchall()
for row in rows:
    print(row)

cur.close()
conn.close()
