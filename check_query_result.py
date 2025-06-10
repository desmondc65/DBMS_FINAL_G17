import json
import os

# File paths
in_context_learning_path = "benchmark/teacher_student_queries/query_execution_results.json"
original_queries_path = "benchmark/original_queries/query_execution_results.json"
output_path = "benchmark/query_comparison_results_ts.json"

# Load JSON data
def load_json(filepath):
    with open(filepath, 'r') as file:
        return json.load(file)

# Save JSON data
def save_json(filepath, data):
    with open(filepath, 'w') as file:
        json.dump(data, file, indent=4)

# Compare query results
def compare_query_results():
    in_context_data = load_json(in_context_learning_path)
    original_data = load_json(original_queries_path)

    discrepancies = []
    valid_in_context_data = {}
    for query, in_context_result in in_context_data.items():
        # Check if the query exists in the original data
        if query not in original_data:
            discrepancies.append({
                "query": query,
                "issue": "Query not found in original_queries"
            })
            continue

        original_result = original_data[query]

        # Check for errors in execution_time or query_result
        if in_context_result.get("execution_time") == "Error" or original_result.get("execution_time") == "Error":
            discrepancies.append({
                "query": query,
                "issue": "Execution error"
            })
            continue

        # Check for missing execution_time
        if "execution_time" not in in_context_result or "execution_time" not in original_result:
            discrepancies.append({
                "query": query,
                "issue": "Missing execution_time"
            })
            continue

        # Check for missing query_result
        if "query_result" not in in_context_result or "query_result" not in original_result:
            discrepancies.append({
                "query": query,
                "issue": "Missing query_result"
            })
            continue

        # Check if query_result is empty
        if not in_context_result["query_result"] or not original_result["query_result"]:
            discrepancies.append({
                "query": query,
                "issue": "Empty query_result"
            })
            continue

        # Check if query_result matches
        if in_context_result["query_result"] != original_result["query_result"]:
            discrepancies.append({
                "query": query,
                "issue": "Mismatched query_result"
            })
            continue

        valid_in_context_data[query] = in_context_result

    save_json(in_context_learning_path, valid_in_context_data)
    return discrepancies

# Export discrepancies to a JSON file
def export_discrepancies(discrepancies):
    with open(output_path, "w") as output_file:
        json.dump(discrepancies, output_file, indent=4)
    print(f"Discrepancies exported to {output_path}")

# Main function
if __name__ == "__main__":
    discrepancies = compare_query_results()

    if discrepancies:
        print("Discrepancies found. Exporting to JSON...")
        export_discrepancies(discrepancies)
    else:
        print("No discrepancies found.")