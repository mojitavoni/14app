#!/bin/bash
# Quick GitHub repository setup and push
# Usage: ./github-push.sh [repository-name] [visibility]
#
# Examples:
#   ./github-push.sh 14app public
#   ./github-push.sh my-dataops-env private

set -e

# Default values
REPO_NAME="${1:-14app}"
VISIBILITY="${2:-public}"

echo "🚀 GitHub Repository Setup"
echo "=========================="
echo ""
echo "Repository: $REPO_NAME"
echo "Visibility: $VISIBILITY"
echo ""

# Check if gh is installed
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI (gh) not found!"
    echo ""
    echo "Install it from: https://cli.github.com/"
    echo ""
    echo "Or use manual setup:"
    echo "  1. Create repo at https://github.com/new"
    echo "  2. git remote add origin https://github.com/YOUR_USERNAME/$REPO_NAME.git"
    echo "  3. git push -u origin master"
    exit 1
fi

# Check if logged in
if ! gh auth status &> /dev/null; then
    echo "🔐 Not logged in to GitHub. Starting authentication..."
    gh auth login
fi

echo "✓ Authenticated with GitHub"
echo ""

# Run pre-push validation
echo "🔍 Running pre-push validation..."
if [ -f "pre-push-check.sh" ]; then
    if ./pre-push-check.sh; then
        echo ""
    else
        echo ""
        echo "❌ Pre-push validation failed!"
        echo "Please fix the issues and try again."
        exit 1
    fi
fi

# Check if remote already exists
if git remote | grep -q "^origin$"; then
    echo "⚠️  Remote 'origin' already exists:"
    git remote -v | grep origin
    echo ""
    read -p "Do you want to replace it? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git remote remove origin
        echo "✓ Removed old remote"
    else
        echo "Keeping existing remote. Skipping repository creation."
        echo ""
        echo "To push manually:"
        echo "  git push origin master"
        exit 0
    fi
fi

# Create repository
echo "📦 Creating GitHub repository..."
if gh repo create "$REPO_NAME" \
    --"$VISIBILITY" \
    --description "Minimal DataOps Development Environment - Alpine-based devcontainer with Python, Node.js, DuckDB, Delta Lake" \
    --source=. \
    --remote=origin \
    --push; then
    
    echo ""
    echo "✅ Repository created and pushed successfully!"
    echo ""
    
    # Add topics
    echo "🏷️  Adding repository topics..."
    gh repo edit --add-topic dataops
    gh repo edit --add-topic devcontainer
    gh repo edit --add-topic docker
    gh repo edit --add-topic python
    gh repo edit --add-topic duckdb
    gh repo edit --add-topic delta-lake
    gh repo edit --add-topic alpine-linux
    echo "✓ Topics added"
    echo ""
    
    # Get repository info
    REPO_URL=$(gh repo view --json url -q .url)
    ACTIONS_URL="${REPO_URL}/actions"
    
    echo "=============================="
    echo "✨ Setup Complete!"
    echo "=============================="
    echo ""
    echo "📍 Repository: $REPO_URL"
    echo "🔧 Actions: $ACTIONS_URL"
    echo ""
    echo "🎯 Next Steps:"
    echo "  1. Visit $ACTIONS_URL to watch builds"
    echo "  2. First CI/CD run should start automatically"
    echo "  3. Builds will run on every push to master"
    echo ""
    echo "📊 Expected build time:"
    echo "  - Security Scan: ~2-3 minutes"
    echo "  - Python Lint: ~1-2 minutes"
    echo "  - Docker Build: ~8-12 minutes (first time)"
    echo "  - Total: ~12-15 minutes"
    echo ""
    echo "To watch builds:"
    echo "  gh run watch"
    echo ""
    echo "To view repository:"
    echo "  gh repo view --web"
    echo ""
    
else
    echo ""
    echo "❌ Failed to create repository!"
    echo ""
    echo "Try manual setup:"
    echo "  1. Go to https://github.com/new"
    echo "  2. Repository name: $REPO_NAME"
    echo "  3. Visibility: $VISIBILITY"
    echo "  4. Create without README/license/.gitignore"
    echo "  5. Then run:"
    echo "     git remote add origin https://github.com/YOUR_USERNAME/$REPO_NAME.git"
    echo "     git push -u origin master"
    exit 1
fi
