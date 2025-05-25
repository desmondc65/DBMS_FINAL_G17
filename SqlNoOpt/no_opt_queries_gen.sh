#!/bin/bash

INPUT_DIR="queries"
OUTPUT_DIR="queries_no_opt"
OFF_SQL="optimizer_switch_off.sql"
DEFAULT_SQL="optimizer_switch_default.sql"

mkdir -p "$OUTPUT_DIR"
cp ../benchmark/queries . -r

for file in "$INPUT_DIR"/*.sql; do
    filename=$(basename "$file")
    cat "$OFF_SQL" "$file" "$DEFAULT_SQL" > "$OUTPUT_DIR/$filename"
done
cp "$INPUT_DIR"/*.txt "$OUTPUT_DIR"

echo "output at $OUTPUT_DIR"
