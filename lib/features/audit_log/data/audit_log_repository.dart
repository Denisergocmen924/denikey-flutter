import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';

class AuditLogRepository {
  final Dio _dio = DioClient.instance.dio;

  Future<List<Map<String, dynamic>>> getLogs() async {
    final response = await _dio.get(ApiConstants.auditLog);
    return List<Map<String, dynamic>>.from(response.data);
  }
}
