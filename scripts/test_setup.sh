#!/bin/sh
# Test script to verify container setup
# Run this after rebuilding the container

set -e

echo "🧪 Testing 14app container setup..."
echo ""

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

test_command() {
    if command -v "$1" > /dev/null 2>&1; then
        echo "${GREEN}✅${NC} $1: $($1 --version 2>&1 | head -1)"
    else
        echo "${RED}❌${NC} $1: NOT FOUND"
        return 1
    fi
}

test_python_package() {
    if python -c "import $1" 2>/dev/null; then
        version=$(python -c "import $1; print($1.__version__)" 2>/dev/null || echo "installed")
        echo "${GREEN}✅${NC} Python $1: $version"
    else
        echo "${RED}❌${NC} Python $1: NOT FOUND"
        return 1
    fi
}

test_node_package() {
    if npm list -g "$1" > /dev/null 2>&1; then
        echo "${GREEN}✅${NC} Node.js $1: installed"
    else
        echo "${RED}❌${NC} Node.js $1: NOT FOUND"
        return 1
    fi
}

echo "📦 Core Tools:"
test_command git
test_command curl
test_command wget
test_command jq
test_command yq || echo "⚠️  yq: optional"

echo ""
echo "🗣️ Languages & Runtimes:"
test_command python
test_command node
test_command npm
test_command pwsh || echo "⚠️  PowerShell: optional"

echo ""
echo "🗄️ Database Clients:"
test_command duckdb
test_command sqlite3
test_command psql
test_command mysql

echo ""
echo "🐍 Python Packages:"
test_python_package duckdb
test_python_package pandas
test_python_package polars
test_python_package pyarrow

echo ""
echo "📦 Node.js Packages:"
test_node_package csvtojson || echo "⚠️  Run: npm install -g csvtojson"
test_node_package json2csv || echo "⚠️  Run: npm install -g json2csv"
test_node_package prettier

echo ""
echo "🛠️ Text Processing:"
test_command awk
test_command sed
test_command grep

echo ""
echo "📊 Testing DuckDB with sample data..."
echo "name,age,city
Alice,30,NYC
Bob,25,LA
Charlie,35,SF" > /tmp/test.csv

result=$(duckdb -csv -c "SELECT COUNT(*) as count FROM '/tmp/test.csv'" | tail -1)
if [ "$result" = "3" ]; then
    echo "${GREEN}✅${NC} DuckDB query test: PASSED"
else
    echo "${RED}❌${NC} DuckDB query test: FAILED"
fi

rm /tmp/test.csv

echo ""
echo "🎉 Testing complete!"
echo ""
echo "📝 Next steps:"
echo "1. Create your data processing scripts"
echo "2. Add data files to data/raw/"
echo "3. Run: duckdb -c \"SELECT * FROM 'data/raw/yourfile.csv'\""
echo ""
