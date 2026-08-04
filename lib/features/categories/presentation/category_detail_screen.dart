import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../vault/providers/vault_provider.dart';
import 'package:denikey_app/l10n/generated/app_localizations.dart';
import '../../../core/presentation/app_animations.dart';
import '../../../core/presentation/app_tiles.dart';

class CategoryDetailScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> category;
  const CategoryDetailScreen({super.key, required this.category});

  @override
  ConsumerState<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends ConsumerState<CategoryDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(vaultProvider.notifier).loadItems());
  }

  Color _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return kBlaze;
    try {
      final h = hex.replaceAll('#', '');
      return Color(int.parse('FF$h', radix: 16));
    } catch (_) {
      return kBlaze;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final vaultState = ref.watch(vaultProvider);
    final categoryId = widget.category['id'] as String;
    final categoryName = widget.category['name_tr'] ?? widget.category['name_en'] ?? '';
    final color = _parseColor(widget.category['color'] as String?);

    // Bu kategoriye ait item'ları filtrele
    final items = vaultState.items.where((item) => item['category_id'] == categoryId).toList();

    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName),
        // Kategori rengi zemine değil alttaki ince şeride uygulanır —
        // dolu renkli app bar koyu temanın dengesini bozuyordu.
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(height: 3, color: color),
        ),
      ),
      body: vaultState.status == VaultStatus.loading
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
              ? AppEmptyState(
                  icon: Icons.lock_open_outlined,
                  title: l10n.categoryDetailEmpty,
                  accent: color,
                ).animate().fadeIn(
                    duration: AppAnim.slow, curve: AppAnim.smooth)
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final subtitle = item['username'] ?? item['url'] ?? '';

                    return AppListCard(
                      onTap: () => context.push('/vault/detail', extra: item),
                      child: Row(
                        children: [
                          DuotoneIcon(Icons.lock_outline, color: color),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['title'] ?? l10n.categoryDetailItem,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600),
                                ),
                                if (subtitle.toString().isNotEmpty) ...[
                                  const SizedBox(height: 3),
                                  Text(
                                    subtitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 12.5,
                                        color: cs.onSurfaceVariant),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right,
                              size: 20, color: cs.onSurfaceVariant),
                        ],
                      ),
                    )
                        .animate(delay: AppAnim.listDelay(index))
                        .fadeIn(duration: AppAnim.normal)
                        .slideY(begin: 0.12, curve: AppAnim.smooth);
                  },
                ),
    );
  }
}
