# qscanner-demo

> **WARNING**: All code here contains intentional security vulnerabilities for Qualys qscanner demo purposes only. Never deploy in production.

## Repo Structure

```
qscanner-demo/
├── .github/workflows/
│   ├── docker-build-push.yml      ← CI: builds + pushes images (intentionally misconfigured)
│   └── qscanner-code-scan.yml     ← CI: runs qscanner code + pipeline scan
├── apps/
│   ├── python-app/
│   │   ├── app.py                 ← Vulnerable Flask app
│   │   ├── auth.py                ← Weak JWT auth (feature/auth branch)
│   │   ├── db.py                  ← Pickle deserialization (develop branch)
│   │   ├── requirements.txt       ← CVE-flagged packages
│   │   └── Dockerfile
│   └── node-app/
│       ├── index.js               ← Vulnerable Express app
│       ├── package.json           ← CVE-flagged npm packages
│       └── Dockerfile
├── setup_repo.ps1                 ← One-time git init + branch setup
└── README.md
```

## Branches

| Branch | Purpose |
|---|---|
| `main` | Base — Flask + Express apps, Dockerfiles, CI workflows |
| `develop` | Adds SQLAlchemy, paramiko, pickle-based DB module |
| `feature/auth` | Adds weak JWT auth (MD5, no signature verification) |
| `release/v1.0` | Older pinned package versions (more CVEs) |

## Setup (local)

```powershell
cd qscanner-demo
.\setup_repo.ps1

# Push to GitHub (optional)
.\setup_repo.ps1 -Remote https://github.com/<your-org>/qscanner-demo.git
```

## Vulnerabilities per App

### Python App (`apps/python-app`)
| CVE / CWE | Description |
|---|---|
| CWE-89 | SQL Injection |
| CWE-78 | OS Command Injection |
| CWE-918 | SSRF |
| CWE-95 | Eval Injection |
| CWE-798 | Hardcoded credentials |
| CWE-532 | Sensitive data in logs |
| CWE-327 | Weak MD5 hashing (auth.py) |
| CWE-502 | Pickle deserialization (db.py) |
| CVE-2023-32681 | requests 2.28.0 |
| CVE-2023-43804 | urllib3 1.26.14 |
| CVE-2023-25577 | Werkzeug 2.2.2 |
| CVE-2024-34064 | Jinja2 3.0.3 |

### Node.js App (`apps/node-app`)
| CVE / CWE | Description |
|---|---|
| CWE-89 | SQL Injection |
| CWE-95 | Eval Injection |
| CWE-22 | Path Traversal |
| CWE-532 | Logging credentials |
| CVE-2019-10744 | lodash prototype pollution (4.17.15) |
| CVE-2021-3803 | node-fetch 2.6.1 |
| CVE-2021-32803 | tar 4.4.13 |

### CI/CD Pipeline (`docker-build-push.yml`)
| Issue | Description |
|---|---|
| Unsafe `pull_request_target` | Untrusted code executes in privileged context |
| Secrets exposed in logs | `echo ${{ secrets.AWS_ACCESS_KEY_ID }}` |
| Self-hosted runner | No container isolation |
| `--privileged` Docker flag | Full host access |

---

## Scanning Locally

### Code scan (Python app)
```bash
./qscanner code ./apps/python-app \
  --pod <POD> \
  --client-id <CLIENT_ID> \
  --client-secret <CLIENT_SECRET> \
  --skip-verify-tls \
  -l debug \
  --image ghcr.io/<org>/qscanner-demo/python-app:latest
```

### Code scan (Node.js app)
```bash
./qscanner code ./apps/node-app \
  --pod <POD> \
  --client-id <CLIENT_ID> \
  --client-secret <CLIENT_SECRET> \
  --skip-verify-tls \
  -l debug \
  --image ghcr.io/<org>/qscanner-demo/node-app:latest
```

### Pipeline scan
```bash
./qscanner pipeline .github/workflows \
  --pod <POD> \
  --client-id <CLIENT_ID> \
  --client-secret <CLIENT_SECRET> \
  --skip-verify-tls \
  -l debug
```

## GitHub Secrets Required (for CI)

| Secret | Value |
|---|---|
| `QUALYS_POD` | Your Qualys pod hostname (e.g. `ENG-POD01`) |
| `QUALYS_CLIENT_ID` | Qualys API client ID |
| `QUALYS_CLIENT_SECRET` | Qualys API client secret |
