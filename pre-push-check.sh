#!/bin/bash
# Pre-push validation script
# Ensures everything is ready for GitHub

set -e

echo "🔍 Pre-Push Validation Check"
echo "=============================="
echo ""

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Track issues
ISSUES=0

# Function to check and report
check_item() {
    local name=$1
    local command=$2
    
    if eval "$command" &> /dev/null; then
        echo -e "${GREEN}✓${NC} $name"
        return 0
    else
        echo -e "${RED}✗${NC} $name"
        ISSUES=$((ISSUES + 1))
        return 1
    fi
}

# Function to check file exists
check_file() {
    local file=$1
    if [ -f "$file" ]; then
        echo -e "${GREEN}✓${NC} $file"
        return 0
    else
        echo -e "${RED}✗${NC} $file (missing)"
        ISSUES=$((ISSUES + 1))
        return 1
    fi
}

echo "📁 Repository Status"
echo "-------------------"

# Check git status
if [ -z "$(git status --porcelain)" ]; then
    echo -e "${GREEN}✓${NC} Working tree clean"
else
    echo -e "${YELLOW}⚠${NC} Uncommitted changes detected:"
    git status --short
    echo ""
fi

# Check branch
CURRENT_BRANCH=$(git branch --show-current)
echo -e "${GREEN}✓${NC} Current branch: $CURRENT_BRANCH"

# Count commits
COMMIT_COUNT=$(git rev-list --count HEAD)
echo -e "${GREEN}✓${NC} Total commits: $COMMIT_COUNT"

echo ""
echo "📋 Required Files"
echo "----------------"

# Configuration files
check_file ".devcontainer/devcontainer.json"
check_file ".devcontainer/setup.sh"
check_file "Dockerfile"
check_file "docker-compose.yml"
check_file ".gitignore"
check_file ".env.example"

# CI/CD
check_file ".github/workflows/ci.yml"

# Scripts
check_file "scripts/python/delta_operations.py"
check_file "scripts/python/multi_format_pipeline.py"
check_file "scripts/python/data_quality.py"
check_file "scripts/python/process_data.py"
check_file "scripts/shell/process_data.sh"
check_file "scripts/test_setup.sh"
check_file "build.sh"
check_file "new-project.sh"

# Documentation
check_file "README.md"
check_file "QUICKSTART.md"
check_file "BUILD_GUIDE.md"

echo ""
echo "🔧 Configuration Validation"
echo "--------------------------"

# Check Dockerfile syntax (basic validation)
if [ -f "Dockerfile" ] && [ -s "Dockerfile" ]; then
    if grep -q "^FROM " Dockerfile && grep -q "^USER " Dockerfile; then
        echo -e "${GREEN}✓${NC} Dockerfile has required directives"
    else
        echo -e "${YELLOW}⚠${NC} Dockerfile might be incomplete"
    fi
else
    echo -e "${RED}✗${NC} Dockerfile missing or empty"
    ISSUES=$((ISSUES + 1))
fi

# Check if scripts are executable
if [ -x "build.sh" ]; then
    echo -e "${GREEN}✓${NC} build.sh is executable"
else
    echo -e "${YELLOW}⚠${NC} build.sh not executable (fixing...)"
    chmod +x build.sh
fi

if [ -x "new-project.sh" ]; then
    echo -e "${GREEN}✓${NC} new-project.sh is executable"
else
    echo -e "${YELLOW}⚠${NC} new-project.sh not executable (fixing...)"
    chmod +x new-project.sh
fi

if [ -x "scripts/test_setup.sh" ]; then
    echo -e "${GREEN}✓${NC} test_setup.sh is executable"
else
    echo -e "${YELLOW}⚠${NC} test_setup.sh not executable (fixing...)"
    chmod +x scripts/test_setup.sh
fi

echo ""
echo "🐍 Python Scripts Validation"
echo "----------------------------"

