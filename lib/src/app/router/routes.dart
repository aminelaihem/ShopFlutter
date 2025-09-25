// lib/src/app/router/routes.dart
// Source de vérité des chemins
class AppRoutes {
  static const home = '/home';
  static const login = '/login';
  static const register = '/register';
  static const catalog = '/catalog';
  static String product(int id) => '/product/$id';
  static const cart = '/cart';
  static const checkout = '/checkout';
  static const orders = '/orders';

}
