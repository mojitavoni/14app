# Complete Guide: Build and Use as Default DevContainer

## 🎯 Three Ways to Use This Environment

1. **Rebuild current container** (Quickest - for this project only)
2. **Build Docker image** (Reusable - use in any project)
3. **Publish to registry** (Team-wide - share with others)

---

## 🚀 Method 1: Rebuild Current Container (5 minutes)

### For This Project Only

```bash
# Just rebuild the container
# Press F1 in VS Code
# Type: "Dev Containers: Rebuild Container"
# Wait 8-10 minutes
```

**Pros**: 
- ✅ Quickest to get started
- ✅ No Docker knowledge needed

**Cons**:
- ❌ Only works for this project
- ❌ Must rebuild for each new project

---

## 🐳 Method 2: Build Docker Image (Recommended)

### Build Once, Use Everywhere

#### Step 1: Build the Image

```bash
# Navigate to project
cd /workspaces/14app

# Build Docker image
docker build -t dataops-env:latest .

# This takes 10-15 minutes first time
# Creates a 450MB reusable image
```

#### Step 2: Verify Image

```bash
# List images
docker images | grep dataops-env

# Should show:
# dataops-env   latest   abc123   2 minutes ago   450MB

# Test the image
docker run --rm -it dataops-env:latest python3 --version
docker run --rm -it dataops-env:latest duckdb --version
```

#### Step 3: Create Template for New Projects

```bash
# Copy template to your projects
mkdir -p ~/devcontainer-templates/dataops
cp .devcontainer/devcontainer.template.json ~/devcontainer-templates/dataops/devcontainer.json

# For any new project:
cd /path/to/new-project
mkdir .devcontainer
cp ~/devcontainer-templates/dataops/devcontainer.json .devcontainer/
```

#### Step 4: Use in VS Code

```bash
# In any project with .devcontainer/devcontainer.json:
# Press F1 → "Dev Containers: Reopen in Container"
# Uses your pre-built dataops-env:latest image
# Starts in ~30 seconds! ⚡
```

---

## 📦 Method 3: Publish to Registry (Team Use)

### Share with Your Team

#### Option A: Docker Hub (Public/Private)

```bash
# Login to Docker Hub
docker login

# Tag image
docker tag dataops-env:latest yourusername/dataops-env:latest

# Push to Docker Hub
docker push yourusername/dataops-env:latest

# Team members can now use:
# "image": "yourusername/dataops-env:latest"
```

#### Option B: Private Registry (AWS ECR)

```bash
# Login to AWS ECR
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin \
  123456789.dkr.ecr.us-east-1.amazonaws.com

# Tag image
docker tag dataops-env:latest \
  123456789.dkr.ecr.us-east-1.amazonaws.com/dataops-env:latest

# Push to ECR
docker push 123456789.dkr.ecr.us-east-1.amazonaws.com/dataops-env:latest

# Team uses:
# "image": "123456789.dkr.ecr.us-east-1.amazonaws.com/dataops-env:latest"
```

#### Option C: Azure Container Registry

```bash
# Login to ACR
az acr login --name myregistry

# Tag and push
docker tag dataops-env:latest myregistry.azurecr.io/dataops-env:latest
docker push myregistry.azurecr.io/dataops-env:latest
```

#### Option D: GitHub Container Registry

```bash
# Login to GitHub Container Registry
echo $GITHUB_TOKEN | docker login ghcr.io -u USERNAME --password-stdin

# Tag and push
docker tag dataops-env:latest ghcr.io/username/dataops-env:latest
docker push ghcr.io/username/dataops-env:latest
```

---

## 🔧 Set as Default for VS Code

### Make it Your Default DevContainer

#### Method A: User Settings (Global)

```bash
# Open VS Code settings
# Press Ctrl+, (or Cmd+, on Mac)
# Search: "dev containers default"

# Or edit settings.json directly:
{
  "dev.containers.defaultImage": "dataops-env:latest",
  "dev.containers.defaultExtensions": [
    "ms-python.python",
    "ms-python.vscode-pylance",
    "dbaeumer.vscode-eslint",
    "RandomFractalsInc.vscode-data-preview",
    "ms-azuretools.vscode-docker"
  ]
}
```

