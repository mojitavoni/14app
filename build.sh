#!/bin/bash
# Quick setup script for Minimal Developer Environment - DataOps

set -e

echo "🚀 Setting up Minimal Developer Environment - DataOps"
echo ""

# Check Docker is available
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed or not running"
    echo "   Please install Docker Desktop and try again"
    exit 1
fi

echo "✅ Docker found: $(docker --version)"
echo ""

# Check if image already exists
if docker images | grep -q "dataops-env.*latest"; then
    echo "⚠️  Image 'dataops-env:latest' already exists"
    read -p "   Rebuild? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "   Skipping build"
        exit 0
    fi
fi

echo "🔨 Building Docker image (this takes 10-15 minutes first time)..."
echo ""

# Build image
docker build -t dataops-env:latest .

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Build successful!"
    echo ""
    echo "📊 Image details:"
    docker images dataops-env:latest
    echo ""
    echo "🧪 Testing image..."
    docker run --rm dataops-env:latest python3 -c "
import pandas, polars, duckdb
from deltalake import DeltaTable
print('✅ All Python libraries working!')
" && echo "✅ Image tests passed!"
    
    echo ""
    echo "🎉 Setup complete!"
    echo ""
    echo "📝 Next steps:"
    echo "   1. Use in this project:"
    echo "      Press F1 → 'Dev Containers: Rebuild Container'"
    echo ""
    echo "   2. Create new project with this image:"
    echo "      mkdir my-project && cd my-project"
    echo "      mkdir .devcontainer"
    echo "      cp .devcontainer/devcontainer.template.json .devcontainer/devcontainer.json"
    echo "      code ."
    echo "      Press F1 → 'Dev Containers: Reopen in Container'"
    echo ""
    echo "   3. Share with team (optional):"
    echo "      docker tag dataops-env:latest yourusername/dataops-env:latest"
    echo "      docker push yourusername/dataops-env:latest"
    echo ""
else
    echo "❌ Build failed!"
    echo "   Check errors above and try again"
    exit 1
fi
