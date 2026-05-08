import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/trash_provider.dart';
import 'package:denikey_app/l10n/generated/app_localizations.dart';

class TrashScreen extends ConsumerStatefulWidget {
  const TrashScreen({super.key});

  @override
  ConsumerState<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends ConsumerState<TrashScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(trashProvider.notifier).load());
  }

  Future<void> _confirmEmptyTrash() async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.trashEmptyTitle),
        content: Text(l10n.trashEmptyMessage),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.trashCancel)),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.trashEmptyButton),
          ),
        ],
      ),
    );
    if (ok == true) ref.read(trashProvider.notifier).emptyTrash();
  }

  Future<void> _confirmDelete(String trashId, String title) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.trashDeleteTitle),
        content: Text(l10n.trashDeleteMessage(title)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.trashCancel)),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.trashDeleteButton),
          ),
        ],
      ),
    );
    if (ok == true) ref.read(trashProvider.notifier).deletePermanently(trashId);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(trashProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.trashTitle),
        foregroundColor: Colors.white,
        actions: [
          if (state.items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: l10n.trashEmptyButton,
              onPressed: _confirmEmptyTrash,
            ),
        ],
      ),
      body: _buildBody(state, l10n),
    );
  }

  Widget _buildBody(TrashState state, AppLocalizations l10n) {
    if (state.status == TrashStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == TrashStatus.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(state.error ?? l10n.trashError),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => ref.read(trashProvider.notifier).load(),
              child: Text(l10n.trashRetry),
            ),
          ],
        ),
      );
    }

    if (state.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.delete_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(l10n.trashEmpty,
                style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 8),
            Text(l10n.trashEmptyHint,
                style: const TextStyle(fontSize: 13, color: Colors.grey)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(trashProvider.notifier).load(),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: state.items.length,
        separatorBuilder: (context, idx) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final entry = state.items[index];
          final trashId = entry['trash_id'] as String;
          final item = entry['item'] as Map<String, dynamic>;
          final title = item['title'] as String? ?? 'Başlıksız';
          final permanentDeleteAt = entry['permanent_delete_at'] as String?;

          return Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.red.shade50,
                child: const Icon(Icons.delete_outline,
                    color: Colors.red, size: 20),
              ),
              title: Text(title,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: permanentDeleteAt != null
                  ? Text(
                      l10n.trashDeleteFor(_formatDate(permanentDeleteAt)),
                      style: TextStyle(
                          fontSize: 12, color: Colors.orange.shade700),
                    )
                  : null,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.restore_outlined,
                        color: Colors.green),
                    tooltip: l10n.trashRestore,
                    onPressed: () =>
                        ref.read(trashProvider.notifier).restore(trashId),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_forever_outlined,
                        color: Colors.red),
                    tooltip: l10n.trashDeletePermanent,
                    onPressed: () => _confirmDelete(trashId, title),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate).toLocal();
      return '${dt.day}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
    } catch (_) {
      return '';
    }
  }
}
