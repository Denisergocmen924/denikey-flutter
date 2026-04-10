import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/support_ticket_repository.dart';

enum SupportTicketStatus { idle, loading, success, error }

class SupportTicketState {
  final SupportTicketStatus status;
  final String? errorMessage;

  const SupportTicketState({
    this.status = SupportTicketStatus.idle,
    this.errorMessage,
  });

  SupportTicketState copyWith({
    SupportTicketStatus? status,
    String? errorMessage,
  }) {
    return SupportTicketState(
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }
}

class SupportTicketNotifier extends StateNotifier<SupportTicketState> {
  final _repo = SupportTicketRepository();

  SupportTicketNotifier() : super(const SupportTicketState());

  Future<void> createTicket({
    required String category,
    required String subject,
    required String message,
    required String priority,
  }) async {
    state = state.copyWith(status: SupportTicketStatus.loading);
    try {
      await _repo.createTicket(
        category: category,
        subject: subject,
        message: message,
        priority: priority,
      );
      state = state.copyWith(status: SupportTicketStatus.success);
    } on DioException catch (e) {
      final msg = e.response?.data['detail'] ?? 'Talep gönderilemedi';
      state = state.copyWith(
        status: SupportTicketStatus.error,
        errorMessage: msg.toString(),
      );
    }
  }

  void reset() => state = const SupportTicketState();
}

final supportTicketProvider =
    StateNotifierProvider<SupportTicketNotifier, SupportTicketState>(
  (ref) => SupportTicketNotifier(),
);
