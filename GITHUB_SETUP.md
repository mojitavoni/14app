# GitHub Repository Setup Guide

Complete checklist for pushing to GitHub and triggering builds.

---

## ✅ Pre-Push Checklist

### 1. Local Repository Status
```bash
# Check git status
git status

# View commit history
git log --oneline --graph | head -10

# Verify all files are committed
git diff HEAD
```

**Expected**: Clean working tree, no uncommitted changes

---

### 2. Create GitHub Repository

#### Option A: GitHub CLI (Recommended)
```bash
# Install GitHub CLI if not available
# Already available in this devcontainer

# Login to GitHub
gh auth login

# Create repository
gh repo create 14app \
  --public \
  --description "Minimal DataOps Development Environment - Alpine-based devcontainer with Python, Node.js, DuckDB, Delta Lake, and Docker-in-Docker support" \
  --source=. \
  --remote=origin \
  --push
```

#### Option B: GitHub Web UI
1. Go to https://github.com/new
2. Repository name: `14app`
3. Description: `Minimal DataOps Development Environment`
4. Visibility: **Public** (or Private)
5. **DO NOT** initialize with README, .gitignore, or license
6. Click "Create repository"

Then connect:
```bash
git remote add origin https://github.com/YOUR_USERNAME/14app.git
git branch -M master
git push -u origin master
```

---

## 🚀 Push to GitHub

### First Push
```bash
# Verify remote is set
git remote -v

# Push master branch with all history
git push -u origin master

# Push tags (if any)
git push --tags
```

### Subsequent Pushes
```bash
git push origin master
```

---

## 🔍 Verification Checklist

After pushing, verify on GitHub:

### Repository Files
- [ ] All 30 files are present
- [ ] README.md displays correctly
- [ ] `.github/workflows/ci.yml` is visible
- [ ] Documentation files (BUILD_GUIDE, QUICKSTART, etc.) are accessible

### GitHub Actions
1. Go to **Actions** tab
2. Should see "CI/CD Pipeline" workflow
3. First run should trigger automatically after push

### Expected Workflow Jobs
- [ ] **Security Scan** - Trivy vulnerability scanning
- [ ] **Python Code Quality** - Pylint + Black formatting
- [ ] **Docker Build Test** - Build and test image

### Check Workflow Status
```bash
# Using GitHub CLI
gh run list --limit 5

# View specific run details
gh run view

# Watch live workflow
gh run watch
```

---

## 🐛 Troubleshooting

### Issue: No Remote Configured
```bash
# Check remotes
git remote -v

# Add remote
git remote add origin https://github.com/YOUR_USERNAME/14app.git
```

### Issue: Push Rejected (Force Push Needed)
```bash
# Only if you rewrote history and remote has old commits
git push --force-with-lease origin master
```

⚠️ **Warning**: Only use `--force-with-lease` if you're sure!

### Issue: GitHub Actions Not Running
1. Go to repository **Settings** → **Actions** → **General**
2. Ensure "Allow all actions and reusable workflows" is enabled
3. Check workflow file syntax: https://www.actionslint.co/

### Issue: Docker Build Fails
Common causes:
- Missing Dockerfile (should be in root)
- Syntax errors in Dockerfile
- Base image pull issues

Check logs:
```bash
gh run view --log
```

### Issue: Security Scan Fails
- May require permissions for GitHub Security tab
- Go to **Settings** → **Code security and analysis**
- Enable "Dependency graph" and "Dependabot alerts"

---

## 📋 Files Checklist

Ensure these key files are present:

### Configuration
- [x] `.devcontainer/devcontainer.json`
- [x] `.devcontainer/setup.sh`
- [x] `Dockerfile`
- [x] `docker-compose.yml`
- [x] `.env.example`
- [x] `.gitignore`

### CI/CD
- [x] `.github/workflows/ci.yml`

### Scripts
- [x] `scripts/python/` (4 files)
- [x] `scripts/shell/` (3 files)
- [x] `scripts/nodejs/` (1 file)
- [x] `scripts/test_setup.sh`
- [x] `scripts/validate_data.py`

### Automation
- [x] `build.sh`
- [x] `new-project.sh`

