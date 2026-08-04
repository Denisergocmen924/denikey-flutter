import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/crypto/encryption_service.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../core/providers/clipboard_timeout_provider.dart';
import 'package:denikey_app/l10n/generated/app_localizations.dart';
import '../../../core/presentation/app_animations.dart';
import '../../../core/presentation/app_tiles.dart';

class PasswordHistoryScreen extends ConsumerStatefulWidget {
  final String itemId;
  final String itemTitle;

  const PasswordHistoryScreen({
    super.key,
    required this.itemId,
    required this.itemTitle,
  });

  @override
  ConsumerState<PasswordHistoryScreen> createState() => _PasswordHistoryScreenState();
}

class _PasswordHistoryScreenState extends ConsumerState<PasswordHistoryScreen> {
  List<Map<String, dynamic>> _history = [];
  bool _loading = true;
  String? _error;
  final Set<int> _revealed = {};
  Timer? _clipboardTimer;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final dio = DioClient.instance.dio;
      final response =
          await dio.get('/api/v1/vault/items/${widget.itemId}/history');

      final masterKey = await SecureStorage.instance.getMasterKey();
      final rawList = List<Map<String, dynamic>>.from(response.data);
      final decrypted = <Map<String, dynamic>>[];

      for (final h in rawList) {
        final encPwd = h['encrypted_old_password'] as String? ?? '';
        String plain = '';
        if (masterKey != null && encPwd.isNotEmpty) {
          try {
            plain = await EncryptionService.instance.decryptCombined(encPwd, masterKey);
          } catch (_) {}
        }
        decrypted.add({...h, 'decrypted': plain});
      }

      if (mounted) setState(() { _history = decrypted; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = AppLocalizations.of(context).passwordHistoryError; _loading = false; });
    }
  }

  Future<void> _clearHistory() async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.passwordHistoryClearTitle),
        content: Text(l10n.passwordHistoryClearMessage),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.addItemCancel)),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(ctx).colorScheme.error),
            child: Text(l10n.passwordHistoryClear),
          ),
        ],
      ),
    );
    if (ok != true) return;

    try {
      await DioClient.instance.dio
          .delete('/api/v1/vault/items/${widget.itemId}/history');
      if (mounted) setState(() => _history = []);
    } catch (_) {}
  }

  @override
  void dispose() {
    _clipboardTimer?.cancel();
    super.dispose();
  }

  void _copyToClipboard(String value) {
    final l10n = AppLocalizations.of(context);
    final timeout = ref.read(clipboardTimeoutProvider);
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          timeout != null
              ? l10n.passwordHistoryCopy(timeout)
              : l10n.passwordHistoryCopyNoTimeout,
        ),
      ),
    );
    _clipboardTimer?.cancel();
    if (timeout != null) {
      _clipboardTimer = Timer(Duration(seconds: timeout), () {
        Clipboard.setData(const ClipboardData(text: ''));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.passwordHistoryTitle(widget.itemTitle)),
        actions: [
          if (_history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: l10n.passwordHistoryClear,
              onPressed: _clearHistory,
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final l10n = AppLocalizations.of(context);
    if (_loading) return const Center(child: CircularProgressIndicator());

    if (_error != null) {
      return AppErrorState(
        message: _error!,
        retryLabel: l10n.passwordHistoryRetry,
        onRetry: _load,
      );
    }

    if (_history.isEmpty) {
      return AppEmptyState(
        icon: Icons.history,
        title: l10n.passwordHistoryEmpty,
        subtitle: l10n.passwordHistoryEmptyHint,
        accent: kTeal,
      ).animate().fadeIn(duration: AppAnim.slow, curve: AppAnim.smooth);
    }

    final cs = Theme.of(context).colorScheme;

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      itemCount: _history.length,
      separatorBuilder: (context, idx) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final h = _history[i];
        final decrypted = h['decrypted'] as String? ?? '';
        final changedAt = h['changed_at'] as String?;
        final isRevealed = _revealed.contains(i);

        return AppListCard(
          padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
          child: Row(
            children: [
              // Sürüm numarası — en yeni kayıt en üstte, en büyük numarayı alır
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [kBlaze.withAlpha(55), kBlaze.withAlpha(20)],
                  ),
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(color: kBlaze.withAlpha(55)),
                ),
                child: Text(
                  '${_history.length - i}',
                  style: const TextStyle(
                      color: kBlaze,
                      fontSize: 14,
                      fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isRevealed ? decrypted : '••••••••••',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 14,
                          fontWeight: FontWeight.w600),
                    ),
                    if (changedAt != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        _formatDate(changedAt),
                        style: TextStyle(
                          fontSize: 11.5,
                          fontFeatures: const [FontFeature.tabularFigures()],
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                iconSize: 20,
                icon: Icon(
                    isRevealed ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() {
                  if (isRevealed) { _revealed.remove(i); }
                  else { _revealed.add(i); }
                }),
              ),
              IconButton(
                iconSize: 20,
                icon: const Icon(Icons.copy),
                color: kTeal,
                onPressed: () => _copyToClipboard(decrypted),
              ),
            ],
          ),
        )
            .animate(delay: AppAnim.listDelay(i))
            .fadeIn(duration: AppAnim.normal)
            .slideY(begin: 0.12, curve: AppAnim.smooth);
      },
    );
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.day}.${dt.month.toString().padLeft(2, '0')}.${dt.year} '
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }
}
