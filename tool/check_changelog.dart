import 'dart:io';

/// Check CHANGELOG.md for proper content based on branch type.
///
/// For release branches (release/*):
///   - Verifies there's a versioned section matching pubspec.yaml version
///
/// For other branches:
///   - Verifies there's content under [Unreleased] section
Future<void> main(List<String> args) async {
  // Parse arguments
  String? branchName;

  for (var i = 0; i < args.length; i++) {
    if (args[i] == '--branch' && i + 1 < args.length) {
      branchName = args[i + 1];
      i++;
    }
  }

  if (branchName == null) {
    stderr.writeln('Usage: dart tool/check_changelog.dart --branch <branch>');
    stderr.writeln('');
    stderr.writeln('Examples:');
    stderr.writeln(
        '  dart tool/check_changelog.dart --branch feature/add-something');
    stderr.writeln('  dart tool/check_changelog.dart --branch release/v0.1.1');
    exit(1);
  }

  // Check if CHANGELOG.md exists
  final changelogFile = File('CHANGELOG.md');
  if (!changelogFile.existsSync()) {
    _fail('CHANGELOG.md not found');
  }

  final changelog = await changelogFile.readAsString();

  // Determine check type based on branch name
  if (branchName.startsWith('release/')) {
    await _checkReleaseBranch(changelog);
  } else {
    _checkUnreleasedContent(changelog);
  }
}

/// Check that CHANGELOG has a versioned section matching pubspec.yaml version
Future<void> _checkReleaseBranch(String changelog) async {
  stdout.writeln('📦 Detected release branch');
  stdout.writeln('');

  // Get version from pubspec.yaml
  final pubspecFile = File('pubspec.yaml');
  if (!pubspecFile.existsSync()) {
    _fail('pubspec.yaml not found');
  }

  final pubspec = await pubspecFile.readAsString();
  final versionMatch = RegExp(r'version: (\d+\.\d+\.\d+)').firstMatch(pubspec);

  if (versionMatch == null) {
    _fail('Could not find version in pubspec.yaml');
  }

  final version = versionMatch.group(1)!;
  stdout.writeln('Expected version: $version');
  stdout.writeln('');

  // Check if CHANGELOG has a section for this version
  // Pattern: ## [0.1.1] - YYYY-MM-DD or ## [0.1.1]
  final versionPattern = RegExp(r'## \[' + RegExp.escape(version) + r'\]');

  if (versionPattern.hasMatch(changelog)) {
    // Extract and display the content for this version
    final content = _extractVersionContent(changelog, version);
    stdout.writeln('✅ Found changelog entry for version $version:');
    stdout.writeln('');
    for (final line in content.take(20)) {
      stdout.writeln('  $line');
    }
    if (content.length > 20) {
      stdout.writeln('  ... (truncated)');
    }
  } else {
    _fail(
      'No changelog entry found for version $version\n'
      '\n'
      'Expected to find: ## [$version] - YYYY-MM-DD\n'
      '\n'
      'Make sure you ran: dart tool/version_bump.dart <patch|minor|major>',
    );
  }
}

/// Check that CHANGELOG has content under [Unreleased] section
void _checkUnreleasedContent(String changelog) {
  stdout.writeln('🔍 Checking for unreleased content');
  stdout.writeln('');

  final content = _extractUnreleasedContent(changelog);

  if (content.isEmpty) {
    _fail(
      'No content found under ## [Unreleased] section\n'
      '\n'
      'Please add your changes to the CHANGELOG.md under the ## [Unreleased] section.\n'
      "If this PR doesn't require a changelog entry, add the 'skip-changelog' label.",
    );
  } else {
    stdout.writeln('✅ Found unreleased content in CHANGELOG.md:');
    stdout.writeln('');
    for (final line in content.take(20)) {
      stdout.writeln('  $line');
    }
    if (content.length > 20) {
      stdout.writeln('  ... (truncated)');
    }
  }
}

/// Extract content between ## [version] and the next ## heading
List<String> _extractVersionContent(String changelog, String version) {
  final lines = changelog.split('\n');
  final result = <String>[];
  var inSection = false;
  final versionPattern = RegExp(r'## \[' + RegExp.escape(version) + r'\]');

  for (final line in lines) {
    if (versionPattern.hasMatch(line)) {
      inSection = true;
      continue;
    }
    if (inSection && line.startsWith('## [')) {
      break;
    }
    if (inSection && line.trim().isNotEmpty) {
      result.add(line);
    }
  }

  return result;
}

/// Extract content between ## [Unreleased] and the next ## heading
List<String> _extractUnreleasedContent(String changelog) {
  final lines = changelog.split('\n');
  final result = <String>[];
  var inSection = false;

  for (final line in lines) {
    if (line.startsWith('## [Unreleased]')) {
      inSection = true;
      continue;
    }
    if (inSection && line.startsWith('## [')) {
      break;
    }
    if (inSection && line.trim().isNotEmpty) {
      result.add(line);
    }
  }

  return result;
}

/// Print error message and exit with failure
Never _fail(String message) {
  stderr.writeln('❌ $message');
  exit(1);
}