### Documentation
- [x] `README.md`
- [x] `QUICKSTART.md`
- [x] `BUILD_GUIDE.md`
- [x] `BUILD_TEST.md`
- [x] `USAGE_GUIDE.md`
- [x] `SETUP.md`
- [x] `MIGRATION.md`
- [x] `DEVELOPMENT_TIMELINE.md`

---

## 🎯 Expected Build Results

### Build Time
- **Security Scan**: ~2-3 minutes
- **Python Lint**: ~1-2 minutes
- **Docker Build**: ~8-12 minutes (first time)
- **Docker Build**: ~2-3 minutes (cached)

### Build Artifacts
- Security SARIF report uploaded to GitHub Security
- Docker image built (not pushed, just tested)
- Lint results in workflow logs

### Success Indicators
✅ All jobs complete with green checkmarks  
✅ No critical security vulnerabilities found  
✅ Python linting passes or has acceptable warnings  
✅ Docker image builds successfully  
✅ Runtime tests pass (Python, Node, DuckDB versions)

---

## 🔐 Security Considerations

### Secrets (DO NOT COMMIT)
The `.gitignore` already protects:
- `.env` files
- `*.pem`, `*.key` files
- `secrets/` directory

### Add GitHub Secrets (if needed)
For Docker registry push:
1. Go to **Settings** → **Secrets and variables** → **Actions**
2. Add secrets:
   - `DOCKER_USERNAME`
   - `DOCKER_PASSWORD`
   - `DOCKER_REGISTRY` (optional)

---

## 📊 Post-Push Actions

### 1. Add Repository Description
```bash
gh repo edit --description "Minimal DataOps Development Environment - Alpine-based devcontainer with Python, Node.js, DuckDB, Delta Lake"
```

### 2. Add Topics
```bash
gh repo edit --add-topic dataops
gh repo edit --add-topic devcontainer
gh repo edit --add-topic docker
gh repo edit --add-topic python
gh repo edit --add-topic duckdb
gh repo edit --add-topic delta-lake
gh repo edit --add-topic alpine-linux
```

### 3. Enable GitHub Pages (Optional)
For documentation hosting:
1. Go to **Settings** → **Pages**
2. Source: Deploy from a branch
3. Branch: `master` → `/docs` (if you have docs folder)

### 4. Configure Branch Protection (Optional)
```bash
gh api repos/{owner}/{repo}/branches/master/protection \
  --method PUT \
  --field required_status_checks[strict]=true \
  --field required_status_checks[contexts][]=security-scan \
  --field required_status_checks[contexts][]=python-lint
```

---

## 🎉 Success Confirmation

Once everything is pushed and building:

1. **Repository is live**: https://github.com/YOUR_USERNAME/14app
2. **Actions are running**: https://github.com/YOUR_USERNAME/14app/actions
3. **First build completes**: Check for green checkmark
4. **README displays**: Well-formatted with all sections

### Share Your Repository
```bash
# Get repository URL
gh repo view --web

# Clone command for others
echo "git clone https://github.com/YOUR_USERNAME/14app.git"
```

---

## 📞 Quick Reference Commands

```bash
# Check status
git status
git log --oneline | head -5
git remote -v

# Create and push
gh repo create 14app --public --source=. --remote=origin --push

# Or manually
git remote add origin https://github.com/YOUR_USERNAME/14app.git
git push -u origin master

# Verify
gh repo view
gh run list
gh run watch

# View build logs
gh run view --log
```

---

## 🔄 Continuous Development

After initial push, your workflow:

```bash
# Make changes
vim some_file.py

# Commit
git add some_file.py
git commit -m "feat: add new feature"

# Push (triggers build automatically)
git push origin master

# Watch build
gh run watch
```

Every push to `master` branch triggers:
- Security scanning
- Python linting
- Docker build test

---

## ✨ Ready to Go!

Your repository is fully configured with:
- ✅ Clean git history (weekend development)
- ✅ Minimal configuration (~450MB environment)
- ✅ Complete documentation (8 guides)
- ✅ Production-ready CI/CD
- ✅ Docker build automation
- ✅ Security scanning

**Next Step**: Push to GitHub and watch it build! 🚀

