import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';

class PasswordGeneratorRepository {
  final Dio _dio = DioClient.instance.dio;

  Future<String> generatePassword({
    required int length,
    required bool uppercase,
    required bool lowercase,
    required bool numbers,
    required bool symbols,
  }) async {
    final response = await _dio.post(
      ApiConstants.generatePassword,
      data: {
        'length': length,
        'uppercase': uppercase,
        'lowercase': lowercase,
        'numbers': numbers,
        'symbols': symbols,
      },
    );
    return response.data['password'] as String;
  }
}
