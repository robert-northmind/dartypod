# AGENTS.md

This file provides context for AI agents working in this repository.

## Project Overview

**dartypod** is a minimal Service Locator with compile-time safe provider references, enabling clean dependency injection patterns in Dart.

### Core Design Principles

1. **Zero dependencies** - This is a core design goal. Do NOT add external runtime dependencies.
2. **Compile-time safety** - Provider references instead of runtime type lookup. Users are guaranteed no runtime exceptions from forgotten registrations.
3. **Pure Dart** - This is a Dart package, not a Flutter package. No Flutter dependencies.

### Key Concepts

- **Pod** - The container that holds and resolves dependencies
- **Provider** - Defines how to create an instance of a dependency
- **Scope** - Controls instance lifecycle (Singleton, Transient, Custom)
- **PodResolver** - Interface for resolving providers (used in factory functions)
- **Disposable** - Interface for cleanup when Pod is disposed

## Project Structure

```
dartypod/
├── lib/
│   ├── dartypod.dart          # Library entry point, exports public API
│   └── src/
│       ├── disposable.dart    # Disposable interface
│       ├── pod.dart           # Main Pod container class
│       ├── pod_resolver.dart  # PodResolver interface
│       ├── provider.dart      # Provider class
│       └── scope.dart         # Scope classes (Singleton, Transient, Custom)
├── test/
│   ├── pod_test.dart          # Tests for Pod
│   ├── provider_test.dart     # Tests for Provider
│   └── scope_test.dart        # Tests for Scope
├── tool/
│   ├── pre_release_check.dart # Pre-release validation script
│   └── version_bump.dart      # Version bumping script
├── example/
│   └── example.dart           # Usage example for pub.dev
└── .github/
    └── workflows/
        ├── ci.yml             # CI: format, analyze, test, changelog check
        ├── publish.yml        # Publish to pub.dev on version tags
        └── security.yml       # Security scanning
```

### Test Organization

Tests mirror the `lib/src/` structure. When adding new source files, create corresponding test files with the same name pattern: `lib/src/foo.dart` → `test/foo_test.dart`.

## Development Practices

### Testing Approach

Follow TDD when it fits naturally, but be pragmatic - don't force it when it doesn't make sense. The goal is well-tested code, not dogmatic adherence to a process.

- Write tests for new functionality
- Run tests before committing: `dart test`
- Tests should be focused and readable

### Code Quality

This project uses **strict Dart analysis**:

```yaml
analyzer:
  language:
    strict-casts: true
    strict-inference: true
    strict-raw-types: true
```

This means:
- Avoid `dynamic` types
- Explicit type annotations where inference isn't possible
- No implicit casts

### Before Committing

Always run these checks (or use `dart tool/pre_release_check.dart`):

```bash
dart format .                              # Format code
dart analyze --fatal-infos                 # Static analysis
dart test                                  # Run tests
```

### Changelog

Every PR must update `CHANGELOG.md` under `## [Unreleased]` unless labeled with `skip-changelog`. Use [Keep a Changelog](https://keepachangelog.com/) format:

- **Added** - New features
- **Changed** - Changes to existing functionality
- **Fixed** - Bug fixes
- **Removed** - Removed features

### Commit Messages

Use [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation
- `chore:` - Maintenance
- `refactor:` - Code refactoring
- `test:` - Tests

## MCP Tools (for AI agents)

This workspace has a Dart MCP server available. Prefer using MCP tools over shell commands:

| Task | MCP Tool | Shell Alternative |
|------|----------|-------------------|
| Run tests | `run_tests` | `dart test` |
| Analyze code | `analyze_files` | `dart analyze` |
| Format code | `dart_format` | `dart format .` |
| Apply fixes | `dart_fix` | `dart fix --apply` |
| Pub commands | `pub` | `dart pub get` |

## Key Documentation

| Document | Purpose |
|----------|---------|
| [README.md](README.md) | Package overview, API reference, usage examples |
| [CONTRIBUTING.md](CONTRIBUTING.md) | Development setup, PR workflow, local validation |
| [RELEASING.md](RELEASING.md) | Version bumping, release process, publishing |
| [CHANGELOG.md](CHANGELOG.md) | Version history and changes |

## Common Tasks

### Adding a new feature

1. Create feature branch from `main`
2. Write tests in `test/`
3. Implement in `lib/src/`
4. Export from `lib/dartypod.dart` if public API
5. Update `CHANGELOG.md` under `## [Unreleased]`
6. Run `dart tool/pre_release_check.dart` to validate
7. Create PR

### Fixing a bug

1. Write a failing test that reproduces the bug
2. Fix the bug
3. Verify test passes
4. Update `CHANGELOG.md`
5. Create PR

### Running the full validation suite

```bash
dart tool/pre_release_check.dart
```

This runs: dependency check, formatting, analysis, tests, and changelog validation.
