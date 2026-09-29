import 'package:flutter_test/flutter_test.dart';
import 'package:mewmory/services/sync_service.dart';

void main() {
  final t10 = DateTime.utc(2026, 9, 28, 10);
  final t11 = DateTime.utc(2026, 9, 28, 11);
  final t12 = DateTime.utc(2026, 9, 28, 12);

  test('nextSyncCursor picks the newest server timestamp seen', () {
    expect(nextSyncCursor(null, [t10, t12, t11]), t12);
  });

  test('nextSyncCursor keeps the previous cursor when nothing newer arrived', () {
    // Rows re-read inside the overlap window are older than the cursor.
    expect(nextSyncCursor(t12, [t10, t11]), t12);
    expect(nextSyncCursor(t12, const []), t12);
  });

  test('nextSyncCursor is null when there is no data at all', () {
    expect(nextSyncCursor(null, const []), isNull);
  });

  test('syncQueryStart rewinds by the overlap and is UTC', () {
    final start = syncQueryStart(t12);
    expect(start, endsWith('Z'));
    expect(t12.difference(DateTime.parse(start)), syncCursorOverlap);
  });
}
