import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';

class ItemTypeRepository {
  final Dio _dio = DioClient.instance.dio;

  Future<List<Map<String, dynamic>>> getItemTypes() async {
    final response = await _dio.get('/api/v1/item-types/');
    return List<Map<String, dynamic>>.from(response.data);
  }

  Future<Map<String, dynamic>> createItemType(
    String nameTr,
    String icon,
    String color, {
    List<Map<String, dynamic>>? fields,
  }) async {
    final response = await _dio.post('/api/v1/item-types/', data: {
      'name_tr': nameTr,
      'icon': icon,
      'color': color,
      if (fields != null && fields.isNotEmpty) 'fields': fields,
    });
    return Map<String, dynamic>.from(response.data);
  }

  Future<Map<String, dynamic>> updateItemType(
    String id,
    String nameTr,
    String icon,
    String color, {
    List<Map<String, dynamic>>? fields,
    List<Map<String, dynamic>>? newFields,
  }) async {
    final response = await _dio.patch('/api/v1/item-types/$id', data: {
      'name_tr': nameTr,
      'icon': icon,
      'color': color,
      if (fields != null && fields.isNotEmpty) 'fields': fields,
      if (newFields != null && newFields.isNotEmpty) 'new_fields': newFields,
    });
    return Map<String, dynamic>.from(response.data);
  }

  Future<void> deleteItemType(String id) async {
    await _dio.delete('/api/v1/item-types/$id');
  }
}
