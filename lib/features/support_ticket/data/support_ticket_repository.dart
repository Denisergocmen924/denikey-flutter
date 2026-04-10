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
}
