#!/bin/sh
# Scalable data pipeline using Docker containers
# Process data in isolated containers for reproducibility

set -e

PIPELINE_NAME="${1:-data_pipeline}"
INPUT_DIR="$(pwd)/data/raw"
OUTPUT_DIR="$(pwd)/data/output"

echo "🐳 Running containerized data pipeline: $PIPELINE_NAME"

# Ensure Docker is available
if ! command -v docker > /dev/null 2>&1; then
    echo "❌ Docker not available. Ensure Docker-in-Docker is running."
    exit 1
fi

# Create network for pipeline containers
docker network create ${PIPELINE_NAME}_net 2>/dev/null || true

echo "📦 Step 1: Data validation container"
docker run --rm \
    --network ${PIPELINE_NAME}_net \
    -v "$INPUT_DIR:/data/input:ro" \
    -v "$OUTPUT_DIR:/data/output" \
    python:3.12-alpine \
    sh -c "
        pip install -q pandas duckdb && \
        python -c '
import pandas as pd
import os
files = os.listdir(\"/data/input\")
print(f\"📊 Found {len(files)} file(s) to validate\")
for f in files:
    if f.endswith(\".csv\"):
        df = pd.read_csv(f\"/data/input/{f}\")
        print(f\"✅ {f}: {len(df)} rows\")
'
    "

echo "📦 Step 2: Data transformation container"
docker run --rm \
    --network ${PIPELINE_NAME}_net \
    -v "$INPUT_DIR:/data/input:ro" \
    -v "$OUTPUT_DIR:/data/output" \
    python:3.12-alpine \
    sh -c "
        pip install -q pandas pyarrow && \
        python -c '
import pandas as pd
import os
# Transform all CSV files to Parquet
for f in os.listdir(\"/data/input\"):
    if f.endswith(\".csv\"):
        df = pd.read_csv(f\"/data/input/{f}\")
        out_name = f.replace(\".csv\", \".parquet\")
        df.to_parquet(f\"/data/output/{out_name}\", compression=\"snappy\")
        print(f\"✅ Transformed {f} -> {out_name}\")
'
    "

echo "📦 Step 3: Data quality check container"
docker run --rm \
    --network ${PIPELINE_NAME}_net \
    -v "$OUTPUT_DIR:/data/output:ro" \
    python:3.12-alpine \
    sh -c "
        pip install -q pandas pyarrow && \
        python -c '
import pandas as pd
import os
# Verify output files
for f in os.listdir(\"/data/output\"):
    if f.endswith(\".parquet\"):
        df = pd.read_parquet(f\"/data/output/{f}\")
        print(f\"✅ Verified {f}: {len(df)} rows, {len(df.columns)} cols\")
'
    "

# Cleanup
docker network rm ${PIPELINE_NAME}_net 2>/dev/null || true

echo ""
echo "✅ Containerized pipeline complete!"
echo "   Input: $INPUT_DIR"
echo "   Output: $OUTPUT_DIR"
echo ""
echo "🎯 Benefits:"
echo "   - Reproducible: Same results every time"
echo "   - Isolated: No dependency conflicts"
echo "   - Scalable: Run on any Docker host"
echo "   - Portable: Works locally and in production"
