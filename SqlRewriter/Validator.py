import os
import re 
import random 
import logging
import json 
from typing import Optional, Dict, List, Set, Tuple
import mysql.connector 
import sqlparse 
import sqlglot
from sqlglot import parse_one, exp
from itertools import product
from sqlglot.expressions import Table
from z3 import *

# ========== Get Connector ========== #
def get_connection(
    config_file: str = './config.json',
    # sql_dump_file: str = './tpcds_data_dump.sql'
) -> mysql.connector.connection.MySQLConnection:
    """
    Connects to MySQL, recreates the 'tpcsds' database, loads data from the given SQL dump file,
    and returns a connection to the newly created database.

    Args:
        config_file (str): Path to JSON config file with host, user, passwd.

    Returns:
        mysql.connector.connection.MySQLConnection: Connection to the newly created 'tpcsds' database.
    """
    if not os.path.exists(config_file):
        raise FileNotFoundError(f"Config file not found: {config_file}")

    with open(config_file) as f:
        config = json.load(f)

    return mysql.connector.connect(
        host=config['host'],
        user=config['user'],
        passwd=config['passwd'],
        database="tpcsds"
    )

# ========== Read and Clean SQL File ========== #
def read_clean_sql(filepath: str) -> Optional[str]:
    """
    Reads a SQL file, removes comments, and returns a cleaned SQL string.
    Preserves semicolons inside strings and avoids misinterpreting them as delimiters.
    
    Args:
        filepath (str): Path to the .sql file

    Returns:
        str: Cleaned SQL string, or None if no valid SQL found
    """
    if not os.path.isfile(filepath):
        raise FileNotFoundError(f"SQL file not found: {filepath}")

    with open(filepath, 'r', encoding='utf-8') as f:
        raw_sql = f.read()

    # Strip comments safely and normalize whitespace
    cleaned_sql = sqlparse.format(
        raw_sql,
        strip_comments=True,
        strip_whitespace=True,
        reindent=False
    )

    # Extract non-empty statement (assume first one is the main query)
    statements = sqlparse.split(cleaned_sql)
    for stmt in statements:
        if stmt.strip():
            return stmt.strip()

    return None


# ========== Generate Symbolic Tables ========== #
def generate_symbolic_tables(
    table_schemas: Dict[str, List[str]],
    num_rows: int = 2
) -> Dict[str, List[List[ExprRef]]]:
    """
    Generate symbolic tables for each table and column using Z3 variables.

    Args:
        table_schemas (Dict[str, List[str]]): Mapping of table name to list of column names.
        num_rows (int): Number of symbolic rows per table.

    Returns:
        Dict[str, List[List[z3.ExprRef]]]: Symbolic table data.
    """
    symbolic_tables = {}

    for table_name, columns in table_schemas.items():
        table_data = []
        for row_index in range(num_rows):
            row = []
            for col in columns:
                var_name = f"{table_name}_{col}_{row_index}"
                sym_var = Int(var_name)  # assuming INT types for now
                row.append(sym_var)
            table_data.append(row)
        symbolic_tables[table_name] = table_data

    return symbolic_tables


# ========== Extract Table Schemas ========== #
def extract_table_schemas(
    conn: mysql.connector.connection.MySQLConnection,
    database: str = "tpcsds",
    only_tables: List[str] = None
) -> Dict[str, List[str]]:
    """
    Extract column names for each table in the specified MySQL database.

    Args:
        conn (MySQLConnection): A live connection to MySQL
        database (str): Name of the target database
        only_tables (List[str], optional): List of table names to include

    Returns:
        Dict[str, List[str]]: {table_name: [col1, col2, ...]}
    """
    cursor = conn.cursor()
    table_schemas = {}

    if only_tables:
        tables = only_tables
    else:
        cursor.execute(f"""
            SELECT table_name
            FROM information_schema.tables
            WHERE table_schema = %s
            ORDER BY table_name
        """, (database,))
        tables = [row[0] for row in cursor.fetchall()]

    for table in tables:
        cursor.execute(f"""
            SELECT column_name
            FROM information_schema.columns
            WHERE table_schema = %s AND table_name = %s
            ORDER BY ordinal_position
        """, (database, table))
        columns = [row[0] for row in cursor.fetchall()]
        table_schemas[table] = columns

    cursor.close()
    return table_schemas


# ========== Extract Table Names ========== #
def extract_table_names(sql: str) -> List[str]:
    """
    Extract all physical table names (not aliases or CTEs) from a SQL query.
    Uses sqlglot for full AST parsing.

    Args:
        sql (str): SQL query string

    Returns:
        List[str]: Unique table names used in the query
    """
    expression = sqlglot.parse_one(sql)
    table_names = {
        t.name for t in expression.find_all(Table)
    }
    return sorted(table_names)


