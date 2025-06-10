import mysql.connector
import json
import time
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

with open("./SqlRewriter/config.json") as f:
    config = json.load(f)

def execute_query(query: str):
    """
    Executes a SQL query and returns the execution time and results.

    Args:
        query (str): The SQL query to execute.

    Returns:
        tuple: A tuple containing the execution time (in seconds) and the query results (list).
    """
    try:
        # Create a new connection for each query
        conn = mysql.connector.connect(
            host=config["host"],
            user=config["user"],
            password=config["password"],
            database="my_database"
        )
        cursor = conn.cursor()

        # Start the timer
        start_time = time.time()

        # Execute the query
        cursor.execute(query)

        # Fetch all results to ensure the cursor is cleared
        results = cursor.fetchall()

        # Stop the timer
        end_time = time.time()

        # Calculate execution time
        execution_time = end_time - start_time

        # Close the cursor and connection
        cursor.close()
        conn.close()

        return execution_time, results
    except mysql.connector.Error as err:
        print(f"Error: {err}")
        return None, None

def time_queries(queries_dir: str):
    """
    Executes all SQL queries in the benchmark/queries directory, measures their execution time,
    and saves the results (execution time and query results) to a JSON file.
    """
    results = {}

    # Iterate over all .sql files in the directory
    for filename in os.listdir(queries_dir):
        if filename.endswith(".sql"):
            print(f"Processing {filename}...")
            file_path = os.path.join(queries_dir, filename)
            sql_query = load_sql_file(file_path)

            # Execute the query and measure execution time
            execution_time, query_result = execute_query(sql_query)

            # Save the result
            if execution_time is not None:
                results[filename] = {
                    "execution_time": execution_time,
                    "query_result": query_result
                }
                print(f"Executed {filename} in {execution_time:.4f} seconds")
            else:
                results[filename] = {
                    "execution_time": "Error",
                    "query_result": "Error"
                }
                print(f"Error executing {filename}")

    # Save results to a JSON file
    output_file = os.path.join(queries_dir, "query_execution_results.json")
    with open(output_file, "w") as json_file:
        json.dump(results, json_file, indent=4, default=str)  # Use `default=str` to handle non-serializable objects

    print(f"Execution results saved to {output_file}")



# cursor.execute("SELECT * FROM call_center LIMIT 5;")

# # Fetch and print results
# for row in cursor.fetchall():
#     print(row)


# cursor.close()
# conn.close()

if __name__ == "__main__":
    time_queries("benchmark/original_queries")
    time_queries("benchmark/in_context_learning_queries")
    time_queries("benchmark/static_rule_queries")
    time_queries("benchmark/teacher_student_queries")