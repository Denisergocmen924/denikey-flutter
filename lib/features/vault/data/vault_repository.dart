import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';

class VaultRepository {
  final Dio _dio = DioClient.instance.dio;

  Future<List<Map<String, dynamic>>> getItems() async {
    final response = await _dio.get(ApiConstants.vaultItems);
    return List<Map<String, dynamic>>.from(response.data);
  }

  Future<Map<String, dynamic>> createItem(Map<String, dynamic> data) async {
    final response = await _dio.post(ApiConstants.vaultItems, data: data);
    return Map<String, dynamic>.from(response.data);
  }

  Future<Map<String, dynamic>> updateItem(String id, Map<String, dynamic> data) async {
    final response = await _dio.put(ApiConstants.vaultItem(id), data: data);
    return Map<String, dynamic>.from(response.data);
  }

  Future<void> deleteItem(String id) async {
    await _dio.delete(ApiConstants.vaultItem(id));
  }
}