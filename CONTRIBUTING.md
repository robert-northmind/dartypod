# Contributing to dartypod

Thank you for your interest in contributing to dartypod! This document explains how to set up your development environment and contribute changes.

## Development Setup

1. **Clone the repository**

   ```bash
   git clone https://github.com/robert-northmind/dartypod.git
   cd dartypod
   ```

2. **Install dependencies**

   ```bash
   dart pub get
   ```

3. **Run tests**

   ```bash
   dart test
   ```

4. **Run the analyzer**

   ```bash
   dart analyze
   ```

## Making Changes

### 1. Create a Branch

```bash
git checkout main
git pull origin main
git checkout -b feature/my-new-feature   # or bugfix/fix-something
```

### 2. Make Your Changes

- Write your code
- Add or update tests as needed
- Run tests locally: `dart test`
- Run the analyzer: `dart analyze`
- Format your code: `dart format .`

### 3. Update the Changelog

Add your changes under `## [Unreleased]` in `CHANGELOG.md`:

```markdown
## [Unreleased]

### Added
- My new feature description

### Fixed
- Bug fix description

## [0.1.0] - 2026-02-03
...
```

Use these standard sections:

| Section | Use for |
|---------|---------|
| **Added** | New features |
| **Changed** | Changes to existing functionality |
| **Deprecated** | Features that will be removed |
| **Removed** | Features that were removed |
| **Fixed** | Bug fixes |
| **Security** | Security-related changes |

> **Note:** The CI will fail if you don't add changelog entries. If your change doesn't warrant a changelog entry (e.g., CI config, typo fix), add the `skip-changelog` label to your PR instead.

### 4. Commit and Push

```bash
git add .
git commit -m "feat: add my new feature"
git push origin feature/my-new-feature
```

Use conventional commit messages:
- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation changes
- `chore:` - Maintenance tasks
- `refactor:` - Code refactoring
- `test:` - Adding or updating tests

### 5. Create a Pull Request

- Open a PR against `main`
- CI will automatically run:
  - Code formatting check
  - Static analysis
  - Tests
  - Changelog check
- Get review and approval
- Merge to `main`

## Local Validation

Before pushing, you can run the same checks that CI runs:

```bash
# Format code
dart format .

# Run analyzer
dart analyze --fatal-infos

# Run tests
dart test

# Check formatting without modifying files
dart format --output=none --set-exit-if-changed .
```

Or use the pre-release check tool (runs all checks):

```bash
dart tool/pre_release_check.dart
```

## Releasing

If you're a maintainer and need to release a new version, see [RELEASING.md](RELEASING.md).

## Questions?

Feel free to open an issue if you have questions or need help with your contribution.
