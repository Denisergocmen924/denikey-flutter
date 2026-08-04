import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../providers/vault_provider.dart';
import 'package:denikey_app/l10n/generated/app_localizations.dart';
import '../../../core/presentation/app_animations.dart';
import '../../../core/presentation/app_tiles.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _ctrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
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

  List<Map<String, dynamic>> _filter(List<Map<String, dynamic>> items) {
    if (_query.isEmpty) return items;
    final q = _query.toLowerCase();
    return items.where((item) {
      final title    = (item['title'] as String? ?? '').toLowerCase();
      final username = (item['username'] as String? ?? '').toLowerCase();
      final url      = (item['url'] as String? ?? '').toLowerCase();
      final notes    = (item['notes'] as String? ?? '').toLowerCase();
      return title.contains(q) || username.contains(q) || url.contains(q) || notes.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(vaultProvider);
    final results = _filter(state.items);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _ctrl,
          autofocus: true,
          decoration: InputDecoration(
            hintText: l10n.searchHint,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
            contentPadding: EdgeInsets.zero,
            prefixIcon: Icon(Icons.search, size: 20, color: cs.onSurfaceVariant),
            prefixIconConstraints:
                const BoxConstraints(minWidth: 32, minHeight: 20),
            hintStyle: TextStyle(color: cs.onSurfaceVariant),
          ),
          style: TextStyle(color: cs.onSurface, fontSize: 16),
          onChanged: (v) => setState(() => _query = v),
        ),
        actions: [
          if (_query.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _ctrl.clear();
                setState(() => _query = '');
              },
            ),
        ],
      ),
      body: state.status == VaultStatus.loading
          ? const Center(child: CircularProgressIndicator())
          : _query.isEmpty
              ? AppEmptyState(
                  icon: Icons.search,
                  title: l10n.searchEmpty,
                  accent: kTeal,
                ).animate().fadeIn(
                    duration: AppAnim.slow, curve: AppAnim.smooth)
              : results.isEmpty
                  ? AppEmptyState(
                      icon: Icons.search_off,
                      title: l10n.searchNoResults(_query),
                      accent: kTeal,
                    ).animate().fadeIn(duration: AppAnim.normal)
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                      itemCount: results.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (ctx, i) {
                        final item = results[i];
                        final l10n = AppLocalizations.of(ctx);
                        final title = item['title'] as String? ?? l10n.vaultItemUntitled;
                        final username = item['username'] as String? ?? '';
                        final type = item['item_type_name'] as String?;
                        return AppListCard(
                          onTap: () =>
                              context.push('/vault/detail', extra: item),
                          child: Row(
                            children: [
                              DuotoneIcon(_iconForType(type)),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    _HighlightText(
                                      text: title,
                                      query: _query,
                                      style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    if (username.isNotEmpty) ...[
                                      const SizedBox(height: 3),
                                      _HighlightText(
                                        text: username,
                                        query: _query,
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
                            .animate(delay: AppAnim.listDelay(i))
                            .fadeIn(duration: AppAnim.normal)
                            .slideY(begin: 0.12, curve: AppAnim.smooth);
                      },
                    ),
    );
  }
}

class _HighlightText extends StatelessWidget {
  final String text;
  final String query;
  final TextStyle? style;

  const _HighlightText({required this.text, required this.query, this.style});

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) return Text(text, style: style);
    final lower = text.toLowerCase();
    final idx = lower.indexOf(query.toLowerCase());
    if (idx < 0) return Text(text, style: style);

    final base = style ?? DefaultTextStyle.of(context).style;
    return RichText(
      text: TextSpan(
        style: base,
        children: [
          TextSpan(text: text.substring(0, idx)),
          TextSpan(
            text: text.substring(idx, idx + query.length),
            style: base.copyWith(
              backgroundColor: kBlaze.withAlpha(60),
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(text: text.substring(idx + query.length)),
        ],
      ),
      overflow: TextOverflow.ellipsis,
    );
  }
}
