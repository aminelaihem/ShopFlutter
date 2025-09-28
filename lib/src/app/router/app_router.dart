// lib/src/app/router/app_router.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'routes.dart';
import '../di/auth_providers.dart';

// pages
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/profile_page.dart';
import '../../features/catalog/presentation/pages/catalog_page.dart';
import '../../features/catalog/presentation/pages/product_detail_page.dart';
import '../../features/cart/presentation/pages/cart_page.dart';
import '../../features/orders/presentation/pages/checkout_page.dart';
import '../../features/orders/presentation/pages/orders_page.dart';
import '../../app_shell/home_page.dart';

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
    // Home = écran par défaut
    initialLocation: AppRoutes.home,
    refreshListenable: GoRouterRefreshStream(sessionStream),
    redirect: (context, state) {
      final session = ref.read(sessionProvider);
      final isLoggedIn = session.maybeWhen(
        data: (u) => u != null,
        orElse: () => false,
      );
      final currentPath = state.uri.path;
      final isAuthRoute =
          currentPath == AppRoutes.login || currentPath == AppRoutes.register;

      if (!isLoggedIn && !isAuthRoute) return AppRoutes.login;
      if (isLoggedIn && isAuthRoute)
        return AppRoutes.home; // après login, va sur Home
      return null;
    },
    routes: [
      // routes publiques
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (_, __) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (_, __) => const RegisterPage(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        name: 'profile',
        builder: (context, state) => const ProfilePage(),
      ),

      // home
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (_, __) => const HomePage(),
      ),

      // catalog
      GoRoute(
        path: AppRoutes.catalog,
        name: 'catalog',
        builder: (_, __) => const CatalogPage(),
      ),
      GoRoute(
        path: '/product/:id',
        name: 'product',
        builder: (_, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          if (id == null)
            return const Scaffold(
              body: Center(child: Text('Produit invalide')),
            );
          return ProductDetailPage(id: id);
        },
      ),

      // cart / checkout / orders
      GoRoute(
        path: AppRoutes.cart,
        name: 'cart',
        builder: (_, __) => const CartPage(),
      ),
      GoRoute(
        path: AppRoutes.checkout,
        name: 'checkout',
        builder: (_, __) => const CheckoutPage(),
      ),
      GoRoute(
        path: AppRoutes.orders,
        name: 'orders',
        builder: (_, __) => const OrdersPage(),
      ),
    ],
  );
});
