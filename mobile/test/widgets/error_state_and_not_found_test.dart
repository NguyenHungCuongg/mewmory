import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mewmory/config/theme.dart';
import 'package:mewmory/pages/not_found_page.dart';
import 'package:mewmory/widgets/common/error_state.dart';

void main() {
  Widget buildTestApp(Widget child) {
    return MaterialApp(
      theme: MewTheme.light,
      home: Scaffold(body: child),
    );
  }

  group('ErrorState Widget Tests', () {
    testWidgets('renders title, message and triggers onRetry callback', (tester) async {
      bool retried = false;

      await tester.pumpWidget(
        buildTestApp(
          ErrorState(
            title: 'Lỗi tải dữ liệu',
            message: 'Không thể kết nối đến máy chủ.',
            actionLabel: 'Thử lại ngay',
            onRetry: () {
              retried = true;
            },
          ),
        ),
      );

      expect(find.text('Lỗi tải dữ liệu'), findsOneWidget);
      expect(find.text('Không thể kết nối đến máy chủ.'), findsOneWidget);
      expect(find.text('Thử lại ngay'), findsOneWidget);

      await tester.tap(find.text('Thử lại ngay'));
      await tester.pump();

      expect(retried, isTrue);
    });

    testWidgets('renders without action button when onRetry is null', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          const ErrorState(
            title: 'Lỗi không xác định',
            message: 'Đã có sự cố xảy ra.',
          ),
        ),
      );

      expect(find.text('Lỗi không xác định'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsNothing);
    });
  });

  group('NotFoundPage Widget Tests', () {
    testWidgets('renders 404 message and home button', (tester) async {
      final router = GoRouter(
        initialLocation: '/non-existent-page',
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (_, __) => const Scaffold(body: Text('Dashboard Page')),
          ),
        ],
        errorBuilder: (context, state) => NotFoundPage(error: state.error),
      );

      await tester.pumpWidget(
        MaterialApp.router(
          theme: MewTheme.light,
          routerConfig: router,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Không tìm thấy trang'), findsOneWidget);
      expect(find.text('Về trang chủ'), findsOneWidget);

      await tester.tap(find.text('Về trang chủ'));
      await tester.pumpAndSettle();

      expect(find.text('Dashboard Page'), findsOneWidget);
    });
  });
}
