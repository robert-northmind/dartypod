import 'dart:io';

/// Version bump types
enum BumpType {
  patch,
  minor,
  major,
}

/// Represents a semantic version
class Version {
  Version(this.major, this.minor, this.patch);

  /// Parse version string into Version object
  factory Version.parse(String version) {
    final parts = version.split('.');
    if (parts.length != 3) {
      throw FormatException('Invalid version format: $version');
    }
    return Version(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  final int major;
  final int minor;
  final int patch;

  /// Bump version according to specified type
  Version bump(BumpType type) {
    switch (type) {
      case BumpType.major:
        return Version(major + 1, 0, 0);
      case BumpType.minor:
        return Version(major, minor + 1, 0);
      case BumpType.patch:
        return Version(major, minor, patch + 1);
    }
  }

  @override
  String toString() => '$major.$minor.$patch';
}

/// Update version in pubspec.yaml
Future<void> updatePubspec(String version) async {
  final file = File('pubspec.yaml');
  final content = await file.readAsString();
  final updated = content.replaceFirst(
    RegExp(r'version: \d+\.\d+\.\d+'),
    'version: $version',
  );
  await file.writeAsString(updated);
  stdout.writeln('  ✓ Updated pubspec.yaml');
}

/// Update CHANGELOG.md with new version
Future<void> updateChangelog(String version) async {
  final file = File('CHANGELOG.md');
  final content = await file.readAsString();

  // Get current date
  final now = DateTime.now();
  final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-'
      '${now.day.toString().padLeft(2, '0')}';

  // Replace "## [Unreleased]" with version and date, then add new Unreleased
  final updated = content.replaceFirst(
    '## [Unreleased]',
    '## [Unreleased]\n\n## [$version] - $dateStr',
  );

  if (updated == content) {
    stderr
        .writeln('  ✗ Could not find ## [Unreleased] section in CHANGELOG.md');
    exit(1);
  }

  await file.writeAsString(updated);
  stdout.writeln('  ✓ Updated CHANGELOG.md');
}

/// Main entry point
Future<void> main(List<String> args) async {
  if (args.isEmpty) {
    stderr.writeln('Usage: dart tool/version_bump.dart <patch|minor|major>');
    stderr.writeln('');
    stderr.writeln('Examples:');
    stderr.writeln('  dart tool/version_bump.dart patch  # 0.1.0 -> 0.1.1');
    stderr.writeln('  dart tool/version_bump.dart minor  # 0.1.0 -> 0.2.0');
    stderr.writeln('  dart tool/version_bump.dart major  # 0.1.0 -> 1.0.0');
    exit(1);
  }

  // Parse bump type
  final bumpTypeStr = args[0].toLowerCase();
  BumpType? bumpType;

  switch (bumpTypeStr) {
    case 'patch':
      bumpType = BumpType.patch;
      break;
    case 'minor':
      bumpType = BumpType.minor;
      break;
    case 'major':
      bumpType = BumpType.major;
      break;
    default:
      stderr.writeln(
          'Invalid bump type: $bumpTypeStr. Must be patch, minor, or major');
      exit(1);
  }

  try {
    // Read current version from pubspec
    final pubspecFile = File('pubspec.yaml');
    final pubspecContent = await pubspecFile.readAsString();
    final versionMatch =
        RegExp(r'version: (\d+\.\d+\.\d+)').firstMatch(pubspecContent);

    if (versionMatch == null) {
      stderr.writeln('Could not find version in pubspec.yaml');
      exit(1);
    }

    // Calculate new version
    final currentVersion = Version.parse(versionMatch.group(1)!);
    final newVersion = currentVersion.bump(bumpType);

    stdout.writeln('');
    stdout.writeln('Bumping version: $currentVersion -> $newVersion');
    stdout.writeln('');

    // Update all files
    await updatePubspec(newVersion.toString());
    await updateChangelog(newVersion.toString());

    stdout.writeln('');
    stdout.writeln('✅ Successfully updated version to $newVersion');
    stdout.writeln('');
    stdout.writeln('Next steps:');
    stdout.writeln('  1. Review the changes: git diff');
    stdout.writeln(
        '  2. Commit: git add . && git commit -m "chore: bump version to v$newVersion"');
    stdout.writeln(
        '  3. Run post-checks: dart tool/pre_release_check.dart --post');
    stdout.writeln('  4. Push and create PR');
  } catch (e) {
    stderr.writeln('Error updating version: $e');
    exit(1);
  }
}
