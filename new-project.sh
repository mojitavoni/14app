#!/bin/bash
# Create a new project with DataOps environment

PROJECT_NAME=$1

if [ -z "$PROJECT_NAME" ]; then
    echo "Usage: ./new-project.sh <project-name>"
    echo "Example: ./new-project.sh my-data-pipeline"
    exit 1
fi

echo "📦 Creating new DataOps project: $PROJECT_NAME"

# Create project directory
mkdir -p "$PROJECT_NAME"
cd "$PROJECT_NAME"

# Create .devcontainer directory
mkdir -p .devcontainer

# Create devcontainer.json
cat > .devcontainer/devcontainer.json << 'EOF'
{
  "name": "DataOps Project",
  "image": "dataops-env:latest",
  "remoteUser": "tmj",
  "containerUser": "tmj",
  "workspaceFolder": "/workspace",
  "mounts": [
    "source=${localEnv:HOME}/.ssh,target=/home/tmj/.ssh,readonly,type=bind,consistency=cached"
  ],
  "forwardPorts": [8000, 8080],
  "customizations": {
    "vscode": {
      "extensions": [
        "ms-python.python",
        "ms-python.vscode-pylance",
        "RandomFractalsInc.vscode-data-preview",
        "mechatroner.rainbow-csv"
      ],
      "settings": {
        "python.defaultInterpreterPath": "/usr/local/bin/python3",
        "editor.formatOnSave": true,
        "files.eol": "\n"
      }
    }
  },
  "containerEnv": {
    "PYTHONDONTWRITEBYTECODE": "1",
    "PYTHONUNBUFFERED": "1"
  }
}
EOF

# Create project structure
mkdir -p data/{raw,processed,output}
mkdir -p scripts/{python,shell}
mkdir -p tests

# Create .gitignore
cat > .gitignore << 'EOF'
# Data files
data/raw/**
data/processed/**
data/output/**
*.parquet
*.duckdb
*.delta

# Python
__pycache__/
*.py[cod]
.pytest_cache/

# Environment
.env
.env.local

# IDE
.vscode/*
!.vscode/settings.json
EOF

# Create README
cat > README.md << EOF
# $PROJECT_NAME

DataOps project created with Minimal Developer Environment.

## Setup

\`\`\`bash
# Open in VS Code
code .

# Reopen in container
# Press F1 → "Dev Containers: Reopen in Container"
\`\`\`

## Structure

- \`data/raw/\` - Source data
- \`data/processed/\` - Transformed data
- \`data/output/\` - Results
- \`scripts/python/\` - Python scripts
- \`scripts/shell/\` - Shell scripts
- \`tests/\` - Tests

## Available Tools

- Python 3.12 + pandas, polars, duckdb
- Node.js 20 + data tools
- DuckDB - Fast analytics
- Delta Lake - ACID tables
- All data formats: CSV, JSON, Parquet, XML, Excel, Avro

## Examples

\`\`\`bash
# Query CSV with DuckDB
duckdb -c "SELECT * FROM 'data/raw/file.csv'"

# Convert to Parquet
duckdb -c "COPY (SELECT * FROM 'data/raw/file.csv') TO 'data/output/file.parquet'"
\`\`\`
EOF

# Create example Python script
cat > scripts/python/example.py << 'EOF'
"""
Example data processing script
"""
import pandas as pd
import duckdb

def main():
    print("🐍 Python script running...")
    print(f"Pandas version: {pd.__version__}")
    print(f"DuckDB version: {duckdb.__version__}")
    
    # Your code here
    
if __name__ == "__main__":
    main()
EOF

# Create example shell script
cat > scripts/shell/example.sh << 'EOF'
#!/bin/sh
# Example shell script

echo "🐚 Shell script running..."
echo "User: $(whoami)"
echo "Python: $(python3 --version)"
echo "DuckDB: $(duckdb --version)"
EOF

chmod +x scripts/shell/example.sh

echo ""
echo "✅ Project created successfully!"
echo ""
echo "📁 Project structure:"
echo "   $PROJECT_NAME/"
echo "   ├── .devcontainer/"
echo "   ├── data/"
echo "   │   ├── raw/"
echo "   │   ├── processed/"
echo "   │   └── output/"
echo "   ├── scripts/"
echo "   │   ├── python/"
echo "   │   └── shell/"
echo "   ├── tests/"
echo "   └── README.md"
echo ""
echo "🚀 Next steps:"
echo "   cd $PROJECT_NAME"
echo "   code ."
echo "   Press F1 → 'Dev Containers: Reopen in Container'"
echo ""
