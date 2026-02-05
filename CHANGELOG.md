# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.2.0] - 2026-02-05

### Added

- Circular dependency detection with `PodCycleError` during resolution
- Optional `debugName` for providers to improve diagnostics

## [0.1.1] - 2026-02-04

### Added

- Release automation with tag-based publishing to pub.dev
- Numbered steps in RELEASING.md Quick Reference for easier scanning
- Version bump tooling (`dart tool/version_bump.dart`)
- Pre-release validation (`dart tool/pre_release_check.dart`)
- Release creation script (`dart tool/create_release.dart`) - creates tag, pushes, and creates GitHub release with changelog
- CI changelog check with `skip-changelog` label escape hatch
- Smart changelog validation (`dart tool/check_changelog.dart`) - auto-detects release branches
- `CONTRIBUTING.md` with development workflow and PR guidelines
- `RELEASING.md` documentation for maintainers
- Contributing section in README

## [0.1.0] - 2026-02-03

### Added

- Initial release with core DI functionality
- `Pod` class for defining dependencies with lazy initialization
- `Provider` for scoped dependency management
- `Scope` for hierarchical dependency resolution
- Zero external dependencies
