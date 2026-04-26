import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/vault_provider.dart';
import '../../categories/providers/category_provider.dart';
import '../../item_types/providers/item_type_provider.dart';

class AddVaultItemScreen extends ConsumerStatefulWidget {
  const AddVaultItemScreen({super.key});

  @override
  ConsumerState<AddVaultItemScreen> createState() => _AddVaultItemScreenState();
}

class _AddVaultItemScreenState extends ConsumerState<AddVaultItemScreen> {
  // Adımlar: 0 = kategori seç, 1 = tip seç, 2 = form
  int _step = 0;

  // Seçimler
  String? _selectedCategoryId;
  String? _selectedCategoryName;
  Map<String, dynamic>? _selectedItemType;

  // Dinamik form controller'ları — field id → TextEditingController
  final Map<String, TextEditingController> _fieldControllers = {};
  final Map<String, bool> _obscureFields = {};

  // Başlık alanı (her tip için ortak)
  final _titleCtrl = TextEditingController();
  final _urlCtrl = TextEditingController();

  // Form hata mesajları
  String? _titleError;
  final Map<String, String?> _fieldErrors = {};

  // Ek özel alanlar
  final List<Map<String, TextEditingController>> _extraFields = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(categoryProvider.notifier).loadCategories();
      ref.read(itemTypeProvider.notifier).loadItemTypes();
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _urlCtrl.dispose();
    for (final ctrl in _fieldControllers.values) {
      ctrl.dispose();
    }
    for (final f in _extraFields) {
      f['key']!.dispose();
      f['value']!.dispose();
    }
    super.dispose();
  }

  // Item type seçildiğinde controller'ları hazırla
  void _selectItemType(Map<String, dynamic> itemType) {
    // Önceki controller'ları temizle
    for (final ctrl in _fieldControllers.values) {
      ctrl.dispose();
    }
    _fieldControllers.clear();
    _obscureFields.clear();

    final fields = itemType['fields'] as List<dynamic>? ?? [];
    for (final field in fields) {
      final id = field['id'] as String;
      _fieldControllers[id] = TextEditingController();
      if (field['field_type'] == 'secret') {
        _obscureFields[id] = true;
      }
    }

    setState(() {
      _selectedItemType = itemType;
      _fieldErrors.clear();
      _step = 2;
    });
  }

  void _addExtraField() {
    setState(() {
      _extraFields.add({
        'key': TextEditingController(),
        'value': TextEditingController(),
      });
    });
  }

  Future<void> _save() async {
    bool hasError = false;

    if (_titleCtrl.text.trim().isEmpty) {
      setState(() => _titleError = 'Başlık boş bırakılamaz');
      hasError = true;
    }

    final fields = (_selectedItemType?['fields'] as List<dynamic>? ?? []);

    for (final field in fields) {
      final id = field['id'] as String;
      final isRequired = field['is_required'] as bool? ?? false;
      if (isRequired && (_fieldControllers[id]?.text.trim().isEmpty ?? true)) {
        final label = field['field_name_tr'] as String? ?? 'Alan';
        setState(() => _fieldErrors[id] = '$label boş bırakılamaz');
        hasError = true;
      }
    }

    if (hasError) return;

    // İlk secret alanı → password
    String password = '';
    String? firstSecretId;
    for (final field in fields) {
      if (field['field_type'] == 'secret') {
        firstSecretId = field['id'] as String;
        password = _fieldControllers[firstSecretId]?.text.trim() ?? '';
        break;
      }
    }

    // Diğer alanlar → custom_fields_data
    final customFieldsData = <Map<String, String>>[];
    for (final field in fields) {
      final id = field['id'] as String;
      if (id == firstSecretId) continue; // zaten password olarak kullanıldı
      final value = _fieldControllers[id]?.text.trim() ?? '';
      if (value.isNotEmpty) {
        customFieldsData.add({
          'field_name': field['field_name_tr'] as String,
          'value': value,
          'field_type': field['field_type'] as String,
        });
      }
    }

    // Ek özel alanlar
    for (final f in _extraFields) {
      final k = f['key']!.text.trim();
      final v = f['value']!.text.trim();
      if (k.isNotEmpty) {
        customFieldsData.add({'field_name': k, 'value': v, 'field_type': 'text'});
      }
    }

    final data = <String, dynamic>{
      'title': _titleCtrl.text.trim(),
      'password': password,
      if (_selectedCategoryId != null) 'category_id': _selectedCategoryId,
      if (_selectedItemType != null) 'item_type_id': _selectedItemType!['id'],
      if (_selectedItemType != null) 'icon': _selectedItemType!['icon'],
      if (_selectedItemType != null) 'color': _selectedItemType!['color'],
      if (customFieldsData.isNotEmpty) 'custom_fields_data': customFieldsData,
      if (_urlCtrl.text.trim().isNotEmpty) 'url': _urlCtrl.text.trim(),
    };

    try {
      await ref.read(vaultProvider.notifier).createItem(data);
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 8),
          ),
        );
      }
    }
  }

  void _goBack() {
    if (_step == 2) {
      setState(() => _step = 1);
    } else if (_step == 1) {
      setState(() => _step = 0);
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final titles = ['Kategori Seç', 'Tür Seç', 'Bilgileri Gir'];
    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_step]),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _goBack,
        ),
      ),
      body: [
        _buildCategorySelection(),
        _buildItemTypeSelection(),
        _buildForm(),
      ][_step],
    );
  }

  // ─── Adım 0: Kategori Seç ───────────────────────────────────────────────

  Widget _buildCategorySelection() {
    final state = ref.watch(categoryProvider);
    final categories = state.categories;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _selectionTile(
          icon: Icons.inbox_outlined,
          color: Colors.grey,
          title: 'Kategorisiz',
          subtitle: 'Kategorisizler altında sakla',
          onTap: () {
            final uncategorized = categories.firstWhere(
              (c) => c['name_en'] == 'Uncategorized',
              orElse: () => <String, dynamic>{},
            );
            setState(() {
              _selectedCategoryId = uncategorized['id'] as String?;
              _selectedCategoryName = 'Kategorisizler';
              _step = 1;
            });
          },
        ),
        const SizedBox(height: 8),
        _selectionTile(
          icon: Icons.add_circle_outline,
          color: const Color(0xFFFF5900),
          title: 'Kategori Oluştur',
          subtitle: 'Yeni kategori ekle',
          onTap: _showCreateCategoryDialog,
        ),
        const SizedBox(height: 16),
        if (state.status == CategoryStatus.loading)
          const Center(child: CircularProgressIndicator())
        else ...[
          Text('Kategoriler',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600)),
          const SizedBox(height: 8),
          ...categories.where((c) => c['name_en'] != 'Uncategorized').map((cat) {
            final color = _parseColor(cat['color']);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _selectionTile(
                icon: Icons.folder_outlined,
                color: color,
                title: cat['name_tr'] ?? cat['name_en'] ?? '',
                subtitle: '',
                onTap: () => setState(() {
                  _selectedCategoryId = cat['id'] as String?;
                  _selectedCategoryName = cat['name_tr'] ?? cat['name_en'];
                  _step = 1;
                }),
              ),
            );
          }),
        ],
      ],
    );
  }

  void _showCreateCategoryDialog() {
    final nameCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Yeni Kategori'),
        content: TextField(
          controller: nameCtrl,
          decoration: const InputDecoration(
            labelText: 'Kategori Adı',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal')),
          FilledButton(
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty) return;
              await ref.read(categoryProvider.notifier).createCategory(
                    nameCtrl.text.trim(),
                    nameCtrl.text.trim(),
                    null,
                    '#FF5900',
                  );
              final cats = ref.read(categoryProvider).categories;
              final newCat = cats.lastWhere(
                (c) => c['name_en'] == nameCtrl.text.trim(),
                orElse: () => <String, dynamic>{},
              );
              final catId = newCat['id'] as String?;
              final catName = nameCtrl.text.trim();
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                setState(() {
                  _selectedCategoryId = catId;
                  _selectedCategoryName = catName;
                  _step = 1;
                });
              }
            },
            child: const Text('Oluştur'),
          ),
        ],
      ),
    );
  }

  // ─── Adım 1: Öğe Tipi Seç ────────────────────────────────────────────────

  Widget _buildItemTypeSelection() {
    final state = ref.watch(itemTypeProvider);

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(child: Text('Hata: ${state.error}'));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Tür Seçin',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600)),
        const SizedBox(height: 8),
        ...state.itemTypes.map((type) {
          final color = _parseColor(type['color'] as String?);
          final icon = _materialIcon(type['icon'] as String?);
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _selectionTile(
              icon: icon,
              color: color,
              title: type['name_tr'] as String? ?? type['name_en'] as String? ?? '',
              subtitle: _fieldsSummary(type),
              onTap: () => _selectItemType(type),
            ),
          );
        }),
      ],
    );
  }

  String _fieldsSummary(Map<String, dynamic> type) {
    final fields = type['fields'] as List<dynamic>? ?? [];
    if (fields.isEmpty) return '';
    final names = fields
        .take(3)
        .map((f) => f['field_name_tr'] as String? ?? '')
        .where((n) => n.isNotEmpty)
        .join(', ');
    return fields.length > 3 ? '$names...' : names;
  }

  // ─── Adım 2: Dinamik Form ─────────────────────────────────────────────────

  Widget _buildForm() {
    final fields = (_selectedItemType?['fields'] as List<dynamic>? ?? [])
      ..sort((a, b) => (a['sort_order'] as int).compareTo(b['sort_order'] as int));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Seçim özeti
          _selectionSummaryRow(),
          const SizedBox(height: 16),

          // Başlık
          TextField(
            controller: _titleCtrl,
            onChanged: (_) {
              if (_titleError != null) setState(() => _titleError = null);
            },
            decoration: InputDecoration(
              labelText: 'Başlık *',
              hintText: 'Örn: Instagram, Gmail, Netflix',
              errorText: _titleError,
              border: const OutlineInputBorder(),
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

          // Item type alanları
          ...fields.map((field) => _buildDynamicField(field)),

          const SizedBox(height: 8),

          // Ek özel alanlar
          ..._extraFields.asMap().entries.map((entry) {
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
                            labelText: 'Alan Adı',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: f['value'],
                          decoration: const InputDecoration(
                            labelText: 'Değer',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                    onPressed: () => setState(() => _extraFields.removeAt(i)),
                  ),
                ],
              ),
            );
          }),

          OutlinedButton.icon(
            onPressed: _addExtraField,
            icon: const Icon(Icons.add),
            label: const Text('Alan Ekle'),
            style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFFF5900)),
          ),
          const SizedBox(height: 24),

          FilledButton(
            onPressed: _save,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Kaydet', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicField(Map<String, dynamic> field) {
    final id = field['id'] as String;
    final label = field['field_name_tr'] as String? ?? '';
    final fieldType = field['field_type'] as String? ?? 'text';
    final isRequired = field['is_required'] as bool? ?? false;
    final isSecret = fieldType == 'secret';
    final ctrl = _fieldControllers[id];
    if (ctrl == null) return const SizedBox.shrink();

    final textField = TextField(
      controller: ctrl,
      obscureText: isSecret ? (_obscureFields[id] ?? true) : false,
      keyboardType: fieldType == 'number' ? TextInputType.number : TextInputType.text,
      onChanged: (_) {
        if (_fieldErrors[id] != null) setState(() => _fieldErrors[id] = null);
      },
      decoration: InputDecoration(
        labelText: isRequired ? '$label *' : label,
        errorText: _fieldErrors[id],
        border: const OutlineInputBorder(),
        suffixIcon: isSecret
            ? IconButton(
                icon: Icon(
                  (_obscureFields[id] ?? true)
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed: () => setState(
                  () => _obscureFields[id] = !(_obscureFields[id] ?? true),
                ),
              )
            : null,
      ),
    );

    if (!isSecret) {
      return Padding(
          padding: const EdgeInsets.only(bottom: 12), child: textField);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          textField,
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: ctrl,
            builder: (_, value, __) =>
                _PasswordStrengthIndicator(password: value.text),
          ),
        ],
      ),
    );
  }

  Widget _selectionSummaryRow() {
    final typeColor = _parseColor(_selectedItemType?['color'] as String?);
    final typeIcon = _materialIcon(_selectedItemType?['icon'] as String?);
    return Row(
      children: [
        if (_selectedCategoryName != null) ...[
          const Icon(Icons.folder_outlined, size: 14, color: Color(0xFFFF5900)),
          const SizedBox(width: 4),
          Text(_selectedCategoryName!,
              style: const TextStyle(color: Color(0xFFFF5900), fontSize: 12)),
          const SizedBox(width: 12),
        ],
        if (_selectedItemType != null) ...[
          Icon(typeIcon, size: 14, color: typeColor),
          const SizedBox(width: 4),
          Text(
            _selectedItemType!['name_tr'] as String? ?? '',
            style: TextStyle(color: typeColor, fontSize: 12),
          ),
        ],
      ],
    );
  }

  // ─── Yardımcılar ─────────────────────────────────────────────────────────

  Widget _selectionTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withAlpha(30),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: subtitle.isNotEmpty
            ? Text(subtitle, style: const TextStyle(fontSize: 12))
            : null,
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  Color _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return const Color(0xFFFF5900);
    try {
      return Color(int.parse('FF${hex.replaceAll('#', '')}', radix: 16));
    } catch (_) {
      return const Color(0xFFFF5900);
    }
  }

  IconData _materialIcon(String? name) {
    switch (name) {
      case 'lock':
        return Icons.lock_outline;
      case 'credit_card':
        return Icons.credit_card;
      case 'badge':
        return Icons.badge_outlined;
      case 'note':
        return Icons.note_outlined;
      case 'wifi':
        return Icons.wifi;
      case 'account_balance':
        return Icons.account_balance_outlined;
      case 'subscriptions':
        return Icons.subscriptions_outlined;
      default:
        return Icons.category_outlined;
    }
  }
}

class _PasswordStrengthIndicator extends StatelessWidget {
  final String password;
  const _PasswordStrengthIndicator({required this.password});

  static const _labels = ['Çok Zayıf', 'Zayıf', 'Orta', 'Güçlü', 'Çok Güçlü'];
  static const _colors = [
    Color(0xFFE53935),
    Color(0xFFFF7043),
    Color(0xFFFFB300),
    Color(0xFF7CB342),
    Color(0xFF43A047),
  ];

  int _level() {
    if (password.isEmpty) return -1;
    int score = 0;
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;
    if (password.length >= 16) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[a-z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(password)) score++;
    if (score <= 1) return 0;
    if (score <= 3) return 1;
    if (score == 4) return 2;
    if (score == 5) return 3;
    return 4;
  }

  @override
  Widget build(BuildContext context) {
    final level = _level();
    if (level < 0) return const SizedBox.shrink();
    final color = _colors[level];
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(5, (i) => Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsets.only(right: i < 4 ? 4 : 0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: i <= level ? color : color.withAlpha(40),
                ),
              ),
            )),
          ),
          const SizedBox(height: 4),
          Text(
            _labels[level],
            style: TextStyle(
                fontSize: 11, color: color, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
