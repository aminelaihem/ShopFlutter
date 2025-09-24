// lib/src/app/di/cart_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../features/cart/data/repositories_impl/cart_repository_impl.dart';
import '../../features/cart/domain/repositories/cart_repository.dart';
import '../../features/cart/domain/entities/cart_item.dart';

final _cartBoxProvider = Provider<Box>((_) => Hive.box('cart'));

final cartRepositoryProvider = Provider<CartRepository>(
      (ref) => CartRepositoryImpl(ref.watch(_cartBoxProvider)),
);

// Items en live
final cartItemsStreamProvider = StreamProvider<List<CartItem>>(
      (ref) => ref.watch(cartRepositoryProvider).watchItems(),
);

// Compteur en live
final cartCountProvider = StreamProvider<int>(
      (ref) => ref.watch(cartRepositoryProvider).watchItems().map(
        (items) => items.fold<int>(0, (acc, e) => acc + e.qty),
  ),
);

// Total en live
final cartTotalProvider = StreamProvider<double>(
      (ref) => ref.watch(cartRepositoryProvider).watchItems().map(
        (items) => items.fold<double>(0, (acc, e) => acc + e.price * e.qty),
  ),
);
