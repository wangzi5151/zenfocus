import 'package:flutter_test/flutter_test.dart';
import 'package:zenfocus/services/stats_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('StatsStore', () {
    test('keyOf formats date correctly', () {
      expect(StatsStore.keyOf(DateTime(2026, 1, 5)), '2026-01-05');
      expect(StatsStore.keyOf(DateTime(2026, 12, 31)), '2026-12-31');
    });
  });
}
