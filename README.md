# Minimal Developer Environment - DataOps

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Size](https://img.shields.io/badge/size-~450MB-green.svg)
![User](https://img.shields.io/badge/user-tmj-orange.svg)

> **Ultra-lightweight, production-ready DataOps environment for modern data engineering workflows**

## 🎯 What is This?

A **minimal Alpine-based development container** (~450MB) optimized for:
- 📊 **Data Engineering** - ETL/ELT pipelines, data transformation
- 🗄️ **Multi-format support** - Parquet, Delta Lake, CSV, JSON, XML, Avro, Excel
- 🐳 **Containerized workflows** - Docker-in-Docker for scalable pipelines
- 🔍 **Data quality** - Validation, profiling, testing
- 🚀 **Production-ready** - CI/CD, monitoring, best practices

## ✨ What's Included

| Component | Size | Purpose |
|-----------|------|---------|
| **Alpine Linux 3.19** | 5MB | Minimal, secure base |
| **Python 3.12** | 50MB | Data processing core |
| **Node.js 20 LTS** | 80MB | Tooling & APIs |
| **PowerShell Core** | 60MB | Cross-platform scripting |
| **Docker-in-Docker** | 100MB | Containerized pipelines |
| **DuckDB + extensions** | 30MB | Analytics database |
| **DB Clients** | 17MB | PostgreSQL, MySQL, SQLite |
| **DataOps Libraries** | 108MB | Delta Lake, dbt, Great Expectations |
| **Total** | **~450MB** | Complete environment |

---

## 📦 Supported Data Formats

### ✅ All Common Formats

| Format | Libraries | Use Case |
|--------|-----------|----------|
| **CSV/TSV** | pandas, polars, csvkit, DuckDB | Universal interchange |
| **JSON/JSONL** | pandas, jq, Node.js | APIs, logs, config |
| **Parquet** | pyarrow, fastparquet, DuckDB | Analytics (10x smaller than CSV) |
| **Delta Lake** | deltalake, DuckDB | ACID transactions, time travel |
| **XML** | lxml, xmltodict, xmlstarlet | Legacy systems, SOAP |
| **Excel** | openpyxl | Business data |
| **Avro** | avro-python3, fastavro | Schema evolution |
| **Protobuf** | protobuf | gRPC, efficient binary |
| **YAML** | pyyaml, yq | Configuration |
| **Text** | awk, sed, grep, regex | Log processing |

---

## 🚀 Quick Start

```bash
# 1. Open in VS Code
code .

# 2. Rebuild container
# Press F1 → "Dev Containers: Rebuild Container"
# Wait 8-10 minutes for first build

# 3. Verify installation
sh scripts/test_setup.sh

# 4. Start building pipelines!
```

---

## 💡 Usage Examples

### Delta Lake - ACID Transactions

```python
from deltalake import DeltaTable, write_deltalake
import pandas as pd
import duckdb

# Create Delta table
df = pd.read_csv('data/raw/sales.csv')
write_deltalake('data/processed/sales_delta', df, mode='overwrite')

# Query with DuckDB (fast!)
con = duckdb.connect()
con.execute("INSTALL delta; LOAD delta;")
result = con.execute("""
    SELECT category, SUM(amount) as total
    FROM delta_scan('data/processed/sales_delta')
    GROUP BY category
""").df()

# Time travel - query historical versions
dt = DeltaTable('data/processed/sales_delta', version=0)
old_data = dt.to_pandas()
```

### Multi-Format Pipeline

```python
from scripts.python.multi_format_pipeline import DataPipeline

pipeline = DataPipeline()

# Read any format
df_csv = pipeline.read_csv('data/raw/input.csv')
df_json = pipeline.read_json('data/raw/input.json')
df_xml = pipeline.read_xml('data/raw/input.xml')
df_excel = pipeline.read_excel('data/raw/input.xlsx')

# Transform with DuckDB SQL
result = pipeline.transform_with_duckdb("""
    SELECT category, COUNT(*) as count, SUM(amount) as total
    FROM df_csv
    WHERE date >= '2024-01-01'
    GROUP BY category
""")

# Write optimized Parquet (10x smaller!)
pipeline.write_parquet(result, 'summary.parquet')
```

### Data Quality Validation

```python
from scripts.python.data_quality import validate_data_quality

df = pd.read_csv('data/raw/input.csv')
results = validate_data_quality(df)

if results['failed']:
    raise ValueError("Data quality checks failed!")
# Continue processing...
```

### Containerized Pipeline (Scalable!)

```bash
# Run entire pipeline in Docker containers
sh scripts/shell/containerized_pipeline.sh

# Benefits:
# - Reproducible (same results every time)
# - Isolated (no dependency conflicts)
# - Scalable (deploy to Kubernetes, ECS, etc.)
# - Portable (works locally and in production)
```

---

## 🏗️ Project Structure

```
14app/
├── .devcontainer/              # Container configuration
│   ├── devcontainer.json       # Alpine + Docker + DataOps
│   ├── setup.sh                # Installation script
│   └── README.md               # Technical docs
├── .github/workflows/
│   └── ci.yml                  # CI/CD pipeline
├── data/
│   ├── raw/                    # Source data (gitignored)
│   ├── processed/              # Delta tables, transformed
│   └── output/                 # Results
├── scripts/
│   ├── python/
│   │   ├── delta_operations.py       # Delta Lake examples
│   │   ├── multi_format_pipeline.py  # Format conversion
│   │   ├── data_quality.py           # Validation
│   │   └── process_data.py           # DuckDB processing
│   ├── nodejs/
│   │   └── convert_csv.js            # Node.js utilities
│   ├── shell/
│   │   ├── containerized_pipeline.sh # Docker pipeline
│   │   ├── process_data.sh           # Bash processing
│   │   └── text_processing.sh        # awk/sed/grep
│   └── test_setup.sh                 # Verify installation
├── .env.example                # Environment template
└── README.md                   # This file
```

---

## 🐳 Scaling to Production

### Local Development
```bash
sh scripts/shell/containerized_pipeline.sh
```

### Kubernetes
```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: data-pipeline
spec:
  template:
    spec:
      containers:
      - name: dataops
        image: your-registry/dataops:latest
        command: ["python", "scripts/python/process_data.py"]
```

### AWS ECS / Azure Container Instances
```bash
# Build and push image
docker build -t dataops:latest .
docker push your-ecr/dataops:latest

# Deploy as ECS task
aws ecs run-task --task-definition dataops-pipeline
```

### Serverless (AWS Lambda)
```python
def lambda_handler(event, context):
    from scripts.python.multi_format_pipeline import DataPipeline
    pipeline = DataPipeline()
    # Process data triggered by S3, SQS, etc.
```

---

## 📊 Performance Comparison

### File Size (1M rows)
| Format | Size | Read Time |
|--------|------|-----------|
| CSV | 100 MB | 5 sec |
| JSON | 150 MB | 8 sec |
| **Parquet** | **10 MB** | **0.5 sec** |
| **Delta Lake** | **10 MB** | **0.5 sec** + ACID |

### Processing Speed (10M rows)
| Tool | Time | Memory |
|------|------|--------|
| Pandas | 30 sec | 8 GB |
| **Polars** | **6 sec** | **2 GB** |
| **DuckDB** | **3 sec** | **500 MB** |

---

## 🔧 DataOps Tools

### Data Transformation
- **dbt-core** + **dbt-duckdb** - SQL-based transformations
- **DuckDB** - In-process analytics (no server needed)
- **Polars** - Fast DataFrame library (5-10x faster than Pandas)

### Data Quality
- **Great Expectations** - Comprehensive validation framework
- **JSON Schema** - JSON validation
- Custom validators (see `scripts/python/data_quality.py`)

### Data Orchestration (Compatible)
- Airflow, Prefect, Dagster
- Kubernetes CronJobs
- GitHub Actions
- AWS Step Functions

---

## 🔒 Security & Best Practices

### ✅ Security
- **Non-root user** - Runs as `tmj`
- **Minimal packages** - No unnecessary tools
- **Secret management** - `.env` files (never committed)
- **CI/CD scanning** - Trivy security scanner
- **Container isolation** - Docker-in-Docker

### ✅ DataOps Best Practices
- **Version control** - Git for code, Delta Lake for data
- **Data validation** - Quality checks before processing
- **Reproducibility** - Containerized pipelines
- **Testing** - Unit tests, integration tests, data tests
- **Monitoring** - Logging, metrics, alerts

---

## 🎓 Common Tasks

### Convert CSV to Parquet (10x smaller)
```bash
duckdb -c "COPY (SELECT * FROM 'data.csv') TO 'data.parquet' (FORMAT PARQUET, COMPRESSION SNAPPY)"
```

### Query Multiple Files
```bash
duckdb -c "SELECT * FROM 'sales/*.parquet' WHERE amount > 1000"
```

### Join Files
```bash
duckdb -c "
  SELECT * FROM 'sales.csv' s
  JOIN 'customers.csv' c ON s.customer_id = c.id
"
```

### Process XML
```bash
# Extract specific elements
xmlstarlet sel -t -v "//item/name" data.xml

# Convert XML to JSON
python -c "
import xmltodict, json
with open('data.xml') as f:
    data = xmltodict.parse(f.read())
print(json.dumps(data, indent=2))
"
```

### Text Processing
```bash
# Extract emails
grep -oE '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}' logs.txt

# Sum column with awk
awk -F',' '{sum+=$3} END {print sum}' data.csv

# Remove duplicates
sort data.txt | uniq
```

---

## 🐛 Troubleshooting

### Container Build Issues
```bash
# Clear Docker cache
docker system prune -a

# Rebuild without cache
# F1 → "Dev Containers: Rebuild Without Cache"
```

### Python Package Issues (Alpine)
```bash
# Some packages need build tools
sudo apk add gcc musl-dev python3-dev
```

### DuckDB Out of Memory
```bash
# Increase memory limit
duckdb -c "SET memory_limit='8GB'"
```

### Docker-in-Docker Not Working
```bash
# Check Docker is available
docker ps

# Restart if needed
sudo service docker restart
```

---

## 📚 Documentation

- **README.md** - This file (overview, examples)
- **SETUP.md** - Detailed setup guide
- **.devcontainer/README.md** - Technical documentation
- **scripts/** - Inline code documentation

---

## 🎯 Why This Environment?

### vs Cloud Data Platforms (Databricks, Snowflake)
- ✅ **Free** - No cloud costs
- ✅ **Portable** - Works anywhere (local, cloud, edge)
- ✅ **Fast** - No cold starts, local processing
- ✅ **Privacy** - Data stays local

### vs Heavy Containers (Jupyter, Anaconda)
- ✅ **10-20x smaller** - 450MB vs 5-10GB
- ✅ **Production-ready** - Not just notebooks
- ✅ **Fast builds** - Minutes vs hours

### vs Single-Language
- ✅ **Polyglot** - Python, Node.js, Bash, PowerShell
- ✅ **Flexible** - Best tool for each task
- ✅ **Future-proof** - Easy to extend

---

## 📝 Environment Setup

```bash
# Copy template
cp .env.example .env

# Edit with your values
nano .env

# Common variables:
DB_HOST=localhost
DB_USER=tmj
DB_PASSWORD=secret
DELTA_LAKE_PATH=/workspace/data/delta
DUCKDB_MEMORY_LIMIT=4GB
```

---

## 💬 Support

- 📖 Documentation in `.devcontainer/README.md`
- 🐛 Issues on GitHub
- 💡 Discussions for questions

---

## 🏆 Best For

✅ Data engineers building ETL/ELT pipelines  
✅ Analytics engineers using dbt  
✅ Teams wanting reproducible workflows  
✅ Edge/IoT data processing  
✅ Cost-conscious projects  
✅ Hybrid cloud/on-prem deployments  
✅ Learning modern DataOps  

---

## 📝 License

MIT License - Free for personal and commercial use

---

**Minimal Developer Environment - DataOps**  
*450MB. Production-ready. Scales to billions of rows.*

**User:** tmj (non-root, sudo enabled)  
**Made with ❤️ for modern data engineering**
