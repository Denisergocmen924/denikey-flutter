import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/vault_provider.dart';

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
    final state = ref.watch(vaultProvider);
    final results = _filter(state.items);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _ctrl,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Ara...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white70),
          ),
          style: const TextStyle(color: Colors.white),
          onChanged: (v) => setState(() => _query = v),
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
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
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.search, size: 64, color: Colors.grey),
                      SizedBox(height: 12),
                      Text('Aramak için yazmaya başlayın', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : results.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.search_off, size: 64, color: Colors.grey),
                          const SizedBox(height: 12),
                          Text('"$_query" için sonuç bulunamadı',
                              style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: results.length,
                      itemBuilder: (ctx, i) {
                        final item = results[i];
                        final title = item['title'] as String? ?? 'İsimsiz';
                        final username = item['username'] as String? ?? '';
                        final type = item['item_type_name'] as String?;
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.deepPurple.withAlpha(25),
                            child: Icon(
                              _iconForType(type),
                              color: Colors.deepPurple,
                              size: 20,
                            ),
                          ),
                          title: _HighlightText(text: title, query: _query),
                          subtitle: username.isNotEmpty
                              ? _HighlightText(text: username, query: _query, style: const TextStyle(fontSize: 12))
                              : null,
                          onTap: () => context.push('/vault/detail', extra: item),
                        );
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
              backgroundColor: Colors.deepPurple.withAlpha(60),
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
