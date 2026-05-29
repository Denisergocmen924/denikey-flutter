import 'dart:async';
import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../storage/secure_storage.dart';
import '../router/app_router.dart';

// Token yenileme işlemlerinde maksimum bekleme süresi.
// refreshDio'nun timeout'u olmazsa backend yavaş/kapalı olduğunda
// vault ekranı sonsuz spinner'da kalır — asla exception atmaz.
const _kRefreshConnectTimeout  = Duration(seconds: 10);
const _kRefreshReceiveTimeout  = Duration(seconds: 35);

class DioClient {
  DioClient._();
  static final DioClient instance = DioClient._();

  late final Dio dio = _buildDio();

  Dio _buildDio() {
    final d = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 40),
        // Content-Type burada set edilmiyor — her istek türüne göre Dio otomatik belirler.
        // JSON için interceptor ekliyor, FormData için Dio multipart set eder.
      ),
    );
    d.interceptors.add(_JwtInterceptor(d));
    return d;
  }
}

class _JwtInterceptor extends Interceptor {
  final Dio _dio;
  bool _isRefreshing = false;
  Completer<String?>? _refreshCompleter;

  _JwtInterceptor(this._dio);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await SecureStorage.instance.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    // FormData değilse JSON varsayımı yap
    if (options.data is! FormData) {
      options.headers.putIfAbsent('Content-Type', () => 'application/json');
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401 ||
        err.requestOptions.path == ApiConstants.refreshToken ||
        err.requestOptions.path == ApiConstants.totpVerifyLogin) {
      handler.next(err);
      return;
    }

    // Refresh zaten sürüyorsa tamamlanmasını bekle
    if (_isRefreshing) {
      final newToken = await _refreshCompleter!.future;
      if (newToken == null) {
        handler.next(err);
        return;
      }
      final opts = err.requestOptions;
      opts.headers['Authorization'] = 'Bearer $newToken';
      handler.resolve(await _dio.fetch(opts));
      return;
    }

    _isRefreshing = true;
    _refreshCompleter = Completer<String?>();

    try {
      final refreshToken = await SecureStorage.instance.getRefreshToken();
      if (refreshToken == null) {
        _refreshCompleter!.complete(null);
        await _clearSession();
        handler.next(err);
        return;
      }

      final refreshDio = Dio(BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: _kRefreshConnectTimeout,
        receiveTimeout: _kRefreshReceiveTimeout,
        headers: {'Content-Type': 'application/json'},
      ));
      final response = await refreshDio.post(
        ApiConstants.refreshToken,
        data: {'refresh_token': refreshToken},
      );

      final newAccess  = response.data['access_token']  as String;
      final newRefresh = response.data['refresh_token'] as String;
      await SecureStorage.instance.saveToken(newAccess);
      await SecureStorage.instance.saveRefreshToken(newRefresh);

      _refreshCompleter!.complete(newAccess);

      final opts = err.requestOptions;
      opts.headers['Authorization'] = 'Bearer $newAccess';
      handler.resolve(await _dio.fetch(opts));
    } on DioException {
      _refreshCompleter!.complete(null);
      await _clearSession();
      handler.next(err);
    } finally {
      _isRefreshing = false;
      _refreshCompleter = null;
    }
  }

  Future<void> _clearSession() async {
    await SecureStorage.instance.clearAll();
    router.go('/login');
  }
}
