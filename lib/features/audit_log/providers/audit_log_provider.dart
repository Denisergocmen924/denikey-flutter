import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/audit_log_repository.dart';

enum AuditLogStatus { idle, loading, success, error }

class AuditLogState {
  final AuditLogStatus status;
  final List<Map<String, dynamic>> logs;
  final String? errorMessage;

  const AuditLogState({
    this.status = AuditLogStatus.idle,
    this.logs = const [],
    this.errorMessage,
  });

  AuditLogState copyWith({
    AuditLogStatus? status,
    List<Map<String, dynamic>>? logs,
    String? errorMessage,
  }) {
    return AuditLogState(
      status: status ?? this.status,
      logs: logs ?? this.logs,
      errorMessage: errorMessage,
    );
  }
}

class AuditLogNotifier extends StateNotifier<AuditLogState> {
  final _repo = AuditLogRepository();

  AuditLogNotifier() : super(const AuditLogState());

  Future<void> loadLogs() async {
    state = state.copyWith(status: AuditLogStatus.loading);
    try {
      final logs = await _repo.getLogs();
      state = state.copyWith(status: AuditLogStatus.success, logs: logs);
    } on DioException catch (e) {
      final msg = e.response?.data['detail'] ?? 'Kayıtlar yüklenemedi';
      state = state.copyWith(
        status: AuditLogStatus.error,
        errorMessage: msg.toString(),
      );
    }
  }
}

final auditLogProvider =
    StateNotifierProvider<AuditLogNotifier, AuditLogState>(
  (ref) => AuditLogNotifier(),
);