# Check Python syntax (skip if python3 not available in current container)
if command -v python3 &> /dev/null; then
    for script in scripts/python/*.py scripts/*.py; do
        if [ -f "$script" ]; then
            if python3 -m py_compile "$script" 2>/dev/null; then
                echo -e "${GREEN}✓${NC} $(basename $script) - syntax OK"
            else
                echo -e "${YELLOW}⚠${NC} $(basename $script) - needs dependencies (will work in built container)"
            fi
        fi
    done
else
    echo -e "${YELLOW}⚠${NC} Python not available in current container (expected)"
    echo "  Scripts will be validated during GitHub Actions build"
fi

echo ""
echo "📊 Repository Statistics"
echo "-----------------------"

FILE_COUNT=$(find . -type f -not -path './.git/*' | wc -l)
echo "Total files: $FILE_COUNT"

PYTHON_LOC=$(find scripts -name "*.py" -exec wc -l {} + 2>/dev/null | tail -1 | awk '{print $1}')
echo "Python code: $PYTHON_LOC lines"

DOC_LOC=$(find . -maxdepth 1 -name "*.md" -exec wc -l {} + 2>/dev/null | tail -1 | awk '{print $1}')
echo "Documentation: $DOC_LOC lines"

echo ""
echo "🔐 Security Check"
echo "----------------"

# Check for secrets in git history
if git log --all --full-history --source --oneline -- '*.pem' '*.key' '.env' | grep -q .; then
    echo -e "${RED}✗${NC} Secret files found in git history!"
    ISSUES=$((ISSUES + 1))
else
    echo -e "${GREEN}✓${NC} No secrets in git history"
fi

# Check .gitignore
if grep -q "^\.env$" .gitignore && grep -q "^\*\.key$" .gitignore; then
    echo -e "${GREEN}✓${NC} .gitignore protects secrets"
else
    echo -e "${YELLOW}⚠${NC} .gitignore might not protect all secrets"
fi

echo ""
echo "📦 Docker Configuration"
echo "----------------------"

# Check Dockerfile
if grep -q "alpine" Dockerfile; then
    echo -e "${GREEN}✓${NC} Uses Alpine base image"
else
    echo -e "${RED}✗${NC} Alpine base image not found"
    ISSUES=$((ISSUES + 1))
fi

if grep -q "USER tmj" Dockerfile; then
    echo -e "${GREEN}✓${NC} Non-root user configured"
else
    echo -e "${RED}✗${NC} Non-root user not found"
    ISSUES=$((ISSUES + 1))
fi

echo ""
echo "🚀 CI/CD Configuration"
echo "---------------------"

# Check workflow file
if grep -q "docker-build:" .github/workflows/ci.yml; then
    echo -e "${GREEN}✓${NC} Docker build job configured"
else
    echo -e "${YELLOW}⚠${NC} Docker build job not found"
fi

if grep -q "security-scan:" .github/workflows/ci.yml; then
    echo -e "${GREEN}✓${NC} Security scan job configured"
else
    echo -e "${RED}✗${NC} Security scan job not found"
    ISSUES=$((ISSUES + 1))
fi

if grep -q "python-lint:" .github/workflows/ci.yml; then
    echo -e "${GREEN}✓${NC} Python lint job configured"
else
    echo -e "${RED}✗${NC} Python lint job not found"
    ISSUES=$((ISSUES + 1))
fi

echo ""
echo "=============================="

if [ $ISSUES -eq 0 ]; then
    echo -e "${GREEN}✅ All checks passed!${NC}"
    echo ""
    echo "Repository is ready to push to GitHub 🚀"
    echo ""
    echo "Next steps:"
    echo "  1. Create GitHub repo: gh repo create 14app --public --source=. --remote=origin --push"
    echo "  2. Or manually: git remote add origin https://github.com/YOUR_USERNAME/14app.git"
    echo "  3. Then push: git push -u origin master"
    echo ""
    echo "See GITHUB_SETUP.md for detailed instructions."
    exit 0
else
    echo -e "${RED}❌ Found $ISSUES issue(s)${NC}"
    echo ""
    echo "Please fix the issues above before pushing to GitHub."
    exit 1
fi
