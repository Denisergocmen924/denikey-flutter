import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/vault_provider.dart';
import '../../../core/storage/secure_storage.dart';

class VaultScreen extends ConsumerStatefulWidget {
  const VaultScreen({super.key});

  @override
  ConsumerState<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends ConsumerState<VaultScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(vaultProvider.notifier).loadItems());
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

  void _showAddDialog() {
    final titleCtrl    = TextEditingController();
    final usernameCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    final urlCtrl      = TextEditingController();
    bool obscure       = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('New Password'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: usernameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passwordCtrl,
                  obscureText: obscure,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setDialogState(() => obscure = !obscure),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: urlCtrl,
                  decoration: const InputDecoration(
                    labelText: 'URL (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (titleCtrl.text.isEmpty) return;
                ref.read(vaultProvider.notifier).createItem({
                  'title':    titleCtrl.text.trim(),
                  'username': usernameCtrl.text.trim(),
                  'password': passwordCtrl.text.trim(),
                  'url':      urlCtrl.text.trim(),
                  'item_type': 'login',
                });
                Navigator.pop(ctx);
              },
              style: FilledButton.styleFrom(backgroundColor: Colors.deepPurple),
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
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
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await SecureStorage.instance.clearAll();
              if (context.mounted) context.go('/login');
            },
          ),
          IconButton(
            icon: const Icon(Icons.category_outlined),
            onPressed: () => context.push('/categories'),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(vaultProvider.notifier).loadItems(),
          ),
        ],
      ),
      body: Builder(builder: (context) {
        if (state.status == VaultStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.status == VaultStatus.error) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(state.errorMessage ?? 'Error'),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => ref.read(vaultProvider.notifier).loadItems(),
                  child: const Text('Retry'),
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
                Text(
                  'No passwords yet',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Tap + to add a password',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
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
                    item['title'] ?? 'Untitled',
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
