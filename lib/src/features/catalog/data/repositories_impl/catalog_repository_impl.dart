// lib/src/features/catalog/data/repositories_impl/catalog_repository_impl.dart
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../datasources/catalog_remote_ds.dart';
import '../models/product_model.dart';
import '../../../../core/storage/cache.dart';

class CatalogRepositoryImpl implements CatalogRepository {
  CatalogRepositoryImpl(this._remote, this._cacheBox)
    : _cache = CacheStore(_cacheBox);

  final CatalogRemoteDs _remote;
  final Box _cacheBox;
  final CacheStore _cache;

  static const _kProductsKey = 'products_all';
  static String _kProductKey(int id) => 'product_$id';
  static const _ttl = Duration(minutes: 30);

  @override
  Future<List<Product>> fetchProducts() async {
    final cached = _cache.readJson<List<Product>>(_kProductsKey, (data) {
      final list = (data as List).cast<Map<String, dynamic>>();
      return list.map((e) => ProductModel.fromJson(e).toEntity()).toList();
    });
    if (cached != null) return cached;

    final raw = await _remote.getProducts();
    final models = raw.map((e) => ProductModel.fromJson(e)).toList();
    final entities = models.map((m) => m.toEntity()).toList();

    await _cache.writeJson(_kProductsKey, raw, ttl: _ttl);
    return entities;
  }

  @override
  Future<Product> fetchProduct(int id) async {
    final key = _kProductKey(id);
    final cached = _cache.readJson<Product>(key, (data) {
      final map = data as Map<String, dynamic>;
      return ProductModel.fromJson(map).toEntity();
    });
    if (cached != null) return cached;

    final raw = await _remote.getProduct(id);
    final entity = ProductModel.fromJson(raw).toEntity();

    await _cache.writeJson(key, raw, ttl: _ttl);
    return entity;
  }

  @override
  Future<List<String>> fetchCategories() async {
    const key = 'categories';
    final cached = _cache.readJson<List<String>>(key, (data) {
      final list = (data as List).cast<String>();
      return list;
    });
    if (cached != null) return cached;

    final cats = await _remote.getCategories();
    await _cache.writeJson(key, cats, ttl: _ttl);
    return cats;
  }
}
