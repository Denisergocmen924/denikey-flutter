import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';

class ItemTypeRepository {
  final Dio _dio = DioClient.instance.dio;

  Future<List<Map<String, dynamic>>> getItemTypes() async {
    final response = await _dio.get('/api/v1/item-types/');
    return List<Map<String, dynamic>>.from(response.data);
  }
}
