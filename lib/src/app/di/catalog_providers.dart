// lib/src/app/di/catalog_providers.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../features/catalog/data/datasources/catalog_remote_ds.dart';
import '../../features/catalog/data/repositories_impl/catalog_repository_impl.dart';
import '../../features/catalog/domain/repositories/catalog_repository.dart';
import '../../features/catalog/domain/usecases/fetch_categories.dart';
import '../../features/catalog/domain/usecases/fetch_product.dart';
import '../../features/catalog/domain/usecases/fetch_products.dart';

final _dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: 'https://fakestoreapi.com',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 20),
  ));
  if (kDebugMode) {
    dio.interceptors.add(InterceptorsWrapper(
      onError: (e, h) {
        debugPrint('DioError: ${e.message}');
        h.next(e);
      },
    ));
  }
  return dio;
});

final _cacheBoxProvider = Provider<Box>((ref) => Hive.box('cache'));

final catalogRemoteDsProvider = Provider<CatalogRemoteDs>(
      (ref) => CatalogRemoteDs(ref.watch(_dioProvider)),
);

final catalogRepositoryProvider = Provider<CatalogRepository>(
      (ref) => CatalogRepositoryImpl(
    ref.watch(catalogRemoteDsProvider),
    ref.watch(_cacheBoxProvider),
  ),
);

final fetchProductsProvider = Provider<FetchProducts>(
      (ref) => FetchProducts(ref.watch(catalogRepositoryProvider)),
);

final fetchProductProvider = Provider<FetchProduct>(
      (ref) => FetchProduct(ref.watch(catalogRepositoryProvider)),
);

final fetchCategoriesProvider = Provider<FetchCategories>(
      (ref) => FetchCategories(ref.watch(catalogRepositoryProvider)),
);

final catalogProvider = FutureProvider((ref) async {
  final fetchProducts = ref.watch(fetchProductsProvider);
  return await fetchProducts();
});