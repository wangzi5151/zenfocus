import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:zenfocus/core/app_info.dart';

void main() {
  test('pubspec version matches the user-facing app version', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final match =
        RegExp(r'^version:\s*([0-9]+\.[0-9]+\.[0-9]+)', multiLine: true)
            .firstMatch(pubspec);
    expect(match, isNotNull);
    expect(match!.group(1), kAppVersion);
  });
}
