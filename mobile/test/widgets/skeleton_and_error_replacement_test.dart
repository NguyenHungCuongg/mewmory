import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mewmory/config/theme.dart';
import 'package:mewmory/widgets/common/skeleton_loader.dart';

void main() {
  Widget buildTestApp(Widget child) {
    return MaterialApp(
      theme: MewTheme.light,
      home: Scaffold(body: child),
    );
  }

  group('SkeletonLoader Widget Tests', () {
    testWidgets('WordListSkeleton renders 4 animated skeleton cards', (tester) async {
      await tester.pumpWidget(buildTestApp(const WordListSkeleton(itemCount: 4)));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(WordCardSkeleton), findsNWidgets(4));
    });

    testWidgets('CollectionListSkeleton renders collection card skeletons', (tester) async {
      await tester.pumpWidget(buildTestApp(const CollectionListSkeleton(itemCount: 3)));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(CollectionCardSkeleton), findsNWidgets(3));
    });
  });
}
