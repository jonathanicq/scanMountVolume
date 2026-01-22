# scanMountVolume - Project Scope

**Project Name:** scanMountVolume
**Version:** 0.1.0
**Created:** 2026-01-22
**Status:** Planning

---

## Executive Summary

scanMountVolume is a Python-based tool that scans and catalogs contents of mounted network shares (NFS, SMB/CIFS) and stores comprehensive file metadata in a remote MySQL database. The tool provides full analysis capabilities including file hashing, MIME type detection, duplicate identification, and automatic categorization.

The system includes a **web interface on port 8056** for managing scans, configuring mount points, and monitoring progress in real-time.

---

## Problem Statement

Organizations with multiple network shares often lack visibility into:
- What files exist across their network storage
- Duplicate files consuming storage space
- File ownership and permission structures
- Content distribution and categorization
- Historical tracking of file changes over time

This tool addresses these challenges by providing a centralized, queryable catalog of all files across mounted network volumes with a web-based management interface.

---

## Project Goals

1. **Comprehensive Scanning** - Scan mounted network shares and extract full file metadata
2. **Centralized Storage** - Store all catalog data in a remote MySQL database
3. **Duplicate Detection** - Identify duplicate files across volumes using content hashing
4. **Categorization** - Automatically categorize files by type and content
5. **Performance** - Handle large volumes (1TB-10TB) efficiently with progress tracking
6. **Web Management** - Provide web interface for configuration, scheduling, and monitoring

---

## Scope

### In Scope

| Feature | Description |
|---------|-------------|
| Network Share Support | Scan NFS and SMB/CIFS mounted shares |
| Dynamic Share Management | Add/remove mount points via web UI |
| Basic Metadata | File name, path, size, created/modified dates |
| Extended Metadata | Permissions, owner, group, file type |
| Content Analysis | MD5/SHA256 hashing, MIME type detection |
| Duplicate Detection | Identify duplicates via hash comparison |
| Categorization | Auto-categorize (documents, images, videos, code, etc.) |
| MySQL Storage | Store all data in remote MySQL database |
| Soft Delete Tracking | Mark deleted files as removed (preserve history) |
| CLI Interface | Command-line tool (`webscanbot`) for running scans |
| Web Interface | Management UI on port 8056 |
| Basic Authentication | Username/password protection for web UI |
| Scheduled Scans | Cron-based scheduling with enable/disable via UI |
| Manual Triggers | On-demand scan execution from web UI |
| Real-time Monitoring | Live KPIs: files scanned, elapsed time |
| Progress Tracking | Real-time progress during scans |
| Incremental Scans | Only scan changed files on subsequent runs |

### Out of Scope (v1.0)

- Real-time file monitoring (inotify/fswatch)
- Automatic remediation actions
- Cloud storage support (S3, GCS, Azure)
- Content indexing/full-text search
- Windows native support (Linux/macOS only)
- Multi-user role-based access control
- Email/Slack notifications

---

## Technical Requirements

### Technology Stack

| Component | Technology |
|-----------|------------|
| Language | Python 3.10+ |
| Database | MySQL 8.0+ (remote) |
| ORM | SQLAlchemy |
| Web Framework | Flask or FastAPI |
| CLI Framework | Click or Typer |
| File Hashing | hashlib (MD5, SHA256) |
| MIME Detection | python-magic |
| Task Scheduling | APScheduler or system cron |
| Network Mounts | Native OS mount support |

### System Requirements

- Linux or macOS operating system
- Python 3.10 or higher
- Network connectivity to MySQL server
- Appropriate permissions to read mounted shares
- NFS/CIFS client packages installed
- Port 8056 available for web interface

### Database Schema (High-Level)

```
Tables:
- scans           : Scan sessions (id, start_time, end_time, volume_id, status, files_count, errors_count)
- volumes         : Configured mount points (id, name, path, enabled, created_at)
- files           : File catalog (id, scan_id, volume_id, path, name, size, hash_md5, hash_sha256,
                    mime_type, category_id, is_deleted, deleted_at, ...)
- categories      : File categories (id, name, extensions, mime_patterns)
- duplicates      : Duplicate file groups (id, hash, file_count, total_size)
- schedules       : Cron schedules (id, volume_id, cron_expression, enabled, last_run, next_run)
- users           : Basic auth users (id, username, password_hash)
```

---

## Functional Requirements

### FR-1: Volume Management
- Add new mount points via web UI
- Edit/remove existing mount points
- Enable/disable volumes for scanning
- Validate mount point accessibility

### FR-2: Volume Scanning
- Accept mount point path as input
- Recursively traverse all directories
- Handle permission errors gracefully
- Support include/exclude patterns
- Track scan progress in real-time

