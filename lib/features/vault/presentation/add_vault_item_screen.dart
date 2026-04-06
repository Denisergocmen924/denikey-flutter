import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/vault_provider.dart';
import '../../categories/providers/category_provider.dart';

class AddVaultItemScreen extends ConsumerStatefulWidget {
  const AddVaultItemScreen({super.key});

  @override
  ConsumerState<AddVaultItemScreen> createState() => _AddVaultItemScreenState();
}

class _AddVaultItemScreenState extends ConsumerState<AddVaultItemScreen> {
  // Adım: kategori seç → form
  bool _categorySelected = false;
  String? _selectedCategoryId;
  String? _selectedCategoryName;

  // Form
  final _titleCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;

  // Ek alanlar
  final List<Map<String, TextEditingController>> _extraFields = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(categoryProvider.notifier).loadCategories());
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _passwordCtrl.dispose();
    for (final f in _extraFields) {
      f['key']!.dispose();
      f['value']!.dispose();
    }
    super.dispose();
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
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Başlık zorunludur')),
      );
      return;
    }

    final data = <String, dynamic>{
      'title': _titleCtrl.text.trim(),
      'password': _passwordCtrl.text.trim(),
      if (_selectedCategoryId != null) 'category_id': _selectedCategoryId,
    };

    // Ek alanlar
    final extraFields = <Map<String, String>>[];
    for (final f in _extraFields) {
      final k = f['key']!.text.trim();
      final v = f['value']!.text.trim();
      if (k.isNotEmpty) {
        extraFields.add({'field_name': k, 'value': v, 'field_type': 'text'});
      }
    }
    if (extraFields.isNotEmpty) data['custom_fields_data'] = extraFields;

    await ref.read(vaultProvider.notifier).createItem(data);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_categorySelected ? 'Şifre Ekle' : 'Kategori Seç'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_categorySelected) {
              setState(() => _categorySelected = false);
            } else {
              context.pop();
            }
          },
        ),
      ),
      body: _categorySelected ? _buildForm() : _buildCategorySelection(),
    );
  }

  Widget _buildCategorySelection() {
    final state = ref.watch(categoryProvider);
    final categories = state.categories;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Kategorisiz
        _categoryTile(
          icon: Icons.inbox_outlined,
          color: Colors.grey,
          title: 'Kategorisiz',
          subtitle: 'Kategorisizler altında sakla',
          onTap: () {
            // Kategorisizler kategorisini bul
            final uncategorized = categories.firstWhere(
              (c) => c['name_en'] == 'Uncategorized',
              orElse: () => <String, dynamic>{},
            );
            setState(() {
              _selectedCategoryId = uncategorized['id'] as String?;
              _selectedCategoryName = 'Kategorisizler';
              _categorySelected = true;
            });
          },
        ),
        const SizedBox(height: 8),
        // Kategori oluştur
        _categoryTile(
          icon: Icons.add_circle_outline,
          color: Colors.deepPurple,
          title: 'Kategori Oluştur',
          subtitle: 'Yeni kategori ekle',
          onTap: () => _showCreateCategoryDialog(),
        ),
        const SizedBox(height: 16),
        if (state.status == CategoryStatus.loading)
          const Center(child: CircularProgressIndicator())
        else ...[
          Text('Kategoriler',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.grey.shade600)),
          const SizedBox(height: 8),
          ...categories
            .where((c) => c['name_en'] != 'Uncategorized')
            .map((cat) {
              final color = _parseColor(cat['color']);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _categoryTile(
                  icon: Icons.folder_outlined,
                  color: color,
                  title: cat['name_en'] ?? cat['name_tr'] ?? '',
                  subtitle: '',
                  onTap: () => setState(() {
                    _selectedCategoryId = cat['id'] as String?;
                    _selectedCategoryName = cat['name_en'] ?? cat['name_tr'];
                    _categorySelected = true;
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
                '#534AB7',
              );
              // Yeni kategoriyi seç
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
                  _categorySelected = true;
                });
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.deepPurple),
            child: const Text('Oluştur'),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Kategori göstergesi
          if (_selectedCategoryName != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.deepPurple.withAlpha(50)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.folder_outlined, size: 16, color: Colors.deepPurple),
                  const SizedBox(width: 8),
                  Text(_selectedCategoryName!,
                    style: const TextStyle(color: Colors.deepPurple, fontSize: 13)),
                ],
              ),
            ),

          // Başlık
          TextField(
            controller: _titleCtrl,
            decoration: const InputDecoration(
              labelText: 'Başlık',
              hintText: 'Örn: Instagram, Gmail, Netflix',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),

          // Şifre
          TextField(
            controller: _passwordCtrl,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Şifre',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Ek alanlar
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
                    onPressed: () => setState(() => _extraFields.removeAt(i)),
                  ),
                ],
              ),
            );
          }),

          // Alan ekle butonu
          OutlinedButton.icon(
            onPressed: _addExtraField,
            icon: const Icon(Icons.add),
            label: const Text('Alan Ekle'),
            style: OutlinedButton.styleFrom(foregroundColor: Colors.deepPurple),
          ),
          const SizedBox(height: 24),

          // Kaydet
          FilledButton(
            onPressed: _save,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Kaydet', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _categoryTile({
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
        subtitle: subtitle.isNotEmpty ? Text(subtitle, style: const TextStyle(fontSize: 12)) : null,
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  Color _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return Colors.deepPurple;
    try {
      return Color(int.parse('FF${hex.replaceAll('#', '')}', radix: 16));
    } catch (_) {
      return Colors.deepPurple;
    }
  }
}
