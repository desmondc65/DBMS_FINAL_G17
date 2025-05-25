import re 
import random 
import json 
import mysql.connector 

# ========== Get Connector ========== #
def get_connection(config_file: str='config.json') -> mysql.connector.connection.MySQLConnection:
    """
    Establishes a connection to the MySQL database.

    Returns:
        mysql.connector.connection.MySQLConnection: A connection object to the MySQL database.
    """
    with open(config_file) as f:
        config = json.load(f)

    # Connect without specifying the database
    conn = mysql.connector.connect(
        host=config['host'],
        user=config['user'],
        passwd=config['passwd']
    )
    cursor = conn.cursor()

    # Drop and recreate the database
    cursor.execute("SET FOREIGN_KEY_CHECKS = 0;")  # Disable foreign key checks
    cursor.execute("DROP DATABASE IF EXISTS tpcsds;")
    cursor.execute("CREATE DATABASE tpcsds;")
    cursor.execute("USE tpcsds;")
    print("Database 'tpcsds' recreated successfully.")

    # # Check if the database exists, and create it if it doesn't
    # cursor.execute("SHOW DATABASES;")
    # databases = [db[0] for db in cursor.fetchall()]
    # if "tpcsds" not in databases:
    #     cursor.execute("CREATE DATABASE tpcsds;")
    #     print("Database 'tpcsds' created successfully.")

    # Close the temporary connection and reconnect with the database
    cursor.close()
    conn.close()

    # Reconnect with the database specified
    return mysql.connector.connect(
        host=config['host'],
        user=config['user'],
        passwd=config['passwd'],
        database="tpcsds"
    )


# ========== Create Tables for Schema ========== #
def create_tables(conn, schema_dict):
    """
    Creates tables in the database based on the provided schema.

    Args:
        conn (mysql.connector.connection.MySQLConnection): The database connection.
        schema_dict (dict): A dictionary mapping table names to their schemas.

    Returns:
        None
    """
    cursor = conn.cursor()
    for table, schema in schema_dict.items():
        # Filter out primary key entries and get regular columns
        regular_columns = [
            (col, dtype) for col, dtype in schema 
            if dtype.upper() != "KEY"
        ]

        # Get primary key columns
        primary_keys = [
            col for col, dtype in schema 
            if dtype.upper() == "KEY"
        ]

        # Create column definitions
        column_defs = []
        for col, dtype in regular_columns:
            # Handle different data types
            if dtype == "DECIMAL":
                column_defs.append(f"{col} DECIMAL(10,2)")
            elif dtype == "VARCHAR":
                column_defs.append(f"{col} VARCHAR(255)")
            else:
                column_defs.append(f"{col} {dtype}")

        # Add primary key constraint if exists
        if primary_keys:
            column_defs.append(f"PRIMARY KEY ({', '.join(primary_keys)})")

        # Create the table
        sql = f"CREATE TABLE IF NOT EXISTS {table} ({', '.join(column_defs)});"
        
        try:
            print(f"Executing SQL: {sql}")  # Debug print
            cursor.execute(sql)
            print(f"Table '{table}' created or already exists.")
        except mysql.connector.Error as err:
            print(f"Error creating table '{table}': {err}")
            continue

    conn.commit()
    cursor.close()


# ========== Execute Query ========== #
def execute_query(cursor, query):
    """
    Executes a SQL query using the provided cursor.

    Args:
        cursor (mysql.connector.cursor.MySQLCursor): The cursor to execute the query.
        query (str): The SQL query to execute.

    Returns:
        list: The result of the query as a list of tuples.
    """
    try:
        cursor.execute(query)
        results = cursor.fetchall()
        cursor.close()  # Close cursor after fetching results
        return sorted(results) if results else []
    except mysql.connector.Error as err:
        print(f"Error executing query: {err}")
        print(f"Query: {query}")
        return []

# ========== Generate Data ========== #
def generate_data(
        cursor: mysql.connector.cursor.MySQLCursor, 
        table: str, 
        schema: list[tuple[str, str]], 
        num_rows: int = 5) -> None:
    """
    Generates and inserts data into a specified table.

    Args:
        cursor (mysql.connector.cursor.MySQLCursor): The cursor to execute the SQL queries.
        table (str): The name of the table to insert data into.
        schema (list[tuple[str, str]]): A list of tuples where each tuple contains the column name and its data type.
        num_rows (int, optional): The number of rows to generate. Defaults to 5.

    Returns:
        None
    """
    # Filter out KEY entries and get column names
    columns = [col for col, dtype in schema if dtype.upper() != 'KEY']
    regular_columns = [(col, dtype) for col, dtype in schema if dtype.upper() != 'KEY']
    
    for i in range(num_rows):
        values = []
        for col, dtype in regular_columns:
            if dtype == 'INT':
                values.append(str(random.randint(1, 1000)))
            elif dtype == 'DECIMAL':
                values.append(str(round(random.uniform(1.0, 1000.0), 2)))
            elif dtype == 'VARCHAR':
                values.append(f"'value_{i}_{col}'")
            elif dtype == 'DATE':
                values.append(f"'2023-{random.randint(1,12):02d}-{random.randint(1,28):02d}'")
            else:
                values.append("NULL")
        
        sql = f"INSERT INTO {table} ({', '.join(columns)}) VALUES ({', '.join(values)})"
        try:
            cursor.execute(sql)
        except mysql.connector.Error as err:
            print(f"Error inserting data into table '{table}': {err}")
            print(f"SQL statement: {sql}")
            continue

