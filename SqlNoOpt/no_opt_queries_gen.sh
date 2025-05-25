#!/bin/bash

INPUT_DIR="queries"
OUTPUT_DIR="queries_no_opt"
OFF_SQL="optimizer_switch_off.sql"
DEFAULT_SQL="optimizer_switch_default.sql"

cp ../benchmark/queries/ . -r
mkdir -p "$OUTPUT_DIR"

for file in "$INPUT_DIR"/*.sql; do
    filename=$(basename "$file")
    cat "$OFF_SQL" "$file" "$DEFAULT_SQL" > "$OUTPUT_DIR/$filename"
done

echo "output at $OUTPUT_DIR"
