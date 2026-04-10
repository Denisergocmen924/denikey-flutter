import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/trash_provider.dart';

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
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Çöp Kutusunu Boşalt'),
        content: const Text(
            'Tüm öğeler kalıcı olarak silinecek. Bu işlem geri alınamaz.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('İptal')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Boşalt'),
          ),
        ],
      ),
    );
    if (ok == true) ref.read(trashProvider.notifier).emptyTrash();
  }

  Future<void> _confirmDelete(String trashId, String title) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Kalıcı Sil'),
        content: Text('"$title" kalıcı olarak silinsin mi?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('İptal')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
    if (ok == true) ref.read(trashProvider.notifier).deletePermanently(trashId);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(trashProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Çöp Kutusu'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          if (state.items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Tümünü Sil',
              onPressed: _confirmEmptyTrash,
            ),
        ],
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(TrashState state) {
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
            Text(state.error ?? 'Hata'),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => ref.read(trashProvider.notifier).load(),
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      );
    }

    if (state.items.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Çöp kutusu boş',
                style: TextStyle(fontSize: 16, color: Colors.grey)),
            SizedBox(height: 8),
            Text('Silinen öğeler 7 gün burada saklanır',
                style: TextStyle(fontSize: 13, color: Colors.grey)),
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
                      _formatDeleteDate(permanentDeleteAt),
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
                    tooltip: 'Geri Yükle',
                    onPressed: () =>
                        ref.read(trashProvider.notifier).restore(trashId),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_forever_outlined,
                        color: Colors.red),
                    tooltip: 'Kalıcı Sil',
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

  String _formatDeleteDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate).toLocal();
      return '${dt.day}.${dt.month.toString().padLeft(2, '0')}.${dt.year} tarihinde kalıcı silinecek';
    } catch (_) {
      return 'Yakında kalıcı silinecek';
    }
  }
}
