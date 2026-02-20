# Changelog

All notable changes to this project will be documented in this file.

## [1.0.1] - 2026-02-18

### Added
- Bilingual project documentation in `README.md` (English/German) with installation, usage examples, and troubleshooting.

### Changed
- Added native `-WhatIf` support to `Export-TaskBranch` and `Import-TaskBranch` via `SupportsShouldProcess`.
- Hardened `Export-TaskBranch`:
  - Handles unreadable/invalid task folders without null-reference follow-up errors.
  - Exits cleanly when no tasks are found.
  - Sanitizes task names for filesystem-safe XML filenames.
  - Uses terminating file output errors to ensure catch blocks trigger reliably.
- Hardened `Import-TaskBranch`:
  - Validates `SourcePath` and resolves canonical source root.
  - Exits cleanly when no XML files are present.
  - Adds safer relative path handling and guarded folder creation.
  - Uses robust XML loading (`-Raw`, `-LiteralPath`, terminating errors).
  - Uses terminating registration errors to improve per-task error handling.
- Updated default credential helper:
  - Replaced `ConvertTo-SecureString "" -AsPlainText -Force` with an empty `SecureString` constructor for better compatibility.
