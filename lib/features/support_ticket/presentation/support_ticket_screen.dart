import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/support_ticket_provider.dart';
import 'package:denikey_app/l10n/generated/app_localizations.dart';
import '../../../core/presentation/app_nav_bar.dart';
import '../../../core/presentation/app_animations.dart';
import '../../../core/presentation/app_tiles.dart';

class SupportTicketScreen extends ConsumerStatefulWidget {
  const SupportTicketScreen({super.key});

  @override
  ConsumerState<SupportTicketScreen> createState() => _SupportTicketScreenState();
}

class _SupportTicketScreenState extends ConsumerState<SupportTicketScreen> {
  final _subjectCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _category = 'bug';
  String _priority = 'normal';
  bool _ticketsExpanded = false;

  // Durum renkleri "Onyx & Ember" paletiyle hizalandı:
  // açık → bilgi mavisi, işlemde → amber, kapandı → teal.
  static const _statusColors = {
    'open': Color(0xFF4FC3F7),
    'in_progress': Color(0xFFFFB020),
    'closed': kTeal,
  };

  Map<String, String> _categoryLabels(AppLocalizations l10n) => {
    'bug': l10n.supportTicketCategoryBug,
    'suggestion': l10n.supportTicketCategorySuggestion,
    'other': l10n.supportTicketCategoryOther,
  };

  Map<String, String> _priorityLabels(AppLocalizations l10n) => {
    'low': l10n.supportTicketPriorityLow,
    'normal': l10n.supportTicketPriorityNormal,
    'high': l10n.supportTicketPriorityHigh,
  };

