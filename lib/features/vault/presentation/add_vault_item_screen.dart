import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/vault_provider.dart';
import '../../categories/providers/category_provider.dart';
import '../../item_types/providers/item_type_provider.dart';
import 'package:denikey_app/l10n/generated/app_localizations.dart';

// ─── Alan modeli ─────────────────────────────────────────────────────────────

class _FieldEntry {
  final int uid;
  final String? backendFieldId;
  final TextEditingController nameCtr;
  final TextEditingController valueCtr;
  bool isSecret;
  bool obscure;
  String? error;

  _FieldEntry({
    required this.uid,
    this.backendFieldId,
    String name = '',
    this.isSecret = false,
  })  : nameCtr = TextEditingController(text: name),
        valueCtr = TextEditingController(),
        obscure = false;

  void dispose() {
    nameCtr.dispose();
    valueCtr.dispose();
  }
}

// ─── Ana ekran ────────────────────────────────────────────────────────────────

class AddVaultItemScreen extends ConsumerStatefulWidget {
  const AddVaultItemScreen({super.key});

  @override
  ConsumerState<AddVaultItemScreen> createState() => _AddVaultItemScreenState();
}

class _AddVaultItemScreenState extends ConsumerState<AddVaultItemScreen> {
  int _step = 0; // 0 = kategori seç, 1 = form
  String? _selectedCategoryId;
  String? _selectedCategoryName;
  Map<String, dynamic>? _selectedItemType;

