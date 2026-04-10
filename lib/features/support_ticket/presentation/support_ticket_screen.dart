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
  final _formKey     = GlobalKey<FormState>();

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
        setState(() {
          _category = 'bug';
          _priority = 'normal';
        });
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
      appBar: AppBar(title: const Text('Destek Talebi')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.support_agent_outlined, size: 48, color: Colors.deepPurple),
              const SizedBox(height: 8),
              const Text(
                'Nasıl yardımcı olabiliriz?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 32),

              // Kategori seçimi
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
              const SizedBox(height: 16),

              // Konu
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
              const SizedBox(height: 16),

              // Mesaj
              TextFormField(
                controller: _messageCtrl,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'Mesajınız',
                  alignLabelWithHint: true,
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 80),
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
              const SizedBox(height: 16),

              // Öncelik seçimi
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
              const SizedBox(height: 32),

              FilledButton(
                onPressed: state.status == SupportTicketStatus.loading ? null : _submit,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.deepPurple,
                ),
                child: state.status == SupportTicketStatus.loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Gönder', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
