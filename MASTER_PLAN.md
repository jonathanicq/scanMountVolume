# Master Plan: scanMountVolume

**Project:** scanMountVolume
**Created:** 2026-01-22
**Last Updated:** 2026-01-22
**Current Phase:** Phase 0 - Planning

---

## Project Overview

**Goal:** Build a Python-based tool that scans and catalogs network share contents, stores metadata in MySQL, and provides a web interface for management and monitoring.

**Success Criteria:**
- [ ] Successfully scan 1TB+ network shares
- [ ] Store all metadata in MySQL with no data loss
- [ ] Correctly identify 95%+ of duplicate files
- [ ] Complete scan of 100K files in under 30 minutes
- [ ] Web UI functional with real-time progress updates
- [ ] Scheduled scans execute reliably
- [ ] Docker deployment working
- [ ] Test coverage >80%

---

## Phases Overview

| Phase | Name | Status | Dependencies | Key Deliverables |
|-------|------|--------|--------------|------------------|
| 0 | Planning & Setup | 🔄 In Progress | None | Project structure, CI/CD |
| 1 | Foundation | ⬜ Not Started | Phase 0 | DB schema, basic scanner |
| 2 | Metadata & Analysis | ⬜ Not Started | Phase 1 | Hashing, MIME, duplicates |
| 3 | Web Interface | ⬜ Not Started | Phase 1 | Dashboard, volume management |
| 4 | Scheduling & Monitoring | ⬜ Not Started | Phase 2, 3 | Cron, real-time KPIs |
| 5 | CLI Tool | ⬜ Not Started | Phase 2 | webscanbot CLI |
| 6 | Testing & Documentation | ⬜ Not Started | Phase 4, 5 | Tests, docs, deployment |

**Status Legend:**
- ⬜ Not Started
- 🔄 In Progress
- ✅ Complete
- ⏸️ Blocked
- ⚠️ Issues/Risks

---

## Phase 0: Planning & Setup

**Status:** 🔄 In Progress

**Objective:** Establish project foundation, documentation, and development environment

**Deliverables:**
- [x] PROJECT_SCOPE.md created and reviewed
- [x] PROJECT_CONFIG.md created and locked
- [x] MASTER_PLAN.md created
- [x] Repository created on GitHub
- [ ] Project structure created
- [ ] Development environment setup (pyproject.toml, requirements)
- [ ] CI/CD pipeline configured (GitHub Actions)
- [ ] Docker configuration (Dockerfile, docker-compose.yml)
- [ ] .env.example and .gitignore

**Directory:** `phases/phase-0-planning/`

**Acceptance Criteria:**
- Project can be cloned and virtual environment created
- `pip install -r requirements.txt` succeeds
- CI/CD pipeline runs lint on push
- Docker image builds successfully

---

## Phase 1: Foundation

**Status:** ⬜ Not Started

**Objective:** Create database schema, models, and basic file scanning capability

**Deliverables:**
- [ ] SQLAlchemy models (Volume, Scan, File, Category)
- [ ] Alembic migrations setup
- [ ] Database connection management
- [ ] Basic file scanner (directory traversal)
- [ ] File metadata extraction (stat: size, dates, permissions)
- [ ] Scan session management (start, complete, error handling)
- [ ] Unit tests for models and scanner

**Directory:** `phases/phase-1-foundation/`

**Key Components:**
```
scanmountvolume/
├── models/
│   ├── __init__.py
│   ├── base.py           # SQLAlchemy base
│   ├── volume.py         # Volume model
│   ├── scan.py           # Scan session model
│   ├── file.py           # File catalog model
│   └── category.py       # Category model
├── scanner/
│   ├── __init__.py
│   └── file_scanner.py   # Core scanning logic
└── database/
    ├── __init__.py
    └── connection.py     # DB connection
```

**Dependencies:**
- Phase 0 must be complete

**Acceptance Criteria:**
- Can create database schema via Alembic migrations
- Can scan a local directory and extract basic metadata
- Scan results stored in MySQL
- Files can be queried from database
- Unit tests pass with >80% coverage for this phase

**Risks/Issues:**
- MySQL connection configuration needs testing with remote server

---

## Phase 2: Metadata & Analysis

**Status:** ⬜ Not Started

**Objective:** Add full metadata extraction, hashing, MIME detection, and duplicate detection