#### Method B: Workspace Template

Create a reusable template:

```bash
# Create template directory
mkdir -p ~/.vscode/devcontainer-templates/dataops

# Copy files
cp .devcontainer/devcontainer.template.json \
   ~/.vscode/devcontainer-templates/dataops/devcontainer.json

# Create new project with template
mkdir my-new-project
cd my-new-project
cp -r ~/.vscode/devcontainer-templates/dataops .devcontainer

# Open in VS Code
code .

# Press F1 → "Dev Containers: Reopen in Container"
```

#### Method C: Project Scaffolding Script

```bash
# Create a script for new projects
cat > ~/bin/new-dataops-project << 'EOF'
#!/bin/bash
PROJECT_NAME=$1

if [ -z "$PROJECT_NAME" ]; then
    echo "Usage: new-dataops-project <project-name>"
    exit 1
fi

mkdir -p "$PROJECT_NAME"
cd "$PROJECT_NAME"

# Create .devcontainer
mkdir -p .devcontainer
cat > .devcontainer/devcontainer.json << 'JSON'
{
  "name": "DataOps Project",
  "image": "dataops-env:latest",
  "remoteUser": "tmj",
  "workspaceFolder": "/workspace",
  "customizations": {
    "vscode": {
      "extensions": [
        "ms-python.python",
        "ms-python.vscode-pylance",
        "RandomFractalsInc.vscode-data-preview"
      ]
    }
  }
}
JSON

# Create project structure
mkdir -p data/{raw,processed,output}
mkdir -p scripts/{python,shell}

# Create .gitignore
cat > .gitignore << 'IGNORE'
data/raw/**
data/processed/**
data/output/**
*.duckdb
.env
IGNORE

echo "✅ Project '$PROJECT_NAME' created!"
echo "   Open with: code $PROJECT_NAME"
EOF

chmod +x ~/bin/new-dataops-project

# Use it:
new-dataops-project my-awesome-pipeline
```

---

## 🎨 Using with Docker Compose

### For Complex Setups

```bash
# Start with docker-compose
docker-compose up -d

# Attach VS Code to running container
# Press F1 → "Dev Containers: Attach to Running Container"
# Select: dataops-dev

# Or use in devcontainer.json:
{
  "dockerComposeFile": "docker-compose.yml",
  "service": "dataops",
  "workspaceFolder": "/workspace"
}
```

---

## 🔄 Updating the Image

### When You Need New Tools

```bash
# Edit Dockerfile (add new packages)
# Rebuild image
docker build -t dataops-env:latest .

# Tag with version
docker tag dataops-env:latest dataops-env:1.1.0

# Push updates
docker push yourusername/dataops-env:latest
docker push yourusername/dataops-env:1.1.0

# Team pulls latest
docker pull yourusername/dataops-env:latest

# Rebuild containers
# Press F1 → "Dev Containers: Rebuild Container"
```

---

## 📊 Comparison: Which Method?

| Method | Speed | Reusability | Team Sharing | Storage |
|--------|-------|-------------|--------------|---------|
| **Rebuild Container** | ⚡ Fast (30s) | ❌ No | ❌ No | Low |
| **Docker Image** | ⚡⚡ Very Fast (30s) | ✅ Yes | ⚠️  Local only | 450MB once |
| **Registry** | ⚡⚡⚡ Instant (5s) | ✅ Yes | ✅ Yes | Cloud |

### Recommendation:
- **Solo developer**: Method 2 (Docker Image)
- **Small team**: Method 3 (Private Registry)
- **Open source**: Method 3 (Docker Hub / GHCR)

---

## 🧪 Testing Your Setup

### After Building Image

