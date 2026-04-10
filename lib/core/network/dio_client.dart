import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../storage/secure_storage.dart';

class DioClient {
  DioClient._();
  static final DioClient instance = DioClient._();

  late final Dio dio = _buildDio();

  Dio _buildDio() {
    final d = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );
    d.interceptors.add(_JwtInterceptor(d));
    return d;
  }
}

class _JwtInterceptor extends Interceptor {
  final Dio _dio;
  bool _isRefreshing = false;

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
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Refresh endpoint'inden 401 gelirse sonsuz döngüye girme
    if (err.response?.statusCode == 401 &&
        !_isRefreshing &&
        err.requestOptions.path != ApiConstants.refreshToken) {
      _isRefreshing = true;
      try {
        final refreshToken = await SecureStorage.instance.getRefreshToken();
        if (refreshToken == null) {
          await _clearSession();
          handler.next(err);
          return;
        }

        // Yeni token al — interceptor'ı bypass etmek için ayrı Dio instance
        final refreshDio = Dio(BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          headers: {'Content-Type': 'application/json'},
        ));
        final response = await refreshDio.post(
          ApiConstants.refreshToken,
          data: {'refresh_token': refreshToken},
        );

        final newAccess = response.data['access_token'] as String;
        final newRefresh = response.data['refresh_token'] as String;
        await SecureStorage.instance.saveToken(newAccess);
        await SecureStorage.instance.saveRefreshToken(newRefresh);

        // Orijinal isteği yeni token ile tekrar gönder
        final opts = err.requestOptions;
        opts.headers['Authorization'] = 'Bearer $newAccess';
        final retryResponse = await _dio.fetch(opts);
        handler.resolve(retryResponse);
      } on DioException {
        // Refresh başarısız — oturumu temizle
        await _clearSession();
        handler.next(err);
      } finally {
        _isRefreshing = false;
      }
      return;
    }

    handler.next(err);
  }

  Future<void> _clearSession() async {
    await SecureStorage.instance.deleteToken();
    await SecureStorage.instance.deleteRefreshToken();
  }
}
