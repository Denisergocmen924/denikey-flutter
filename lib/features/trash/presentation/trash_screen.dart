import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/trash_provider.dart';
import 'package:denikey_app/l10n/generated/app_localizations.dart';
import '../../../core/presentation/app_animations.dart';
import '../../../core/presentation/app_tiles.dart';

class TrashScreen extends ConsumerStatefulWidget {
  const TrashScreen({super.key});

  @override
  ConsumerState<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends ConsumerState<TrashScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(trashProvider.notifier).load());
  }

  Future<void> _confirmEmptyTrash() async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.trashEmptyTitle),
        content: Text(l10n.trashEmptyMessage),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.trashCancel)),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(ctx).colorScheme.error),
            child: Text(l10n.trashEmptyButton),
          ),
        ],
      ),
    );
    if (ok == true) ref.read(trashProvider.notifier).emptyTrash();
  }

  Future<void> _confirmDelete(String trashId, String title) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.trashDeleteTitle),
        content: Text(l10n.trashDeleteMessage(title)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.trashCancel)),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(ctx).colorScheme.error),
            child: Text(l10n.trashDeleteButton),
          ),
        ],
      ),
    );
    if (ok == true) ref.read(trashProvider.notifier).deletePermanently(trashId);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(trashProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.trashTitle),
        actions: [
          if (state.items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: l10n.trashEmptyButton,
              onPressed: _confirmEmptyTrash,
            ),
        ],
      ),
      body: _buildBody(state, l10n),
    );
  }

  Widget _buildBody(TrashState state, AppLocalizations l10n) {
    if (state.status == TrashStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == TrashStatus.error) {
      return AppErrorState(
        message: state.error ?? l10n.trashError,
        retryLabel: l10n.trashRetry,
        onRetry: () => ref.read(trashProvider.notifier).load(),
      );
    }

    if (state.items.isEmpty) {
      return AppEmptyState(
        icon: Icons.delete_outline,
        title: l10n.trashEmpty,
        subtitle: l10n.trashEmptyHint,
        accent: kTeal,
      ).animate().fadeIn(duration: AppAnim.slow, curve: AppAnim.smooth);
    }

    final cs = Theme.of(context).colorScheme;

    return RefreshIndicator(
      onRefresh: () => ref.read(trashProvider.notifier).load(),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        itemCount: state.items.length,
        separatorBuilder: (context, idx) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final entry = state.items[index];
          final trashId = entry['trash_id'] as String;
          final item = entry['item'] as Map<String, dynamic>;
          final title = item['title'] as String? ?? l10n.vaultItemUntitled;
          final permanentDeleteAt = entry['permanent_delete_at'] as String?;

          return AppListCard(
            child: Row(
              children: [
                const DuotoneIcon(Icons.delete_outline, color: Colors.redAccent),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                      if (permanentDeleteAt != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          l10n.trashDeleteFor(_formatDate(permanentDeleteAt)),
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFFFFB020)),
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.restore_outlined, size: 20),
                  color: kTeal,
                  tooltip: l10n.trashRestore,
                  onPressed: () =>
                      ref.read(trashProvider.notifier).restore(trashId),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_forever_outlined, size: 20),
                  color: cs.error,
                  tooltip: l10n.trashDeletePermanent,
                  onPressed: () => _confirmDelete(trashId, title),
                ),
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

  String _formatDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate).toLocal();
      return '${dt.day}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
    } catch (_) {
      return '';
    }
  }
}
