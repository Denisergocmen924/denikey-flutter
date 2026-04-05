import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/category_provider.dart';

class CategoryScreen extends ConsumerStatefulWidget {
  const CategoryScreen({super.key});

  @override
  ConsumerState<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends ConsumerState<CategoryScreen> {
  final List<Color> _colorPalette = [
    Color(0xFF6200EE),
    Color(0xFF03DAC6),
    Color(0xFFFF5722),
    Color(0xFF2196F3),
    Color(0xFF4CAF50),
    Color(0xFFFF9800),
    Color(0xFFE91E63),
    Color(0xFF9C27B0),
    Color(0xFF607D8B),
    Color(0xFFF44336),
  ];

  Color _selectedColor = Color(0xFF6200EE);

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(categoryProvider.notifier).loadCategories());
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  Color _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return Colors.deepPurple;
    try {
      final h = hex.replaceAll('#', '');
      return Color(int.parse('FF$h', radix: 16));
    } catch (_) {
      return Colors.deepPurple;
    }
  }

  void _showAddDialog() {
    final nameCtrl = TextEditingController();
    _selectedColor = _colorPalette[0];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('New Category'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Category Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Select Color',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _colorPalette.map((color) {
                    final isSelected = _selectedColor == color;
                    return GestureDetector(
                      onTap: () => setDialogState(() => _selectedColor = color),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: Colors.black, width: 3)
                              : null,
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, color: Colors.white, size: 18)
                            : null,
                      ),
                    );
                  }).toList(),
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
                if (nameCtrl.text.isEmpty) return;
                ref.read(categoryProvider.notifier).createCategory(
                  nameCtrl.text.trim(),
                  nameCtrl.text.trim(),
                  null,
                  _colorToHex(_selectedColor),
                );
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

  void _confirmDelete(String id, bool isSystem) {
    if (isSystem) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('System categories cannot be deleted.')),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete'),
        content: const Text('Are you sure you want to delete this category?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(categoryProvider.notifier).deleteCategory(id);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(categoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Builder(builder: (context) {
        if (state.status == CategoryStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.status == CategoryStatus.error) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(state.errorMessage ?? 'Error'),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => ref.read(categoryProvider.notifier).loadCategories(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state.categories.isEmpty) {
          return const Center(
            child: Text(
              'No categories yet',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: state.categories.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final cat = state.categories[index];
            final isSystem = cat['is_system'] == true;
            final color = _parseColor(cat['color']);
            final name = cat['name_en'] ?? cat['name_tr'] ?? '';

            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: color.withOpacity(0.15),
                  child: Icon(
                    isSystem ? Icons.folder : Icons.folder_outlined,
                    color: color,
                  ),
                ),
                title: Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: isSystem
                    ? const Text('System', style: TextStyle(fontSize: 12))
                    : null,
                trailing: isSystem
                    ? const Icon(Icons.lock_outline, size: 16, color: Colors.grey)
                    : IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () =>
                            _confirmDelete(cat['id'].toString(), isSystem),
                      ),
              ),
            );
          },
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