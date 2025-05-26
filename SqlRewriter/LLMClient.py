
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
select  *
from
 (select count(*) h8_30_to_9
 from store_sales, household_demographics , time_dim, store
 where ss_sold_time_sk = time_dim.t_time_sk   
     and ss_hdemo_sk = household_demographics.hd_demo_sk 
     and ss_store_sk = s_store_sk
     and time_dim.t_hour = 8
     and time_dim.t_minute >= 30
     and ((household_demographics.hd_dep_count = 2 and household_demographics.hd_vehicle_count<=2+2) or
          (household_demographics.hd_dep_count = 1 and household_demographics.hd_vehicle_count<=1+2) or
          (household_demographics.hd_dep_count = 4 and household_demographics.hd_vehicle_count<=4+2)) 
     and store.s_store_name = 'ese') s1,
 (select count(*) h9_to_9_30 
 from store_sales, household_demographics , time_dim, store
 where ss_sold_time_sk = time_dim.t_time_sk
     and ss_hdemo_sk = household_demographics.hd_demo_sk
     and ss_store_sk = s_store_sk 
     and time_dim.t_hour = 9 
     and time_dim.t_minute < 30
     and ((household_demographics.hd_dep_count = 2 and household_demographics.hd_vehicle_count<=2+2) or
          (household_demographics.hd_dep_count = 1 and household_demographics.hd_vehicle_count<=1+2) or
          (household_demographics.hd_dep_count = 4 and household_demographics.hd_vehicle_count<=4+2))
     and store.s_store_name = 'ese') s2,
 (select count(*) h9_30_to_10 
 from store_sales, household_demographics , time_dim, store
 where ss_sold_time_sk = time_dim.t_time_sk
     and ss_hdemo_sk = household_demographics.hd_demo_sk
     and ss_store_sk = s_store_sk
     and time_dim.t_hour = 9
     and time_dim.t_minute >= 30
     and ((household_demographics.hd_dep_count = 2 and household_demographics.hd_vehicle_count<=2+2) or
          (household_demographics.hd_dep_count = 1 and household_demographics.hd_vehicle_count<=1+2) or
          (household_demographics.hd_dep_count = 4 and household_demographics.hd_vehicle_count<=4+2))
     and store.s_store_name = 'ese') s3,
 (select count(*) h10_to_10_30
 from store_sales, household_demographics , time_dim, store
 where ss_sold_time_sk = time_dim.t_time_sk
     and ss_hdemo_sk = household_demographics.hd_demo_sk
     and ss_store_sk = s_store_sk
     and time_dim.t_hour = 10 
     and time_dim.t_minute < 30
     and ((household_demographics.hd_dep_count = 2 and household_demographics.hd_vehicle_count<=2+2) or
          (household_demographics.hd_dep_count = 1 and household_demographics.hd_vehicle_count<=1+2) or
          (household_demographics.hd_dep_count = 4 and household_demographics.hd_vehicle_count<=4+2))
     and store.s_store_name = 'ese') s4,
 (select count(*) h10_30_to_11
 from store_sales, household_demographics , time_dim, store
 where ss_sold_time_sk = time_dim.t_time_sk
     and ss_hdemo_sk = household_demographics.hd_demo_sk
     and ss_store_sk = s_store_sk
     and time_dim.t_hour = 10 
     and time_dim.t_minute >= 30
     and ((household_demographics.hd_dep_count = 2 and household_demographics.hd_vehicle_count<=2+2) or
          (household_demographics.hd_dep_count = 1 and household_demographics.hd_vehicle_count<=1+2) or
          (household_demographics.hd_dep_count = 4 and household_demographics.hd_vehicle_count<=4+2))
     and store.s_store_name = 'ese') s5,
 (select count(*) h11_to_11_30
 from store_sales, household_demographics , time_dim, store
 where ss_sold_time_sk = time_dim.t_time_sk
     and ss_hdemo_sk = household_demographics.hd_demo_sk
     and ss_store_sk = s_store_sk 
     and time_dim.t_hour = 11
     and time_dim.t_minute < 30
     and ((household_demographics.hd_dep_count = 2 and household_demographics.hd_vehicle_count<=2+2) or
          (household_demographics.hd_dep_count = 1 and household_demographics.hd_vehicle_count<=1+2) or
          (household_demographics.hd_dep_count = 4 and household_demographics.hd_vehicle_count<=4+2))
     and store.s_store_name = 'ese') s6,
 (select count(*) h11_30_to_12
 from store_sales, household_demographics , time_dim, store
 where ss_sold_time_sk = time_dim.t_time_sk
     and ss_hdemo_sk = household_demographics.hd_demo_sk
     and ss_store_sk = s_store_sk
     and time_dim.t_hour = 11
     and time_dim.t_minute >= 30
     and ((household_demographics.hd_dep_count = 2 and household_demographics.hd_vehicle_count<=2+2) or
          (household_demographics.hd_dep_count = 1 and household_demographics.hd_vehicle_count<=1+2) or
          (household_demographics.hd_dep_count = 4 and household_demographics.hd_vehicle_count<=4+2))
     and store.s_store_name = 'ese') s7,
 (select count(*) h12_to_12_30
 from store_sales, household_demographics , time_dim, store
 where ss_sold_time_sk = time_dim.t_time_sk
     and ss_hdemo_sk = household_demographics.hd_demo_sk
     and ss_store_sk = s_store_sk
     and time_dim.t_hour = 12
     and time_dim.t_minute < 30
     and ((household_demographics.hd_dep_count = 2 and household_demographics.hd_vehicle_count<=2+2) or
          (household_demographics.hd_dep_count = 1 and household_demographics.hd_vehicle_count<=1+2) or
          (household_demographics.hd_dep_count = 4 and household_demographics.hd_vehicle_count<=4+2))
     and store.s_store_name = 'ese') s8
