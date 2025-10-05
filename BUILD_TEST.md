# 🧪 BUILD & TEST INSTRUCTIONS

## Current Status
✅ All configuration files created
✅ Dockerfile ready
✅ Scripts ready
✅ Documentation complete
⏳ **Next**: Rebuild container with new config

---

## 🚀 STEP-BY-STEP: Build & Test

### Option A: Rebuild Current Container (Recommended First)

This will rebuild THIS container with all the DataOps tools.

#### Step 1: Rebuild Container
```
1. Press F1 (or Cmd+Shift+P on Mac)
2. Type: "Dev Containers: Rebuild Container"
3. Click it
4. Wait 8-10 minutes (downloads & installs everything)
```

**What happens:**
- Downloads Alpine Linux base
- Installs Python 3.12, Node.js 20, PowerShell
- Installs Docker-in-Docker
- Installs DuckDB, Delta Lake, all data libraries
- Creates user 'tmj'
- Total: ~450MB

#### Step 2: After Rebuild - Test Installation
```bash
# Run test script
sh scripts/test_setup.sh

# Should show:
# ✅ DuckDB
# ✅ Python + all libraries
# ✅ Node.js + packages
# ✅ Docker
# ✅ All data format support
```

#### Step 3: Build Reusable Docker Image
```bash
# Now Docker-in-Docker is available!
./build.sh

# Or manually:
docker build -t dataops-env:latest .
```

---

### Option B: Build Directly (If Docker Available on Host)

If you have Docker on your host machine (outside VS Code):

```bash
# On your host machine (not in container):
cd /path/to/14app

# Build image
docker build -t dataops-env:latest .

# Test image
docker run --rm -it dataops-env:latest /bin/sh

# Inside container:
whoami          # Should be: tmj
python3 --version
duckdb --version
```

---

## 🧪 TEST SEQUENCE

### Test 1: Verify Current Setup
```bash
# Check files are in place
ls -lh Dockerfile
ls -lh docker-compose.yml
ls -lh build.sh
ls -lh new-project.sh

# All should exist ✅
```

### Test 2: After Container Rebuild
```bash
# Check user
whoami
# Expected: tmj

# Check tools
python3 --version
node --version
duckdb --version
docker --version

# Check Python packages
python3 -c "import pandas, polars, duckdb; print('✅ Imports work!')"
python3 -c "from deltalake import DeltaTable; print('✅ Delta Lake works!')"

# Run full test
sh scripts/test_setup.sh
```

### Test 3: Build Docker Image
```bash
# Build reusable image
docker build -t dataops-env:latest .

# Check image size
docker images | grep dataops-env
# Expected: ~450MB

# Test image
docker run --rm dataops-env:latest python3 -c "
import pandas as pd
import duckdb
import polars as pl
from deltalake import DeltaTable
print('✅ All libraries working in image!')
"
```

### Test 4: Create New Project
```bash
# Create test project
./new-project.sh test-pipeline

# Check structure
ls -la test-pipeline/
# Should have: .devcontainer/, data/, scripts/, README.md

# Open in VS Code
cd test-pipeline
code .

# Reopen in container
# F1 → "Dev Containers: Reopen in Container"
# Should start in ~30 seconds using pre-built image!
```

### Test 5: Test Data Processing
```bash
# Create sample data
echo "id,name,value,date
1,Alice,100,2024-01-01
2,Bob,200,2024-01-02
3,Charlie,300,2024-01-03" > data/raw/sample.csv

# Query with DuckDB
duckdb -c "SELECT * FROM 'data/raw/sample.csv'"

# Convert to Parquet
duckdb -c "COPY (SELECT * FROM 'data/raw/sample.csv') TO 'data/output/sample.parquet'"

# Check file size (should be ~10x smaller)
ls -lh data/raw/sample.csv data/output/sample.parquet

# Test Delta Lake
python3 scripts/python/delta_operations.py data/raw/sample.csv

# Test multi-format pipeline
python3 -c "
from scripts.python.multi_format_pipeline import DataPipeline
pipeline = DataPipeline()
df = pipeline.read_csv('data/raw/sample.csv')
pipeline.write_parquet(df, 'test.parquet')
print('✅ Pipeline works!')
"
```

