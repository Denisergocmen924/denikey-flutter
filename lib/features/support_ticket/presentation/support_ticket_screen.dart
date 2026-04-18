import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/support_ticket_provider.dart';

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

  static const _categories = {
    'bug': 'Hata Bildirimi',
    'suggestion': 'Öneri',
    'other': 'Diğer',
  };

  static const _priorities = {
    'low': 'Düşük',
    'normal': 'Normal',
    'high': 'Yüksek',
  };

  static const _statusLabels = {
    'open': 'Açık',
    'in_progress': 'İşlemde',
    'closed': 'Kapalı',
  };

  static const _statusColors = {
    'open': Color(0xFF2563EB),
    'in_progress': Color(0xFFD97706),
    'closed': Color(0xFF16A34A),
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

  void _showTicketDetail(Map<String, dynamic> ticket) {
    final status = ticket['status'] as String? ?? 'open';
    final adminReply = ticket['admin_reply'] as String?;
    final statusColor = _statusColors[status] ?? Colors.grey;
    final statusLabel = _statusLabels[status] ?? status;
    final category = _categories[ticket['category']] ?? ticket['category'] ?? '';
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
                // Başlık satırı
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

                // Mesaj
                const Text('Mesajınız', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
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

                // Admin yanıtı
                if (adminReply != null && adminReply.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Icon(Icons.support_agent, size: 16, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 6),
                      Text(
                        'Destek Yanıtı',
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
                      const Text('Yanıt bekleniyor...', style: TextStyle(fontSize: 13, color: Colors.grey)),
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
    final state = ref.watch(supportTicketProvider);

    ref.listen(supportTicketProvider, (_, next) {
      if (next.status == SupportTicketStatus.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Destek talebiniz gönderildi')),
        );
        _subjectCtrl.clear();
        _messageCtrl.clear();
        setState(() { _category = 'bug'; _priority = 'normal'; });
        ref.read(supportTicketProvider.notifier).reset();
      }
      if (next.status == SupportTicketStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage ?? 'Hata oluştu')),
        );
        ref.read(supportTicketProvider.notifier).reset();
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Destek')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // --- Geçmiş talepler ---
            if (state.ticketsLoading)
              const Center(child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ))
            else if (state.tickets.isNotEmpty) ...[
              Row(
                children: [
                  const Text('Taleplerim', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                ],
              ),
              const SizedBox(height: 10),
              ...state.tickets.map((t) {
                final status = t['status'] as String? ?? 'open';
                final statusColor = _statusColors[status] ?? Colors.grey;
                final statusLabel = _statusLabels[status] ?? status;
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
                      hasReply ? 'Yanıtlandı' : 'Yanıt bekleniyor',
                      style: TextStyle(
                        fontSize: 12,
                        color: hasReply ? Theme.of(context).colorScheme.primary : Colors.grey,
                      ),
                    ),
                    trailing: Container(
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
                  ),
                );
              }),
              const Divider(height: 32),
            ],

            // --- Yeni talep formu ---
            const Text('Yeni Talep', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('Nasıl yardımcı olabiliriz?', style: TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 20),

            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _category,
                    decoration: const InputDecoration(
                      labelText: 'Kategori',
                      prefixIcon: Icon(Icons.category_outlined),
                      border: OutlineInputBorder(),
                    ),
                    items: _categories.entries
                        .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                        .toList(),
                    onChanged: (v) => setState(() => _category = v!),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _subjectCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Konu',
                      prefixIcon: Icon(Icons.title_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Konu gerekli';
                      if (v.length < 5) return 'En az 5 karakter';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _messageCtrl,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Mesajınız',
                      alignLabelWithHint: true,
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(bottom: 64),
                        child: Icon(Icons.message_outlined),
                      ),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Mesaj gerekli';
                      if (v.length < 20) return 'En az 20 karakter';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: _priority,
                    decoration: const InputDecoration(
                      labelText: 'Öncelik',
                      prefixIcon: Icon(Icons.flag_outlined),
                      border: OutlineInputBorder(),
                    ),
                    items: _priorities.entries
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
                        : const Text('Gönder', style: TextStyle(fontSize: 16)),
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
