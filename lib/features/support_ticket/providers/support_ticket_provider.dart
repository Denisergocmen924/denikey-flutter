import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/support_ticket_repository.dart';

enum SupportTicketStatus { idle, loading, success, error }

class SupportTicketState {
  final SupportTicketStatus status;
  final String? errorMessage;
  final List<Map<String, dynamic>> tickets;
  final bool ticketsLoading;

  const SupportTicketState({
    this.status = SupportTicketStatus.idle,
    this.errorMessage,
    this.tickets = const [],
    this.ticketsLoading = false,
  });

  SupportTicketState copyWith({
    SupportTicketStatus? status,
    String? errorMessage,
    List<Map<String, dynamic>>? tickets,
    bool? ticketsLoading,
  }) {
    return SupportTicketState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      tickets: tickets ?? this.tickets,
      ticketsLoading: ticketsLoading ?? this.ticketsLoading,
    );
  }
}

class SupportTicketNotifier extends StateNotifier<SupportTicketState> {
  final _repo = SupportTicketRepository();

  SupportTicketNotifier() : super(const SupportTicketState());

  Future<void> loadTickets() async {
    state = state.copyWith(ticketsLoading: true);
    try {
      final tickets = await _repo.getMyTickets();
      state = state.copyWith(tickets: tickets, ticketsLoading: false);
    } on DioException catch (_) {
      state = state.copyWith(ticketsLoading: false);
    }
  }

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
      await loadTickets();
    } on DioException catch (e) {
      final msg = e.response?.data['detail'] ?? 'Talep gönderilemedi';
      state = state.copyWith(
        status: SupportTicketStatus.error,
        errorMessage: msg.toString(),
      );
    }
  }

  void reset() => state = state.copyWith(status: SupportTicketStatus.idle, errorMessage: null);
}

final supportTicketProvider =
    StateNotifierProvider<SupportTicketNotifier, SupportTicketState>(
  (ref) => SupportTicketNotifier(),
);
