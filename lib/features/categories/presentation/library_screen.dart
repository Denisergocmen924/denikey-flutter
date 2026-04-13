import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/category_provider.dart';
import '../../item_types/providers/item_type_provider.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final List<Color> _colorPalette = [
    const Color(0xFF534AB7),
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

  Color _selectedColor = const Color(0xFF534AB7);
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
    if (hex == null || hex.isEmpty) return Colors.deepPurple;
    try {
      final h = hex.replaceAll('#', '');
      return Color(int.parse('FF$h', radix: 16));
    } catch (_) {
      return Colors.deepPurple;
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
        builder: (context, setS) => AlertDialog(
          title: const Text('Yeni Kategori'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Kategori Adı',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Renk Seç', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _colorPalette.map((c) {
                    final sel = _selectedColor == c;
                    return GestureDetector(
                      onTap: () => setS(() => _selectedColor = c),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: sel ? Border.all(color: Colors.black, width: 3) : null,
                        ),
                        child: sel ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal')),
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
              style: FilledButton.styleFrom(backgroundColor: Colors.deepPurple),
              child: const Text('Ekle'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteCategory(String id, bool isSystem) {
    if (isSystem) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sistem kategorileri silinemez.')),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sil'),
        content: const Text('Bu kategoriyi silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal')),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(categoryProvider.notifier).deleteCategory(id);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sil'),
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

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setS) => AlertDialog(
          title: const Text('Yeni Tür'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Tür Adı',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('İkon Seç', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _iconOptions.map((e) {
                    final sel = _selectedIcon == e.key;
                    return GestureDetector(
                      onTap: () => setS(() => _selectedIcon = e.key),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: sel
                              ? _selectedColor.withAlpha(51)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: sel
                              ? Border.all(color: _selectedColor, width: 2)
                              : null,
                        ),
                        child: Icon(e.value,
                            size: 22,
                            color: sel ? _selectedColor : Colors.grey.shade600),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                const Text('Renk Seç', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _colorPalette.map((c) {
                    final sel = _selectedColor == c;
                    return GestureDetector(
                      onTap: () => setS(() => _selectedColor = c),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: sel ? Border.all(color: Colors.black, width: 3) : null,
                        ),
                        child: sel ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal')),
            FilledButton(
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty) return;
                ref.read(itemTypeProvider.notifier).createItemType(
                  nameCtrl.text.trim(),
                  _selectedIcon,
                  _colorToHex(_selectedColor),
                );
                Navigator.pop(ctx);
              },
              style: FilledButton.styleFrom(backgroundColor: Colors.deepPurple),
              child: const Text('Ekle'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteItemType(String id, bool isSystem) {
    if (isSystem) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sistem türleri silinemez.')),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sil'),
        content: const Text('Bu türü silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal')),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(itemTypeProvider.notifier).deleteItemType(id);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  // --- Build ---

  @override
  Widget build(BuildContext context) {
    final catState = ref.watch(categoryProvider);
    final typeState = ref.watch(itemTypeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kütüphane'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Kategoriler'),
            Tab(text: 'Türler'),
          ],
        ),
      ),
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
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add, color: Colors.white),
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
    if (state.status == CategoryStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.status == CategoryStatus.error) {
      return Center(child: Text(state.errorMessage ?? 'Hata'));
    }
    if (state.categories.isEmpty) {
      return const Center(
        child: Text('Henüz kategori yok', style: TextStyle(color: Colors.grey)),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: state.categories.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final cat = state.categories[index];
        final isSystem = cat['is_system'] == true;
        final color = parseColor(cat['color'] as String?);
        final name = cat['name_tr'] ?? cat['name_en'] ?? '';

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: color.withAlpha(38),
              child: Icon(
                isSystem ? Icons.folder : Icons.folder_outlined,
                color: color,
              ),
            ),
            title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: isSystem
                ? const Text('Sistem', style: TextStyle(fontSize: 12))
                : null,
            trailing: isSystem
                ? const Icon(Icons.lock_outline, size: 16, color: Colors.grey)
                : IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => onDelete(cat['id'].toString(), isSystem),
                  ),
            onTap: () => context.push('/categories/detail', extra: cat),
          ),
        );
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
  final void Function(String, bool) onDelete;

  const _ItemTypesTab({
    required this.state,
    required this.parseColor,
    required this.iconDataFor,
    required this.onAdd,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.itemTypes.isEmpty) {
      return const Center(
        child: Text('Henüz tür yok', style: TextStyle(color: Colors.grey)),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: state.itemTypes.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final type = state.itemTypes[index];
        final isSystem = type['is_system'] == true;
        final color = parseColor(type['color'] as String?);
        final icon = iconDataFor(type['icon'] as String?);
        final name = type['name_tr'] ?? type['name_en'] ?? '';
        final fields = (type['fields'] as List<dynamic>? ?? []);

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: color.withAlpha(38),
              child: Icon(icon, color: color),
            ),
            title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(
              '${fields.length} alan',
              style: const TextStyle(fontSize: 12),
            ),
            trailing: isSystem
                ? const Icon(Icons.lock_outline, size: 16, color: Colors.grey)
                : IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => onDelete(type['id'].toString(), isSystem),
                  ),
          ),
        );
      },
    );
  }
}