# ========== Compile Value ========== #
def compile_value(val_expr, env: Dict[str, ExprRef]) -> ExprRef:
    if isinstance(val_expr, exp.Column):
        col = val_expr.sql().lower()
        return env.get(col, Int(f"missing_{col}"))

    if isinstance(val_expr, exp.Literal):
        if val_expr.is_string:
            return StringVal(val_expr.name)
        try:
            return IntVal(int(val_expr.name))
        except ValueError:
            return RealVal(val_expr.name)

    if isinstance(val_expr, exp.Paren):
        return compile_value(val_expr.this, env)

    if isinstance(val_expr, exp.Mul):
        return compile_value(val_expr.left, env) * compile_value(val_expr.right, env)
    if isinstance(val_expr, exp.Div):
        return compile_value(val_expr.left, env) / compile_value(val_expr.right, env)
    if isinstance(val_expr, exp.Add):
        return compile_value(val_expr.left, env) + compile_value(val_expr.right, env)
    if isinstance(val_expr, exp.Sub):
        return compile_value(val_expr.left, env) - compile_value(val_expr.right, env)

    return IntVal(0)  # fallback


# ========== Compile Binary Expression ========== #
def compile_binary(expr, env: Dict[str, ExprRef], operator: str) -> ExprRef:
    """
    Compile a binary expression (e.g. x = y, x > 5) into a Z3 expression.
    """
    left = compile_value(expr.left, env)
    right = compile_value(expr.right, env)

    if operator == '==':
        return left == right
    elif operator == '!=':
        return left != right
    elif operator == '>':
        return left > right
    elif operator == '>=':
        return left >= right
    elif operator == '<':
        return left < right
    elif operator == '<=':
        return left <= right

    return BoolVal(True)


# ========== Compile Condition ========== #
def compile_condition(expr, env: Dict[str, ExprRef]) -> ExprRef:
    """
    Recursively compiles a SQL expression into a Z3 logical expression.

    Args:
        expr: sqlglot Expression (WHERE clause or part of it)
        env: mapping from qualified column names to Z3 symbolic variables

    Returns:
        Z3 expression (ExprRef)
    """
    if expr is None:
        return BoolVal(True)

    if isinstance(expr, exp.Paren):
        return compile_condition(expr.this, env)

    if isinstance(expr, exp.And):
        return And(
            compile_condition(expr.left, env),
            compile_condition(expr.right, env)
        )

    if isinstance(expr, exp.Or):
        return Or(
            compile_condition(expr.left, env),
            compile_condition(expr.right, env)
        )

    if isinstance(expr, exp.Not):
        return Not(compile_condition(expr.this, env))

    # Comparison Operators
    if isinstance(expr, exp.EQ):
        return compile_binary(expr, env, operator='==')
    if isinstance(expr, exp.NEQ):
        return compile_binary(expr, env, operator='!=')
    if isinstance(expr, exp.GT):
        return compile_binary(expr, env, operator='>')
    if isinstance(expr, exp.GTE):
        return compile_binary(expr, env, operator='>=')
    if isinstance(expr, exp.LT):
        return compile_binary(expr, env, operator='<')
    if isinstance(expr, exp.LTE):
        return compile_binary(expr, env, operator='<=')

    return BoolVal(True)  # fallback for unsupported nodes


# ========== Symbolic Query Compiler ========== #
def compile_symbolic_query(
    sql: str,
    symbolic_tables: Dict[str, List[List[ExprRef]]],
    table_schemas: Dict[str, List[str]],
    num_rows: int = 2
) -> List[Tuple]:
    ast = parse_one(sql)
    result = []

    if not isinstance(ast, exp.Select):
        ast = ast.find(exp.Select)

    # Get real tables used
    from_tables = [t.name for t in ast.find_all(exp.Table)]
    select_exprs = ast.expressions
    where_clause = ast.args.get("where")
    group_by_exprs = ast.args.get("group")

    # Build table rows as Cartesian product
    table_rows = [symbolic_tables[t] for t in from_tables]
    for row_indices in product(range(num_rows), repeat=len(from_tables)):
        env = {}
        for t_idx, t_name in enumerate(from_tables):
            schema = table_schemas[t_name]
            row = table_rows[t_idx][row_indices[t_idx]]
            for col_idx, col in enumerate(schema):
                env[f"{t_name}.{col}"] = row[col_idx]

        # Evaluate WHERE condition
        if where_clause:
            condition = compile_condition(where_clause, env)
            s = Solver()
            s.add(condition)
            if s.check() != sat:
                continue  # skip this row

        # Evaluate SELECT projection
        projected = []
        for sel in select_exprs:
            expr_val = compile_value(sel.this, env)
            projected.append(expr_val)

        result.append(projected)

    # Grouping and Aggregation
    if group_by_exprs:
        grouped = {}
        for row in result:
            group_key = tuple(compile_value(e, env) for e in group_by_exprs.expressions)
            grouped.setdefault(group_key, []).append(row)

        agg_result = []
        for key, group_rows in grouped.items():
            # Replace AVG(x) or SUM(x) with symbolic aggregate
            row_exprs = []
            for sel in select_exprs:
                if isinstance(sel.this, exp.Alias):
                    inner = sel.this.this
                else:
                    inner = sel.this

                if isinstance(inner, exp.Avg):
                    values = [compile_value(inner.this, env) for env in group_rows]
                    avg_expr = Sum(values) / len(values)
                    row_exprs.append(avg_expr)
                elif isinstance(inner, exp.Sum):
                    values = [compile_value(inner.this, env) for env in group_rows]
                    sum_expr = Sum(values)
                    row_exprs.append(sum_expr)
                else:
                    row_exprs.append(compile_value(inner, env))  # pass-through

            agg_result.append(row_exprs)
        return agg_result

    return result


