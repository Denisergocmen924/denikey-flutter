import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/vault_provider.dart';
import '../data/vault_repository.dart';
import '../../../core/network/dio_client.dart';

class VaultItemDetailScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> item;
  const VaultItemDetailScreen({super.key, required this.item});

  @override
  ConsumerState<VaultItemDetailScreen> createState() =>
      _VaultItemDetailScreenState();
}

class _VaultItemDetailScreenState extends ConsumerState<VaultItemDetailScreen> {
  String? _decryptedPassword;
  bool _decrypting = true;
  bool _showPassword = false;
  List<dynamic> _customFields = [];

  @override
  void initState() {
    super.initState();
    _loadItem();
  }

  Future<void> _loadItem() async {
    try {
      // Backend'den direkt çek
      final dio = DioClient.instance.dio;
      final itemId = widget.item['id'].toString();
      final response = await dio.get('/api/v1/vault/items/$itemId');
      final fullItem = Map<String, dynamic>.from(response.data);

      // Şifreyi çöz
      final decrypted = await VaultRepository().getItemDecrypted(fullItem);

      if (mounted) {
        setState(() {
          _decryptedPassword = decrypted['decrypted_password'] as String?;
          _customFields = fullItem['custom_fields'] as List<dynamic>? ?? [];
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
      SnackBar(content: Text('$label kopyalandı')),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sil'),
        content: const Text('Bu şifreyi silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal')),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(vaultProvider.notifier).deleteItem(widget.item['id'].toString());
              if (mounted) Navigator.pop(context);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(String label, String? value, {bool isSecret = false}) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: ListTile(
          title: Text(label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          subtitle: Text(
            isSecret && !_showPassword ? '••••••••' : value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isSecret)
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return Scaffold(
      appBar: AppBar(
        title: Text(item['title'] ?? 'Detay'),
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
                _infoTile('Şifre', _decryptedPassword, isSecret: true),
                if (_customFields.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8, left: 4),
                    child: Text('Ek Bilgiler',
                      style: TextStyle(fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600)),
                  ),
                  ..._customFields.map((field) {
                    final fieldName = field['field_name'] as String? ?? '';
                    final fieldValue = field['encrypted_value'] as String? ?? '';
                    return _infoTile(fieldName, fieldValue);
                  }),
                ],
              ],
            ),
    );
  }
}
