// lib/src/app/di/order_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../features/orders/data/repositories_impl/order_repository_impl.dart';
import '../../features/orders/domain/repositories/order_repository.dart';
import '../../features/orders/domain/entities/order.dart';

final _ordersBoxProvider = Provider<Box>((_) => Hive.box('orders'));

final orderRepositoryProvider = Provider<OrderRepository>(
      (ref) => OrderRepositoryImpl(ref.watch(_ordersBoxProvider)),
);

final ordersStreamProvider = StreamProvider<List<OrderEntity>>(
      (ref) => ref.watch(orderRepositoryProvider).watchOrders(),
);
