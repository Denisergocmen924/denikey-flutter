import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/vault_provider.dart';
import '../../categories/providers/category_provider.dart';
import '../../../core/notifications/notification_service.dart';
import '../../../core/presentation/app_nav_bar.dart';
import '../../../core/presentation/desktop_onboarding_dialog.dart';

class VaultScreen extends ConsumerStatefulWidget {
  const VaultScreen({super.key});

  @override
  ConsumerState<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends ConsumerState<VaultScreen> {
  // null = "Tümü", dolu = seçili kategori id'si
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref.read(vaultProvider.notifier).loadItems();
      ref.read(categoryProvider.notifier).loadCategories();
      NotificationService.instance.scheduleWeeklySecurityReminder();
      if (mounted) await showDesktopOnboardingIfNeeded(context);
      await ref.read(vaultProvider.notifier).createSampleItemIfNeeded();
    });
  }

  IconData _iconForType(String? type) {
    switch (type) {
      case 'login':    return Icons.lock_outline;
      case 'card':     return Icons.credit_card;
      case 'identity': return Icons.badge_outlined;
      case 'note':     return Icons.note_outlined;
      default:         return Icons.key_outlined;
    }
  }

  Color _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return const Color(0xFFFF5900);
    try {
      return Color(int.parse('FF${hex.replaceAll('#', '')}', radix: 16));
    } catch (_) {
      return const Color(0xFFFF5900);
    }
  }

  List<Map<String, dynamic>> _filteredItems(List<Map<String, dynamic>> items) {
    List<Map<String, dynamic>> result = items;
    if (_selectedCategoryId != null) {
      result = result.where((item) {
        final catId = item['category_id']?.toString();
        return catId == _selectedCategoryId;
      }).toList();
    }
    // Favoriler üste
    final favorites = result.where((i) => i['is_favorite'] == true).toList();
    final rest = result.where((i) => i['is_favorite'] != true).toList();
    return [...favorites, ...rest];
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(vaultProvider);
    final catState = ref.watch(categoryProvider);
    final cs = Theme.of(context).colorScheme;
    final filtered = _filteredItems(state.items);

    return Scaffold(
      appBar: AppBar(
        title: const Text('DeniKey'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Ara',
            onPressed: () => context.push('/search'),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Çöp Kutusu',
            onPressed: () => context.push('/trash'),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Yenile',
            onPressed: () => ref.read(vaultProvider.notifier).loadItems(),
          ),
        ],
      ),
      bottomNavigationBar: const AppNavBar(currentIndex: 0),
      body: Column(
        children: [
          // Çevrimdışı banner
          if (state.isOffline)
            Container(
              width: double.infinity,
              color: Colors.orange.shade800,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.wifi_off, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    (Platform.isLinux || Platform.isWindows)
                        ? 'İnternet bağlantısı olmadan kasanıza erişemezsiniz'
                        : 'Çevrimdışı mod — Salt okunur',
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ],
              ),
            ),

          // Kategoriler yatay listesi
          if (catState.categories.isNotEmpty)
            _CategoryBar(
              categories: catState.categories,
              selectedId: _selectedCategoryId,
              parseColor: _parseColor,
              onSelect: (id) => setState(() => _selectedCategoryId = id),
            ),

          // Şifre listesi
          Expanded(
            child: Builder(builder: (context) {
              if (state.status == VaultStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state.status == VaultStatus.error) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: cs.error),
                      const SizedBox(height: 12),
                      Text(state.errorMessage ?? 'Hata',
                        style: TextStyle(color: cs.onSurfaceVariant)),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () => ref.read(vaultProvider.notifier).loadItems(),
                        child: const Text('Yeniden Dene'),
                      ),
                    ],
                  ),
                );
              }
              if (state.items.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shield_outlined, size: 72,
                        color: cs.onSurfaceVariant.withAlpha(80)),
                      const SizedBox(height: 20),
                      Text('Henüz şifre yok',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600,
                          color: cs.onSurface)),
                      const SizedBox(height: 8),
                      Text('+ ile yeni şifre ekleyin',
                        style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant)),
                    ],
                  ),
                );
              }
              if (filtered.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.folder_open_outlined, size: 64,
                        color: cs.onSurfaceVariant.withAlpha(80)),
                      const SizedBox(height: 16),
                      Text('Bu kategoride şifre yok',
                        style: TextStyle(fontSize: 16, color: cs.onSurfaceVariant)),
                    ],
                  ),
                );
              }
              final favorites = filtered.where((i) => i['is_favorite'] == true).toList();
              final hasFavorites = favorites.isNotEmpty;

              return RefreshIndicator(
                onRefresh: () => ref.read(vaultProvider.notifier).loadItems(),
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  itemCount: filtered.length + (hasFavorites ? 2 : 0),
                  itemBuilder: (context, index) {
                    // Favoriler başlığı
                    if (hasFavorites && index == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Icon(Icons.star, size: 14, color: Colors.amber.shade600),
                            const SizedBox(width: 6),
                            Text(
                              'Favoriler',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.6,
                                color: Colors.amber.shade700,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    // Diğerleri başlığı
                    if (hasFavorites && index == favorites.length + 1) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 8),
                        child: Row(
                          children: [
                            Expanded(child: Divider(color: cs.outlineVariant, height: 1)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                'Diğerleri',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                            ),
                            Expanded(child: Divider(color: cs.outlineVariant, height: 1)),
                          ],
                        ),
                      );
                    }

                    final itemIndex = hasFavorites
                        ? (index <= favorites.length ? index - 1 : index - 2)
                        : index;
                    final item = filtered[itemIndex];
                    final isFavorite = item['is_favorite'] == true;
                    final itemId = item['id']?.toString() ?? '';

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.only(
                            left: 16, right: 4, top: 8, bottom: 8),
                          leading: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: cs.primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              _iconForType(item['item_type']),
                              color: cs.onPrimaryContainer,
                              size: 22,
                            ),
                          ),
                          title: Text(
                            item['title'] ?? 'İsimsiz',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 15),
                          ),
                          subtitle: item['username'] != null || item['url'] != null
                            ? Text(
                                item['username'] ?? item['url'] ?? '',
                                style: TextStyle(
                                  color: cs.onSurfaceVariant, fontSize: 13),
                              )
                            : null,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  isFavorite ? Icons.star : Icons.star_border,
                                  color: isFavorite
                                      ? Colors.amber.shade600
                                      : cs.onSurfaceVariant,
                                  size: 20,
                                ),
                                tooltip: isFavorite
                                    ? 'Favoriden çıkar'
                                    : 'Favorilere ekle',
                                onPressed: () => ref
                                    .read(vaultProvider.notifier)
                                    .toggleFavorite(itemId, !isFavorite),
                              ),
                              Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
                              const SizedBox(width: 4),
                            ],
                          ),
                          onTap: () async {
                            await context.push('/vault/detail', extra: item);
                            ref.read(vaultProvider.notifier).loadItems();
                          },
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: state.isOffline
            ? () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('İnternet bağlantısı yok.')))
            : () => context.push('/add-item').then(
                (_) => ref.read(vaultProvider.notifier).loadItems()),
        icon: const Icon(Icons.add),
        label: const Text('Yeni Şifre',
          style: TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}

// --- Kategoriler yatay bar ---

class _CategoryBar extends StatelessWidget {
  final List<Map<String, dynamic>> categories;
  final String? selectedId;
  final Color Function(String?) parseColor;
  final void Function(String?) onSelect;

  const _CategoryBar({
    required this.categories,
    required this.selectedId,
    required this.parseColor,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      color: cs.surfaceContainerLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 56,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              scrollDirection: Axis.horizontal,
              children: [
                // "Tümü" chip
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _CategoryChip(
                    label: 'Tümü',
                    color: cs.primary,
                    isSelected: selectedId == null,
                    onTap: () => onSelect(null),
                  ),
                ),
                ...categories.map((cat) {
                  final id = cat['id']?.toString();
                  final name = cat['name_tr'] ?? cat['name_en'] ?? '';
                  final color = parseColor(cat['color'] as String?);
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _CategoryChip(
                      label: name,
                      color: color,
                      isSelected: selectedId == id,
                      onTap: () => onSelect(id),
                    ),
                  );
                }),
              ],
            ),
          ),
          Divider(height: 1, color: cs.outlineVariant),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withAlpha(30),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : color.withAlpha(80),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : color,
          ),
        ),
      ),
    );
  }
}