---

## 📋 EXPECTED RESULTS

### After Rebuild (Test 2)
```
✅ User: tmj (not root)
✅ Python: 3.12.x
✅ Node.js: 20.x
✅ DuckDB: 0.10.x
✅ Docker: Available
✅ All Python packages installed
✅ All Node packages installed
✅ Text tools: awk, sed, grep, jq, yq
```

### After Image Build (Test 3)
```
✅ Image: dataops-env:latest
✅ Size: ~450MB
✅ All tests pass
✅ Can run standalone
```

### After New Project (Test 4)
```
✅ Project created in <1 minute
✅ Container starts in ~30 seconds
✅ All tools available immediately
✅ No rebuild needed
```

---

## 🐛 TROUBLESHOOTING

### Container Rebuild Fails
```bash
# Clear VS Code cache
# Press F1 → "Dev Containers: Rebuild Without Cache"

# Or restart Docker
# Restart Docker Desktop and try again
```

### Docker Build Fails
```bash
# Check Docker is running
docker ps

# Clear Docker cache
docker system prune -a

# Build with verbose output
docker build --progress=plain -t dataops-env:latest . 2>&1 | tee build.log
```

### Python Package Fails (Alpine)
```bash
# Some packages need build tools
sudo apk add --no-cache gcc musl-dev python3-dev

# Then retry
pip install <package>
```

### Image Too Large
```bash
# Check what's taking space
docker history dataops-env:latest --human

# Layers are already optimized in Dockerfile
# ~450MB is expected for full DataOps environment
```

---

## ✅ SUCCESS CRITERIA

You know it works when:

- [ ] Container rebuilds without errors (8-10 min)
- [ ] User is 'tmj' (not root)
- [ ] `sh scripts/test_setup.sh` passes all checks
- [ ] Docker is available inside container
- [ ] Can build image: `docker build -t dataops-env:latest .`
- [ ] Image is ~450MB
- [ ] Can create new project: `./new-project.sh test`
- [ ] New project opens in <30 seconds
- [ ] Sample data processing works
- [ ] Delta Lake operations work

---

## 🎯 RECOMMENDED SEQUENCE

```bash
# 1. Rebuild THIS container first
# F1 → "Dev Containers: Rebuild Container"
# ⏱️  8-10 minutes

# 2. After rebuild, test setup
sh scripts/test_setup.sh

# 3. Build Docker image for reuse
./build.sh
# ⏱️  10-15 minutes

# 4. Create test project
./new-project.sh test-pipeline
cd test-pipeline
code .

# 5. Open in container
# F1 → "Dev Containers: Reopen in Container"
# ⏱️  30 seconds (using pre-built image!)

# 6. Test data processing
echo "id,value
1,100
2,200" > data/raw/test.csv

duckdb -c "SELECT * FROM 'data/raw/test.csv'"

# 7. Success! 🎉
```

---

## 📞 NEXT STEPS AFTER SUCCESSFUL BUILD

1. **Use in this project**: Already done! ✅
2. **Create new projects**: `./new-project.sh <name>`
3. **Share with team**: `docker push yourusername/dataops-env:latest`
4. **Set as default**: Add to VS Code settings (see BUILD_GUIDE.md)

---

## ⏱️ TIME ESTIMATES

| Task | First Time | Subsequent |
|------|-----------|------------|
| Rebuild container | 8-10 min | 2-3 min (cached) |
| Build Docker image | 10-15 min | 2-3 min (cached) |
| Create new project | 30 sec | 30 sec |
| Open in container | 8-10 min (first) | 30 sec (with image) |

**Total first setup**: ~20-25 minutes  
**Future project starts**: 30 seconds ⚡

---

## 🎉 YOU'RE READY!

**Start now**:
1. Press **F1**
2. Type: **"Dev Containers: Rebuild Container"**
3. Wait for completion
4. Run: `sh scripts/test_setup.sh`

See you on the other side! 🚀