def clear_table(
        cursor: mysql.connector.cursor.MySQLCursor, 
        table: str) -> None:
    """
    Clears all data from a specified table.

    Args:
        cursor (mysql.connector.cursor.MySQLCursor): The cursor to execute the SQL queries.
        table (str): The name of the table to clear.

    Returns:
        None
    """
    sql = f"DELETE FROM {table}"
    cursor.execute(sql)


# ========== Extract Table from Query ========== #
def extract_tables_from_query(schema_dict, query):
    return list({table for table in schema_dict if re.search(
        rf'\b{table}\b', query, re.IGNORECASE)})


# ========== Reset and Regenerate Data ========== # 
def reset_and_regenerate_data(
        conn: mysql.connector.connection.MySQLConnection, 
        # table: str, 
        # schema: list[tuple[str, str]], 
        schema_dict: dict,
        query: str,
        num_rows: int=5):
    """
        Resets the specified table by clearing its contents and regenerating sample data.

        Args:
            conn (mysql.connector.connection.MySQLConnection): The MySQL database connection object.
            table (str): The name of the table to reset and regenerate data for.
            schema (list[tuple[str, str]]): The schema of the table, represented as a list of (column_name, column_type) tuples.
            num_rows (int, optional): The number of rows of sample data to generate. Defaults to 5.

        Returns:
            None
        """
    cursor = conn.cursor()
    tables = extract_tables_from_query(schema_dict, query)

    for table in tables:
        schema = schema_dict.get(table, []) 
        clear_table(cursor, table)
        generate_data(cursor, table, schema, num_rows=num_rows)

    # Commit the changes to the database
    conn.commit()


# ========== Get Query Results ========== # 
def get_query_results(cursor, query):
    return execute_query(cursor, query)


# ========== Query Equivalence ========== #
def queries_equivalent(
        conn: mysql.connector.connection.MySQLConnection, 
        q1: str, 
        q2: str) -> bool:
    """
    Determines whether two SQL queries produce equivalent results.
    """
    # Add MySQL 8.0 compatibility settings
    cursor = conn.cursor()
    cursor.execute("SET SESSION sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));")
    cursor.execute("SET SESSION sql_mode=(SELECT REPLACE(@@sql_mode,'ANSI',''));")
    
    try:
        # Use separate cursors for each query
        cursor1 = conn.cursor(buffered=True)
        r1 = get_query_results(cursor1, q1)
        conn.commit()
        
        cursor2 = conn.cursor(buffered=True)
        r2 = get_query_results(cursor2, q2)
        conn.commit()
        
        return r1 == r2
    except mysql.connector.Error as err:
        print(f"Database error: {err}")
        return False
    finally:
        try:
            cursor1.close()
            cursor2.close()
        except:
            pass


# ========== Find CounterExample ========== #
def find_counterexample(
        conn: mysql.connector.connection.MySQLConnection, 
        schema_dict: dict,
        q1: str, 
        q2: str, 
        max_attempts: int=5):
    """
    Attempts to find a counterexample that demonstrates the non-equivalence 
    of two SQL queries by repeatedly resetting and regenerating data and 
    testing their equivalence.

    Args:
        conn (mysql.connector.connection.MySQLConnection): 
            A MySQL database connection object.
        q1 (str): The first SQL query to compare.
        q2 (str): The second SQL query to compare.
        max_attempts (int, optional): 
            The maximum number of attempts to find a counterexample. 
            Defaults to 5.

    Returns:
        bool: 
            False if a counterexample is found (queries are not equivalent), 
            True if no counterexample is found after the specified attempts 
            (queries are equivalent).
    """
    try:
        for _ in range(max_attempts):
            # Reset and regenerate data
            reset_and_regenerate_data(conn, schema_dict, q1 + " " + q2)
            conn.commit()  # Ensure changes are committed
            
            # Create fresh connection for query comparison
            new_conn = get_connection()
            try:
                if not queries_equivalent(new_conn, q1, q2):
                    return False
            finally:
                new_conn.close()
        return True
    except mysql.connector.Error as err:
        print(f"Database error in find_counterexample: {err}")
        return False


# ========== Main Function ========== #
if __name__ == '__main__':
    conn = None
    try:
        # Load the schema
        with open("../benchmark/tpcds_schema.json") as f:
            TPCDS_SCHEMA = json.load(f)

        # Create fresh connection
        conn = get_connection()
        
        # Create tables and ensure they're committed
        create_tables(conn, TPCDS_SCHEMA)
        conn.commit()

        # Load queries
        with open("../benchmark/queries/query2.sql") as f:
            q1 = f.read()
        q2 = q1.replace("sales_price", "sales_price * 1.0")

        # Ensure tables exist before testing
        cursor = conn.cursor()
        cursor.execute("SHOW TABLES;")
        tables = cursor.fetchall()
        print(f"Available tables: {[t[0] for t in tables]}")
        cursor.close()

        # Test equivalence
        equivalent = find_counterexample(conn, TPCDS_SCHEMA, q1, q2)
        print("Queries appear equivalent." if equivalent else "Counterexample found. Queries are not equivalent.")

    except Exception as e:
        print(f"An error occurred: {e}")
    finally:
        if conn:
            try:
                conn.close()
            except:
                pass