import csv

# File paths
input_file = "/Users/desmondcheong/Library/CloudStorage/GoogleDrive-dczy@cmlab.csie.ntu.edu.tw/My Drive/NTU/113-2/Database/final project/benchmark/execution_times.csv"
output_file = "/Users/desmondcheong/Library/CloudStorage/GoogleDrive-dczy@cmlab.csie.ntu.edu.tw/My Drive/NTU/113-2/Database/final project/benchmark/execution_times_cleaned.csv"

# Scrub rows, calculate percentage improvements, and round values
def scrub_and_calculate(input_file, output_file):
    with open(input_file, 'r') as infile, open(output_file, 'w', newline='') as outfile:
        reader = csv.DictReader(infile)
        # Dynamically generate fieldnames to include improvement columns
        fieldnames = reader.fieldnames + [
            "static_rule_queries_improvement(%)",
            "teacher_student_queries_improvement(%)",
            "in_context_learning_queries_improvement(%)"
        ]
        writer = csv.DictWriter(outfile, fieldnames=fieldnames)

        # Write the header row
        writer.writeheader()

        # Process each row
        rows = []
        for row in reader:
            # Check for empty cells
            if any(cell.strip() == "" for cell in row.values()):
                continue

            # Check if original_queries is less than 0.1
            try:
                original_time = float(row["original_queries"])
                if original_time < 0.1:
                    print(f"Skipping row with original time < 0.1: {row}")
                    continue
            except ValueError:
                # Skip rows where original_queries is not a valid number
                continue

            # Calculate percentage improvements
            for col in ["static_rule_queries", "teacher_student_queries", "in_context_learning_queries"]:
                try:
                    time = float(row[col])
                    improvement = ((original_time - time) / original_time) * 100
                    row[f"{col}_improvement(%)"] = round(improvement, 4)
                except (ValueError, ZeroDivisionError):
                    row[f"{col}_improvement(%)"] = "N/A"

            # Round all numeric values in the row to 4 decimals
            for key in row:
                try:
                    row[key] = round(float(row[key]), 4)
                except (ValueError, TypeError):
                    # Skip non-numeric values
                    pass

            rows.append(row)

        # Sort rows by the value of original_queries
        rows.sort(key=lambda x: float(x["original_queries"]))

        # Write all valid rows with improvements
        writer.writerows(rows)

    print(f"Cleaned, rounded, and sorted CSV saved to {output_file}")

# Run the script
if __name__ == "__main__":
    scrub_and_calculate(input_file, output_file)