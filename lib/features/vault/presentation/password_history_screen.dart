import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/crypto/encryption_service.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../core/providers/clipboard_timeout_provider.dart';
import 'package:denikey_app/l10n/generated/app_localizations.dart';

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
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
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
    final timeout = ref.read(clipboardTimeoutProvider);
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).passwordHistoryCopy)),
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(_error!),
            const SizedBox(height: 12),
            FilledButton(onPressed: _load, child: Text(l10n.passwordHistoryRetry)),
          ],
        ),
      );
    }

    if (_history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.history, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(l10n.passwordHistoryEmpty,
                style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 8),
            Text(l10n.passwordHistoryEmptyHint,
                style: const TextStyle(fontSize: 13, color: Colors.grey),
                textAlign: TextAlign.center),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _history.length,
      separatorBuilder: (context, idx) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final h = _history[i];
        final decrypted = h['decrypted'] as String? ?? '';
        final changedAt = h['changed_at'] as String?;
        final isRevealed = _revealed.contains(i);

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFFFF5900).withAlpha(25),
              child: Text(
                '${_history.length - i}',
                style: const TextStyle(
                    color: Color(0xFFFF5900), fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(
              isRevealed ? decrypted : '••••••••',
              style: const TextStyle(
                  fontFamily: 'monospace', fontWeight: FontWeight.w500),
            ),
            subtitle: changedAt != null
                ? Text(_formatDate(changedAt),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600))
                : null,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(isRevealed ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() {
                    if (isRevealed) { _revealed.remove(i); }
                    else { _revealed.add(i); }
                  }),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, size: 20),
                  onPressed: () => _copyToClipboard(decrypted),
                ),
              ],
            ),
          ),
        );
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
