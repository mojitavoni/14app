#!/bin/sh
# Example: Process CSV file with DuckDB and export results

INPUT_FILE="${1:-data/raw/input.csv}"
OUTPUT_FILE="${2:-data/output/result.parquet}"

echo "📊 Processing data with DuckDB..."
echo "   Input: $INPUT_FILE"
echo "   Output: $OUTPUT_FILE"

# Example query - modify as needed
duckdb << EOF
-- Create output directory if needed
.shell mkdir -p data/output

-- Process and export
COPY (
    SELECT 
        *,
        CURRENT_TIMESTAMP as processed_at
    FROM '$INPUT_FILE'
    WHERE 1=1  -- Add your filters here
) TO '$OUTPUT_FILE' (FORMAT PARQUET);

-- Show summary
SELECT 
    COUNT(*) as total_rows,
    COUNT(DISTINCT *) as unique_rows
FROM '$INPUT_FILE';
EOF

echo "✅ Processing complete!"
