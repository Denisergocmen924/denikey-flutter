import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../providers/category_provider.dart';
import '../../item_types/providers/item_type_provider.dart';
import '../../../core/presentation/app_animations.dart';
import '../../../core/presentation/app_nav_bar.dart';
import '../../../core/presentation/app_tiles.dart';
import 'package:denikey_app/l10n/generated/app_localizations.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final List<Color> _colorPalette = [
    kBlaze,
    const Color(0xFF185FA5),
    const Color(0xFF0F6E56),
    const Color(0xFF993C1D),
    const Color(0xFF993556),
    const Color(0xFF854F0B),
    const Color(0xFF3B6D11),
    const Color(0xFF607D8B),
    const Color(0xFF6200EE),
    const Color(0xFFE91E63),
  ];

  // (icon adı, IconData) çiftleri
  final List<MapEntry<String, IconData>> _iconOptions = const [
    MapEntry('category', Icons.category_outlined),
    MapEntry('lock', Icons.lock_outline),
    MapEntry('credit_card', Icons.credit_card),
    MapEntry('badge', Icons.badge_outlined),
    MapEntry('note', Icons.note_outlined),
    MapEntry('wifi', Icons.wifi),
    MapEntry('account_balance', Icons.account_balance_outlined),
    MapEntry('subscriptions', Icons.subscriptions_outlined),
    MapEntry('star', Icons.star_outline),
    MapEntry('work', Icons.work_outline),
    MapEntry('home', Icons.home_outlined),
    MapEntry('email', Icons.email_outlined),
  ];

  Color _selectedColor = kBlaze;
  String _selectedIcon = 'category';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.microtask(() {
      ref.read(categoryProvider.notifier).loadCategories();
      ref.read(itemTypeProvider.notifier).loadItemTypes();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // --- Yardımcı ---

  String _colorToHex(Color color) =>
      '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';

  Color _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return kBlaze;
    try {
      final h = hex.replaceAll('#', '');
      return Color(int.parse('FF$h', radix: 16));
    } catch (_) {
      return kBlaze;
    }
  }

  IconData _iconDataFor(String? name) {
    return _iconOptions
            .firstWhere(
              (e) => e.key == name,
              orElse: () => const MapEntry('category', Icons.category_outlined),
            )
            .value;
  }

  // --- Kategoriler diyalogları ---

  void _showAddCategoryDialog() {
    final nameCtrl = TextEditingController();
    _selectedColor = _colorPalette[0];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setS) {
          final l10n = AppLocalizations.of(context);
          return AlertDialog(
          title: Text(l10n.libraryAddCategory),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: l10n.libraryCategoryName,
                    prefixIcon: const Icon(Icons.folder_outlined, size: 20),
                  ),
                ),
                const SizedBox(height: 18),
                AppSectionTitle(l10n.libraryCategoryColorSelect,
                    accent: _selectedColor),
                _ColorPalette(
                  colors: _colorPalette,
                  selected: _selectedColor,
                  onSelect: (c) => setS(() => _selectedColor = c),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.libraryCancel)),
            FilledButton(
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty) return;
                ref.read(categoryProvider.notifier).createCategory(
                  nameCtrl.text.trim(),
                  nameCtrl.text.trim(),
                  null,
                  _colorToHex(_selectedColor),
                );
                Navigator.pop(ctx);
              },
              child: Text(l10n.libraryAddButton),
            ),
          ],
        );
        },
      ),
    );
  }

  void _confirmDeleteCategory(String id, bool isSystem) {
    if (isSystem) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).libraryDeleteSystemCategory)),
      );
      return;
    }
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.libraryDeleteCategoryTitle),
        content: Text(l10n.libraryDeleteCategoryMessage),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.libraryCancel)),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(categoryProvider.notifier).deleteCategory(id);
            },
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(ctx).colorScheme.error),
            child: Text(l10n.libraryDeleteCategoryTitle),
          ),
        ],
      ),
    );
  }

  // --- Türler diyalogları ---

  void _showAddItemTypeDialog() {
    final nameCtrl = TextEditingController();
    _selectedColor = _colorPalette[0];
    _selectedIcon = 'category';

    // Sabit alanlar: {name, type, isRequired}
    final List<Map<String, dynamic>> fixedFields = [];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setS) {
          final cs = Theme.of(context).colorScheme;
          final l10n = AppLocalizations.of(context);
          final fieldTypes = [
            ('text',    l10n.addItemTypeFieldTypeText),
            ('secret',  l10n.addItemTypeFieldTypeSecret),
            ('number',  l10n.addItemTypeFieldTypeNumber),
            ('date',    l10n.addItemTypeFieldTypeDate),
          ];
          return AlertDialog(
            title: Text(l10n.libraryTypesTab),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameCtrl,
                      decoration: InputDecoration(
                        labelText: l10n.addItemTypeNameLabel,
                        prefixIcon: Icon(_iconDataFor(_selectedIcon), size: 20),
                      ),
                    ),
                    const SizedBox(height: 18),
                    AppSectionTitle(l10n.addItemTypeSelectIcon,
                        accent: _selectedColor),
                    _IconPalette(
                      options: _iconOptions,
                      selectedKey: _selectedIcon,
                      accent: _selectedColor,
                      onSelect: (k) => setS(() => _selectedIcon = k),
                    ),
                    const SizedBox(height: 18),
                    AppSectionTitle(l10n.libraryCategoryColorSelect,
                        accent: _selectedColor),
                    _ColorPalette(
                      colors: _colorPalette,
                      selected: _selectedColor,
                      onSelect: (c) => setS(() => _selectedColor = c),
                    ),

                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(l10n.addItemTypeFixedFields,
                          style: TextStyle(
                            fontWeight: FontWeight.w600, color: cs.onSurface)),
                        TextButton.icon(
                          onPressed: () {
                            setS(() => fixedFields.add({
                              'field_name': '',
                              'field_type': 'text',
                              'is_required': false,
                            }));
                          },
                          icon: const Icon(Icons.add, size: 18),
                          label: Text(l10n.addItemTypeFieldAdd),
                        ),
                      ],
                    ),
                    if (fixedFields.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          l10n.addItemTypeFieldDefault,
                          style: TextStyle(
                            fontSize: 12, color: cs.onSurfaceVariant),
                        ),
                      ),
                    ...fixedFields.asMap().entries.map((entry) {
                      final i = entry.key;
                      final f = entry.value;
                      final ctrl = TextEditingController(text: f['field_name'] as String);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextField(
                                controller: ctrl,
                                onChanged: (v) => f['field_name'] = v,
                                decoration: InputDecoration(
                                  labelText: l10n.addItemTypeFieldName,
                                  isDense: true,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 2,
                              child: DropdownButtonFormField<String>(
                                initialValue: f['field_type'] as String,
                                isDense: true,
                                decoration: const InputDecoration(isDense: true),
                                items: fieldTypes.map((t) => DropdownMenuItem(
                                  value: t.$1,
                                  child: Text(t.$2, style: const TextStyle(fontSize: 13)),
                                )).toList(),
                                onChanged: (v) => setS(() => f['field_type'] = v!),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.close, size: 18, color: cs.error),
                              onPressed: () => setS(() => fixedFields.removeAt(i)),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.libraryCancel)),
              FilledButton(
                onPressed: () {
                  if (nameCtrl.text.trim().isEmpty) return;
                  final validFields = fixedFields
                      .where((f) => (f['field_name'] as String).trim().isNotEmpty)
                      .map((f) => {
                        'field_name': (f['field_name'] as String).trim(),
                        'field_type': f['field_type'] as String,
                        'is_required': f['is_required'] as bool,
                      })
                      .toList();
                  ref.read(itemTypeProvider.notifier).createItemType(
                    nameCtrl.text.trim(),
                    _selectedIcon,
                    _colorToHex(_selectedColor),
                    fields: validFields.isNotEmpty ? validFields : null,
                  );
                  Navigator.pop(ctx);
                },
                child: Text(l10n.libraryAddButton),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEditItemTypeDialog(Map<String, dynamic> type) {
    final nameCtrl = TextEditingController(text: type['name_tr'] as String? ?? '');
    _selectedColor = _parseColor(type['color'] as String?);
    _selectedIcon = type['icon'] as String? ?? 'category';
    final fields = (type['fields'] as List<dynamic>? ?? []);
    final fieldControllers = <String, TextEditingController>{
      for (final f in fields)
        if (f['id'] != null)
          f['id'] as String: TextEditingController(text: f['field_name_tr'] as String? ?? ''),
    };
    final newFields = <Map<String, dynamic>>[]; // {nameCtrl, isSecret}

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setS) {
          final cs = Theme.of(context).colorScheme;
          final l10n = AppLocalizations.of(context);
          return AlertDialog(
            title: Text(l10n.libraryTypesTab),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameCtrl,
                      decoration: InputDecoration(
                        labelText: l10n.addItemTypeNameLabel,
                        prefixIcon: Icon(_iconDataFor(_selectedIcon), size: 20),
                      ),
                    ),
                    const SizedBox(height: 18),
                    AppSectionTitle(l10n.addItemTypeSelectIcon,
                        accent: _selectedColor),
                    _IconPalette(
                      options: _iconOptions,
                      selectedKey: _selectedIcon,
                      accent: _selectedColor,
                      onSelect: (k) => setS(() => _selectedIcon = k),
                    ),
                    const SizedBox(height: 18),
                    AppSectionTitle(l10n.libraryCategoryColorSelect,
                        accent: _selectedColor),
                    _ColorPalette(
                      colors: _colorPalette,
                      selected: _selectedColor,
                      onSelect: (c) => setS(() => _selectedColor = c),
                    ),
                    if (fields.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      AppSectionTitle(l10n.addItemTypeFixedFields,
                          accent: _selectedColor),
                      ...fields.map((f) {
                        final fid = f['id'] as String? ?? '';
                        final fieldType = f['field_type'] as String? ?? 'text';
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              DuotoneIcon(
                                fieldType == 'secret'
                                    ? Icons.lock_outline
                                    : Icons.text_fields,
                                color: fieldType == 'secret'
                                    ? kBlaze
                                    : cs.onSurfaceVariant,
                                size: 32,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: fieldControllers[fid],
                                  decoration: const InputDecoration(
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  ),
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                    const SizedBox(height: 12),
                    ...newFields.asMap().entries.map((e) {
                      final i = e.key;
                      final nf = e.value;
                      final isSecret = nf['isSecret'] == true;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            // Tek dokunuşla normal ↔ gizli alan tipi
                            Tooltip(
                              message: isSecret
                                  ? l10n.addItemTypeFieldTypeSecret
                                  : l10n.addItemTypeFieldTypeText,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(10),
                                onTap: () => setS(
                                    () => nf['isSecret'] = !(nf['isSecret'] as bool)),
                                child: DuotoneIcon(
                                  isSecret ? Icons.lock_outline : Icons.text_fields,
                                  color: isSecret ? kBlaze : cs.onSurfaceVariant,
                                  size: 32,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: nf['nameCtrl'] as TextEditingController,
                                decoration: InputDecoration(
                                  labelText: l10n.addItemExtraFieldKeyLabel,
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                ),
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline, size: 18),
                              color: cs.error,
                              onPressed: () => setS(() => newFields.removeAt(i)),
                            ),
                          ],
                        ),
                      );
                    }),
                    TextButton.icon(
                      onPressed: () => setS(() => newFields.add({'nameCtrl': TextEditingController(), 'isSecret': false})),
                      icon: const Icon(Icons.add, size: 18),
                      label: Text(l10n.addItemAddFieldButton),
                      style: TextButton.styleFrom(foregroundColor: kBlaze),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.libraryCancel)),
              FilledButton(
                onPressed: () {
                  if (nameCtrl.text.trim().isEmpty) return;
                  final fieldUpdates = fields
                      .where((f) => f['id'] != null)
                      .map((f) {
                        final fid = f['id'] as String;
                        return {
                          'id': fid,
                          'field_name': fieldControllers[fid]?.text.trim() ?? f['field_name_tr'] as String? ?? '',
                        };
                      })
                      .toList();
                  ref.read(itemTypeProvider.notifier).updateItemType(
                    type['id'].toString(),
                    nameCtrl.text.trim(),
                    _selectedIcon,
                    _colorToHex(_selectedColor),
                    fields: fieldUpdates.isNotEmpty ? fieldUpdates : null,
                    newFields: newFields
                        .where((nf) => (nf['nameCtrl'] as TextEditingController).text.trim().isNotEmpty)
                        .map((nf) => {
                          'field_name': (nf['nameCtrl'] as TextEditingController).text.trim(),
                          'field_type': nf['isSecret'] == true ? 'secret' : 'text',
                        })
                        .toList(),
                  );
                  Navigator.pop(ctx);
                },
                child: Text(l10n.libraryAddButton),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmDeleteItemType(String id, bool isSystem) {
    if (isSystem) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).libraryDeleteSystemType)),
      );
      return;
    }
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.libraryDeleteCategoryTitle),
        content: Text(l10n.libraryDeleteCategoryMessage),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.libraryCancel)),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(itemTypeProvider.notifier).deleteItemType(id);
            },
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(ctx).colorScheme.error),
            child: Text(l10n.libraryDeleteCategoryTitle),
          ),
        ],
      ),
    );
  }

  // --- Build ---

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final catState = ref.watch(categoryProvider);
    final typeState = ref.watch(itemTypeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.libraryTitle),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.libraryCategoriesTab),
            Tab(text: l10n.libraryTypesTab),
          ],
        ),
      ),
      bottomNavigationBar: const AppNavBar(currentIndex: 1),
      body: TabBarView(
        controller: _tabController,
        children: [
          _CategoriesTab(
            state: catState,
            parseColor: _parseColor,
            onAdd: _showAddCategoryDialog,
            onDelete: _confirmDeleteCategory,
          ),
          _ItemTypesTab(
            state: typeState,
            parseColor: _parseColor,
            iconDataFor: _iconDataFor,
            onAdd: _showAddItemTypeDialog,
            onEdit: _showEditItemTypeDialog,
            onDelete: _confirmDeleteItemType,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_tabController.index == 0) {
            _showAddCategoryDialog();
          } else {
            _showAddItemTypeDialog();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// --- Kategoriler sekmesi ---

class _CategoriesTab extends StatelessWidget {
  final dynamic state;
  final Color Function(String?) parseColor;
  final VoidCallback onAdd;
  final void Function(String, bool) onDelete;

  const _CategoriesTab({
    required this.state,
    required this.parseColor,
    required this.onAdd,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;

    if (state.status == CategoryStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.status == CategoryStatus.error) {
      return AppEmptyState(
        icon: Icons.error_outline,
        title: state.errorMessage ?? l10n.libraryEmptyCategories,
        accent: cs.error,
      );
    }
    if (state.categories.isEmpty) {
      return AppEmptyState(
        icon: Icons.folder_outlined,
        title: l10n.libraryEmptyCategories,
      ).animate().fadeIn(duration: AppAnim.slow, curve: AppAnim.smooth);
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
      itemCount: state.categories.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final cat = state.categories[index];
        final isSystem = cat['is_system'] == true;
        final color = parseColor(cat['color'] as String?);
        final name = isSystem ? l10n.categoriesUncategorized : (cat['name_tr'] ?? cat['name_en'] ?? '');

        return AppListCard(
          onTap: () => context.push('/categories/detail', extra: cat),
          child: Row(
            children: [
              DuotoneIcon(
                isSystem ? Icons.folder : Icons.folder_outlined,
                color: color,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    if (isSystem) ...[
                      const SizedBox(height: 3),
                      Text(
                        l10n.librarySystemLabel,
                        style: TextStyle(
                            fontSize: 12, color: cs.onSurfaceVariant),
                      ),
                    ],
                  ],
                ),
              ),
              if (isSystem)
                Icon(Icons.lock_outline, size: 17, color: cs.onSurfaceVariant)
              else
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  color: cs.error,
                  onPressed: () => onDelete(cat['id'].toString(), isSystem),
                ),
            ],
          ),
        )
            .animate(delay: AppAnim.listDelay(index))
            .fadeIn(duration: AppAnim.normal)
            .slideY(begin: 0.12, curve: AppAnim.smooth);
      },
    );
  }
}

