#!/bin/bash
# Quick command reference for GitHub deployment
# Source this file or run individual commands

cat << 'EOF'

╔════════════════════════════════════════════════════════════════╗
║              GITHUB DEPLOYMENT - QUICK REFERENCE               ║
╚════════════════════════════════════════════════════════════════╝

┌─────────────────────────────────────────────────────────────────┐
│ 🚀 PUSH TO GITHUB (Choose One)                                 │
└─────────────────────────────────────────────────────────────────┘

  ⭐ Automated (Recommended):
     ./github-push.sh 14app public

  📱 GitHub CLI:
     gh auth login
     gh repo create 14app --public --source=. --remote=origin --push

  ✍️  Manual:
     # 1. Create repo at https://github.com/new
     # 2. Then:
     git remote add origin https://github.com/YOUR_USERNAME/14app.git
     git push -u origin master

┌─────────────────────────────────────────────────────────────────┐
│ ✅ VALIDATION                                                   │
└─────────────────────────────────────────────────────────────────┘

  Pre-push check:
     ./pre-push-check.sh

  Git status:
     git status
     git log --oneline | head -10

  File count:
     find . -type f -not -path './.git/*' | wc -l

┌─────────────────────────────────────────────────────────────────┐
│ 👀 MONITOR BUILDS                                               │
└─────────────────────────────────────────────────────────────────┘

  Watch live build:
     gh run watch

  List recent runs:
     gh run list --limit 5

  View specific run:
     gh run view

  View logs:
     gh run view --log

  Re-run failed jobs:
     gh run rerun

┌─────────────────────────────────────────────────────────────────┐
│ 🔧 REPOSITORY MANAGEMENT                                        │
└─────────────────────────────────────────────────────────────────┘

  View in browser:
     gh repo view --web

  View Actions tab:
     open https://github.com/YOUR_USERNAME/14app/actions

  Add topics:
     gh repo edit --add-topic dataops
     gh repo edit --add-topic devcontainer

  Clone for testing:
     git clone https://github.com/YOUR_USERNAME/14app.git

┌─────────────────────────────────────────────────────────────────┐
│ 🐛 TROUBLESHOOTING                                              │
└─────────────────────────────────────────────────────────────────┘

  Check remote:
     git remote -v

  Re-authenticate:
     gh auth logout
     gh auth login

  Force push (CAREFUL!):
     git push --force-with-lease origin master

  View workflow files:
     cat .github/workflows/ci.yml

┌─────────────────────────────────────────────────────────────────┐
│ 📚 DOCUMENTATION                                                │
└─────────────────────────────────────────────────────────────────┘

  • READY_TO_PUSH.md    - Complete deployment guide
  • GITHUB_SETUP.md     - Detailed GitHub setup
  • README.md           - Main documentation
  • QUICKSTART.md       - One-page reference
  • BUILD_GUIDE.md      - Build instructions
  • BUILD_TEST.md       - Testing guide

┌─────────────────────────────────────────────────────────────────┐
│ ⏱️  EXPECTED RESULTS                                            │
└─────────────────────────────────────────────────────────────────┘

  Build Jobs:
     ✓ Security Scan:  2-3 minutes
     ✓ Python Lint:    1-2 minutes
     ✓ Docker Build:   8-12 minutes (first time)
     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
     Total:           ~15 minutes (first build)

  Success Indicators:
     ✓ All 3 jobs with green checkmarks
     ✓ No critical vulnerabilities
     ✓ Python code passes linting
     ✓ Docker image builds successfully
     ✓ Runtime tests pass

┌─────────────────────────────────────────────────────────────────┐
│ 🎯 WORKFLOW                                                     │
└─────────────────────────────────────────────────────────────────┘

  1. Validate:  ./pre-push-check.sh
  2. Push:      ./github-push.sh 14app public
  3. Monitor:   gh run watch
  4. Verify:    gh repo view --web

  Future pushes:
     git add .
     git commit -m "feat: description"
     git push origin master
     # Build triggers automatically!

╔════════════════════════════════════════════════════════════════╗
║                    ✨ READY TO DEPLOY! 🚀                      ║
╚════════════════════════════════════════════════════════════════╝

EOF
