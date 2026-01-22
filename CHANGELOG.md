# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

### Added
- Project scope document (PROJECT_SCOPE.md)
- Technology configuration (PROJECT_CONFIG.md)
- Master plan with 6 development phases (MASTER_PLAN.md)
- Repository setup on GitHub

### Planned (Next Release: 0.1.0)
- Database schema and SQLAlchemy models
- Basic file scanning capability
- FastAPI web application on port 8056
- Volume management via web UI
- File metadata extraction (size, dates, permissions)
- MySQL database integration

---

## Version Roadmap

| Version | Milestone | Key Features |
|---------|-----------|--------------|
| 0.1.0 | Foundation | Database schema, basic scanning, project structure |
| 0.2.0 | Analysis | File hashing, MIME detection, duplicate detection |
| 0.3.0 | Web UI | Dashboard, volume management, authentication |
| 0.4.0 | Scheduling | Cron scheduling, real-time progress, KPIs |
| 0.5.0 | CLI | webscanbot CLI tool |
| 1.0.0 | Release | Full documentation, Docker deployment, tests |

---

## Version Numbering Guide

**MAJOR.MINOR.PATCH** (e.g., 1.2.3)

- **MAJOR** version: Incompatible API changes or major functionality changes
- **MINOR** version: Added functionality in a backwards-compatible manner
- **PATCH** version: Backwards-compatible bug fixes

---

## Category Definitions

- **Added**: New features, functionality, or capabilities
- **Changed**: Changes to existing functionality (may include breaking changes)
- **Deprecated**: Features marked for removal in future versions
- **Removed**: Removed features or functionality
- **Fixed**: Bug fixes and issue resolutions
- **Security**: Security-related changes, patches, and updates

---

## Notes

- Each version should have a release date in YYYY-MM-DD format
- Reference issues/PRs when applicable: `Fixed #123`, `See PR #456`
- Group related changes together under appropriate categories
- Keep descriptions concise but meaningful
- Update this file with every significant commit

---

## Comparison Links

[unreleased]: https://github.com/jonathanicq/scanMountVolume/compare/v0.1.0...HEAD
