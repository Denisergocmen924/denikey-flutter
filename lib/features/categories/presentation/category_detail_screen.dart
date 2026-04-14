import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../vault/providers/vault_provider.dart';

class CategoryDetailScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> category;
  const CategoryDetailScreen({super.key, required this.category});

  @override
  ConsumerState<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends ConsumerState<CategoryDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(vaultProvider.notifier).loadItems());
  }

  Color _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return const Color(0xFFFF5900);
    try {
      final h = hex.replaceAll('#', '');
      return Color(int.parse('FF$h', radix: 16));
    } catch (_) {
      return const Color(0xFFFF5900);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vaultState = ref.watch(vaultProvider);
    final categoryId = widget.category['id'] as String;
    final categoryName = widget.category['name_tr'] ?? widget.category['name_en'] ?? '';
    final color = _parseColor(widget.category['color'] as String?);

    // Bu kategoriye ait item'ları filtrele
    final items = vaultState.items.where((item) => item['category_id'] == categoryId).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName),
        backgroundColor: color,
        foregroundColor: Colors.white,
      ),
      body: vaultState.status == VaultStatus.loading
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_open_outlined, size: 64, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text(
                        'Bu kategoride henüz öğe yok',
                        style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: color.withAlpha(38),
                          child: Icon(Icons.lock_outline, color: color, size: 20),
                        ),
                        title: Text(
                          item['title'] ?? 'İsimsiz',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          item['username'] ?? item['url'] ?? '',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                        ),
                        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                        onTap: () => context.push('/vault/detail', extra: item),
                      ),
                    );
                  },
                ),
    );
  }
}
