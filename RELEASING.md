# Releasing

This document describes the process for releasing new versions of dartypod to pub.dev.

> **Note:** For contributing changes, see [CONTRIBUTING.md](CONTRIBUTING.md).

## Quick Reference

```bash
# Create release branch
git checkout main && git pull origin main
git checkout -b release/v0.2.0

# Pre-release validation
dart tool/pre_release_check.dart

# Version bump (choose one)
dart tool/version_bump.dart patch   # 0.1.0 -> 0.1.1
dart tool/version_bump.dart minor   # 0.1.0 -> 0.2.0
dart tool/version_bump.dart major   # 0.1.0 -> 1.0.0

# Commit
git add . && git commit -m "chore: bump version to v0.2.0"

# Post-bump validation
dart tool/pre_release_check.dart --post

# Push and create PR, then after merge:
git checkout main && git pull origin main
git tag v0.2.0 && git push origin v0.2.0
```

## Release Process

### 1. Create Release Branch

```bash
git checkout main
git pull origin main
git checkout -b release/v0.2.0
```

### 2. Pre-Version-Bump Validation

Run the pre-release checks to ensure everything is ready:

```bash
dart tool/pre_release_check.dart
```

This automatically verifies:
- ✅ Dependencies are up to date
- ✅ Code formatting is correct
- ✅ Static analyzer passes
- ✅ All tests pass
- ✅ CHANGELOG has unreleased content

### 3. Bump the Version

```bash
dart tool/version_bump.dart patch  # or minor/major
```

This automatically:
- Updates version in `pubspec.yaml`
- Converts `## [Unreleased]` → `## [0.2.0] - 2026-02-04` in `CHANGELOG.md`
- Creates a new empty `## [Unreleased]` section

### 4. Review and Commit

```bash
# Review the changes
git diff

# Commit
git add .
git commit -m "chore: bump version to v0.2.0"
```

### 5. Post-Version-Bump Validation

```bash
dart tool/pre_release_check.dart --post
```

This verifies:
- ✅ `dart pub publish --dry-run` succeeds

> **Note:** If this check fails, fix the issues and amend the commit: `git commit --amend`

### 6. Push and Create PR

```bash
git push origin release/v0.2.0
```

Then create a Pull Request to `main` with:
- Title: `chore: bump version to v0.2.0`
- Description: Summary of changes from the changelog

### 7. Merge and Tag

After PR review and merge:

```bash
git checkout main
git pull origin main
git tag v0.2.0
git push origin v0.2.0
```

### 8. Automated Publishing

When you push a version tag:

1. GitHub Actions detects the tag
2. The `publish.yml` workflow is triggered
3. **Important:** You need to approve the deployment in the GitHub Actions UI (if environment protection is configured)
4. The package is automatically published to pub.dev using OIDC authentication

No manual `dart pub publish` needed!

### 9. Post-Release Verification

- Verify the package is available on [pub.dev/packages/dartypod](https://pub.dev/packages/dartypod)
- Test that an example project can depend on the new version

## Version Numbering

We follow [Semantic Versioning](https://semver.org/):

- **MAJOR** version for incompatible API changes
- **MINOR** version for backward-compatible functionality additions  
- **PATCH** version for backward-compatible bug fixes

## Hotfixes

For urgent fixes to a released version:

1. Create a hotfix branch from the tag: `git checkout -b hotfix/v0.2.1 v0.2.0`
2. Make the fix and add changelog entry
3. Bump the patch version: `dart tool/version_bump.dart patch`
4. Follow the normal release process (PR → merge → tag → publish)

## GitHub Environment Setup

For the approval confirmation when publishing, you need to set up a GitHub environment:

1. Go to your repository Settings → Environments
2. Create a new environment named `pub.dev`
3. Enable "Required reviewers" and add yourself
4. (Optional) Add deployment branch rules to only allow `main`

This ensures you get a confirmation dialog before the package is published to pub.dev.

## Troubleshooting

### Pre-release check fails

- **Formatting issues:** Run `dart format .` to fix
- **Analyzer issues:** Check the output and fix the reported issues
- **Test failures:** Run `dart test` locally to debug
- **No changelog content:** Add your changes under `## [Unreleased]`

### Publish dry-run fails

- Check that all required fields are in `pubspec.yaml` (name, description, version, etc.)
- Ensure the version in `pubspec.yaml` doesn't already exist on pub.dev
- Check for any files that shouldn't be published (add them to `.gitignore`)

### Tag already exists

If you need to re-release the same version (not recommended):

```bash
git tag -d v0.2.0           # Delete local tag
git push origin :v0.2.0     # Delete remote tag
git tag v0.2.0              # Recreate tag
git push origin v0.2.0      # Push new tag
```

> **Warning:** This is generally discouraged. Consider releasing a new patch version instead.
