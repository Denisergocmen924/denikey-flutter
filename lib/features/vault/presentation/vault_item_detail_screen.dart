import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/vault_provider.dart';
import '../data/vault_repository.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/providers/clipboard_timeout_provider.dart';
import '../../categories/providers/category_provider.dart';
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
  final Map<int, bool> _showCustomField = {}; // her custom field için ayrı görünürlük
  List<dynamic> _customFields = [];
  Map<String, dynamic> _fullItem = {};

  // Edit modu
  bool _isEditing = false;
  bool _saving = false;
  String? _saveError;

  // Link açma onayı — "bir daha sorma" tercihi
  bool _linkNoAsk = false;

  final _titleCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _urlCtrl = TextEditingController();
  // custom fields — her biri {key: ctrl, value: ctrl}
  final List<Map<String, TextEditingController>> _editCustomFields = [];
  final List<String> _editFieldTypes = []; // _editCustomFields ile paralel, field_type saklar

  @override
  void initState() {
    super.initState();
    _loadItem();
    _loadLinkPref();
  }

  Future<void> _loadLinkPref() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) setState(() => _linkNoAsk = prefs.getBool('link_no_ask') ?? false);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _passwordCtrl.dispose();
    _urlCtrl.dispose();
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
    _urlCtrl.text = _fullItem['url'] as String? ?? '';

    // Mevcut custom field controller'larını temizle
    _disposeCustomFieldCtrls();
    _editCustomFields.clear();
    _editFieldTypes.clear();

    // Mevcut custom field'ları yükle
    for (final field in _customFields) {
      _editCustomFields.add({
        'key': TextEditingController(text: field['field_name'] as String? ?? ''),
        'value': TextEditingController(text: field['decrypted_value'] as String? ?? ''),
      });
      _editFieldTypes.add(field['field_type'] as String? ?? 'text');
    }
  }

  void _addEditCustomField() {
    setState(() {
      _editCustomFields.add({
        'key': TextEditingController(),
        'value': TextEditingController(),
      });
      _editFieldTypes.add('text');
    });
  }

  void _removeEditCustomField(int index) {
    setState(() {
      _editCustomFields[index]['key']!.dispose();
      _editCustomFields[index]['value']!.dispose();
      _editCustomFields.removeAt(index);
      if (index < _editFieldTypes.length) _editFieldTypes.removeAt(index);
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
        'url': _urlCtrl.text.trim(),
      };

      final customFieldsList = <Map<String, String>>[];
      for (int i = 0; i < _editCustomFields.length; i++) {
        final f = _editCustomFields[i];
        final k = f['key']!.text.trim();
        final v = f['value']!.text.trim();
        if (k.isNotEmpty) {
          final ft = i < _editFieldTypes.length ? _editFieldTypes[i] : 'text';
          customFieldsList.add({'field_name': k, 'value': v, 'field_type': ft});
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

  bool _isUrl(String value) =>
      value.startsWith('http://') || value.startsWith('https://');

  Future<void> _openLink(String url) async {
    if (_linkNoAsk) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      return;
    }

    if (!mounted) return;
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Dış Link'),
        content: Text(
          'DeniKey bu bağlantıyı açmak üzere:\n\n$url',
          style: const TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'cancel'),
            child: const Text('İzin Verme'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'once'),
            child: const Text('Bu Seferlik'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, 'noask'),
            child: const Text('Bir Daha Sorma'),
          ),
        ],
      ),
    );

    if (result == 'noask') {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('link_no_ask', true);
      if (mounted) setState(() => _linkNoAsk = true);
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else if (result == 'once') {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  void _copyToClipboard(String value, String label) {
    final timeout = ref.read(clipboardTimeoutProvider);
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          timeout != null
              ? '$label kopyalandı, $timeout saniye sonra silinecek'
              : '$label kopyalandı',
        ),
      ),
    );
    if (timeout != null) {
      Future.delayed(Duration(seconds: timeout), () {
        Clipboard.setData(const ClipboardData(text: ''));
      });
    }
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

  Future<void> _showCategoryPicker() async {
    final categoryState = ref.read(categoryProvider);
    if (categoryState.categories.isEmpty) {
      await ref.read(categoryProvider.notifier).loadCategories();
    }
    if (!mounted) return;

    final categories = ref.read(categoryProvider).categories;
    final currentCategoryId = _fullItem['category_id'] as String?;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Text('Klasöre Taşı', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            ListTile(
              leading: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey.shade200,
                child: const Icon(Icons.folder_off_outlined, size: 18, color: Colors.grey),
              ),
              title: const Text('Sınıflandırılmamış'),
              trailing: currentCategoryId == null ? const Icon(Icons.check, color: Color(0xFFFF5900)) : null,
              onTap: () async {
                Navigator.pop(ctx);
                await ref.read(vaultProvider.notifier).updateItem(
                  _fullItem['id'].toString(),
                  {'category_id': null},
                );
                setState(() => _fullItem['category_id'] = null);
              },
            ),
            ...categories.map((cat) {
              final catId = cat['id'] as String?;
              final name = cat['name_tr'] as String? ?? cat['name_en'] ?? '';
              final isSelected = catId == currentCategoryId;
              return ListTile(
                leading: CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFFFF5900).withAlpha(25),
                  child: const Icon(Icons.folder_outlined, size: 18, color: Color(0xFFFF5900)),
                ),
                title: Text(name),
                trailing: isSelected ? const Icon(Icons.check, color: Color(0xFFFF5900)) : null,
                onTap: () async {
                  Navigator.pop(ctx);
                  await ref.read(vaultProvider.notifier).updateItem(
                    _fullItem['id'].toString(),
                    {'category_id': catId},
                  );
                  setState(() => _fullItem['category_id'] = catId);
                },
              );
            }),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(String label, String? value, {
    bool isSecret = false,
    bool showSecret = false,
    VoidCallback? onToggleSecret,
  }) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: cs.outlineVariant),
        ),
        child: ListTile(
          title: Text(label,
            style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
          subtitle: Text(
            isSecret && !showSecret ? '••••••••' : value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: (!isSecret && _isUrl(value))
                  ? const Color(0xFF4FC3F7)
                  : cs.onSurface,
              decoration: (!isSecret && _isUrl(value))
                  ? TextDecoration.underline
                  : null,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isSecret)
                IconButton(
                  icon: Icon(showSecret ? Icons.visibility_off : Icons.visibility),
                  onPressed: onToggleSecret,
                ),
              if (!isSecret && _isUrl(value))
                IconButton(
                  icon: const Icon(Icons.open_in_new, size: 20),
                  tooltip: 'Linki Aç',
                  onPressed: () => _openLink(value),
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
        actions: _isEditing
            ? [
                TextButton(
                  onPressed: _saving ? null : _cancelEdit,
                  child: const Text('İptal', style: TextStyle(color: Colors.white)),
                ),
              ]
            : [
                IconButton(
                  icon: Icon(
                    _fullItem['is_favorite'] == true
                        ? Icons.star
                        : Icons.star_border,
                    color: _fullItem['is_favorite'] == true
                        ? Colors.amber.shade600
                        : null,
                  ),
                  tooltip: _fullItem['is_favorite'] == true
                      ? 'Favoriden çıkar'
                      : 'Favorilere ekle',
                  onPressed: _decrypting ? null : () {
                    final isFav = _fullItem['is_favorite'] == true;
                    setState(() => _fullItem['is_favorite'] = !isFav);
                    ref.read(vaultProvider.notifier).toggleFavorite(
                      _fullItem['id'].toString(),
                      !isFav,
                    );
                  },
                ),
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

    final categories = ref.watch(categoryProvider).categories;
    final currentCategoryId = _fullItem['category_id'] as String?;
    final currentCategory = currentCategoryId != null
        ? categories.firstWhere(
            (c) => c['id'] == currentCategoryId,
            orElse: () => <String, dynamic>{},
          )
        : null;
    final categoryName = currentCategory != null && currentCategory.isNotEmpty
        ? (currentCategory['name_tr'] as String? ?? currentCategory['name_en'] ?? '')
        : null;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 8),
        // Klasör satırı
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
            ),
            child: Builder(builder: (context) {
              final cs = Theme.of(context).colorScheme;
              return ListTile(
                leading: Icon(
                  Icons.folder_outlined,
                  color: categoryName != null ? const Color(0xFFFF5900) : cs.onSurfaceVariant,
                ),
                title: Text('Klasör', style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
                subtitle: Text(
                  categoryName ?? 'Sınıflandırılmamış',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: categoryName != null ? cs.onSurface : cs.onSurfaceVariant,
                  ),
                ),
                trailing: Icon(Icons.chevron_right, size: 20, color: cs.onSurfaceVariant),
                onTap: _showCategoryPicker,
              );
            }),
          ),
        ),
        _infoTile('Şifre', _decryptedPassword,
          isSecret: true,
          showSecret: _showPassword,
          onToggleSecret: () => setState(() => _showPassword = !_showPassword),
        ),
        if (_customFields.isNotEmpty) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 4),
            child: Text('Ek Bilgiler',
              style: TextStyle(fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ),
          ..._customFields.asMap().entries.map((entry) {
            final i = entry.key;
            final field = entry.value;
            final fieldName = field['field_name'] as String? ?? '';
            final fieldValue = field['decrypted_value'] as String? ?? '';
            final isSecret = field['field_type'] == 'secret';
            return _infoTile(fieldName, fieldValue,
              isSecret: isSecret,
              showSecret: _showCustomField[i] ?? false,
              onToggleSecret: () => setState(() =>
                _showCustomField[i] = !(_showCustomField[i] ?? false)),
            );
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

          // URL
          TextField(
            controller: _urlCtrl,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(
              labelText: 'Web Sitesi (URL)',
              hintText: 'Örn: https://instagram.com',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.link),
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
            final fieldType = i < _editFieldTypes.length ? _editFieldTypes[i] : 'text';
            final isFieldSecret = fieldType == 'secret';
            final showFieldValue = _showCustomField[i] ?? false;
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
                          obscureText: isFieldSecret && !showFieldValue,
                          decoration: InputDecoration(
                            labelText: 'İçerik',
                            border: const OutlineInputBorder(),
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Gizli/açık toggle (field_type değiştirir)
                                IconButton(
                                  tooltip: isFieldSecret ? 'Gizli alan' : 'Normal alan',
                                  icon: Icon(
                                    isFieldSecret ? Icons.lock_outline : Icons.lock_open_outlined,
                                    size: 20,
                                    color: isFieldSecret
                                        ? Theme.of(context).colorScheme.primary
                                        : null,
                                  ),
                                  onPressed: () => setState(() {
                                    if (i < _editFieldTypes.length) {
                                      _editFieldTypes[i] = isFieldSecret ? 'text' : 'secret';
                                    }
                                  }),
                                ),
                                // Değeri göster/gizle (sadece gizli alanlarda)
                                if (isFieldSecret)
                                  IconButton(
                                    icon: Icon(
                                      showFieldValue ? Icons.visibility_off : Icons.visibility,
                                      size: 20,
                                    ),
                                    onPressed: () => setState(() =>
                                      _showCustomField[i] = !showFieldValue),
                                  ),
                              ],
                            ),
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
            style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFFF5900)),
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
