import re
import json
from collections import defaultdict

def extract_schemas(sql_file_path: str) -> dict:
    """
    Extracts table schemas from a SQL file.

    This function reads a SQL file, identifies `CREATE TABLE` statements, and extracts
    the table names along with their fields and data types. The data types are normalized
    to a simplified format (e.g., `VARCHAR`, `DECIMAL`, `DATE`, `INT`).

    Args:
        sql_file_path (str): The path to the SQL file containing `CREATE TABLE` statements.

    Returns:
        dict: A dictionary where keys are table names (str) and values are 
            lists of tuples.
            Each tuple contains a field name (str) and its normalized data type (str).
    """
    with open(sql_file_path, 'r') as f:
        content = f.read()

    # Regex to match CREATE TABLE statements
    table_pattern = re.compile(
        r'create table (\w+)\s*\((.*?)\);\s*',
        re.DOTALL | re.IGNORECASE
    )
    # Regex to match individual fields
    field_pattern = re.compile(
        r'^\s*(\w+)\s+([a-zA-Z0-9\(\),]+)', re.MULTILINE
    )
    # Regex to match primary key definitions
    primary_key_pattern = re.compile(
        r'primary key\s*\((.*?)\)', re.IGNORECASE
    )

    schemas = defaultdict(list)

    for table, fields_str in table_pattern.findall(content):
        fields = field_pattern.findall(fields_str)
        primary_keys = primary_key_pattern.findall(fields_str)

        for name, dtype in fields:
            # Normalize the data type
            clean_type = dtype.strip().split()[0].upper()
            if clean_type.startswith('CHAR') or clean_type.startswith('VARCHAR'):
                clean_type = 'VARCHAR'
            elif clean_type.startswith('DECIMAL'):
                clean_type = 'DECIMAL'
            elif clean_type.startswith('DATE'):
                clean_type = 'DATE'
            elif clean_type.startswith('INTEGER') or clean_type == 'INT':
                clean_type = 'INT'
            elif clean_type.startswith('DOUBLE') or clean_type.startswith('FLOAT'):
                clean_type = 'FLOAT'
            else:
                # Skip unsupported or malformed types
                continue

            schemas[table].append((name, clean_type))

        # Add primary key definitions
        if primary_keys:
            for pk in primary_keys:
                pk_columns = [col.strip() for col in pk.split(',')]
                for col in pk_columns:
                    schemas[table].append((col, "KEY"))

    return dict(schemas)


if __name__ == '__main__':
    schema_dict = extract_schemas('../benchmark/tpcds.sql')
    for table, fields in schema_dict.items():
        print(f"\n-- {table} --")
        for name, dtype in fields:
            print(f"{name}: {dtype}")

    # Save to JSON file
    with open('../benchmark/tpcds_schema.json', 'w') as f:
        json.dump(
            schema_dict, 
            f, 
            # indent=2
        )
