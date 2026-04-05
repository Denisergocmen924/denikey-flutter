import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/vault_provider.dart';
import '../data/vault_repository.dart';

class VaultItemDetailScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> item;
  const VaultItemDetailScreen({super.key, required this.item});

  @override
  ConsumerState<VaultItemDetailScreen> createState() =>
      _VaultItemDetailScreenState();
}

class _VaultItemDetailScreenState extends ConsumerState<VaultItemDetailScreen> {
  bool _showPassword = false;
  String? _decryptedPassword;
  bool _decrypting = true;

  @override
  void initState() {
    super.initState();
    _decryptItem();
  }

  Future<void> _decryptItem() async {
    try {
      final decrypted = await VaultRepository().getItemDecrypted(widget.item);
      if (mounted) {
        setState(() {
          _decryptedPassword = decrypted['decrypted_password'] as String?;
          _decrypting = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _decrypting = false);
    }
  }

  void _copyToClipboard(String value, String label) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label copied')),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete'),
        content: const Text('Are you sure you want to delete this password?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref
                  .read(vaultProvider.notifier)
                  .deleteItem(widget.item['id'].toString());
              if (mounted) Navigator.pop(context);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(String label, String? value, {bool isPassword = false}) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        title: Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        subtitle: Text(
          isPassword && !_showPassword ? '••••••••' : value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isPassword)
              IconButton(
                icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _showPassword = !_showPassword),
              ),
            IconButton(
              icon: const Icon(Icons.copy, size: 20),
              onPressed: () => _copyToClipboard(value, label),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return Scaffold(
      appBar: AppBar(
        title: Text(item['title'] ?? 'Detail'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: _decrypting
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const SizedBox(height: 8),
                _infoTile('Username', item['username']),
                const SizedBox(height: 8),
                _infoTile('Password', _decryptedPassword, isPassword: true),
                const SizedBox(height: 8),
                _infoTile('URL', item['url']),
                const SizedBox(height: 8),
                _infoTile('Notes', item['notes']),
              ],
            ),
    );
  }
}
