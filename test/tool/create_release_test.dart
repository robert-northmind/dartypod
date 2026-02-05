import 'package:test/test.dart';

import '../../tool/create_release.dart';

typedef Lines = List<String>;

void main() {
  test(
      'extractChangelogForVersion stops at next header even if version is prefix',
      () {
    final content = _joinLines([
      '# Changelog',
      '',
      '## [Unreleased]',
      '',
      '## [0.1.1] - 2026-02-01',
      '- Fix alpha issue',
      '',
      '## [0.1.10] - 2026-02-03',
      '- Add beta feature',
      '',
      '## [0.1.2] - 2026-02-04',
      '- Another fix',
    ]);

    final extracted = extractChangelogForVersion(content, '0.1.1');

    expect(extracted, contains('- Fix alpha issue'));
    expect(extracted, isNot(contains('- Add beta feature')));
    expect(extracted, isNot(contains('- Another fix')));
  });
}

String _joinLines(Lines lines) => lines.join('\n');
