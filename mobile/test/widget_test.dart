import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mewmory/app.dart';

void main() {
  testWidgets('MewmoryApp launches and displays AppShell with 4 bottom tabs',
      (WidgetTester tester) async {
    // Create a router with auth redirect disabled for pure shell testing
    final testRouter = createRouter(
      initialLocation: '/dashboard',
      enableAuthRedirect: false,
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MewmoryApp(router: testRouter),
      ),
    );
    await tester.pumpAndSettle();

    // Verify initial route shows Mewmory dashboard
    expect(find.text('Mewmory'), findsWidgets);

    // Verify 4 bottom navigation items are present
    expect(find.text('Trang chủ'), findsOneWidget);
    expect(find.text('Từ vựng'), findsOneWidget);
    expect(find.text('Bộ sưu tập'), findsWidgets);
    expect(find.text('Cài đặt'), findsOneWidget);

    // Switch to 'Từ vựng' tab
    await tester.tap(find.text('Từ vựng'));
    await tester.pumpAndSettle();
    expect(find.byType(FloatingActionButton), findsOneWidget);

    // Switch to 'Bộ sưu tập' tab
    await tester.tap(find.text('Bộ sưu tập').first);
    await tester.pumpAndSettle();
    expect(find.text('Bộ sưu tập'), findsWidgets);

    // Switch to 'Cài đặt' tab
    await tester.tap(find.text('Cài đặt'));
    await tester.pumpAndSettle();
    expect(find.text('Cấu hình AI'), findsOneWidget);
    expect(find.text('Tài khoản người dùng'), findsOneWidget);
  });

  testWidgets('MewmoryApp redirects to login when auth redirect is active without session',
      (WidgetTester tester) async {
    final testRouter = createRouter(
      initialLocation: '/dashboard',
      enableAuthRedirect: true,
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MewmoryApp(router: testRouter),
      ),
    );
    await tester.pumpAndSettle();

    // Because Supabase is not logged in / no session, redirects to /login
    expect(find.text('Đăng nhập'), findsWidgets);
    expect(find.text('Đăng nhập với Google'), findsOneWidget);
  });
}
