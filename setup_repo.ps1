<#
.SYNOPSIS
    Initialises the qscanner-demo git repository with multiple branches.

.DESCRIPTION
    Run this script once from the qscanner-demo directory to:
      - git init
      - Create main, develop, feature/auth, and release/v1.0 branches
      - Commit different content per branch to simulate a real multi-branch repo
      - (Optionally) add a GitHub remote and push all branches

.USAGE
    cd "qscanner-demo"
    .\setup_repo.ps1
    # or with GitHub push:
    .\setup_repo.ps1 -Remote https://github.com/<your-org>/qscanner-demo.git
#>

param(
    [string]$Remote = ""
)

$ErrorActionPreference = "Stop"

function Write-Step($msg) { Write-Host "`n==> $msg" -ForegroundColor Cyan }

# ── Init ──────────────────────────────────────────────────────────────────────
Write-Step "Initialising git repository"
git init
git config user.email "demo@qualys.com"
git config user.name  "qscanner Demo"

# ── main branch ───────────────────────────────────────────────────────────────
Write-Step "Committing to main"
git add .
git commit -m "Initial commit: vulnerable apps + CI workflows"

# ── develop branch ────────────────────────────────────────────────────────────
Write-Step "Creating develop branch"
git checkout -b develop

Add-Content -Path "apps\python-app\requirements.txt" -Value "SQLAlchemy==1.4.46`nparamiko==2.10.1"
Add-Content -Path "apps\node-app\package.json"       -Value ""  # touch

git add apps\python-app\requirements.txt
git commit -m "develop: add SQLAlchemy + paramiko (CVE-flagged versions)"

# add db helper (develop-only file)
Copy-Item "apps\python-app\db.py" "apps\python-app\db_develop.py" -ErrorAction SilentlyContinue
git add apps\python-app\db.py
git commit -m "develop: add vulnerable DB helper (pickle deserialization)"

# ── feature/auth branch ───────────────────────────────────────────────────────
Write-Step "Creating feature/auth branch (from develop)"
git checkout -b feature/auth

git add apps\python-app\auth.py
git commit -m "feature/auth: add JWT auth module (weak MD5, no sig verify)"

# ── release/v1.0 branch ───────────────────────────────────────────────────────
Write-Step "Creating release/v1.0 branch (from main)"
git checkout main
git checkout -b release/v1.0

# Pin even older package versions on release branch
(Get-Content "apps\python-app\requirements.txt") `
    -replace "requests==2.28.0",  "requests==2.25.0" `
    -replace "urllib3==1.26.14",  "urllib3==1.24.0" `
    -replace "Werkzeug==2.2.2",   "Werkzeug==1.0.0" |
    Set-Content "apps\python-app\requirements.txt"

git add apps\python-app\requirements.txt
git commit -m "release/v1.0: pin older package versions (more CVEs)"

# ── back to main ──────────────────────────────────────────────────────────────
Write-Step "Returning to main"
git checkout main

# ── Optional remote push ──────────────────────────────────────────────────────
if ($Remote -ne "") {
    Write-Step "Adding remote and pushing all branches"
    git remote add origin $Remote
    git push -u origin main
    git push origin develop
    git push origin feature/auth
    git push origin "release/v1.0"
    Write-Host "`n[Done] All branches pushed to $Remote" -ForegroundColor Green
} else {
    Write-Host "`n[Done] Local repo ready. Branches created:" -ForegroundColor Green
    git branch -a
    Write-Host "`nTo push to GitHub, re-run with:" -ForegroundColor Yellow
    Write-Host "  .\setup_repo.ps1 -Remote https://github.com/<org>/qscanner-demo.git"
}