# ========== Semantic Equivalence Check ========== #
def check_semantic_equivalence(
    q1_exprs: List[List[ExprRef]],
    q2_exprs: List[List[ExprRef]]
) -> Tuple[bool, Optional[ModelRef]]:
    """
    Checks whether the outputs of two queries are semantically equivalent
    by comparing their symbolic outputs using Z3.

    Args:
        q1_exprs: Symbolic result rows from Query 1
        q2_exprs: Symbolic result rows from Query 2

    Returns:
        (bool, model) – True if equivalent, False if a counterexample exists
    """
    s = Solver()

    # Assume unordered set semantics (ignoring order and duplicates)
    # Create disjunction: EXISTS row IN Q1 but NOT IN Q2, OR vice versa
    def set_diff_expr(A, B):
        exprs = []
        for a in A:
            not_in_B = And([Not(And([a[i] == b[i] for i in range(len(a))])) for b in B])
            exprs.append(not_in_B)
        return Or(exprs) if exprs else BoolVal(False)

    q1_diff = set_diff_expr(q1_exprs, q2_exprs)
    q2_diff = set_diff_expr(q2_exprs, q1_exprs)
    inequivalence = Or(q1_diff, q2_diff)

    s.add(inequivalence)

    if s.check() == sat:
        return False, s.model()
    else:
        return True, None
    

# ========== Test Semantic Equivalence ========== #
def test_semantic_equivalence(query_file_1, query_file_2):
    # Step 1: Load queries
    sql1 = read_clean_sql(query_file_1)
    sql2 = read_clean_sql(query_file_2)

    if not sql1 or not sql2:
        print("❌ Failed to load one of the SQL files.")
        return

    # Step 2: Extract table names
    tables_1 = extract_table_names(sql1)
    tables_2 = extract_table_names(sql2)
    tables = sorted(set(tables_1 + tables_2))

    print(f"📦 Tables used: {tables}")

    # Step 3: Connect to MySQL and get schemas
    conn = get_connection()
    schemas = extract_table_schemas(conn, only_tables=tables)

    # Step 4: Generate symbolic tables
    sym_tables = generate_symbolic_tables(schemas, num_rows=2)

    # Step 5: Compile both queries
    q1_exprs = compile_symbolic_query(sql1, sym_tables, schemas, num_rows=2)
    q2_exprs = compile_symbolic_query(sql2, sym_tables, schemas, num_rows=2)

    # Step 6: Check equivalence
    print("🔍 Checking semantic equivalence...")
    equiv, model = check_semantic_equivalence(q1_exprs, q2_exprs)

    if equiv:
        print("✅ Queries are semantically equivalent.")
    else:
        print("❌ Queries are NOT equivalent.")
        print("Counterexample model:")
        print(model)


# ========== Main Function ========== #
if __name__ == '__main__':
    # ========== Example Usage ========== #
    # conn = get_connection()
    # print("TPC-DS database is ready and loaded.")

    # query_file = "../benchmark/queries/query1.sql"
    # cleaned_query = read_clean_sql(query_file)
    # if cleaned_query:
    #     print("Cleaned SQL:")
    #     print(cleaned_query)
    #     tables = extract_table_names(cleaned_query)
    #     print("Detected tables:", tables)
    # else:
    #     print("No valid SQL found.")

    

    # Minimal schema for testing
    # schemas = {
    #     'store_returns': ['sr_customer_sk', 'sr_store_sk', 'sr_returned_date_sk', 'sr_return_amt_inc_tax'],
    #     'date_dim': ['d_date_sk', 'd_year'],
    #     'customer': ['c_customer_sk', 'c_customer_id'],
    #     'store': ['s_store_sk', 's_state']
    # }

    # sym_tables = generate_symbolic_tables(schemas, num_rows=2)

    # for table, rows in sym_tables.items():
    #     print(f"\nTable: {table}")
    #     for row in rows:
    #         print("  " + ", ".join(str(col) for col in row))

    # # Extract full schema or only selected tables
    # schemas = extract_table_schemas(
    #     conn, 
    #     only_tables=['store_returns', 'date_dim', 'customer', 'store']
    # )
    # for table, cols in schemas.items():
    #     print(f"{table}: {cols}")

    test_semantic_equivalence(
        query_file_1="../benchmark/queries/query1.sql", 
        query_file_2="../benchmark/mod_queries/query1.sql")