**Deliverables:**
- [ ] File hashing (MD5 and/or SHA256)
- [ ] MIME type detection (python-magic)
- [ ] Category auto-assignment
- [ ] Soft delete tracking (mark missing files as deleted)
- [ ] Duplicate detection logic
- [ ] Incremental scan support (skip unchanged files)
- [ ] Batch database operations
- [ ] Unit tests for all analysis features

**Directory:** `phases/phase-2-metadata/`

**Key Components:**
```
scanmountvolume/
├── scanner/
│   ├── hasher.py         # File hashing
│   ├── mime_detector.py  # MIME type detection
│   └── categorizer.py    # Category assignment
├── services/
│   ├── __init__.py
│   ├── duplicate_service.py   # Duplicate detection
│   └── scan_service.py        # Orchestrate scan operations
```

**Dependencies:**
- Phase 1 must be complete

**Acceptance Criteria:**
- Files hashed correctly (verified against known hashes)
- MIME types detected accurately (>95% accuracy)
- Duplicates identified by matching hash
- Deleted files marked, not removed
- Incremental scan only processes changed files
- Performance: 1000 files/minute minimum

**Risks/Issues:**
- Large files may slow down hashing (mitigation: configurable depth/skip)
- Network latency on remote mounts

---

## Phase 3: Web Interface

**Status:** ⬜ Not Started

**Objective:** Create FastAPI web application with dashboard and volume management

**Deliverables:**
- [ ] FastAPI application setup
- [ ] Basic authentication (session-based)
- [ ] Dashboard page (overview, stats)
- [ ] Volume management (list, add, edit, delete)
- [ ] Volume detail view (files, stats)
- [ ] Jinja2 templates with Bootstrap/Tailwind
- [ ] API endpoints for AJAX operations
- [ ] Static file serving

**Directory:** `phases/phase-3-web-interface/`

**Key Components:**
```
scanmountvolume/
├── main.py               # FastAPI app
├── config.py             # App configuration
├── api/
│   ├── __init__.py
│   ├── auth.py           # Authentication
│   ├── volumes.py        # Volume API routes
│   ├── scans.py          # Scan API routes
│   └── dashboard.py      # Dashboard routes
├── templates/
│   ├── base.html
│   ├── login.html
│   ├── dashboard.html
│   ├── volumes/
│   │   ├── list.html
│   │   ├── detail.html
│   │   └── form.html
│   └── partials/
└── static/
    ├── css/
    └── js/
```

**Dependencies:**
- Phase 1 must be complete (models)

**Acceptance Criteria:**
- Can login with basic auth credentials
- Dashboard shows volume list and summary stats
- Can add/edit/remove volumes via web UI
- Volume validation (check if path exists and is accessible)
- Responsive design (mobile-friendly)
- Pages load in <2 seconds

**Risks/Issues:**
- Template design iterations may take time

---

## Phase 4: Scheduling & Monitoring

**Status:** ⬜ Not Started

**Objective:** Add scheduled scans, real-time progress monitoring, and KPI display

**Deliverables:**
- [ ] Schedule management (CRUD for cron schedules)
- [ ] APScheduler integration
- [ ] Enable/disable schedules via UI
- [ ] "Run Now" button for immediate scan
- [ ] Real-time scan progress (WebSocket or polling)
- [ ] KPI display (files scanned, elapsed time)
- [ ] Scan history view
- [ ] Background worker for scans

**Directory:** `phases/phase-4-scheduling/`

**Key Components:**
```
scanmountvolume/
├── models/
│   └── schedule.py       # Schedule model
├── api/
│   ├── schedules.py      # Schedule API
│   └── status.py         # Real-time status API
├── services/
│   ├── scheduler.py      # APScheduler integration
│   └── scan_worker.py    # Background scan worker
├── templates/
│   ├── schedules/
│   └── status.html       # Live status page
```

**Dependencies:**
- Phase 2 must be complete (full scanning)
- Phase 3 must be complete (web UI)

**Acceptance Criteria:**
- Can create/edit/delete schedules via UI
- Schedules execute at correct times
- Can trigger immediate scan from UI
- Real-time updates show progress (within 5 seconds latency)
- KPIs display: files scanned count, elapsed time
- Multiple scans don't conflict (queue or reject)

**Risks/Issues:**
- Background task management complexity
- WebSocket may require additional configuration

