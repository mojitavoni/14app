#!/bin/sh
set -e

echo "🚀 Setting up Minimal Developer Environment - DataOps..."

# Create user tmj if doesn't exist
if ! id -u tmj > /dev/null 2>&1; then
    echo "👤 Creating user 'tmj'..."
    adduser -D -s /bin/sh tmj
    echo "tmj ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/tmj
fi

# Text processing tools (already in Alpine)
echo "✅ Text processing: awk, sed, grep, regex (built-in)"

# Install DuckDB CLI (~30MB) - Latest version
echo "📦 Installing DuckDB with Delta extension..."
wget -q https://github.com/duckdb/duckdb/releases/latest/download/duckdb_cli-linux-amd64.zip
unzip -q duckdb_cli-linux-amd64.zip
mv duckdb /usr/local/bin/
chmod +x /usr/local/bin/duckdb
rm duckdb_cli-linux-amd64.zip

# Install essential data processing tools & DB clients
echo "📦 Installing data tools, DB clients & format handlers..."
apk add --no-cache \
    jq \
    yq \
    sqlite \
    postgresql-client \
    mysql-client \
    xmlstarlet \
    libxml2-utils \
    libxslt

# Install Python packages for DataOps (~80MB)
echo "🐍 Installing Python data libraries..."
pip install --no-cache-dir \
    duckdb==0.10.0 \
    pandas==2.2.0 \
    polars==0.20.0 \
    pyarrow==15.0.0 \
    deltalake==0.15.0 \
    fastparquet==2024.2.0 \
    xmltodict==0.13.0 \
    lxml==5.1.0 \
    avro-python3==1.10.2 \
    fastavro==1.9.4 \
    protobuf==4.25.0 \
    openpyxl==3.1.2 \
    pyyaml==6.0.1 \
    jsonschema==4.21.1 \
    python-dotenv==1.0.0 \
    click==8.1.7 \
    great-expectations==0.18.0 \
    dbt-core==1.7.0 \
    dbt-duckdb==1.7.0

# Install Node.js packages for DataOps (~30MB)
echo "📦 Installing Node.js data tools..."
npm install -g --quiet \
    csvtojson \
    json2csv \
    xml2js \
    fast-csv \
    papaparse \
    prettier

# Install DuckDB Delta extension
echo "📦 Configuring DuckDB with Delta Lake support..."
mkdir -p /home/tmj/.duckdb
chown -R tmj:tmj /home/tmj/.duckdb || true

# Security: Update and clean up
echo "🔒 Security cleanup..."
apk upgrade --no-cache
rm -rf /var/cache/apk/* /tmp/* /root/.cache /home/tmj/.cache 2>/dev/null || true

# Set ownership for tmj user
echo "👤 Setting up tmj user permissions..."
chown -R tmj:tmj /workspace 2>/dev/null || true
chown -R tmj:tmj /home/tmj 2>/dev/null || true

# Verify installations
echo ""
echo "✅ Installation complete!"
echo ""
echo "📊 Installed DataOps tools:"
echo "  - DuckDB: $(duckdb --version)"
echo "  - Python: $(python --version)"
echo "  - Node.js: $(node --version)"
echo "  - Docker: $(docker --version 2>/dev/null || echo 'will be available')"
echo "  - jq: $(jq --version)"
echo "  - PostgreSQL: $(psql --version | head -1)"
echo "  - MySQL: $(mysql --version | head -1)"
echo "  - SQLite: $(sqlite3 --version)"
echo ""
echo "� Supported data formats:"
echo "  - Parquet (pyarrow, fastparquet)"
echo "  - Delta Lake (deltalake)"
echo "  - CSV/TSV (csvkit, pandas, polars)"
echo "  - JSON/JSONL (jq, pandas, polars)"
echo "  - XML (xmlstarlet, lxml, xmltodict)"
echo "  - Avro (avro-python3, fastavro)"
echo "  - Protobuf (protobuf)"
echo "  - Excel (openpyxl)"
echo "  - YAML (pyyaml, yq)"
echo ""
echo "�🛠️  Text processing: awk, sed, grep, cut, tr, regex"
echo "🐳  Docker: Available for containerized pipelines"
echo "�  Data quality: great-expectations"
echo "🔄  Data transformation: dbt-core, dbt-duckdb"
echo ""
echo "👤 Running as user: tmj (non-root)"
echo ""
echo "🎉 Minimal Developer Environment ready for DataOps!"
