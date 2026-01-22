# scanMountVolume - Project Scope

**Project Name:** scanMountVolume
**Version:** 0.1.0
**Created:** 2026-01-22
**Status:** Planning

---

## Executive Summary

scanMountVolume is a Python-based tool that scans and catalogs contents of mounted network shares (NFS, SMB/CIFS) and stores comprehensive file metadata in a remote MySQL database. The tool provides full analysis capabilities including file hashing, MIME type detection, duplicate identification, and automatic categorization.

---

## Problem Statement

Organizations with multiple network shares often lack visibility into:
- What files exist across their network storage
- Duplicate files consuming storage space
- File ownership and permission structures
- Content distribution and categorization

This tool addresses these challenges by providing a centralized, queryable catalog of all files across mounted network volumes.

---

## Project Goals

1. **Comprehensive Scanning** - Scan mounted network shares and extract full file metadata
2. **Centralized Storage** - Store all catalog data in a remote MySQL database
3. **Duplicate Detection** - Identify duplicate files across volumes using content hashing
4. **Categorization** - Automatically categorize files by type and content
5. **Performance** - Handle large volumes efficiently with progress tracking

---

## Scope

### In Scope

| Feature | Description |
|---------|-------------|
| Network Share Support | Mount and scan NFS and SMB/CIFS shares |
| Basic Metadata | File name, path, size, created/modified dates |
| Extended Metadata | Permissions, owner, group, file type |
| Content Analysis | MD5/SHA256 hashing, MIME type detection |
| Duplicate Detection | Identify duplicates via hash comparison |
| Categorization | Auto-categorize (documents, images, videos, code, etc.) |
| MySQL Storage | Store all data in remote MySQL database |
| CLI Interface | Command-line interface for running scans |
| Progress Tracking | Real-time progress during scans |
| Incremental Scans | Only scan changed files on subsequent runs |

### Out of Scope (v1.0)

- Web-based dashboard/UI
- Real-time file monitoring (inotify)
- Automatic remediation actions
- Cloud storage support (S3, GCS, Azure)
- Content indexing/full-text search
- Windows native support (Linux/macOS only)

---

## Technical Requirements

### Technology Stack

| Component | Technology |
|-----------|------------|
| Language | Python 3.10+ |
| Database | MySQL 8.0+ (remote) |
| ORM | SQLAlchemy |
| CLI Framework | Click or Typer |
| File Hashing | hashlib (MD5, SHA256) |
| MIME Detection | python-magic |
| Network Mounts | Native OS mount support |

### System Requirements

- Linux or macOS operating system
- Python 3.10 or higher
- Network connectivity to MySQL server
- Appropriate permissions to read mounted shares
- NFS/CIFS client packages installed

### Database Schema (High-Level)

```
Tables:
- scans           : Scan sessions (id, start_time, end_time, volume_path, status)
- files           : File catalog (id, scan_id, path, name, size, hash_md5, hash_sha256, ...)
- categories      : File categories (id, name, patterns)
- duplicates      : Duplicate file groups (id, hash, file_count, total_size)
```

---

## Functional Requirements

### FR-1: Volume Scanning
- Accept mount point path as input
- Recursively traverse all directories
- Handle permission errors gracefully
- Support include/exclude patterns

### FR-2: Metadata Collection
- Extract file system metadata (stat)
- Calculate file hashes (configurable: MD5, SHA256, or both)
- Detect MIME type using libmagic
- Extract file extension and infer type

### FR-3: Database Operations
- Connect to remote MySQL with credentials
- Create schema if not exists
- Insert/update file records
- Track scan sessions

### FR-4: Duplicate Detection
- Compare files by hash values
- Group duplicates by hash
- Calculate wasted space from duplicates

### FR-5: Categorization
- Define category rules (extension, MIME type)
- Auto-assign categories during scan
- Support custom category definitions

### FR-6: CLI Interface
- `scan <mount_path>` - Run a scan
- `status` - Show scan status
- `config` - Manage configuration
- `report` - Generate reports

---

## Non-Functional Requirements

### Performance
- Handle volumes with 1M+ files
- Parallel file processing where possible
- Memory-efficient streaming for large directories

### Reliability
- Resume interrupted scans
- Transaction-safe database operations
- Comprehensive error logging

### Security
- Credentials stored securely (not in code)
- Support environment variables and config files
- No sensitive data in logs

### Maintainability
- Modular architecture
- Comprehensive unit tests
- Clear documentation

---

## Success Criteria

1. Successfully scan a 100GB+ network share
2. Store all metadata in MySQL with no data loss
3. Correctly identify 95%+ of duplicate files
4. Complete scan of 100K files in under 30 minutes
5. CLI is intuitive and well-documented

---

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Network latency affects performance | High | Batch database operations, connection pooling |
| Permission errors on files | Medium | Graceful error handling, continue scanning |
| Large files slow down hashing | Medium | Configurable hash depth, async processing |
| Database connection drops | High | Retry logic, connection health checks |

---

## Project Phases (Overview)

1. **Phase 1: Foundation** - Project setup, database schema, core scanning
2. **Phase 2: Metadata** - Full metadata extraction, hashing, MIME detection
3. **Phase 3: Analysis** - Duplicate detection, categorization
4. **Phase 4: CLI & Polish** - CLI interface, configuration, error handling
5. **Phase 5: Testing & Docs** - Comprehensive testing, documentation

*Detailed breakdown in MASTER_PLAN.md*

---

## Deliverables

1. Python package (`scanmountvolume`)
2. CLI tool (`smv` or `scanmv`)
3. MySQL schema migration scripts
4. Configuration file templates
5. User documentation (README, usage guide)
6. Test suite with >80% coverage

---

## Approval

| Role | Name | Date | Signature |
|------|------|------|-----------|
| Project Owner | | | |
| Technical Lead | | | |

---

**Document Version:** 1.0
**Last Updated:** 2026-01-22
