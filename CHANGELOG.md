# Changelog

All notable changes to this repository will be documented in this file.

The format is based on "Keep a Changelog", and this project follows semantic versioning per module.

## [Unreleased]

## [2026-02-20]

### Added
- `README.html` export of `README.md`.
- `Setup-Modules.ps1` to create GitIgnore templates and check dependencies.
- GitIgnore: `-TemplatePath`, `GITIGNORE_TEMPLATES` fallback, module-local `Templates` fallback.
- SetFoldersICO: `INKSCAPE_PATH` support, `-ApplyExistingIco`.
- SysinternalsManager: proxy, cache, SHA256 verification, task forwarding.
- TaskSchedulerTools: `-NameFilter` for export.
- DatabaseEnv: `-TemplatePath`, `-PasswordSecure`, default host/port.
- DirectoryTree: `-IncludeExtension`, `-ExcludePattern`.
- DomainCheck: retry parameters, `-OutputObject`.
- DualbootSSHKeyStore: `-Force`, `-SkipAcl`, better `-WhatIf` handling.
- WinPwd: default charset and case-insensitive charset resolution.
- CodeSigningTools: thumbprint selection and SubjectMatch passthrough.

### Changed
- Updated module versions and release notes to reflect new features.
- README expanded with setup, examples, and external file requirements.

