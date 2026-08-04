import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/audit_log_provider.dart';
import 'package:denikey_app/l10n/generated/app_localizations.dart';
import '../../../core/presentation/app_animations.dart';
import '../../../core/presentation/app_tiles.dart';

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
    if (status == 'success') return kTeal;
    if (status == 'failure' || status == 'failed') return const Color(0xFFE5484D);
    return const Color(0xFFFFB020);
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

    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.auditLogTitle)),
      body: Column(
        children: [
          // ── Kategori filtresi — segment görünümlü kaydırmalı çipler ──
          SizedBox(
            height: 60,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              children: _filterKeys.map((key) {
                final selected = _selectedCategory == key;
                final index = _filterKeys.indexOf(key);
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => setState(() => _selectedCategory = key),
                      child: AnimatedContainer(
                        duration: AppAnim.fast,
                        curve: AppAnim.smooth,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: selected
                              ? kBlaze.withAlpha(28)
                              : cs.surfaceContainer,
                          border: Border.all(
                            color: selected
                                ? kBlaze.withAlpha(120)
                                : cs.outlineVariant,
                            width: selected ? 1.5 : 1,
                          ),
                        ),
                        child: Text(
                          _filterLabel(key, l10n),
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight:
                                selected ? FontWeight.w700 : FontWeight.w500,
                            color: selected ? kBlaze : cs.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
                    .animate(delay: AppAnim.listDelay(index))
                    .fadeIn(duration: AppAnim.normal)
                    .slideX(begin: 0.15, curve: AppAnim.smooth);
              }).toList(),
            ),
          ),
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
      return AppErrorState(
        message: state.errorMessage ?? l10n.auditLogError,
        retryLabel: l10n.auditLogRetry,
        onRetry: () => ref.read(auditLogProvider.notifier).loadLogs(),
      );
    }

    final filtered = _filteredLogs(state.logs);

    if (filtered.isEmpty) {
      return AppEmptyState(
        icon: Icons.history_outlined,
        title: state.logs.isEmpty
            ? l10n.auditLogEmpty
            : l10n.auditLogEmptyCategory(_filterLabel(_selectedCategory, l10n)),
        accent: kTeal,
      ).animate().fadeIn(duration: AppAnim.slow, curve: AppAnim.smooth);
    }

    final cs = Theme.of(context).colorScheme;

    return RefreshIndicator(
      onRefresh: () => ref.read(auditLogProvider.notifier).loadLogs(),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
        itemCount: filtered.length,
        separatorBuilder: (context, idx) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final log = filtered[index];
          final action = log['action'] as String?;
          final status = log['status'] as String?;
          final extraData = log['extra_data'] as Map<String, dynamic>?;
          final itemTitle = extraData?['title'] as String?;
          final accent = _colorForStatus(status);

          return AppListCard(
            child: Row(
              children: [
                DuotoneIcon(_iconForAction(action), color: accent),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getActionLabel(action, l10n),
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14.5),
                      ),
                      if (itemTitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          itemTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 12.5, color: cs.onSurfaceVariant),
                        ),
                      ],
                      const SizedBox(height: 3),
                      Text(
                        _formatDate(log['created_at'] as String?),
                        style: TextStyle(
                          fontSize: 11.5,
                          fontFeatures: const [FontFeature.tabularFigures()],
                          color: cs.onSurfaceVariant.withAlpha(180),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (status != null && status.isNotEmpty)
                  AppStatusBadge(label: status, color: accent),
              ],
            ),
          )
              .animate(delay: AppAnim.listDelay(index))
              .fadeIn(duration: AppAnim.normal)
              .slideY(begin: 0.12, curve: AppAnim.smooth);
        },
      ),
    );
  }
}
