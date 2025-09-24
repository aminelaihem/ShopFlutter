// lib/src/features/catalog/data/datasources/catalog_remote_ds.dart
import 'package:dio/dio.dart';

class CatalogRemoteDs {
  CatalogRemoteDs(this._dio);
  final Dio _dio;

  Future<List<Map<String, dynamic>>> getProducts() async {
    final res = await _dio.get('/products');
    final data = res.data as List;
    return data.cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> getProduct(int id) async {
    final res = await _dio.get('/products/$id');
    return res.data as Map<String, dynamic>;
  }

  Future<List<String>> getCategories() async {
    final res = await _dio.get('/products/categories');
    final data = res.data as List;
    return data.cast<String>();
  }
}
