
import os
import sqlite3
import pandas as pd

from google import genai
from google.genai import types



# Step 1: Load CSV into DataFrame
# df = pd.read_csv("SqlRewriter/text.csv")
# conn = sqlite3.connect(":memory:")
# df.to_sql("orders", conn, index=False, if_exists="replace")


class GeminiClient:
    def __init__(self):
        gemini_api_key = os.environ.get("GEMINI_API_KEY_DB")
        self.client = genai.Client(api_key=gemini_api_key)
        self.model = "gemini-2.0-flash"

    def teacher_student_learning(self, sql_query: str) -> str:
        """
        Generates a response using a teacher-student learning approach.
        The teacher model provides an explanation of how to optimize the SQL query,
        and the student model applies the suggestion to generate an optimized query.
        
        Args:
            sql_query (str): The original SQL query to be optimized.
        
        Returns:
            types.GenerateContentResponse: The response containing the optimized SQL query.
        """
        # Step 1: Teacher model generates an explanation
        teacher_response = self.teacher_model(sql_query)
        suggestion = teacher_response.text.strip()

        # Step 2: Student model applies the suggestion
        student_response = self.student_model(sql_query, suggestion)

        return student_response.text
    
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
                    "Return ONLY SQL query with no extra text or formatting."
                ),
                temperature=0.2,
                # max_output_tokens=1000,
            ),
            contents=[prompt],
            # candidateCount=k,
        )

    def teacher_model(self, sql_query: str) -> types.GenerateContentResponse:
        result = self.client.models.generate_content(
            model=self.model,
            config=types.GenerateContentConfig(
                system_instruction=(
                    "You are a world-class database query optimization teacher."
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
                    "You are a world-class database query optimization student."
                    f"Please apply the following suggestion to the SQL query: {suggestion}. "
                    "Return only the optimized SQL query with no extra text or formatting."
                    "Dont not add quotation marks or any other characters around the SQL query."
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
    
    # https://dev.mysql.com/doc/refman/8.4/en/where-optimization.html
    def in_context_learning(self, sql_query: str) -> str:
        # Define a few examples of SQL queries and their optimized versions
        examples = [
            {   "instruction": "Removal of unnecessary parentheses",
                "input": "((a AND b) AND c OR (((a AND b) AND (c AND d))))",
                "optimized": "(a AND b AND c) OR (a AND b AND c AND d)"
            },
            {   "instruction": "Constant folding",
                "input": "(a<b AND b=c) AND a=5",
                "optimized": "b>5 AND b=c AND a=5"
            },
            {   "instruction": "Constant condition removal",
                "input": "(b>=5 AND b=5) OR (b=6 AND 5=5) OR (b=7 AND 5=6)",
                "optimized": "(a AND b AND c) OR (a AND b AND c AND d)"
            },
            {   "instruction": "Remove nonkey = 4 and key1 LIKE 'b' because they cannot be used for a range scan. The correct way to remove them is to replace them with TRUE, so that we do not miss any matching rows when doing the range scan. Replacing them with TRUE yields:",
                "input": """(key1 < 'abc' AND (key1 LIKE 'abcde%' OR key1 LIKE '%b')) OR
(key1 < 'bar' AND nonkey = 4) OR
(key1 < 'uux' AND key1 > 'z')""",
                "optimized": """(key1 < 'abc' AND (key1 LIKE 'abcde%' OR TRUE)) OR
(key1 < 'bar' AND TRUE) OR
(key1 < 'uux' AND key1 > 'z')""",
            },
            {   "instruction": """Collapse conditions that are always true or false:
(key1 LIKE 'abcde%' OR TRUE) is always true
(key1 < 'uux' AND key1 > 'z') is always false
             """,
                "input": """((key1 < 'abc' AND (key1 LIKE 'abcde%' OR TRUE)) OR
(key1 < 'bar' AND TRUE) OR
(key1 < 'uux' AND key1 > 'z')""",
                "optimized": """((key1 < 'abc' AND TRUE) OR (key1 < 'bar' AND TRUE) OR (FALSE)""",
            },
            {   "instruction": """Removing unnecessary TRUE and FALSE constants yields:
             """,
                "input": """(key1 < 'abc' AND TRUE) OR (key1 < 'bar' AND TRUE) OR (FALSE)""",
                "optimized": """(key1 < 'abc') OR (key1 < 'bar')""",
            },
            {   "instruction": """If your query has a complex WHERE clause with deep AND/OR nesting and MySQL does not choose the optimal plan, try distributing terms using the following identity transformations:
             """,
                "input": """(x AND y) OR z""",
                "optimized": """(x OR z) AND (y OR z)""",
            },
            {   "instruction": """For a LEFT JOIN, if the WHERE condition is always false for the generated NULL row, the LEFT JOIN is changed to an inner join. For example, the WHERE clause would be false in the following query if t2.column1 were NULL:
             Therefore, it is safe to convert the query to an inner join:
             """,
                "input": """SELECT * FROM t1 LEFT JOIN t2 ON (column1) WHERE t2.column2=5;""",
                "optimized": """SELECT * FROM t1 JOIN t2 WHERE condition_1 AND condition_2""",
            },
            {   "instruction": """In most cases, a DISTINCT clause can be considered as a special case of GROUP BY. For example, the following two queries are equivalent:
When combining LIMIT row_count with DISTINCT, MySQL stops as soon as it finds row_count unique rows.
If you do not use columns from all tables named in a query, MySQL stops scanning any unused tables as soon as it finds the first match. In the following case, assuming that t1 is used before t2 (which you can check with EXPLAIN), MySQL stops reading from t2 (for any particular row in t1) when it finds the first row in t2:
             """,
                "input": """SELECT DISTINCT c1, c2, c3 FROM t1
WHERE c1 > const;

SELECT c1, c2, c3 FROM t1
WHERE c1 > const GROUP BY c1, c2, c3;""",
                "optimized": """SELECT DISTINCT t1.a FROM t1, t2 where t1.a=t2.a;""",
            },
        ]

        # Construct the prompt with examples and the new query
        prompt = "Here are some examples of SQL query optimization:\n\n"
        for example in examples:
            prompt += f"Optimization:\n{example['instruction']}\nOriginal Query:\n{example['input']}\nOptimized Query:\n{example['optimized']}\n\n"
            prompt += f"Now optimize the following query:\n{sql_query}\nReturn only the optimized SQL query with no extra text or formatting."
            prompt += f"Please make sure the optimized query is logically equivalent to the original query.\n\n"

        # Use the model to generate the optimized query
        response = self.client.models.generate_content(
            model=self.model,
            config=types.GenerateContentConfig(
                system_instruction="You are a world-class database query rewriter who can optimize mysql query.",
                temperature=0.2,
            ),
            contents=[prompt],
        )

        return response

        
# if __name__ == '__main__':
    # client = GeminiClient()
    # response = client.teacher_student_learning(sql, K=3)
    # response = client.generate_query(sql)
    # print(response.text)
    # cur = conn.cursor()
    # # execute from /Users/desmondcheong/Library/CloudStorage/GoogleDrive-dczy@cmlab.csie.ntu.edu.tw/My Drive/NTU/113-2/Database/final project/tpcds_data_dump.sql
    # cur.execute(response.text)
    # print(response.candidates[0].text)  # Print the first candidate's text