// --- Türler sekmesi ---

class _ItemTypesTab extends StatelessWidget {
  final ItemTypeState state;
  final Color Function(String?) parseColor;
  final IconData Function(String?) iconDataFor;
  final VoidCallback onAdd;
  final void Function(Map<String, dynamic>) onEdit;
  final void Function(String, bool) onDelete;

  const _ItemTypesTab({
    required this.state,
    required this.parseColor,
    required this.iconDataFor,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.itemTypes.isEmpty) {
      return AppEmptyState(
        icon: Icons.category_outlined,
        title: l10n.libraryEmptyTypes,
        accent: kTeal,
      ).animate().fadeIn(duration: AppAnim.slow, curve: AppAnim.smooth);
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
      itemCount: state.itemTypes.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final type = state.itemTypes[index];
        final isSystem = type['is_system'] == true;
        final color = parseColor(type['color'] as String?);
        final icon = iconDataFor(type['icon'] as String?);
        final name = type['name_tr'] ?? type['name_en'] ?? '';
        final fields = (type['fields'] as List<dynamic>? ?? []);

        return AppListCard(
          onTap: isSystem ? null : () => onEdit(type),
          child: Row(
            children: [
              DuotoneIcon(icon, color: color),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      l10n.libraryTypeFieldCount(fields.length),
                      style:
                          TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              if (isSystem)
                Icon(Icons.lock_outline, size: 17, color: cs.onSurfaceVariant)
              else ...[
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  color: cs.onSurfaceVariant,
                  onPressed: () => onEdit(type),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  color: cs.error,
                  onPressed: () => onDelete(type['id'].toString(), isSystem),
                ),
              ],
            ],
          ),
        )
            .animate(delay: AppAnim.listDelay(index))
            .fadeIn(duration: AppAnim.normal)
            .slideY(begin: 0.12, curve: AppAnim.smooth);
      },
    );
  }
}