;
"""

class GeminiClient:
    def __init__(self, api_key):
        self.client = genai.Client(api_key=api_key)
        self.model = "gemini-2.0-flash"

    def generate_query(self, sql_query: str, k: int = 5) -> types.GenerateContentResponse:
        # Construct the prompt as a simple string.
        prompt = (
            "Rewrite this SQL query to be more efficient and readable. "
            "Keep the logic identical.\n\n"
            f"{sql_query}\n\n"
            "Return only the rewritten SQL."
        )
        return self.client.models.generate_content(
            model=self.model,
            config=types.GenerateContentConfig(
                system_instruction=(
                    "You are a world-class database query optimizer. "
                    "Your job is to rewrite SQL queries to make them more efficient and readable, "
                    "without changing their meaning or logic. Do not explain. "
                    "Return ONLY the improved SQL query with no extra text or formatting."
                ),
                temperature=0.2,
                # max_output_tokens=1000,
            ),
            contents=[prompt],
            # candidateCount=k,
        )

    def teacher_model(self, sql_query: str) -> types.GenerateContentResponse:
        # This method is not used in the current implementation.
        result = self.client.models.generate_content(
            model=self.model,
            config=types.GenerateContentConfig(
                system_instruction=(
                    "You are a world-class database query optimizer teacher."
                    "Please provide a detailed explanation of how to improve the SQL query, "
                    "including the reasoning behind each change. "
                    "Return the explanation in a clear and structured format."
                ),
                temperature=0.2,
            ),
            contents=[sql_query],
        )
        return result
    
    def student_model(self, sql_query: str, suggestion: str) -> types.GenerateContentResponse:
        return self.client.models.generate_content(
            model=self.model,
            config=types.GenerateContentConfig(
                system_instruction=(
                    "You are a world-class database query optimizer student."
                    "Please provide a concise and clear explanation of how to improve the SQL query, "
                    "focusing on the key changes made. "
                    "Return only the optimized SQL query with no extra text or formatting."
                ),
                temperature=0.2,
            ),
            contents=[sql_query],
        )
    
    def pseudo_sql_optimization(self, sql_query: str) -> types.GenerateContentResponse:
        return self.client.models.generate_content(
            model=self.model,
            config=types.GenerateContentConfig(
                system_instruction=(
                    "generate a pseudo SQL query that optimizes the given SQL query. "
                    "The pseudo SQL should be a high-level representation of the query, "
                    "focusing on the logical structure and optimization strategies, "
                ),
                temperature=0.2,
            ),
            contents=[sql_query],
        )
    
    def static_rule(self, sql_query: str) -> types.GenerateContentResponse:
        return self.client.models.generate_content(
            model=self.model,
            config=types.GenerateContentConfig(
                system_instruction=(
                    "You are a world-class database query optimizer. "
                    "Your job is to apply static rules to optimize the SQL query. "
                    "Proper Indexing - Index frequently queried columns, Avoid using unnecessary indexes."
                    "Avoid SELECT * if possible."
                    "Use Joins Efficiently - Order joins logically, Use indexes on join columns, Consider using subqueries to simplify/ "
                    "Use EXISTS Instead of IN for Subqueries - EXISTS is generally more efficient. "
                    "Return only the optimized SQL query with no extra text or formatting."
                ),
                temperature=0.2,
            ),
            contents=[sql_query],
        )
    
    def teacher_student_learning(self, sql_query: str, K: int) -> str:
        sql_query_temp = sql_query
        for i in range(K):
            print(f"Iteration {i+1}/{K}")
            teacher_response = self.teacher_model(sql_query_temp)
            student_response = self.student_model(sql_query_temp, teacher_response.text)
            sql_query_temp = student_response
            print
        return sql_query_temp
    
if __name__ == '__main__':
    client = GeminiClient(gemini_api_key)
    response = client.teacher_student_learning(sql, K=3)
    print(response.text)
    # print(response.candidates[0].text)  # Print the first candidate's text