  final _titleCtrl = TextEditingController();
  String? _titleError;
  final List<_FieldEntry> _fields = [];
  int _uidCounter = 0;

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
    for (final f in _fields) {
      f.dispose();
    }
    super.dispose();
  }

  _FieldEntry _newEntry({String name = '', bool isSecret = false, String? backendFieldId}) {
    return _FieldEntry(uid: _uidCounter++, name: name, isSecret: isSecret, backendFieldId: backendFieldId);
  }

  void _selectType(Map<String, dynamic> type) {
    for (final f in _fields) {
      f.dispose();
    }
    _fields.clear();

    final typeFields = type['fields'] as List<dynamic>? ?? [];
    for (final f in typeFields) {
      _fields.add(_newEntry(
        name: f['field_name_tr'] as String? ?? '',
        isSecret: f['field_type'] == 'secret',
        backendFieldId: f['id'] as String?,
      ));
    }

    setState(() {
      _selectedItemType = type;
    });
  }

  void _deselectType() {
    for (final f in _fields) {
      f.dispose();
    }
    _fields.clear();
    setState(() => _selectedItemType = null);
  }

  void _addField() {
    setState(() => _fields.add(_newEntry()));
  }

  void _removeField(int uid) {
    final idx = _fields.indexWhere((f) => f.uid == uid);
    if (idx != -1) {
      _fields[idx].dispose();
      setState(() => _fields.removeAt(idx));
    }
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    bool hasError = false;

    if (_titleCtrl.text.trim().isEmpty) {
      setState(() => _titleError = l10n.detailEditErrorBlankTitle);
      hasError = true;
    }

    for (final field in _fields) {
      if (field.backendFieldId == null) {
        final name  = field.nameCtr.text.trim();
        final value = field.valueCtr.text.trim();
        if (value.isNotEmpty && name.isEmpty) {
          setState(() => field.error = l10n.addItemFieldNameRequired);
          hasError = true;
        }
      }
    }

    if (hasError) return;

    final customFieldsData = <Map<String, String>>[];
    for (final field in _fields) {
      final name = field.nameCtr.text.trim();
      final value = field.valueCtr.text.trim();
      if (name.isNotEmpty) {
        customFieldsData.add({
          'field_name': name,
          'value': value,
          'field_type': (field.isSecret || field.obscure) ? 'secret' : 'text',
        });
      }
    }

    final data = <String, dynamic>{
      'title': _titleCtrl.text.trim(),
      'password': '',
      if (_selectedCategoryId != null) 'category_id': _selectedCategoryId,
      if (_selectedItemType != null) 'item_type_id': _selectedItemType!['id'],
      if (_selectedItemType != null) 'icon': _selectedItemType!['icon'],
      if (_selectedItemType != null) 'color': _selectedItemType!['color'],
      if (customFieldsData.isNotEmpty) 'custom_fields_data': customFieldsData,
    };

    try {
      await ref.read(vaultProvider.notifier).createItem(data);
      if (mounted) context.pop();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.addItemErrorSave),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _goBack() {
    if (_step == 1) {
      setState(() => _step = 0);
    } else {
      context.pop();
    }
  }

  // ─── Kategori oluşturma sheet ─────────────────────────────────────────────

  void _showCreateCategorySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: const Color(0xFF0E1610),
      builder: (ctx) => _CreateCategorySheet(
        onCreated: (id, name) {
          setState(() {
            _selectedCategoryId = id;
            _selectedCategoryName = name;
            _step = 1;
          });
        },
        onCreate: (name) async {
          await ref.read(categoryProvider.notifier).createCategory(name, name, null, '#FF5900');
          final cats = ref.read(categoryProvider).categories;
          final newCat = cats.lastWhere(
            (c) => c['name_tr'] == name || c['name_en'] == name,
            orElse: () => <String, dynamic>{},
          );
          return (newCat['id'] as String?, name);
        },
      ),
    );
  }

  // ─── Tip oluşturma sheet ──────────────────────────────────────────────────

  void _showCreateTypeSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: const Color(0xFF0E1610),
      builder: (ctx) => _CreateTypeSheet(
        onCreate: (name, fields) async {
          await ref.read(itemTypeProvider.notifier).createItemType(
            name,
            'category',
            '#FF5900',
            fields: fields,
          );
          final types = ref.read(itemTypeProvider).itemTypes;
          final newType = types.lastWhere(
            (t) => t['name_tr'] == name,
            orElse: () => <String, dynamic>{},
          );
          if (newType.isNotEmpty) {
            _selectType(newType);
          }
        },
      ),
    );
  }

  // ─── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final titles = [l10n.addItemStep0, l10n.addItemStep2];
    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_step]),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _goBack,
        ),
      ),
      body: _step == 0 ? _buildCategorySelection() : _buildForm(),
    );
  }

  // ─── Adım 0: Kategori Seç ────────────────────────────────────────────────

  Widget _buildCategorySelection() {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(categoryProvider);
    final categories = state.categories;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _selectionTile(
          icon: Icons.inbox_outlined,
          color: Colors.grey,
          title: l10n.addItemUncategorized,
          subtitle: l10n.addItemUncategorizedSubtitle,
          onTap: () {
            final uncategorized = categories.firstWhere(
              (c) => c['is_system'] == true,
              orElse: () => <String, dynamic>{},
            );
            setState(() {
              _selectedCategoryId = uncategorized['id'] as String?;
              _selectedCategoryName = l10n.categoriesUncategorized;
              _step = 1;
            });
          },
        ),
        const SizedBox(height: 8),
        _selectionTile(
          icon: Icons.add_circle_outline,
          color: const Color(0xFFFF5900),
          title: l10n.addItemCreateCategory,
          subtitle: l10n.addItemCreateCategorySubtitle,
          onTap: _showCreateCategorySheet,
        ),
        const SizedBox(height: 16),
        if (state.status == CategoryStatus.loading)
          const Center(child: CircularProgressIndicator())
        else ...[
          Text(l10n.libraryCategoriesTab,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600)),
          const SizedBox(height: 8),
          ...categories.where((c) => c['is_system'] != true).map((cat) {
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

  // ─── Adım 1: Form + Sol Tip Paneli ───────────────────────────────────────

  Widget _buildForm() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTypePanel(),
        const VerticalDivider(width: 1, thickness: 1),
        Expanded(child: _buildFormArea()),
      ],
    );
  }

  Widget _buildTypePanel() {
    final state = ref.watch(itemTypeProvider);
    final types = state.itemTypes;

    return SizedBox(
      width: 80,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                ...types.map((type) {
                  final isSelected = _selectedItemType?['id'] == type['id'];
                  final color = isSelected
                      ? const Color(0xFFFF5900)
                      : const Color(0xFF9BABA4);
                  final icon = _materialIcon(type['icon'] as String?);
                  return GestureDetector(
                    onTap: () {
                      if (isSelected) {
                        _deselectType();
                      } else {
                        _selectType(type);
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: isSelected
                            ? const Color(0xFFFF5900).withAlpha(20)
                            : Colors.transparent,
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFFFF5900).withAlpha(100)
                              : Colors.transparent,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(icon, size: 22, color: color),
                          const SizedBox(height: 4),
                          Text(
                            (type['name_tr'] as String? ?? ''),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 9,
                              color: color,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: IconButton(
              onPressed: _showCreateTypeSheet,
              icon: const Icon(Icons.add_circle_outline,
                  color: Color(0xFFFF5900), size: 26),
              tooltip: 'Yeni Tip',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormArea() {
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Seçim özeti
          _buildSelectionSummary(),
          const SizedBox(height: 12),

          // Başlık
          TextField(
            controller: _titleCtrl,
            onChanged: (_) {
              if (_titleError != null) setState(() => _titleError = null);
            },
            decoration: InputDecoration(
              labelText: l10n.addItemTitleLabel,
              hintText: l10n.addItemTitleHint,
              errorText: _titleError,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),

          // Alanlar
          ..._fields.asMap().entries.map((e) => _buildFieldRow(e.value)),

          const SizedBox(height: 8),

          OutlinedButton.icon(
            onPressed: _addField,
            icon: const Icon(Icons.add),
            label: Text(l10n.addItemAddFieldButton),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFFF5900),
            ),
          ),
          const SizedBox(height: 24),

          FilledButton(
            onPressed: _save,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(l10n.addItemSaveButton,
                style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldRow(_FieldEntry entry) {
    final isTypeField = entry.backendFieldId != null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tip alanı değilse alan adı düzenlenebilir; tip alanıysa isim label olarak gösterilir
              if (!isTypeField) ...[
                SizedBox(
                  width: 110,
                  child: TextField(
                    controller: entry.nameCtr,
                    onChanged: (_) {
                      if (entry.error != null) setState(() => entry.error = null);
                    },
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context).addItemExtraFieldKeyLabel,
                      errorText: entry.error,
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                const SizedBox(width: 6),
              ],
              // Değer
              Expanded(
                child: TextField(
                  controller: entry.valueCtr,
                  obscureText: entry.obscure,
                  decoration: InputDecoration(
                    labelText: isTypeField
                        ? entry.nameCtr.text
                        : AppLocalizations.of(context).addItemExtraFieldValueLabel,
                    border: const OutlineInputBorder(),
                    isDense: true,
                    suffixIcon: IconButton(
                        iconSize: 18,
                        icon: Icon(entry.obscure
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () =>
                            setState(() => entry.obscure = !entry.obscure),
                      ),
                  ),
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              // Sil
              IconButton(
                icon: const Icon(Icons.remove_circle_outline,
                    color: Colors.red, size: 18),
                onPressed: () => _removeField(entry.uid),
              ),
            ],
          ),
          // Şifre güç göstergesi
          if (entry.isSecret)
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: entry.valueCtr,
              builder: (ctx2, v, child) =>
                  _PasswordStrengthIndicator(password: v.text),
            ),
        ],
      ),
    );
  }

  Widget _buildSelectionSummary() {
    if (_selectedCategoryName == null && _selectedItemType == null) {
      return const SizedBox.shrink();
    }
    final typeColor = _parseColor(_selectedItemType?['color'] as String?);
    final typeIcon = _materialIcon(_selectedItemType?['icon'] as String?);
    return Row(
      children: [
        if (_selectedCategoryName != null) ...[
          const Icon(Icons.folder_outlined,
              size: 13, color: Color(0xFFFF5900)),
          const SizedBox(width: 4),
          Text(_selectedCategoryName!,
              style: const TextStyle(
                  color: Color(0xFFFF5900), fontSize: 11)),
          const SizedBox(width: 10),
        ],
        if (_selectedItemType != null) ...[
          Icon(typeIcon, size: 13, color: typeColor),
          const SizedBox(width: 4),
          Text(
            _selectedItemType!['name_tr'] as String? ?? '',
            style: TextStyle(color: typeColor, fontSize: 11),
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
        title:
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: subtitle.isNotEmpty
            ? Text(subtitle, style: const TextStyle(fontSize: 12))
            : null,
        trailing:
            const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  Color _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return const Color(0xFFFF5900);
    try {
      return Color(
          int.parse('FF${hex.replaceAll('#', '')}', radix: 16));
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

// ─── Kategori oluşturma sheet ─────────────────────────────────────────────────

class _CreateCategorySheet extends StatefulWidget {
  final void Function(String? id, String name) onCreated;
  final Future<(String?, String)> Function(String name) onCreate;

  const _CreateCategorySheet(
      {required this.onCreated, required this.onCreate});

  @override
  State<_CreateCategorySheet> createState() => _CreateCategorySheetState();
}

class _CreateCategorySheetState extends State<_CreateCategorySheet> {
  final _nameCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) return;
    setState(() => _loading = true);
    final (id, name) = await widget.onCreate(_nameCtrl.text.trim());
    if (mounted) {
      Navigator.pop(context);
      widget.onCreated(id, name);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.create_new_folder_outlined,
                  color: Color(0xFFFF5900)),
              const SizedBox(width: 10),
              Text(
                AppLocalizations.of(context).addItemNewCategory,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _nameCtrl,
            autofocus: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _save(),
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).addItemNewCategoryName,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _loading ? null : _save,
            style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14)),
            child: _loading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : Text(AppLocalizations.of(context).addItemCategoryCreate),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ─── Tip oluşturma sheet ──────────────────────────────────────────────────────

class _CreateTypeSheet extends StatefulWidget {
  final Future<void> Function(
      String name, List<Map<String, dynamic>> fields) onCreate;

  const _CreateTypeSheet({required this.onCreate});

  @override
  State<_CreateTypeSheet> createState() => _CreateTypeSheetState();
}

class _CreateTypeSheetState extends State<_CreateTypeSheet> {
  final _nameCtrl = TextEditingController();
  final List<Map<String, TextEditingController>> _fieldRows = [];
  final List<bool> _fieldSecrets = [];
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    for (final r in _fieldRows) {
      r['name']!.dispose();
    }
    super.dispose();
  }

  void _addFieldRow() {
    setState(() {
      _fieldRows.add({'name': TextEditingController()});
      _fieldSecrets.add(false);
    });
  }

  void _removeFieldRow(int i) {
    _fieldRows[i]['name']!.dispose();
    setState(() {
      _fieldRows.removeAt(i);
      _fieldSecrets.removeAt(i);
    });
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) return;
    setState(() => _loading = true);
    final fields = _fieldRows.asMap().entries.map((e) {
      final name = e.value['name']!.text.trim();
      return {
        'field_name': name.isEmpty ? 'Alan ${e.key + 1}' : name,
        'field_type': _fieldSecrets[e.key] ? 'secret' : 'text',
        'is_required': false,
      };
    }).toList();

    await widget.onCreate(_nameCtrl.text.trim(), fields);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (ctx, scrollCtrl) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade600,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  const Icon(Icons.extension_outlined,
                      color: Color(0xFFFF5900)),
                  const SizedBox(width: 10),
                  Text(
                    l10n.addItemTypeCreateTitle,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                controller: scrollCtrl,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  TextField(
                    controller: _nameCtrl,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: l10n.addItemTypeNameLabel,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.addItemTypeFieldsLabel,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 8),
                  ..._fieldRows.asMap().entries.map((e) {
                    final i = e.key;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: e.value['name'],
                              decoration: InputDecoration(
                                labelText: '${l10n.addItemExtraFieldKeyLabel} ${i + 1}',
                                border: const OutlineInputBorder(),
                                isDense: true,
                              ),
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            tooltip: _fieldSecrets[i]
                                ? 'Gizli alan'
                                : 'Normal alan',
                            icon: Icon(
                              _fieldSecrets[i]
                                  ? Icons.lock_outline
                                  : Icons.lock_open_outlined,
                              size: 18,
                              color: _fieldSecrets[i]
                                  ? const Color(0xFFFF5900)
                                  : Colors.grey,
                            ),
                            onPressed: () => setState(
                                () => _fieldSecrets[i] = !_fieldSecrets[i]),
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline,
                                color: Colors.red, size: 18),
                            onPressed: () => _removeFieldRow(i),
                          ),
                        ],
                      ),
                    );
                  }),
                  OutlinedButton.icon(
                    onPressed: _addFieldRow,
                    icon: const Icon(Icons.add, size: 16),
                    label: Text(l10n.addItemAddFieldButton),
                    style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFFF5900)),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _loading ? null : _save,
                    style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: _loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(l10n.addItemSaveButton),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Şifre güç göstergesi ─────────────────────────────────────────────────────

class _PasswordStrengthIndicator extends StatelessWidget {
  final String password;
  const _PasswordStrengthIndicator({required this.password});

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
    final l10n = AppLocalizations.of(context);
    final labels = [
      l10n.addItemPasswordStrengthVeryWeak,
      l10n.addItemPasswordStrengthWeak,
      l10n.addItemPasswordStrengthMedium,
      l10n.addItemPasswordStrengthStrong,
      l10n.addItemPasswordStrengthVeryStrong,
    ];
    final color = _colors[level];
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(
              5,
              (i) => Expanded(
                child: Container(
                  height: 3,
                  margin: EdgeInsets.only(right: i < 4 ? 4 : 0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: i <= level ? color : color.withAlpha(40),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            labels[level],
            style: TextStyle(
                fontSize: 10, color: color, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