```bash
# Test 1: Run container
docker run --rm -it dataops-env:latest /bin/sh

# Inside container, verify:
whoami          # Should be: tmj
python3 --version
duckdb --version
docker --version  # Won't work (needs Docker-in-Docker)

# Test 2: Run with volume
docker run --rm -it -v $(pwd):/workspace dataops-env:latest python3 -c "
import pandas as pd
import duckdb
import polars as pl
from deltalake import DeltaTable
print('✅ All imports successful!')
"

# Test 3: Run example script
docker run --rm -it -v $(pwd):/workspace dataops-env:latest \
  python3 scripts/python/multi_format_pipeline.py
```

---

## 🐛 Troubleshooting

### Image Build Fails

```bash
# Clear Docker cache
docker builder prune -a

# Build with no cache
docker build --no-cache -t dataops-env:latest .

# Check logs
docker build -t dataops-env:latest . 2>&1 | tee build.log
```

### Image Too Large

```bash
# Check image size
docker images dataops-env

# Analyze layers
docker history dataops-env:latest

# Optimize: Remove build dependencies after use
# (Already done in Dockerfile)
```

### Container Won't Start

```bash
# Check container logs
docker logs dataops-dev

# Run with debug
docker run --rm -it dataops-env:latest /bin/sh -c "
  python3 --version && \
  duckdb --version && \
  node --version
"
```

### VS Code Can't Find Image

```bash
# Verify image exists
docker images | grep dataops-env

# Pull from registry if using remote image
docker pull yourusername/dataops-env:latest

# Rebuild dev container
# Press F1 → "Dev Containers: Rebuild Container"
```

---

## 📝 Best Practices

### 1. Version Your Images

```bash
# Tag with semantic versioning
docker tag dataops-env:latest dataops-env:1.0.0
docker tag dataops-env:latest dataops-env:1.0
docker tag dataops-env:latest dataops-env:1
```

### 2. Use Multi-Stage Builds (Advanced)

```dockerfile
# Dockerfile.optimized
FROM alpine:3.19 AS builder
# ... install build tools, compile ...

FROM alpine:3.19
# ... copy only artifacts, smaller final image
```

### 3. Layer Caching

```bash
# Order Dockerfile commands by change frequency:
# 1. System packages (rarely change)
# 2. Language runtimes (occasionally change)
# 3. Application dependencies (often change)
# 4. Application code (very often change)
```

### 4. Security Scanning

```bash
# Scan image for vulnerabilities
docker scan dataops-env:latest

# Or use Trivy
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  aquasec/trivy:latest image dataops-env:latest
```

---

## 🎯 Quick Reference Commands

```bash
# Build image
docker build -t dataops-env:latest .

# Run container
docker run --rm -it -v $(pwd):/workspace dataops-env:latest

# Start with compose
docker-compose up -d

# Stop compose
docker-compose down

# Push to registry
docker push yourusername/dataops-env:latest

# Pull from registry
docker pull yourusername/dataops-env:latest

# List images
docker images | grep dataops

# Remove image
docker rmi dataops-env:latest

# Clean up
docker system prune -a
```

---

## ✅ Success Checklist

After setup, you should be able to:

- [ ] Build Docker image successfully (~10 minutes)
- [ ] Image size is ~450MB
- [ ] Run container as user `tmj`
- [ ] Python, Node.js, DuckDB available
- [ ] Create new project with template in <1 minute
- [ ] Open any project with DevContainer in <30 seconds
- [ ] Access all data formats (Parquet, Delta, XML, etc.)
- [ ] Run example scripts without errors

---

## 🎉 You're Done!

Now you have a **reusable, production-ready DataOps environment** that:
- ✅ Builds once, uses everywhere
- ✅ Starts in 30 seconds
- ✅ Works across all your projects
- ✅ Can be shared with your team

**Next**: Create a new project and test it!

```bash
# Try it:
new-dataops-project test-project
cd test-project
code .
# Press F1 → "Dev Containers: Reopen in Container"
```

---

**Minimal Developer Environment - DataOps**  
*Build once. Use everywhere. 450MB.*
