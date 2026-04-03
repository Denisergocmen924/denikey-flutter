import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../core/constants/api_constants.dart';

class AuthRepository {
  final Dio _dio = DioClient.instance.dio;

  Future<void> register({
    required String username,
    required String email,
    required String masterPassword,
  }) async {
    await _dio.post(
      ApiConstants.register,
      data: {
        'username': username,
        'email': email,
        'master_password': masterPassword,
      },
    );
  }

  Future<void> login({
    required String username,
    required String masterPassword,
  }) async {
    final response = await _dio.post(
      ApiConstants.login,
      data: {
        'username': username,
        'master_password': masterPassword,
      },
    );

    final token = response.data['access_token'] as String;
    await SecureStorage.instance.saveToken(token);
    await SecureStorage.instance.saveEmail(username);
  }

  Future<void> logout() async {
    await SecureStorage.instance.clearAll();
  }
}