  Map<String, String> _statusLabels(AppLocalizations l10n) => {
    'open': l10n.supportTicketStatusOpen,
    'in_progress': l10n.supportTicketStatusInProgress,
    'closed': l10n.supportTicketStatusClosed,
  };

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(supportTicketProvider.notifier).loadTickets());
  }

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(supportTicketProvider.notifier).createTicket(
      category: _category,
      subject: _subjectCtrl.text.trim(),
      message: _messageCtrl.text.trim(),
      priority: _priority,
    );
  }

  void _showDeleteDialog(Map<String, dynamic> ticket) {
    final l10n = AppLocalizations.of(context);
    int countdown = 3;
    Timer? timer;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          timer ??= Timer.periodic(const Duration(seconds: 1), (t) {
            if (countdown > 0) {
              setDialogState(() => countdown--);
            } else {
              t.cancel();
            }
          });

          return AlertDialog(
            title: Text(l10n.supportTicketDeleteConfirmTitle),
            content: Text(l10n.supportTicketDeleteConfirmMessage),
            actions: [
              TextButton(
                onPressed: () {
                  timer?.cancel();
                  Navigator.of(ctx).pop();
                },
                child: Text(l10n.supportTicketDeleteCancel),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(ctx).colorScheme.error),
                onPressed: countdown > 0
                    ? null
                    : () async {
                        timer?.cancel();
                        Navigator.of(ctx).pop();
                        await ref.read(supportTicketProvider.notifier).deleteTicket(ticket['id'] as String);
                      },
                child: Text(
                  countdown > 0
                      ? '${l10n.supportTicketDeleteConfirm} ($countdown)'
                      : l10n.supportTicketDeleteConfirm,
                ),
              ),
            ],
          );
        },
      ),
    ).then((_) => timer?.cancel());
  }

  void _showTicketDetail(Map<String, dynamic> ticket) {
    final l10n = AppLocalizations.of(context);
    final status = ticket['status'] as String? ?? 'open';
    final adminReply = ticket['admin_reply'] as String?;
    final statusColor =
        _statusColors[status] ?? Theme.of(context).colorScheme.onSurfaceVariant;
    final statusLabel = _statusLabels(l10n)[status] ?? status;
    final category = _categoryLabels(l10n)[ticket['category']] ?? ticket['category'] ?? '';
    final repliedAt = ticket['replied_at'];

    final cs = Theme.of(context).colorScheme;
    final hasReply = adminReply != null && adminReply.isNotEmpty;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        builder: (_, controller) => SingleChildScrollView(
          controller: controller,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: cs.onSurfaceVariant.withAlpha(70),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DuotoneIcon(
                      hasReply
                          ? Icons.mark_email_read_outlined
                          : Icons.mail_outline,
                      color: statusColor,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ticket['subject'] ?? '',
                            style: const TextStyle(
                                fontSize: 17.5, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            category,
                            style: TextStyle(
                                fontSize: 12.5, color: cs.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    AppStatusBadge(label: statusLabel, color: statusColor),
                  ],
                ),
                const SizedBox(height: 24),

                AppSectionTitle(l10n.supportTicketDetailMessage),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: cs.outlineVariant),
                  ),
                  child: Text(ticket['message'] ?? '',
                      style: TextStyle(
                          fontSize: 14, height: 1.5, color: cs.onSurface)),
                ),

                if (hasReply) ...[
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: AppSectionTitle(l10n.supportTicketAdminReply,
                            accent: kTeal),
                      ),
                      if (repliedAt != null)
                        Text(
                          _formatDate(repliedAt.toString()),
                          style: TextStyle(
                            fontSize: 11,
                            fontFeatures: const [FontFeature.tabularFigures()],
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: kTeal.withAlpha(22),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: kTeal.withAlpha(70)),
                    ),
                    child: Text(
                      adminReply,
                      style: TextStyle(
                          fontSize: 14, height: 1.5, color: cs.onSurface),
                    ),
                  ).animate().fadeIn(duration: AppAnim.normal).slideY(
                      begin: 0.08, curve: AppAnim.smooth),
                ] else ...[
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Icon(Icons.schedule,
                          size: 15, color: cs.onSurfaceVariant),
                      const SizedBox(width: 6),
                      Text(l10n.supportTicketWaitingReply,
                          style: TextStyle(
                              fontSize: 13, color: cs.onSurfaceVariant)),
                    ],
                  ),
                ],
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(String iso) {
    try {
      final d = DateTime.parse(iso).toLocal();
      return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(supportTicketProvider);
    final categories = _categoryLabels(l10n);
    final priorities = _priorityLabels(l10n);
    final statusLabels = _statusLabels(l10n);
    final cs = Theme.of(context).colorScheme;

    ref.listen(supportTicketProvider, (prev, next) {
      if (next.status == SupportTicketStatus.success) {
        final isDelete = prev?.tickets.length != next.tickets.length && next.tickets.length < (prev?.tickets.length ?? 0);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isDelete ? l10n.supportTicketDeleteSuccess : l10n.supportTicketSuccess)),
        );
        if (!isDelete) {
          _subjectCtrl.clear();
          _messageCtrl.clear();
          setState(() { _category = 'bug'; _priority = 'normal'; });
        }
        ref.read(supportTicketProvider.notifier).reset();
      }
      if (next.status == SupportTicketStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage ?? l10n.supportTicketError)),
        );
        ref.read(supportTicketProvider.notifier).reset();
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(l10n.supportTicketTitle)),
      bottomNavigationBar: const AppNavBar(currentIndex: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            if (state.ticketsLoading)
              const Center(child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ))
            else if (state.ticketsError)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
                decoration: BoxDecoration(
                  color: cs.error.withAlpha(20),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: cs.error.withAlpha(70)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, size: 18, color: cs.error),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l10n.supportTicketLoadingError,
                        style: TextStyle(color: cs.error, fontSize: 13),
                      ),
                    ),
                    TextButton(
                      onPressed: () => ref.read(supportTicketProvider.notifier).loadTickets(),
                      child: Text(l10n.supportTicketLoadingRetry),
                    ),
                  ],
                ),
              )
            else if (state.tickets.isNotEmpty) ...[
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => setState(() => _ticketsExpanded = !_ticketsExpanded),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Expanded(child: AppSectionTitle(l10n.supportTicketMyTickets)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
                          decoration: BoxDecoration(
                            color: kBlaze.withAlpha(28),
                            borderRadius: BorderRadius.circular(9),
                            border: Border.all(color: kBlaze.withAlpha(70)),
                          ),
                          child: Text(
                            '${state.tickets.length}',
                            style: const TextStyle(
                                fontSize: 12,
                                color: kBlaze,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(width: 6),
                        AnimatedRotation(
                          turns: _ticketsExpanded ? 0.5 : 0,
                          duration: AppAnim.fast,
                          curve: AppAnim.smooth,
                          child: Icon(Icons.expand_more,
                              color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (_ticketsExpanded) ...[
              const SizedBox(height: 12),
              ...state.tickets.asMap().entries.map((entry) {
                final index = entry.key;
                final t = entry.value;
                final status = t['status'] as String? ?? 'open';
                final statusColor = _statusColors[status] ?? cs.onSurfaceVariant;
                final statusLabel = statusLabels[status] ?? status;
                final hasReply = (t['admin_reply'] as String?)?.isNotEmpty == true;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: AppListCard(
                    onTap: () => _showTicketDetail(t),
                    accent: hasReply ? kTeal : null,
                    child: Row(
                      children: [
                        DuotoneIcon(
                          hasReply
                              ? Icons.mark_email_read_outlined
                              : Icons.mail_outline,
                          color: hasReply ? kTeal : statusColor,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t['subject'] ?? '',
                                style: const TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w600),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                hasReply
                                    ? l10n.supportTicketReplied
                                    : l10n.supportTicketWaitingReplyLong,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight:
                                      hasReply ? FontWeight.w600 : null,
                                  color:
                                      hasReply ? kTeal : cs.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        AppStatusBadge(label: statusLabel, color: statusColor),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20),
                          color: cs.error,
                          tooltip: l10n.supportTicketDeleteConfirm,
                          onPressed: () => _showDeleteDialog(t),
                        ),
                      ],
                    ),
                  ),
                )
                    .animate(delay: AppAnim.listDelay(index))
                    .fadeIn(duration: AppAnim.normal)
                    .slideY(begin: 0.12, curve: AppAnim.smooth);
              }),
              ],
              const SizedBox(height: 24),
            ],

            AppSectionTitle(l10n.supportTicketNew),
            const SizedBox(height: 6),
            Text(l10n.supportTicketQuestion,
                style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant)),
            const SizedBox(height: 20),

            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _category,
                    decoration: InputDecoration(
                      labelText: l10n.supportTicketCategoryLabel,
                      prefixIcon: const Icon(Icons.category_outlined),
                    ),
                    items: categories.entries
                        .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                        .toList(),
                    onChanged: (v) => setState(() => _category = v!),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _subjectCtrl,
                    decoration: InputDecoration(
                      labelText: l10n.supportTicketSubjectLabel,
                      prefixIcon: const Icon(Icons.title_outlined),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return l10n.supportTicketSubjectError;
                      if (v.length < 5) return l10n.supportTicketSubjectMinError;
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _messageCtrl,
                    maxLines: 5,
                    decoration: InputDecoration(
                      labelText: l10n.supportTicketMessageLabel,
                      alignLabelWithHint: true,
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(bottom: 64),
                        child: Icon(Icons.message_outlined),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return l10n.supportTicketMessageError;
                      if (v.length < 20) return l10n.supportTicketMessageMinError;
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: _priority,
                    decoration: InputDecoration(
                      labelText: l10n.supportTicketPriorityLabel,
                      prefixIcon: const Icon(Icons.flag_outlined),
                    ),
                    items: priorities.entries
                        .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                        .toList(),
                    onChanged: (v) => setState(() => _priority = v!),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: state.status == SupportTicketStatus.loading ? null : _submit,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: state.status == SupportTicketStatus.loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(l10n.supportTicketSubmitButton, style: const TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ).animate().fadeIn(duration: AppAnim.slow, curve: AppAnim.smooth),
          ],
        ),
      ),
    );
  }
}
