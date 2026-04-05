import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';

class CategoryRepository {
  final Dio _dio = DioClient.instance.dio;

  Future<List<Map<String, dynamic>>> getCategories() async {
    final response = await _dio.get(ApiConstants.categories);
    return List<Map<String, dynamic>>.from(response.data);
  }

  Future<Map<String, dynamic>> createCategory(Map<String, dynamic> data) async {
    final response = await _dio.post(ApiConstants.categories, data: data);
    return Map<String, dynamic>.from(response.data);
  }

  Future<Map<String, dynamic>> updateCategory(String id, Map<String, dynamic> data) async {
    final response = await _dio.put(ApiConstants.category(id), data: data);
    return Map<String, dynamic>.from(response.data);
  }

  Future<void> deleteCategory(String id) async {
    await _dio.delete(ApiConstants.category(id));
  }
}