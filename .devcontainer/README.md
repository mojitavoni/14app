# 14app Development Container

## 🎯 Purpose
Minimal, secure development environment for data processing and scripting.

## 📦 What's Included

### Languages & Runtimes (~190MB)
- **Python 3.12** - Data processing, scripting
- **Node.js 20 LTS** - JavaScript scripting, tools
- **PowerShell Core** - Cross-platform scripting
- **Bash/Ash** - Shell scripting

### Data Processing Tools (~80MB)
- **DuckDB** - In-process analytical database
- **SQLite** - Embedded database
- **PostgreSQL client** - psql CLI
- **MySQL client** - mysql CLI
- **jq** - JSON processor
- **yq** - YAML processor
- **csvkit** - CSV toolkit (csvcut, csvgrep, csvsql)

### Python Libraries (~40MB)
- `duckdb` - DuckDB Python API
- `pandas` - DataFrame processing
- `polars` - Fast DataFrame library
- `pyarrow` - Columnar data format
- `python-dotenv` - Environment management
- `click` - CLI framework

### Node.js Tools (~20MB)
- `csvtojson` - CSV to JSON converter
- `json2csv` - JSON to CSV converter
- `prettier` - Code formatter

### Text Processing (Built-in)
- `awk` - Pattern scanning and processing
- `sed` - Stream editor
- `grep` - Pattern matching
- `cut`, `tr`, `sort`, `uniq` - Text manipulation
- Regex support in all tools

### DevOps & GitHub
- **GitHub CLI** - Manage repos, PRs, issues
- **Git** - Version control

**Total Size: ~330MB** (vs 1GB+ typical containers)

## 🔒 Security Features

1. **Non-root user** - Runs as `vscode` user
2. **No build tools** - Minimal attack surface
3. **No package caches** - Reduced storage
4. **SSH mount** - Secure credential access
5. **Latest packages** - Security updates applied
6. **Environment isolation** - PYTHONDONTWRITEBYTECODE=1

## 🚀 Quick Start

### DuckDB Examples
```bash
# Query CSV directly
duckdb -c "SELECT * FROM 'data.csv' WHERE amount > 100"

# Export to Parquet
duckdb -c "COPY (SELECT * FROM 'data.csv') TO 'data.parquet'"

# Join multiple files
duckdb -c "SELECT * FROM 'sales.csv' s JOIN 'customers.csv' c ON s.customer_id = c.id"
```

### Text Processing Examples
```bash
# Extract specific columns from CSV
csvcut -c name,age,email data.csv

# Filter rows
csvgrep -c status -m "active" data.csv

# Convert CSV to JSON
csvjson data.csv > data.json

# Process JSON with jq
cat data.json | jq '.[] | select(.age > 18)'

# AWK processing
awk -F',' '$3 > 100 {print $1, $3}' data.csv

# SED replacement
sed 's/old/new/g' file.txt

# Regex matching
grep -E '^[A-Z]{3}[0-9]{3}$' codes.txt
```

### Python Data Processing
```python
import duckdb
import pandas as pd

# Query with DuckDB
con = duckdb.connect()
df = con.execute("SELECT * FROM 'data.csv'").df()

# Use Pandas
df = pd.read_csv('data.csv')
result = df[df['amount'] > 100]
```

### Node.js Data Processing
```javascript
const csvtojson = require('csvtojson');

// Convert CSV to JSON
csvtojson()
  .fromFile('data.csv')
  .then((json) => {
    console.log(json);
  });
```

## 📁 Recommended Project Structure
```
14app/
├── .devcontainer/          # Dev container config
├── .github/                # GitHub workflows
│   └── workflows/
│       ├── ci.yml
│       └── data-validation.yml
├── data/                   # Data files (gitignored)
│   ├── raw/
│   ├── processed/
│   └── output/
├── scripts/                # Processing scripts
│   ├── python/
│   ├── nodejs/
│   └── shell/
├── sql/                    # SQL queries
├── tests/                  # Test files
├── .gitignore
├── .env.example
├── README.md
└── requirements.txt        # Python dependencies
```

## 🔧 Best Practices

### Data Files
- **Don't commit large data files** - Use `.gitignore`
- **Use Git LFS** - For necessary binary files
- **Document data sources** - Keep README updated

### Security
- **Use .env files** - Never commit credentials
- **Scan dependencies** - Use `npm audit`, `pip-audit`
- **Keep updated** - Rebuild container monthly

### Performance
- **Use DuckDB for large datasets** - Faster than Pandas
- **Use Polars** - When you need DataFrames
- **Stream processing** - For files > 1GB

### GitHub Integration
```bash
# Check status
gh repo view

# Create PR
gh pr create --title "Add data pipeline"

# Run workflow
gh workflow run ci.yml
```

## 🔄 Updating the Container

```bash
# Rebuild with latest packages
# Press F1 > "Dev Containers: Rebuild Container"

# Or from command palette
# Press F1 > "Dev Containers: Rebuild Without Cache"
```

## 🐛 Troubleshooting

### DuckDB Issues
```bash
# Check version
duckdb --version

# Memory limit (if needed)
duckdb -c "SET memory_limit='2GB'"
```

### Python Package Issues
```bash
# Some packages need build tools (rare)
apk add --no-cache gcc musl-dev python3-dev
```

## 📚 Additional Resources

- [DuckDB Documentation](https://duckdb.org/docs/)
- [csvkit Documentation](https://csvkit.readthedocs.io/)
- [jq Manual](https://stedolan.github.io/jq/manual/)
- [AWK Tutorial](https://www.gnu.org/software/gawk/manual/)
- [GitHub CLI Manual](https://cli.github.com/manual/)
