# import mysql.connector
from mysql.connector import MySQLConnection
from typing import Dict, Any, Tuple
import json
import os
import re
from Validator import get_connection 

def parse_explain_output(output: str) -> Dict[str, Any]:
    # This regex-based parser is simplified for MySQL's EXPLAIN ANALYZE output
    metrics = {}

    time_match = re.search(r'->.*cost=.*?rows=.*?time=(\d+\.\d+)ms', output)
    if time_match:
        metrics['execution_time_ms'] = float(time_match.group(1))

    rows_match = re.findall(r'rows=(\d+)', output)
    if rows_match:
        metrics['total_rows_examined'] = sum(map(int, rows_match))

    return metrics

def run_explain_analyze(query: str, conn: MySQLConnection) -> Tuple[str, Dict[str, Any]]:
    cursor = conn.cursor()
    try:
        cursor.execute(f"EXPLAIN ANALYZE {query}")
        result = cursor.fetchall()
        explain_output = "\n".join(row[0] for row in result)
        return explain_output, parse_explain_output(explain_output)
    finally:
        cursor.close()


def compare_queries(query1: str, query2: str, conn: MySQLConnection) -> Dict[str, Any]:
    output1, metrics1 = run_explain_analyze(query1, conn)
    output2, metrics2 = run_explain_analyze(query2, conn)

    comparison = {
        "query1": {
            "plan": output1,
            "metrics": metrics1,
        },
        "query2": {
            "plan": output2,
            "metrics": metrics2,
        },
        "recommendation": "Query 1 is better" if metrics1.get('execution_time_ms', float('inf')) < metrics2.get('execution_time_ms', float('inf')) else "Query 2 is better"
    }
    return comparison

if __name__ == "__main__":
    conn = get_connection()
    query1 = "SELECT * FROM web_sales WHERE ws_quantity > 10;"
    # query2 = "SELECT * FROM sales FORCE INDEX(idx_amount) WHERE amount > 100;"

    # result = compare_queries(query1, query2, conn)
    result = run_explain_analyze(query1, conn)
    print(result)