### FR-3: Metadata Collection
- Extract file system metadata (stat)
- Calculate file hashes (configurable: MD5, SHA256, or both)
- Detect MIME type using libmagic
- Extract file extension and infer type

### FR-4: File Tracking
- Insert new files discovered
- Update changed files (size, hash, modified date)
- Mark missing files as deleted (soft delete)
- Preserve deletion timestamp for audit

### FR-5: Database Operations
- Connect to remote MySQL with credentials
- Create schema if not exists (migrations)
- Insert/update file records
- Track scan sessions with statistics

### FR-6: Duplicate Detection
- Compare files by hash values
- Group duplicates by hash
- Calculate wasted space from duplicates
- Report duplicates per volume and across volumes

### FR-7: Categorization
- Define category rules (extension, MIME type)
- Auto-assign categories during scan
- Support custom category definitions via UI

### FR-8: CLI Interface (`webscanbot`)
- `webscanbot scan <volume_id|path>` - Run a scan
- `webscanbot list` - List configured volumes
- `webscanbot status` - Show scan status
- `webscanbot config` - Manage configuration

### FR-9: Web Interface (Port 8056)
- **Dashboard**: Overview of all volumes, last scan times, file counts
- **Volumes**: Add/edit/remove mount points
- **Schedules**: Configure cron schedules, enable/disable
- **Run Now**: Trigger immediate scan for a volume
- **Live Status**: Real-time KPIs during scan
  - Files scanned so far
  - Elapsed time
  - Current directory being scanned
  - Estimated completion (if possible)
- **Reports**: View duplicates, categories, storage usage

### FR-10: Authentication
- Basic username/password authentication
- Session management
- Configurable credentials

### FR-11: Scheduling
- Define cron expressions per volume
- Enable/disable schedules via web UI
- View next scheduled run time
- Manual override to run immediately

---

## Non-Functional Requirements

### Performance
- Handle volumes with 1M+ files
- Support volumes up to 10TB
- Parallel file processing where possible
- Memory-efficient streaming for large directories
- Batch database inserts (1000+ records per transaction)

### Reliability
- Resume interrupted scans
- Transaction-safe database operations
- Comprehensive error logging
- Graceful handling of network interruptions

### Security
- Credentials stored securely (not in code)
- Support environment variables and config files
- No sensitive data in logs
- Basic auth over HTTPS recommended
- Password hashing for stored credentials

### Usability
- Intuitive web interface
- Clear progress indicators
- Helpful error messages
- Minimal configuration required

### Maintainability
- Modular architecture
- Comprehensive unit tests
- Clear documentation
- Database migrations for schema changes

---

## Success Criteria

1. Successfully scan a 1TB+ network share
2. Store all metadata in MySQL with no data loss
3. Correctly identify 95%+ of duplicate files
4. Complete scan of 100K files in under 30 minutes
5. Web UI responsive and functional
6. Scheduled scans execute reliably
7. Real-time progress updates within 5-second latency

---

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Network latency affects performance | High | Batch database operations, connection pooling |
| Permission errors on files | Medium | Graceful error handling, continue scanning, log errors |
| Large files slow down hashing | Medium | Configurable hash depth, async processing, skip option |
| Database connection drops | High | Retry logic, connection health checks, reconnect |
| Mount point becomes unavailable | High | Detect and report, pause scan, retry mechanism |
| Web UI unresponsive during large scans | Medium | Background workers, async updates, separate threads |

---

## Project Phases (Overview)

1. **Phase 1: Foundation** - Project setup, database schema, basic scanning
2. **Phase 2: Metadata & Analysis** - Full metadata extraction, hashing, MIME, duplicates
3. **Phase 3: Web Interface** - Flask/FastAPI app, dashboard, volume management
4. **Phase 4: Scheduling & Monitoring** - Cron integration, real-time status, KPIs
5. **Phase 5: CLI & Polish** - CLI tool, configuration, error handling
6. **Phase 6: Testing & Docs** - Comprehensive testing, documentation

*Detailed breakdown in MASTER_PLAN.md*

---

## Deliverables

1. Python package (`scanmountvolume`)
2. CLI tool (`webscanbot`)
3. Web application (port 8056)
4. MySQL schema migration scripts
5. Configuration file templates
6. User documentation (README, usage guide)
7. Test suite with >80% coverage
8. Docker deployment option (optional)

---

## Approval

| Role | Name | Date | Signature |
|------|------|------|-----------|
| Project Owner | | | |
| Technical Lead | | | |

---

**Document Version:** 1.1
**Last Updated:** 2026-01-22
