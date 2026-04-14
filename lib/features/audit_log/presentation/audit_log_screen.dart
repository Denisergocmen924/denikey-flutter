import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/audit_log_provider.dart';

class AuditLogScreen extends ConsumerStatefulWidget {
  const AuditLogScreen({super.key});

  @override
  ConsumerState<AuditLogScreen> createState() => _AuditLogScreenState();
}

class _AuditLogScreenState extends ConsumerState<AuditLogScreen> {
  String _selectedCategory = 'Tümü';

  static const _categoryActions = {
    'Hesap':    ['register', 'login_success', 'logout', 'email_changed', 'password_reset'],
    'Güvenlik': ['login_failed', 'login_new_device', 'device_verified'],
    'Kasa':     ['vault_item_created', 'vault_item_updated', 'vault_item_deleted'],
  };

  static const _actionLabels = {
    'register':            'Kayıt Olundu',
    'login_success':       'Giriş Yapıldı',
    'login_failed':        'Başarısız Giriş',
    'login_new_device':    'Yeni Cihaz Girişi',
    'logout':              'Çıkış Yapıldı',
    'device_verified':     'Cihaz Doğrulandı',
    'email_changed':       'E-posta Değiştirildi',
    'password_reset':      'Şifre Sıfırlandı',
    'vault_item_created':  'Şifre Eklendi',
    'vault_item_updated':  'Şifre Güncellendi',
    'vault_item_deleted':  'Şifre Silindi',
  };

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(auditLogProvider.notifier).loadLogs());
  }

  List<Map<String, dynamic>> _filteredLogs(List<Map<String, dynamic>> logs) {
    if (_selectedCategory == 'Tümü') return logs;
    final allowed = _categoryActions[_selectedCategory] ?? [];
    return logs.where((l) => allowed.contains(l['action'])).toList();
  }

  IconData _iconForAction(String? action) {
    if (action == null) return Icons.info_outline;
    switch (action) {
      case 'vault_item_created': return Icons.add_circle_outline;
      case 'vault_item_updated': return Icons.edit_outlined;
      case 'vault_item_deleted': return Icons.delete_outline;
      case 'login_success':      return Icons.login;
      case 'login_failed':       return Icons.no_encryption_outlined;
      case 'login_new_device':   return Icons.devices_outlined;
      case 'logout':             return Icons.logout;
      case 'register':           return Icons.person_add_outlined;
      case 'device_verified':    return Icons.verified_outlined;
      case 'email_changed':      return Icons.email_outlined;
      case 'password_reset':     return Icons.lock_reset_outlined;
      default:                   return Icons.history_outlined;
    }
  }

  Color _colorForStatus(String? status) {
    if (status == 'success') return Colors.green;
    if (status == 'failure' || status == 'failed') return Colors.red;
    return Colors.orange;
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final dt = DateTime.parse(dateStr).toLocal();
      return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year} '
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(auditLogProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Aktivite Geçmişi')),
      body: Column(
        children: [
          // Filter chips
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: ['Tümü', 'Hesap', 'Güvenlik', 'Kasa'].map((cat) {
                final selected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(cat),
                    selected: selected,
                    onSelected: (_) => setState(() => _selectedCategory = cat),
                    selectedColor: Theme.of(context).colorScheme.primaryContainer,
                    checkmarkColor: Theme.of(context).colorScheme.primary,
                    labelStyle: TextStyle(
                      color: selected ? Theme.of(context).colorScheme.primary : null,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1),
          // İçerik
          Expanded(child: _buildBody(state)),
        ],
      ),
    );
  }

  Widget _buildBody(AuditLogState state) {
    if (state.status == AuditLogStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.status == AuditLogStatus.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(state.errorMessage ?? 'Hata'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => ref.read(auditLogProvider.notifier).loadLogs(),
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      );
    }

    final filtered = _filteredLogs(state.logs);

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              state.logs.isEmpty ? 'Henüz aktivite yok' : '$_selectedCategory kategorisinde kayıt yok',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(auditLogProvider.notifier).loadLogs(),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: filtered.length,
        separatorBuilder: (context, idx) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final log = filtered[index];
          final action = log['action'] as String?;
          final status = log['status'] as String?;
          final extraData = log['extra_data'] as Map<String, dynamic>?;
          final itemTitle = extraData?['title'] as String?;

          return Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _colorForStatus(status).withAlpha(25),
                child: Icon(
                  _iconForAction(action),
                  color: _colorForStatus(status),
                  size: 20,
                ),
              ),
              title: Text(
                _actionLabels[action] ?? action ?? 'Bilinmeyen İşlem',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (itemTitle != null)
                    Text(
                      itemTitle,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                    ),
                  Text(
                    _formatDate(log['created_at'] as String?),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
              isThreeLine: itemTitle != null,
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _colorForStatus(status).withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status ?? '',
                  style: TextStyle(
                    fontSize: 11,
                    color: _colorForStatus(status),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
