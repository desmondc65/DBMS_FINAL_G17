
import os
import sqlite3
import pandas as pd

from google import genai
from google.genai import types

gemini_api_key = os.environ.get("GEMINI_API_KEY")

client = genai.Client(api_key=gemini_api_key)

# Step 1: Load CSV into DataFrame
df = pd.read_csv("SqlRewriter/text.csv")
conn = sqlite3.connect(":memory:")
df.to_sql("orders", conn, index=False, if_exists="replace")

sql = """
SELECT o.customer_id,
       COUNT(*) AS order_count,
       SUM(o.total_amount) AS total_spent
FROM orders o
WHERE o.status = 'completed'
  AND o.customer_id IN (
    SELECT customer_id
    FROM orders
    WHERE region = 'US'
    GROUP BY customer_id
    HAVING SUM(total_amount) > 500
)
GROUP BY o.customer_id
ORDER BY total_spent DESC
LIMIT 5;
"""

class GeminiClient:
    def __init__(self, api_key):
        self.client = genai.Client(api_key=api_key)
        self.model="gemini-2.0-flash"

    def generate_query(self, sql_query: str):
        return self.client.models.generate_content(
            model="gemini-2.0-flash",
            config=types.GenerateContentConfig(
                system_instruction="You are a SQL rewriter expert. Rewrite the SQL query to be more efficient and readable.\
                    please only return the SQL query without any additional text.",
                temperature=0.2,
                # max_output_tokens=1000,
                ),
            contents=sql_query,
        )

if __name__ == '__main__':
    client = GeminiClient(gemini_api_key)
    response = client.generate_query(sql_query=sql)
    print(response.text)