import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/audit_log_provider.dart';
import 'package:denikey_app/l10n/generated/app_localizations.dart';

class AuditLogScreen extends ConsumerStatefulWidget {
  const AuditLogScreen({super.key});

  @override
  ConsumerState<AuditLogScreen> createState() => _AuditLogScreenState();
}

class _AuditLogScreenState extends ConsumerState<AuditLogScreen> {
  String _selectedCategory = 'all';

  static const _categoryActions = {
    'account':  ['register', 'login_success', 'logout', 'email_changed', 'password_reset'],
    'security': ['login_failed', 'login_new_device', 'device_verified'],
    'vault':    ['vault_item_created', 'vault_item_updated', 'vault_item_deleted'],
  };

  static const _filterKeys = ['all', 'account', 'security', 'vault'];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(auditLogProvider.notifier).loadLogs());
  }

  String _filterLabel(String key, AppLocalizations l10n) {
    switch (key) {
      case 'all':      return l10n.auditLogFilterAll;
      case 'account':  return l10n.auditLogFilterAccount;
      case 'security': return l10n.auditLogFilterSecurity;
      case 'vault':    return l10n.auditLogFilterVault;
      default:         return key;
    }
  }

  String _getActionLabel(String? action, AppLocalizations l10n) {
    switch (action) {
      case 'register':            return l10n.auditLogActionRegister;
      case 'login_success':       return l10n.auditLogActionLoginSuccess;
      case 'login_failed':        return l10n.auditLogActionLoginFailed;
      case 'login_new_device':    return l10n.auditLogActionLoginNewDevice;
      case 'logout':              return l10n.auditLogActionLogout;
      case 'device_verified':     return l10n.auditLogActionDeviceVerified;
      case 'email_changed':       return l10n.auditLogActionEmailChanged;
      case 'password_reset':      return l10n.auditLogActionPasswordReset;
      case 'vault_item_created':  return l10n.auditLogActionVaultItemCreated;
      case 'vault_item_updated':  return l10n.auditLogActionVaultItemUpdated;
      case 'vault_item_deleted':  return l10n.auditLogActionVaultItemDeleted;
      default:                    return action ?? l10n.auditLogUnknownAction;
    }
  }

  List<Map<String, dynamic>> _filteredLogs(List<Map<String, dynamic>> logs) {
    if (_selectedCategory == 'all') return logs;
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
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(auditLogProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.auditLogTitle)),
      body: Column(
        children: [
          // Filter chips
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: _filterKeys.map((key) {
                final selected = _selectedCategory == key;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(_filterLabel(key, l10n)),
                    selected: selected,
                    onSelected: (_) => setState(() => _selectedCategory = key),
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
          Expanded(child: _buildBody(state, l10n)),
        ],
      ),
    );
  }

  Widget _buildBody(AuditLogState state, AppLocalizations l10n) {
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
            Text(state.errorMessage ?? l10n.auditLogError),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => ref.read(auditLogProvider.notifier).loadLogs(),
              child: Text(l10n.auditLogRetry),
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
              state.logs.isEmpty
                  ? l10n.auditLogEmpty
                  : l10n.auditLogEmptyCategory(_filterLabel(_selectedCategory, l10n)),
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
                _getActionLabel(action, l10n),
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
