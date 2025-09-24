// lib/src/app/router/app_router.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'routes.dart';
import '../di/auth_providers.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/catalog/presentation/pages/catalog_page.dart';
import '../../features/catalog/presentation/pages/product_detail_page.dart';
import '../../app_shell/home_page.dart'; // optionnel

class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _sub;
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _sub = stream.asBroadcastStream().listen((_) => notifyListeners());
  }
  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final sessionStream = ref.watch(sessionProvider.stream);

  return GoRouter(
    initialLocation: AppRoutes.catalog, // on arrive direct sur le catalogue
    refreshListenable: GoRouterRefreshStream(sessionStream),
    redirect: (context, state) {
      final session = ref.read(sessionProvider);
      final isLoggedIn = session.maybeWhen(data: (u) => u != null, orElse: () => false);
      final currentPath = state.uri.path;
      final isAuthRoute = currentPath == AppRoutes.login || currentPath == AppRoutes.register;

      if (!isLoggedIn && !isAuthRoute) return AppRoutes.login;
      if (isLoggedIn && isAuthRoute) return AppRoutes.catalog;
      return null;
    },
    routes: [
      // auth
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),

      // catalog
      GoRoute(
        path: AppRoutes.catalog,
        name: 'catalog',
        builder: (context, state) => const CatalogPage(),
      ),
      GoRoute(
        path: '/product/:id',
        name: 'product',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          if (id == null) {
            return const Scaffold(body: Center(child: Text('Produit invalide')));
          }
          return ProductDetailPage(id: id);
        },
      ),

      // optionnel
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
    ],
  );
});
