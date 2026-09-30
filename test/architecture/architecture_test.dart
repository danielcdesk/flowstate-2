import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const List<String> allowedDependencyViolations = <String>[];
const List<String> allowedStyleViolations = <String>[];

Directory _projectRoot() {
  return Directory.current;
}

List<File> _dartFiles(String path) {
  final Directory directory = Directory(path);
  if (!directory.existsSync()) {
    return <File>[];
  }
  return directory
      .listSync(recursive: true)
      .whereType<File>()
      .where((File file) => file.path.endsWith('.dart'))
      .toList();
}

String _relativePath(File file) {
  return file.path.replaceAll('\\', '/');
}

List<String> _matches(Iterable<File> files, bool Function(String) predicate) {
  final List<String> matches = <String>[];
  for (final File file in files) {
    final String source = file.readAsStringSync();
    if (predicate(source)) {
      matches.add(_relativePath(file));
    }
  }
  return matches;
}

void main() {
  test('domain has no infrastructure or UI imports', () {
    final List<File> files = _dartFiles('${_projectRoot().path}/lib/domain');
    final List<String> violations = _matches(files, (String source) {
      return RegExp(
        r'''import\s+['"](package:flutter|package:drift|\.\.?/data|\.\.?/features)''',
      ).hasMatch(source);
    });

    expect(violations, allowedDependencyViolations);
  });

  test('features depend on domain interfaces only', () {
    final List<File> files = _dartFiles('${_projectRoot().path}/lib/features');
    final List<String> violations = _matches(files, (String source) {
      return RegExp(r'''import\s+['"](\.\.?/data|package:drift)''')
          .hasMatch(source);
    });

    expect(violations, allowedDependencyViolations);
  });

  test('design does not import features', () {
    final List<File> files = _dartFiles('${_projectRoot().path}/lib/design');
    final List<String> violations = _matches(files, (String source) {
      return RegExp(
        r'''import\s+['"](\.\.?/features|package:flowstate/.*/features)''',
      ).hasMatch(source);
    });

    expect(violations, allowedDependencyViolations);
  });

  test('forbidden design literals stay outside lib/design', () {
    final List<File> files = _dartFiles('${_projectRoot().path}/lib')
        .where((File file) => !_relativePath(file).contains('/lib/design/'))
        .toList();
    final List<String> violations = _matches(files, (String source) {
      return RegExp(
        r'Color\s*\(\s*0x[0-9A-Fa-f]+\s*\)|fontSize\s*:\s*\d|EdgeInsets(?:\.\w+)?\s*\([^)]*\d',
      ).hasMatch(source);
    });

    expect(violations, allowedStyleViolations);
  });

  test('user-facing strings do not use parenthesized plurals', () {
    final List<File> files = _dartFiles('${_projectRoot().path}/lib');
    final List<String> violations = _matches(files, (String source) {
      return RegExp(r'''['"][^'"]*\(s\)[^'"]*['"]''').hasMatch(source);
    });

    expect(violations, allowedStyleViolations);
  });

  test('domain and features do not call DateTime.now', () {
    final List<File> files = <File>[
      ..._dartFiles('${_projectRoot().path}/lib/domain'),
      ..._dartFiles('${_projectRoot().path}/lib/features'),
    ];
    final List<String> violations = _matches(files, (String source) {
      return source.contains('DateTime.now()');
    });

    expect(violations, allowedDependencyViolations);
  });
}
