# 🚀 Quick Start - Make This Your Default DevContainer

## Three Simple Steps

### ⚡ Step 1: Build the Image (10 minutes, once)

```bash
# Run the build script
./build.sh

# Or manually:
docker build -t dataops-env:latest .
```

### ⚡ Step 2: Use It Everywhere

```bash
# Create new project with template
./new-project.sh my-awesome-pipeline

# Open in VS Code
cd my-awesome-pipeline
code .

# Reopen in container (30 seconds!)
# Press F1 → "Dev Containers: Reopen in Container"
```

### ⚡ Step 3: Share with Team (Optional)

```bash
# Tag and push to Docker Hub
docker tag dataops-env:latest yourusername/dataops-env:latest
docker push yourusername/dataops-env:latest

# Team members use:
# "image": "yourusername/dataops-env:latest"
```

---

## 📋 One-Liner Commands

### Build Image
```bash
./build.sh
```

### Create New Project
```bash
./new-project.sh my-project && cd my-project && code .
```

### Test Image
```bash
docker run --rm -it dataops-env:latest python3 -c "import pandas, duckdb; print('✅ Works!')"
```

### Update Image
```bash
docker build -t dataops-env:latest . && docker push yourusername/dataops-env:latest
```

---

## 🎯 What You Get

After building once:
- ✅ **30-second** container starts (vs 10-minute rebuilds)
- ✅ **450MB** reusable image
- ✅ Works in **any project**
- ✅ **Consistent** environment everywhere
- ✅ **Shareable** with your team

---

## 📚 Full Documentation

- **BUILD_GUIDE.md** - Complete guide (3 methods, troubleshooting)
- **USAGE_GUIDE.md** - Usage patterns
- **README.md** - DataOps features and examples
- **MIGRATION.md** - Transformation details

---

## 🔧 VS Code Settings (Optional)

Make it truly default:

```json
// settings.json (Ctrl+, → search "dev containers")
{
  "dev.containers.defaultImage": "dataops-env:latest",
  "dev.containers.defaultExtensions": [
    "ms-python.python",
    "RandomFractalsInc.vscode-data-preview"
  ]
}
```

---

## ✅ Verification

After building:

```bash
# Check image exists
docker images | grep dataops-env

# Should show:
# dataops-env   latest   abc123   5 mins ago   450MB

# Test it
docker run --rm dataops-env:latest python3 --version
docker run --rm dataops-env:latest duckdb --version
docker run --rm dataops-env:latest node --version
```

---

## 🎉 Done!

You now have a production-ready DataOps environment that:
- Starts in 30 seconds
- Works across all projects
- Supports all data formats
- Is 450MB total
- Can be shared with team

**Next**: `./new-project.sh my-first-pipeline`

---

**Questions?** Check BUILD_GUIDE.md for complete instructions.
