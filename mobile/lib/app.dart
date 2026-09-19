import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/theme.dart';
import 'pages/add_word_page.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/vocabulary_list_page.dart';

final GlobalKey<NavigatorState> rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> dashboardNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'dashboard');
final GlobalKey<NavigatorState> vocabularyNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'vocabulary');
final GlobalKey<NavigatorState> collectionsNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'collections');
final GlobalKey<NavigatorState> settingsNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'settings');

GoRouter createRouter({
  String initialLocation = '/dashboard',
  bool enableAuthRedirect = true,
  bool Function()? isAuthenticated,
}) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: initialLocation,
    redirect: (context, state) {
      if (!enableAuthRedirect) return null;

      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      final bool loggedIn;
      if (isAuthenticated != null) {
        loggedIn = isAuthenticated();
      } else {
        bool hasSession = false;
        try {
          hasSession = Supabase.instance.client.auth.currentSession != null;
        } catch (_) {
          hasSession = false;
        }
        loggedIn = hasSession;
      }

      if (!loggedIn && !isAuthRoute) {
        return '/login';
      }
      if (loggedIn && isAuthRoute) {
        return '/dashboard';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        redirect: (_, __) => '/dashboard',
      ),
      GoRoute(
        path: '/login',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const RegisterPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: dashboardNavigatorKey,
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) => const PlaceholderPage(
                  title: 'Trang chủ',
                  route: '/dashboard',
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: vocabularyNavigatorKey,
            routes: [
              GoRoute(
                path: '/vocabulary',
                builder: (context, state) => const VocabularyListPage(),
                routes: [
                  GoRoute(
                    path: 'add',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => const AddWordPage(),
                  ),
                  GoRoute(
                    path: ':id',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => PlaceholderPage(
                      title: 'Chi tiết từ vựng',
                      route: '/vocabulary/${state.pathParameters['id']}',
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: collectionsNavigatorKey,
            routes: [
              GoRoute(
                path: '/collections',
                builder: (context, state) => const PlaceholderPage(
                  title: 'Bộ sưu tập',
                  route: '/collections',
                ),
                routes: [
                  GoRoute(
                    path: ':id',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => PlaceholderPage(
                      title: 'Chi tiết bộ sưu tập',
                      route: '/collections/${state.pathParameters['id']}',
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: settingsNavigatorKey,
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const PlaceholderPage(
                  title: 'Cài đặt',
                  route: '/settings',
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

final GoRouter appRouter = createRouter();

class MewmoryApp extends StatelessWidget {
  final GoRouter? router;

  const MewmoryApp({super.key, this.router});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Mewmory',
      theme: MewTheme.light,
      routerConfig: router ?? appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}

class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(
              color: MewColors.stone,
              width: 1.0,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: navigationShell.currentIndex,
          onTap: (index) {
            navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            );
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Trang chủ',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_outlined),
              activeIcon: Icon(Icons.menu_book),
              label: 'Từ vựng',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.folder_outlined),
              activeIcon: Icon(Icons.folder),
              label: 'Bộ sưu tập',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Cài đặt',
            ),
          ],
        ),
      ),
    );
  }
}

class PlaceholderPage extends StatelessWidget {
  final String title;
  final String route;

  const PlaceholderPage({
    super.key,
    required this.title,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: MewColors.warmTaupe,
                  borderRadius: BorderRadius.circular(9999),
                  border: Border.all(color: MewColors.stone),
                ),
                child: Text(
                  route,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: MewColors.smoke,
                        fontFamily: 'monospace',
                      ),
                ),
              ),
              const SizedBox(height: 24),
              if (route == '/login') ...[
                ElevatedButton(
                  onPressed: () => context.go('/dashboard'),
                  child: const Text('Vào ứng dụng (Bypass)'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => context.go('/register'),
                  child: const Text('Đến trang Đăng ký'),
                ),
              ] else if (route == '/register') ...[
                OutlinedButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('Quay lại Đăng nhập'),
                ),
              ] else if (route == '/vocabulary') ...[
                ElevatedButton(
                  onPressed: () => context.push('/vocabulary/add'),
                  child: const Text('Thêm từ mới'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
