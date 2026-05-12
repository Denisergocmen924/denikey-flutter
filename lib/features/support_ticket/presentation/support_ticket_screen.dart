import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/support_ticket_provider.dart';
import 'package:denikey_app/l10n/generated/app_localizations.dart';
import '../../../core/presentation/app_nav_bar.dart';

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

  static const _statusColors = {
    'open': Color(0xFF2563EB),
    'in_progress': Color(0xFFD97706),
    'closed': Color(0xFF16A34A),
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
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
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
    final statusColor = _statusColors[status] ?? Colors.grey;
    final statusLabel = _statusLabels(l10n)[status] ?? status;
    final category = _categoryLabels(l10n)[ticket['category']] ?? ticket['category'] ?? '';
    final repliedAt = ticket['replied_at'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        builder: (_, controller) => SingleChildScrollView(
          controller: controller,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        ticket['subject'] ?? '',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withAlpha(25),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: statusColor.withAlpha(80)),
                      ),
                      child: Text(
                        statusLabel,
                        style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(category, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                const Divider(height: 28),

                Text(l10n.supportTicketDetailMessage, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(ticket['message'] ?? '',
                      style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: Theme.of(context).colorScheme.onSurface)),
                ),

                if (adminReply != null && adminReply.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Icon(Icons.support_agent, size: 16, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 6),
                      Text(
                        l10n.supportTicketAdminReply,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary),
                      ),
                      if (repliedAt != null) ...[
                        const Spacer(),
                        Text(
                          _formatDate(repliedAt.toString()),
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer.withAlpha(80),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Theme.of(context).colorScheme.primary.withAlpha(60)),
                    ),
                    child: Text(
                      adminReply,
                      style: TextStyle(fontSize: 14, height: 1.5, color: Theme.of(context).colorScheme.onPrimaryContainer),
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Icon(Icons.schedule, size: 14, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(l10n.supportTicketWaitingReply, style: const TextStyle(fontSize: 13, color: Colors.grey)),
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
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, size: 16, color: Colors.red),
                    const SizedBox(width: 8),
                    Text(l10n.supportTicketLoadingError, style: const TextStyle(color: Colors.red, fontSize: 13)),
                    const Spacer(),
                    TextButton(
                      onPressed: () => ref.read(supportTicketProvider.notifier).loadTickets(),
                      child: Text(l10n.supportTicketLoadingRetry),
                    ),
                  ],
                ),
              )
            else if (state.tickets.isNotEmpty) ...[
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => setState(() => _ticketsExpanded = !_ticketsExpanded),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Text(l10n.supportTicketMyTickets, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withAlpha(25),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${state.tickets.length}',
                          style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        _ticketsExpanded ? Icons.expand_less : Icons.expand_more,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
              if (_ticketsExpanded) ...[
              const SizedBox(height: 10),
              ...state.tickets.map((t) {
                final status = t['status'] as String? ?? 'open';
                final statusColor = _statusColors[status] ?? Colors.grey;
                final statusLabel = statusLabels[status] ?? status;
                final hasReply = (t['admin_reply'] as String?)?.isNotEmpty == true;

                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: hasReply ? Theme.of(context).colorScheme.primary.withAlpha(80) : Colors.grey.shade200,
                    ),
                  ),
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    onTap: () => _showTicketDetail(t),
                    leading: CircleAvatar(
                      radius: 20,
                      backgroundColor: hasReply
                          ? Theme.of(context).colorScheme.primary.withAlpha(25)
                          : Colors.grey.shade100,
                      child: Icon(
                        hasReply ? Icons.mark_email_read_outlined : Icons.mail_outline,
                        size: 20,
                        color: hasReply ? Theme.of(context).colorScheme.primary : Colors.grey,
                      ),
                    ),
                    title: Text(
                      t['subject'] ?? '',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      hasReply ? l10n.supportTicketReplied : l10n.supportTicketWaitingReplyLong,
                      style: TextStyle(
                        fontSize: 12,
                        color: hasReply ? Theme.of(context).colorScheme.primary : Colors.grey,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: statusColor.withAlpha(20),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            statusLabel,
                            style: TextStyle(fontSize: 11, color: statusColor, fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20),
                          color: Colors.red.shade300,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => _showDeleteDialog(t),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 8),
              ],
              const Divider(height: 32),
            ],

            Text(l10n.supportTicketNew, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(l10n.supportTicketQuestion, style: const TextStyle(fontSize: 13, color: Colors.grey)),
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
                      border: const OutlineInputBorder(),
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
                      border: const OutlineInputBorder(),
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
                      border: const OutlineInputBorder(),
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
                      border: const OutlineInputBorder(),
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
            ),
          ],
        ),
      ),
    );
  }
}
