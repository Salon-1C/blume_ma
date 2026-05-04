import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/api_constants.dart';
import '../errors/app_exception.dart';

// Overridden in main() with a PersistCookieJar backed by the app documents dir
final cookieJarProvider = Provider<PersistCookieJar>((_) {
  throw UnimplementedError('cookieJarProvider must be overridden in main()');
});

final dioProvider = Provider<Dio>((ref) {
  final cookieJar = ref.watch(cookieJarProvider);

  final dio = Dio(BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 30),
    headers: {'Content-Type': 'application/json'},
  ));

  dio.interceptors.add(CookieManager(cookieJar));
  dio.interceptors.add(_ErrorInterceptor());

  return dio;
});

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final response = err.response;
    if (response != null) {
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final appEx = AppException.fromApiError(data);
        handler.reject(DioException(
          requestOptions: err.requestOptions,
          error: appEx,
          response: response,
          type: err.type,
        ));
        return;
      }
      if (response.statusCode == 401) {
        handler.reject(DioException(
          requestOptions: err.requestOptions,
          error: const UnauthorizedException(),
          response: response,
          type: err.type,
        ));
        return;
      }
      if (response.statusCode == 404) {
        handler.reject(DioException(
          requestOptions: err.requestOptions,
          error: const NotFoundException(),
          response: response,
          type: err.type,
        ));
        return;
      }
    }
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError) {
      handler.reject(DioException(
        requestOptions: err.requestOptions,
        error: const NetworkException(),
        type: err.type,
      ));
      return;
    }
    handler.next(err);
  }
}

// Extracts the AppException from a DioException if possible
AppException extractError(Object e) {
  if (e is DioException && e.error is AppException) {
    return e.error as AppException;
  }
  if (e is AppException) return e;
  return AppException(code: 'UNKNOWN', message: e.toString());
}