// --- Diyaloglarda kullanılan renk / ikon seçiciler ---

class _ColorPalette extends StatelessWidget {
  final List<Color> colors;
  final Color selected;
  final ValueChanged<Color> onSelect;

  const _ColorPalette({
    required this.colors,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: colors.map((c) {
        final sel = selected == c;
        return GestureDetector(
          onTap: () => onSelect(c),
          child: AnimatedContainer(
            duration: AppAnim.fast,
            curve: AppAnim.smooth,
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: c,
              borderRadius: BorderRadius.circular(sel ? 12 : 18),
              boxShadow: sel
                  ? [
                      BoxShadow(
                        color: c.withAlpha(120),
                        blurRadius: 14,
                        spreadRadius: -2,
                      ),
                    ]
                  : null,
            ),
            child: sel
                ? const Icon(Icons.check, color: Colors.white, size: 18)
                : null,
          ),
        );
      }).toList(),
    );
  }
}

class _IconPalette extends StatelessWidget {
  final List<MapEntry<String, IconData>> options;
  final String selectedKey;
  final Color accent;
  final ValueChanged<String> onSelect;

  const _IconPalette({
    required this.options,
    required this.selectedKey,
    required this.accent,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options.map((e) {
        final sel = selectedKey == e.key;
        return GestureDetector(
          onTap: () => onSelect(e.key),
          child: AnimatedContainer(
            duration: AppAnim.fast,
            curve: AppAnim.smooth,
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: sel
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [accent.withAlpha(70), accent.withAlpha(25)],
                    )
                  : null,
              color: sel ? null : cs.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: sel ? accent : cs.outlineVariant,
                width: sel ? 1.5 : 1,
              ),
            ),
            child: Icon(e.value,
                size: 21, color: sel ? accent : cs.onSurfaceVariant),
          ),
        );
      }).toList(),
    );
  }
}
