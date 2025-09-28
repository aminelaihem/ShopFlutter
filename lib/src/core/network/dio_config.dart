// lib/src/core/network/dio_config.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class DioConfig {
  static Dio createDio({
    required String baseUrl,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    Duration? sendTimeout,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: connectTimeout ?? const Duration(seconds: 30),
        receiveTimeout: receiveTimeout ?? const Duration(seconds: 60),
        sendTimeout: sendTimeout ?? const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Intercepteur pour le debug
    if (kDebugMode) {
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            debugPrint('🌐 REQUEST: ${options.method} ${options.uri}');
            debugPrint('📤 Headers: ${options.headers}');
            if (options.data != null) {
              debugPrint('📦 Data: ${options.data}');
            }
            handler.next(options);
          },
          onResponse: (response, handler) {
            debugPrint(
              '✅ RESPONSE: ${response.statusCode} ${response.requestOptions.uri}',
            );
            debugPrint('📥 Data: ${response.data}');
            handler.next(response);
          },
          onError: (error, handler) {
            debugPrint(
              '❌ ERROR: ${error.requestOptions.method} ${error.requestOptions.uri}',
            );
            debugPrint('💥 Message: ${error.message}');
            if (error.response != null) {
              debugPrint('📊 Status: ${error.response?.statusCode}');
              debugPrint('📥 Response Data: ${error.response?.data}');
            }
            handler.next(error);
          },
        ),
      );
    }

    // Intercepteur de retry pour les erreurs de timeout
    dio.interceptors.add(
      RetryInterceptor(
        dio: dio,
        logPrint: kDebugMode ? debugPrint : null,
        retries: 3,
        retryDelays: const [
          Duration(seconds: 1),
          Duration(seconds: 2),
          Duration(seconds: 3),
        ],
      ),
    );

    return dio;
  }
}

class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int retries;
  final List<Duration> retryDelays;
  final void Function(String message)? logPrint;

  RetryInterceptor({
    required this.dio,
    this.retries = 3,
    this.retryDelays = const [
      Duration(seconds: 1),
      Duration(seconds: 2),
      Duration(seconds: 3),
    ],
    this.logPrint,
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (_shouldRetry(err)) {
      final retryCount = err.requestOptions.extra['retryCount'] ?? 0;

      if (retryCount < retries) {
        final delay = retryDelays[retryCount % retryDelays.length];

        logPrint?.call(
          '🔄 Retry ${retryCount + 1}/$retries après ${delay.inSeconds}s pour ${err.requestOptions.uri}',
        );

        await Future.delayed(delay);

        try {
          final response = await dio.fetch(
            err.requestOptions.copyWith(
              extra: {
                ...err.requestOptions.extra,
                'retryCount': retryCount + 1,
              },
            ),
          );
          handler.resolve(response);
          return;
        } catch (e) {
          if (e is DioException) {
            err = e;
          }
        }
      }
    }

    handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError ||
        (err.response?.statusCode != null && err.response!.statusCode! >= 500);
  }
}
