import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/vault_provider.dart';
import '../data/vault_repository.dart';
import '../../../core/network/dio_client.dart';
import 'password_history_screen.dart';

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
  Map<String, dynamic> _fullItem = {};

  // Edit modu
  bool _isEditing = false;
  bool _saving = false;
  String? _saveError;

  final _titleCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  // custom fields — her biri {key: ctrl, value: ctrl}
  final List<Map<String, TextEditingController>> _editCustomFields = [];

  @override
  void initState() {
    super.initState();
    _loadItem();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _passwordCtrl.dispose();
    _disposeCustomFieldCtrls();
    super.dispose();
  }

  void _disposeCustomFieldCtrls() {
    for (final f in _editCustomFields) {
      f['key']!.dispose();
      f['value']!.dispose();
    }
  }

  Future<void> _loadItem() async {
    try {
      final dio = DioClient.instance.dio;
      final itemId = widget.item['id'].toString();
      final response = await dio.get('/api/v1/vault/items/$itemId');
      final fullItem = Map<String, dynamic>.from(response.data);

      final decrypted = await VaultRepository().getItemDecrypted(fullItem);

      if (mounted) {
        setState(() {
          _fullItem = fullItem;
          _decryptedPassword = decrypted['decrypted_password'] as String?;
          _customFields = decrypted['custom_fields'] as List<dynamic>? ?? [];
          _decrypting = false;
        });
        _fillControllers();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _decrypting = false;
          _saveError = 'Bilgiler yüklenemedi: ${e.toString()}';
        });
      }
    }
  }

  void _fillControllers() {
    _titleCtrl.text = _fullItem['title'] as String? ?? '';
    _passwordCtrl.text = _decryptedPassword ?? '';

    // Mevcut custom field controller'larını temizle
    _disposeCustomFieldCtrls();
    _editCustomFields.clear();

    // Mevcut custom field'ları yükle
    for (final field in _customFields) {
      _editCustomFields.add({
        'key': TextEditingController(text: field['field_name'] as String? ?? ''),
        'value': TextEditingController(text: field['decrypted_value'] as String? ?? ''),
      });
    }
  }

  void _addEditCustomField() {
    setState(() {
      _editCustomFields.add({
        'key': TextEditingController(),
        'value': TextEditingController(),
      });
    });
  }

  void _removeEditCustomField(int index) {
    setState(() {
      _editCustomFields[index]['key']!.dispose();
      _editCustomFields[index]['value']!.dispose();
      _editCustomFields.removeAt(index);
    });
  }

  void _cancelEdit() {
    _fillControllers();
    setState(() {
      _isEditing = false;
      _saveError = null;
      _showPassword = false;
    });
  }

  Future<void> _saveEdit() async {
    if (_titleCtrl.text.trim().isEmpty) {
      setState(() => _saveError = 'Başlık boş olamaz');
      return;
    }
    setState(() { _saving = true; _saveError = null; });

    try {
      final data = <String, dynamic>{
        'title': _titleCtrl.text.trim(),
        'password': _passwordCtrl.text.trim(),
      };

      final customFieldsList = <Map<String, String>>[];
      for (final f in _editCustomFields) {
        final k = f['key']!.text.trim();
        final v = f['value']!.text.trim();
        if (k.isNotEmpty) {
          customFieldsList.add({'field_name': k, 'value': v, 'field_type': 'text'});
        }
      }
      data['custom_fields_data'] = customFieldsList;

      await ref.read(vaultProvider.notifier).updateItem(
        _fullItem['id'].toString(),
        data,
      );

      await _loadItem();
      if (mounted) setState(() { _isEditing = false; _showPassword = false; });
    } catch (_) {
      if (mounted) setState(() => _saveError = 'Güncellenemedi, tekrar deneyin');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _copyToClipboard(String value, String label) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label kopyalandı, 30 saniye sonra silinecek')),
    );
    Future.delayed(const Duration(seconds: 30), () {
      Clipboard.setData(const ClipboardData(text: ''));
    });
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
    final title = _fullItem['title'] as String? ?? widget.item['title'] ?? 'Detay';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: _isEditing
            ? [
                TextButton(
                  onPressed: _saving ? null : _cancelEdit,
                  child: const Text('İptal', style: TextStyle(color: Colors.white)),
                ),
              ]
            : [
                IconButton(
                  icon: const Icon(Icons.history_outlined),
                  tooltip: 'Şifre Geçmişi',
                  onPressed: _decrypting ? null : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PasswordHistoryScreen(
                          itemId: _fullItem['id'].toString(),
                          itemTitle: _fullItem['title'] as String? ?? '',
                        ),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Düzenle',
                  onPressed: _decrypting ? null : () => setState(() => _isEditing = true),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: _confirmDelete,
                ),
              ],
      ),
      body: _decrypting
          ? const Center(child: CircularProgressIndicator())
          : _isEditing
              ? _buildEditForm()
              : _buildViewMode(),
    );
  }

  Widget _buildViewMode() {
    if (_saveError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(_saveError!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  setState(() => _saveError = null);
                  _loadItem();
                },
                child: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
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
            final fieldValue = field['decrypted_value'] as String? ?? '';
            return _infoTile(fieldName, fieldValue);
          }),
        ],
      ],
    );
  }

  Widget _buildEditForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),

          // Başlık
          TextField(
            controller: _titleCtrl,
            decoration: const InputDecoration(
              labelText: 'Başlık',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),

          // Şifre
          TextField(
            controller: _passwordCtrl,
            obscureText: !_showPassword,
            decoration: InputDecoration(
              labelText: 'Şifre',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _showPassword = !_showPassword),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Mevcut + yeni custom fields
          ..._editCustomFields.asMap().entries.map((entry) {
            final i = entry.key;
            final f = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        TextField(
                          controller: f['key'],
                          decoration: const InputDecoration(
                            labelText: 'Başlık',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: f['value'],
                          decoration: const InputDecoration(
                            labelText: 'İçerik',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                    onPressed: () => _removeEditCustomField(i),
                  ),
                ],
              ),
            );
          }),

          // Alan ekle butonu
          OutlinedButton.icon(
            onPressed: _addEditCustomField,
            icon: const Icon(Icons.add),
            label: const Text('Alan Ekle'),
            style: OutlinedButton.styleFrom(foregroundColor: Colors.deepPurple),
          ),
          const SizedBox(height: 24),

          if (_saveError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(_saveError!,
                style: const TextStyle(color: Colors.red, fontSize: 13)),
            ),

          // Kaydet
          FilledButton(
            onPressed: _saving ? null : _saveEdit,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _saving
                ? const SizedBox(height: 20, width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Kaydet', style: TextStyle(fontSize: 16)),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
