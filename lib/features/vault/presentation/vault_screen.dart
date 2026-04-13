import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/vault_provider.dart';
import '../../categories/providers/category_provider.dart';
import '../../../core/notifications/notification_service.dart';

class VaultScreen extends ConsumerStatefulWidget {
  const VaultScreen({super.key});

  @override
  ConsumerState<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends ConsumerState<VaultScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(vaultProvider.notifier).loadItems();
      ref.read(categoryProvider.notifier).loadCategories();
      NotificationService.instance.scheduleWeeklySecurityReminder();
    });
  }

  IconData _iconForType(String? type) {
    switch (type) {
      case 'login':    return Icons.lock_outline;
      case 'card':     return Icons.credit_card;
      case 'identity': return Icons.badge_outlined;
      case 'note':     return Icons.note_outlined;
      default:         return Icons.key_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(vaultProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('DeniKey'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Ara',
            onPressed: () => context.push('/search'),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Çöp Kutusu',
            onPressed: () => context.push('/trash'),
          ),
          IconButton(
            icon: const Icon(Icons.category_outlined),
            onPressed: () => context.push('/categories'),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(vaultProvider.notifier).loadItems(),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: Column(
        children: [
          if (state.isOffline)
            Container(
              width: double.infinity,
              color: Colors.orange.shade700,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: const Row(
                children: [
                  Icon(Icons.wifi_off, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text('Çevrimdışı mod — Salt okunur',
                    style: TextStyle(color: Colors.white, fontSize: 13)),
                ],
              ),
            ),
          Expanded(
            child: Builder(builder: (context) {
              if (state.status == VaultStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state.status == VaultStatus.error) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(state.errorMessage ?? 'Hata'),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => ref.read(vaultProvider.notifier).loadItems(),
                        child: const Text('Yeniden Dene'),
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
                      Icon(Icons.lock_open_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Henüz şifre yok',
                        style: TextStyle(fontSize: 16, color: Colors.grey)),
                      SizedBox(height: 8),
                      Text('+ ile yeni şifre ekleyin',
                        style: TextStyle(fontSize: 13, color: Colors.grey)),
                    ],
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: () => ref.read(vaultProvider.notifier).loadItems(),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = state.items[index];
                    return Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.deepPurple.shade50,
                          child: Icon(
                            _iconForType(item['item_type']),
                            color: Colors.deepPurple,
                            size: 20,
                          ),
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
                        onTap: () async {
                          await context.push('/vault/detail', extra: item);
                          ref.read(vaultProvider.notifier).loadItems();
                        },
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: state.isOffline ? () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('İnternet bağlantısı yok.'))) : () => context.push('/add-item').then((_) => ref.read(vaultProvider.notifier).loadItems()),
        backgroundColor: state.isOffline ? Colors.grey : Colors.deepPurple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
