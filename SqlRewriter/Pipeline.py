import mysql.connector
from LLMClient import GeminiClient
import json
import os

def load_sql_file(file_path: str) -> str:
    """
    Reads the contents of a .sql file and returns it as a string.

    Args:
        file_path (str): The path to the .sql file.

    Returns:
        str: The SQL query as a string.
    """
    with open(file_path, 'r') as file:
        sql_query = file.read()
    return sql_query

def save_sql_file(file_path: str, sql_query: str):
    """
    Saves the rewritten SQL query to a file.

    Args:
        file_path (str): The path to save the .sql file.
        sql_query (str): The SQL query to save.
    """
    with open(file_path, 'w') as file:
        file.write(sql_query)

# sql_file_path = "benchmark/queries/query1.sql"  # Replace with your file path
# sql_query_str = load_sql_file(sql_file_path)
# print(sql_query_str)
# print(f"type of sql_query_str: {type(sql_query_str)}")


with open("./SqlRewriter/config.json") as f:
    config = json.load(f)

conn = mysql.connector.connect(
    host=config["host"],
    user=config["user"],
    password=config["password"],
    database="my_database"
)

cursor = conn.cursor()

def perform_teacher_student_query_rewrite(sql_query: str) -> str:
    """
    Performs teacher-student query rewriting using the GeminiClient.

    Args:
        sql_query (str): The SQL query to be rewritten.
        conn (mysql.connector.connection.MySQLConnection): The database connection.

    Returns:
        str: The rewritten SQL query.
    """
    client = GeminiClient()
    rewritten_query = client.teacher_student_learning(sql_query)
    return rewritten_query


def all_query_rewrite_ts():
    queries_dir = "benchmark/original_queries"
    new_dir = "benchmark/teacher_student_queries"

    # Ensure the new directory exists
    os.makedirs(new_dir, exist_ok=True)

    # Iterate over all .sql files in the directory
    for filename in os.listdir(queries_dir):
        if filename.endswith(".sql"):
            file_path = os.path.join(queries_dir, filename)

            # Check if the rewritten file already exists
            new_filename = f"{os.path.splitext(filename)[0]}.sql"
            new_file_path = os.path.join(new_dir, new_filename)
            if os.path.exists(new_file_path):
                print(f"Skipping {filename}, already processed.")
                continue

            # Load the SQL query
            sql_query = load_sql_file(file_path)

            # Perform teacher-student query rewrite
            rewritten_query = perform_teacher_student_query_rewrite(sql_query)

            # Save the rewritten query
            save_sql_file(new_file_path, rewritten_query)
            print(f"Rewritten query saved to {new_file_path}")

def all_query_rewrite_static():
    queries_dir = "benchmark/original_queries"
    new_dir = "benchmark/static_rule_queries"

    # Ensure the new directory exists
    os.makedirs(new_dir, exist_ok=True)

    # Iterate over all .sql files in the directory
    for filename in os.listdir(queries_dir):
        if filename.endswith(".sql"):
            file_path = os.path.join(queries_dir, filename)

            # Check if the rewritten file already exists
            new_filename = f"{os.path.splitext(filename)[0]}.sql"
            new_file_path = os.path.join(new_dir, new_filename)
            if os.path.exists(new_file_path):
                print(f"Skipping {filename}, already processed.")
                continue

            # Load the SQL query
            sql_query = load_sql_file(file_path)

            # Perform teacher-student query rewrite
            client = GeminiClient()
            rewritten_query = client.static_rule(sql_query)
            # Save the rewritten query
            save_sql_file(new_file_path, rewritten_query.text)
            print(f"Rewritten query saved to {new_file_path}")

def all_query_rewrite_in_context_learning():
    queries_dir = "benchmark/original_queries"
    new_dir = "benchmark/in_context_learning_queries"

    # Ensure the new directory exists
    os.makedirs(new_dir, exist_ok=True)

    # Iterate over all .sql files in the directory
    for filename in os.listdir(queries_dir):
        if filename.endswith(".sql"):
            file_path = os.path.join(queries_dir, filename)

            # Check if the rewritten file already exists
            new_filename = f"{os.path.splitext(filename)[0]}.sql"
            new_file_path = os.path.join(new_dir, new_filename)
            if os.path.exists(new_file_path):
                print(f"Skipping {filename}, already processed.")
                continue

            # Load the SQL query
            sql_query = load_sql_file(file_path)

            # Perform teacher-student query rewrite
            client = GeminiClient()
            rewritten_query = client.static_rule(sql_query)
            # Save the rewritten query
            save_sql_file(new_file_path, rewritten_query.text)
            print(f"Rewritten query saved to {new_file_path}")

# # Fetch and print results
# for row in cursor.fetchall():
#     print(row)


# cursor.close()
# conn.close()

if __name__ == "__main__":
    all_query_rewrite_ts()
    all_query_rewrite_static()
    all_query_rewrite_in_context_learning()