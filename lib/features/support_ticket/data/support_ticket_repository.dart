import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';

class SupportTicketRepository {
  final Dio _dio = DioClient.instance.dio;

  Future<void> createTicket({
    required String category,
    required String subject,
    required String message,
    required String priority,
  }) async {
    await _dio.post(
      ApiConstants.supportTickets,
      data: {
        'category': category,
        'subject': subject,
        'message': message,
        'priority': priority,
      },
    );
  }

  Future<List<Map<String, dynamic>>> getMyTickets() async {
    final response = await _dio.get(ApiConstants.supportTickets);
    return List<Map<String, dynamic>>.from(response.data);
  }

  Future<void> deleteTicket(String id) async {
    await _dio.delete(ApiConstants.supportTicket(id));
  }
}
