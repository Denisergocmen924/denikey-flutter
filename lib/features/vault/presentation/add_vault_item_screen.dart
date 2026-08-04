import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../providers/vault_provider.dart';
import '../../categories/providers/category_provider.dart';
import '../../item_types/providers/item_type_provider.dart';
import 'package:denikey_app/l10n/generated/app_localizations.dart';
import '../../../core/presentation/app_animations.dart';
import '../../../core/presentation/app_tiles.dart';

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
            backgroundColor: Theme.of(context).colorScheme.error,
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
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
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
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
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

    final cs = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      children: [
        _selectionTile(
          icon: Icons.inbox_outlined,
          color: kTeal,
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
        )
            .animate()
            .fadeIn(duration: AppAnim.normal)
            .slideY(begin: 0.12, curve: AppAnim.smooth),
        const SizedBox(height: 10),
        _selectionTile(
          icon: Icons.add_circle_outline,
          color: kBlaze,
          title: l10n.addItemCreateCategory,
          subtitle: l10n.addItemCreateCategorySubtitle,
          onTap: _showCreateCategorySheet,
        )
            .animate(delay: AppAnim.listDelay(1))
            .fadeIn(duration: AppAnim.normal)
            .slideY(begin: 0.12, curve: AppAnim.smooth),
        const SizedBox(height: 22),
        if (state.status == CategoryStatus.loading)
          const Center(child: CircularProgressIndicator())
        else ...[
          AppSectionTitle(l10n.libraryCategoriesTab),
          const SizedBox(height: 10),
          ...categories
              .where((c) => c['is_system'] != true)
              .toList()
              .asMap()
              .entries
              .map((entry) {
            final cat = entry.value;
            final color = _parseColor(cat['color']);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
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
            )
                .animate(delay: AppAnim.listDelay(entry.key + 2))
                .fadeIn(duration: AppAnim.normal)
                .slideY(begin: 0.12, curve: AppAnim.smooth);
          }),
          if (categories.where((c) => c['is_system'] != true).isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                l10n.addItemCreateCategorySubtitle,
                style: TextStyle(fontSize: 12.5, color: cs.onSurfaceVariant),
              ),
            ),
        ],
      ],
    );
  }

  // ─── Adım 1: Form + Sol Tip Paneli ───────────────────────────────────────

  Widget _buildForm() {
    final cs = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTypePanel(),
        VerticalDivider(width: 1, thickness: 1, color: cs.outlineVariant),
        Expanded(child: _buildFormArea()),
      ],
    );
  }

  Widget _buildTypePanel() {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final state = ref.watch(itemTypeProvider);
    final types = state.itemTypes;

    return SizedBox(
      width: 84,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 10),
              children: [
                ...types.asMap().entries.map((entry) {
                  final type = entry.value;
                  final isSelected = _selectedItemType?['id'] == type['id'];
                  final color = isSelected ? kBlaze : cs.onSurfaceVariant;
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
                      duration: AppAnim.fast,
                      curve: AppAnim.smooth,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 4),
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(13),
                        gradient: isSelected
                            ? LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  kBlaze.withAlpha(45),
                                  kBlaze.withAlpha(16),
                                ],
                              )
                            : null,
                        color: isSelected ? null : cs.surfaceContainer,
                        border: Border.all(
                          color: isSelected
                              ? kBlaze.withAlpha(110)
                              : cs.outlineVariant,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(icon, size: 22, color: color),
                          const SizedBox(height: 5),
                          Text(
                            (type['name_tr'] as String? ?? ''),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 9.5,
                              color: color,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                      .animate(delay: AppAnim.listDelay(entry.key))
                      .fadeIn(duration: AppAnim.normal)
                      .slideX(begin: -0.15, curve: AppAnim.smooth);
                }),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: IconButton(
              onPressed: _showCreateTypeSheet,
              icon: const Icon(Icons.add_circle_outline,
                  color: kBlaze, size: 26),
              tooltip: l10n.addItemTypeCreateTitle,
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
          const SizedBox(height: 14),

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
              prefixIcon: const Icon(Icons.title_outlined),
            ),
          ).animate().fadeIn(duration: AppAnim.normal).slideY(
              begin: 0.1, curve: AppAnim.smooth),
          const SizedBox(height: 18),

          // Alanlar
          if (_fields.isNotEmpty) ...[
            AppSectionTitle(l10n.addItemTypeFieldsLabel),
            const SizedBox(height: 10),
          ],
          ..._fields.asMap().entries.map(
                (e) => _buildFieldRow(e.value)
                    .animate(delay: AppAnim.listDelay(e.key))
                    .fadeIn(duration: AppAnim.normal)
                    .slideY(begin: 0.1, curve: AppAnim.smooth),
              ),

          const SizedBox(height: 4),

          OutlinedButton.icon(
            onPressed: _addField,
            icon: const Icon(Icons.add),
            label: Text(l10n.addItemAddFieldButton),
            style: OutlinedButton.styleFrom(foregroundColor: kBlaze),
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

  Widget _buildDeleteButton(_FieldEntry entry, ColorScheme cs) => IconButton(
        icon: Icon(Icons.remove_circle_outline, color: cs.error, size: 18),
        onPressed: () => _removeField(entry.uid),
      );

  Widget _buildValueField(_FieldEntry entry, bool isTypeField) {
    // Gizlenen metin Flutter'da tek satır olmak zorunda; açık metin yazdıkça
    // 5 satıra kadar büyür, böylece uzun içerik telefonda da tümüyle görünür
    final multiline = !entry.obscure;
    return TextField(
      controller: entry.valueCtr,
      obscureText: entry.obscure,
      minLines: 1,
      maxLines: multiline ? 5 : 1,
      keyboardType: multiline ? TextInputType.multiline : null,
      decoration: InputDecoration(
        labelText: isTypeField
            ? entry.nameCtr.text
            : AppLocalizations.of(context).addItemExtraFieldValueLabel,
        isDense: true,
        suffixIcon: IconButton(
          iconSize: 18,
          icon: Icon(entry.obscure ? Icons.visibility_off : Icons.visibility),
          onPressed: () => setState(() => entry.obscure = !entry.obscure),
        ),
      ),
      style: TextStyle(
        fontSize: 14,
        fontFamily: entry.isSecret || entry.obscure ? 'monospace' : null,
      ),
    );
  }

  Widget _buildFieldRow(_FieldEntry entry) {
    final isTypeField = entry.backendFieldId != null;
    final cs = Theme.of(context).colorScheme;
    final accent = entry.isSecret ? kBlaze : kTeal;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(12, 10, 6, 10),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isTypeField ? accent.withAlpha(60) : cs.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isTypeField)
            // Alan adı sabit label olduğu için değer tüm satırı kullanabilir
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildValueField(entry, isTypeField)),
                _buildDeleteButton(entry, cs),
              ],
            )
          else ...[
            // Alan adı ve değer ALT ALTA: yan yana dizilince telefonda değer
            // kutusuna ~100px kalıyor ve yazılan metin görünmüyordu
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: entry.nameCtr,
                    onChanged: (_) {
                      if (entry.error != null) setState(() => entry.error = null);
                    },
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context).addItemExtraFieldKeyLabel,
                      errorText: entry.error,
                      isDense: true,
                    ),
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                _buildDeleteButton(entry, cs),
              ],
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: _buildValueField(entry, isTypeField),
            ),
          ],
          // Şifre güç göstergesi
          if (entry.isSecret)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: entry.valueCtr,
                builder: (ctx2, v, child) =>
                    _PasswordStrengthIndicator(password: v.text),
              ),
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
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: [
        if (_selectedCategoryName != null)
          _summaryChip(Icons.folder_outlined, _selectedCategoryName!, kBlaze),
        if (_selectedItemType != null)
          _summaryChip(typeIcon,
              _selectedItemType!['name_tr'] as String? ?? '', typeColor),
      ],
    );
  }

  Widget _summaryChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withAlpha(24),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withAlpha(70)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
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
    final cs = Theme.of(context).colorScheme;
    return AppListCard(
      onTap: onTap,
      child: Row(
        children: [
          DuotoneIcon(icon, color: color),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600)),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 12.5, color: cs.onSurfaceVariant)),
                ],
              ],
            ),
          ),
          Icon(Icons.chevron_right, size: 20, color: cs.onSurfaceVariant),
        ],
      ),
    );
  }

  Color _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return kBlaze;
    try {
      return Color(
          int.parse('FF${hex.replaceAll('#', '')}', radix: 16));
    } catch (_) {
      return kBlaze;
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
              const DuotoneIcon(Icons.create_new_folder_outlined),
              const SizedBox(width: 12),
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
              prefixIcon: const Icon(Icons.folder_outlined),
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
    final cs = Theme.of(context).colorScheme;
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
              margin: const EdgeInsets.only(top: 12, bottom: 10),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurfaceVariant.withAlpha(70),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  const DuotoneIcon(Icons.extension_outlined),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.addItemTypeCreateTitle,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w700),
                    ),
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
                      prefixIcon: const Icon(Icons.label_outline),
                    ),
                  ),
                  const SizedBox(height: 20),
                  AppSectionTitle(l10n.addItemTypeFieldsLabel),
                  const SizedBox(height: 10),
                  ..._fieldRows.asMap().entries.map((e) {
                    final i = e.key;
                    final secret = _fieldSecrets[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: secret
                              ? kBlaze.withAlpha(60)
                              : cs.outlineVariant,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: e.value['name'],
                              decoration: InputDecoration(
                                labelText: '${l10n.addItemExtraFieldKeyLabel} ${i + 1}',
                                isDense: true,
                              ),
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            tooltip: secret
                                ? l10n.addItemTypeFieldTypeSecret
                                : l10n.addItemTypeFieldTypeText,
                            icon: Icon(
                              secret
                                  ? Icons.lock_outline
                                  : Icons.lock_open_outlined,
                              size: 18,
                              color: secret ? kBlaze : cs.onSurfaceVariant,
                            ),
                            onPressed: () => setState(
                                () => _fieldSecrets[i] = !_fieldSecrets[i]),
                          ),
                          IconButton(
                            icon: Icon(Icons.remove_circle_outline,
                                color: cs.error, size: 18),
                            onPressed: () => _removeFieldRow(i),
                          ),
                        ],
                      ),
                    )
                        .animate(delay: AppAnim.listDelay(i))
                        .fadeIn(duration: AppAnim.normal)
                        .slideY(begin: 0.1, curve: AppAnim.smooth);
                  }),
                  OutlinedButton.icon(
                    onPressed: _addFieldRow,
                    icon: const Icon(Icons.add, size: 16),
                    label: Text(l10n.addItemAddFieldButton),
                    style: OutlinedButton.styleFrom(foregroundColor: kBlaze),
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

  // Güç renkleri "Onyx & Ember" paletiyle uyumlu: kırmızı → amber → teal
  static const _colors = [
    Color(0xFFE5484D),
    Color(0xFFFF7043),
    Color(0xFFFFB020),
    Color(0xFF7CC47F),
    kTeal,
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