---

## Phase 5: CLI Tool

**Status:** ⬜ Not Started

**Objective:** Create webscanbot CLI tool using Typer

**Deliverables:**
- [ ] Typer CLI structure
- [ ] `webscanbot scan <volume_id|path>` command
- [ ] `webscanbot list` - list volumes
- [ ] `webscanbot status` - show running scan status
- [ ] `webscanbot config` - manage configuration
- [ ] Progress output for CLI scans
- [ ] JSON output option
- [ ] Entry point in pyproject.toml

**Directory:** `phases/phase-5-cli/`

**Key Components:**
```
scanmountvolume/
├── cli/
│   ├── __init__.py
│   ├── main.py           # Typer app
│   ├── scan.py           # Scan commands
│   ├── volumes.py        # Volume commands
│   └── config.py         # Config commands
```

**Dependencies:**
- Phase 2 must be complete (scanning works)

**Acceptance Criteria:**
- `webscanbot --help` shows all commands
- Can trigger scan from CLI
- Progress displayed during scan
- Exit codes appropriate (0 success, non-zero error)
- Can be run alongside web interface

**Risks/Issues:**
- None anticipated

---

## Phase 6: Testing & Documentation

**Status:** ⬜ Not Started

**Objective:** Comprehensive testing, documentation, and deployment preparation

**Deliverables:**
- [ ] Unit tests for all modules (>80% coverage)
- [ ] Integration tests (database, scanning)
- [ ] API endpoint tests
- [ ] README.md with full setup instructions
- [ ] Usage documentation
- [ ] Configuration documentation
- [ ] Docker deployment guide
- [ ] Final Dockerfile optimization
- [ ] docker-compose.yml for easy deployment
- [ ] .env.example complete
- [ ] CHANGELOG.md updated

**Directory:** `phases/phase-6-testing-docs/`

**Key Components:**
```
tests/
├── unit/
│   ├── test_models.py
│   ├── test_scanner.py
│   ├── test_services.py
│   └── test_api.py
├── integration/
│   ├── test_database.py
│   └── test_full_scan.py
├── conftest.py           # Fixtures
docs/
├── adr/
├── setup.md
├── usage.md
└── configuration.md
```

**Dependencies:**
- Phase 4 must be complete
- Phase 5 must be complete

**Acceptance Criteria:**
- Test coverage >80%
- All tests pass in CI
- README sufficient for new user to deploy
- Docker deployment works end-to-end
- No critical security issues

**Risks/Issues:**
- Integration test setup may need mock MySQL or test database

---

## Overall Progress Tracking

### Completed Milestones
- [x] Repository created
- [x] PROJECT_SCOPE.md complete
- [x] PROJECT_CONFIG.md complete
- [x] MASTER_PLAN.md complete
- [ ] Phase 0 Complete
- [ ] Phase 1 Complete
- [ ] Phase 2 Complete
- [ ] Phase 3 Complete
- [ ] Phase 4 Complete
- [ ] Phase 5 Complete
- [ ] Phase 6 Complete
- [ ] All tests passing
- [ ] Documentation complete
- [ ] Docker deployment successful
- [ ] Project launch

### Current Blockers
None currently.

### Technical Debt
[Track any shortcuts or technical debt accumulated that needs future attention]

---

## Critical Path

The critical path (phases that must be sequential):
```
Phase 0 → Phase 1 → Phase 2 ─┬→ Phase 4 → Phase 6
                             │
         Phase 1 → Phase 3 ──┘

         Phase 2 → Phase 5 ───────────→ Phase 6
```

**Parallel Work Opportunities:**
- Phase 3 (Web Interface) can start after Phase 1 (doesn't need hashing)
- Phase 5 (CLI) can progress in parallel with Phase 3, 4
- Phase 3 and Phase 5 can be developed in parallel after Phase 2

---

## Change Log

| Date | Phase | Change Description | Reason |
|------|-------|-------------------|--------|
| 2026-01-22 | 0 | Initial master plan created | Project kickoff |
| 2026-01-22 | All | Added web interface to scope | User requirement |

---

## Notes

- Mount points must be accessible from the Docker container
- Consider using docker volumes to mount network shares into container
- For testing, can use a local directory as a "mock" network share
- Real-time updates may use SSE (Server-Sent Events) as simpler alternative to WebSocket
