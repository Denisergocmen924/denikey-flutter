import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:denikey_app/l10n/generated/app_localizations.dart';
import '../providers/vault_provider.dart';
import '../data/vault_repository.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/presentation/app_animations.dart';
import '../../../core/presentation/app_tiles.dart';
import '../../../core/providers/clipboard_timeout_provider.dart';
import '../../categories/providers/category_provider.dart';
import 'password_history_screen.dart';

class VaultItemDetailScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> item;
  const VaultItemDetailScreen({super.key, required this.item});

  @override
  ConsumerState<VaultItemDetailScreen> createState() =>
      _VaultItemDetailScreenState();
}

class _VaultItemDetailScreenState extends ConsumerState<VaultItemDetailScreen> {
  String? _decryptedPassword;
  bool _decrypting = true;
  bool _showPassword = false;
  final Map<int, bool> _showCustomField = {}; // her custom field için ayrı görünürlük
  List<dynamic> _customFields = [];
  Map<String, dynamic> _fullItem = {};
  Timer? _clipboardTimer;

  // Edit modu
  bool _isEditing = false;
  bool _saving = false;
  String? _saveError;

  // Link açma onayı — "bir daha sorma" tercihi
  bool _linkNoAsk = false;

  final _titleCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  // custom fields — her biri {key: ctrl, value: ctrl}
  final List<Map<String, TextEditingController>> _editCustomFields = [];
  final List<String> _editFieldTypes = []; // _editCustomFields ile paralel, field_type saklar

  @override
  void initState() {
    super.initState();
    _loadItem();
    _loadLinkPref();
  }

  Future<void> _loadLinkPref() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) setState(() => _linkNoAsk = prefs.getBool('link_no_ask') ?? false);
  }

  @override
  void dispose() {
    _clipboardTimer?.cancel();
    _titleCtrl.dispose();
    _passwordCtrl.dispose();
    _disposeCustomFieldCtrls();
    super.dispose();
  }

  void _disposeCustomFieldCtrls() {
    for (final f in _editCustomFields) {
      f['key']!.dispose();
      f['value']!.dispose();
    }
  }

  Future<void> _loadItem() async {
    try {
      final dio = DioClient.instance.dio;
      final itemId = widget.item['id'].toString();
      final response = await dio.get('/api/v1/vault/items/$itemId');
      final fullItem = Map<String, dynamic>.from(response.data);

      final decrypted = await VaultRepository().getItemDecrypted(fullItem);

      if (mounted) {
        setState(() {
          _fullItem = fullItem;
          _decryptedPassword = decrypted['decrypted_password'] as String?;
          _customFields = decrypted['custom_fields'] as List<dynamic>? ?? [];
          _decrypting = false;
        });
        _fillControllers();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _decrypting = false;
          _saveError = AppLocalizations.of(context).detailLoadError(e.toString());
        });
      }
    }
  }

  void _fillControllers() {
    _titleCtrl.text = _fullItem['title'] as String? ?? '';
    _passwordCtrl.text = _decryptedPassword ?? '';

    // Mevcut custom field controller'larını temizle
    _disposeCustomFieldCtrls();
    _editCustomFields.clear();
    _editFieldTypes.clear();

    // Mevcut custom field'ları yükle
    for (final field in _customFields) {
      _editCustomFields.add({
        'key': TextEditingController(text: field['field_name'] as String? ?? ''),
        'value': TextEditingController(text: field['decrypted_value'] as String? ?? ''),
      });
      _editFieldTypes.add(field['field_type'] as String? ?? 'text');
    }
  }

  void _addEditCustomField() {
    setState(() {
      _editCustomFields.add({
        'key': TextEditingController(),
        'value': TextEditingController(),
      });
      _editFieldTypes.add('text');
    });
  }

  void _removeEditCustomField(int index) {
    setState(() {
      _editCustomFields[index]['key']!.dispose();
      _editCustomFields[index]['value']!.dispose();
      _editCustomFields.removeAt(index);
      if (index < _editFieldTypes.length) _editFieldTypes.removeAt(index);
    });
  }

  void _cancelEdit() {
    _fillControllers();
    setState(() {
      _isEditing = false;
      _saveError = null;
      _showPassword = false;
    });
  }

  Future<void> _saveEdit() async {
    final l10n = AppLocalizations.of(context);
    if (_titleCtrl.text.trim().isEmpty) {
      setState(() => _saveError = l10n.detailEditErrorBlankTitle);
      return;
    }
    setState(() { _saving = true; _saveError = null; });

    try {
      final data = <String, dynamic>{
        'title': _titleCtrl.text.trim(),
        'password': _passwordCtrl.text.trim(),
      };

      final customFieldsList = <Map<String, String>>[];
      for (int i = 0; i < _editCustomFields.length; i++) {
        final f = _editCustomFields[i];
        final k = f['key']!.text.trim();
        final v = f['value']!.text.trim();
        if (k.isNotEmpty) {
          final ft = i < _editFieldTypes.length ? _editFieldTypes[i] : 'text';
          customFieldsList.add({'field_name': k, 'value': v, 'field_type': ft});
        }
      }
      data['custom_fields_data'] = customFieldsList;

      await ref.read(vaultProvider.notifier).updateItem(
        _fullItem['id'].toString(),
        data,
      );

      await _loadItem();
      if (mounted) setState(() { _isEditing = false; _showPassword = false; });
    } catch (_) {
      if (mounted) setState(() => _saveError = l10n.detailEditErrorGeneral);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  bool _isUrl(String value) =>
      value.startsWith('http://') || value.startsWith('https://');

  Future<void> _openLink(String url) async {
    if (_linkNoAsk) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      return;
    }

    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.detailExternalLinkTitle),
        content: Text(
          l10n.detailExternalLinkMessage(url),
          style: const TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'cancel'),
            child: Text(l10n.detailExternalLinkDeny),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'once'),
            child: Text(l10n.detailExternalLinkOnce),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, 'noask'),
            child: Text(l10n.detailExternalLinkNoAsk),
          ),
        ],
      ),
    );

    if (result == 'noask') {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('link_no_ask', true);
      if (mounted) setState(() => _linkNoAsk = true);
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else if (result == 'once') {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  void _copyToClipboard(String value, String label) {
    final l10n = AppLocalizations.of(context);
    final timeout = ref.read(clipboardTimeoutProvider);
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          timeout != null
              ? l10n.detailInfoTilePasswordCopied(label, timeout)
              : l10n.detailInfoTileCopied(label),
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

  void _confirmDelete() {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.detailDeleteTitle),
        content: Text(l10n.detailDeleteMessage),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.detailCancelEdit)),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(vaultProvider.notifier).deleteItem(widget.item['id'].toString());
              if (mounted) Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(ctx).colorScheme.error),
            child: Text(l10n.detailDeleteButton),
          ),
        ],
      ),
    );
  }

  Future<void> _showCategoryPicker() async {
    final l10n = AppLocalizations.of(context);
    final categoryState = ref.read(categoryProvider);
    if (categoryState.categories.isEmpty) {
      await ref.read(categoryProvider.notifier).loadCategories();
    }
    if (!mounted) return;

    final categories = ref.read(categoryProvider).categories;
    final currentCategoryId = _fullItem['category_id'] as String?;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 16),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: cs.onSurfaceVariant.withAlpha(70),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: AppSectionTitle(l10n.detailCategoryMove),
                ),
                _categoryOption(
                  ctx: ctx,
                  icon: Icons.folder_off_outlined,
                  accent: cs.onSurfaceVariant,
                  label: l10n.detailCategoryUncategorized,
                  selected: currentCategoryId == null,
                  onTap: () async {
                    Navigator.pop(ctx);
                    await ref.read(vaultProvider.notifier).updateItem(
                      _fullItem['id'].toString(),
                      {'category_id': null},
                    );
                    setState(() => _fullItem['category_id'] = null);
                  },
                ),
                ...categories.map((cat) {
                  final catId = cat['id'] as String?;
                  final name = cat['name_tr'] as String? ?? cat['name_en'] ?? '';
                  return _categoryOption(
                    ctx: ctx,
                    icon: Icons.folder_outlined,
                    accent: kBlaze,
                    label: name,
                    selected: catId == currentCategoryId,
                    onTap: () async {
                      Navigator.pop(ctx);
                      await ref.read(vaultProvider.notifier).updateItem(
                        _fullItem['id'].toString(),
                        {'category_id': catId},
                      );
                      setState(() => _fullItem['category_id'] = catId);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _categoryOption({
    required BuildContext ctx,
    required IconData icon,
    required Color accent,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppListCard(
        onTap: onTap,
        accent: selected ? accent : null,
        child: Row(
          children: [
            DuotoneIcon(icon, color: accent, size: 34),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
            if (selected) Icon(Icons.check, size: 20, color: accent),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(String label, String? value, {
    bool isSecret = false,
    bool showSecret = false,
    VoidCallback? onToggleSecret,
    int index = 0,
  }) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    final cs = Theme.of(context).colorScheme;
    final isLink = !isSecret && _isUrl(value);
    final accent = isSecret ? kBlaze : (isLink ? const Color(0xFF4FC3F7) : kTeal);
    final hidden = isSecret && !showSecret;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppListCard(
        accent: isSecret && showSecret ? kBlaze : null,
        padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
        child: Row(
          children: [
            DuotoneIcon(
              isSecret
                  ? Icons.key_outlined
                  : (isLink ? Icons.link : Icons.short_text),
              color: accent,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.9,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hidden ? '••••••••••' : value,
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w600,
                      // Gizli/açık sır ve linkler dar aralıklı monospace ile
                      // daha okunur (karakter karışması azalır)
                      fontFamily: isSecret ? 'monospace' : null,
                      letterSpacing: isSecret && !hidden ? 0.6 : null,
                      color: isLink ? const Color(0xFF4FC3F7) : cs.onSurface,
                      decoration: isLink ? TextDecoration.underline : null,
                      decorationColor: const Color(0xFF4FC3F7),
                    ),
                  ),
                ],
              ),
            ),
            if (isSecret)
              IconButton(
                iconSize: 20,
                color: cs.onSurfaceVariant,
                icon: Icon(showSecret ? Icons.visibility_off : Icons.visibility),
                onPressed: onToggleSecret,
              ),
            if (isLink)
              IconButton(
                iconSize: 20,
                color: cs.onSurfaceVariant,
                icon: const Icon(Icons.open_in_new),
                tooltip: AppLocalizations.of(context).detailLinkOpen,
                onPressed: () => _openLink(value),
              ),
            IconButton(
              iconSize: 20,
              color: cs.onSurfaceVariant,
              icon: const Icon(Icons.copy),
              onPressed: () => _copyToClipboard(value, label),
            ),
          ],
        ),
      )
          .animate(delay: AppAnim.listDelay(index))
          .fadeIn(duration: AppAnim.normal)
          .slideY(begin: 0.1, curve: AppAnim.smooth),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = _fullItem['title'] as String? ?? widget.item['title'] ?? l10n.vaultItemDetailFallbackTitle;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: _isEditing
            ? [
                TextButton(
                  onPressed: _saving ? null : _cancelEdit,
                  child: Text(l10n.detailCancelEdit),
                ),
              ]
            : [
                IconButton(
                  icon: Icon(
                    _fullItem['is_favorite'] == true
                        ? Icons.star
                        : Icons.star_border,
                    color: _fullItem['is_favorite'] == true
                        ? Colors.amber.shade600
                        : null,
                  ),
                  tooltip: _fullItem['is_favorite'] == true
                      ? l10n.detailFavoritesRemove
                      : l10n.detailFavoritesAdd,
                  onPressed: _decrypting ? null : () {
                    final isFav = _fullItem['is_favorite'] == true;
                    setState(() => _fullItem['is_favorite'] = !isFav);
                    ref.read(vaultProvider.notifier).toggleFavorite(
                      _fullItem['id'].toString(),
                      !isFav,
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.history_outlined),
                  tooltip: l10n.detailPasswordHistory,
                  onPressed: _decrypting ? null : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PasswordHistoryScreen(
                          itemId: _fullItem['id'].toString(),
                          itemTitle: _fullItem['title'] as String? ?? '',
                        ),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: l10n.detailEditButton,
                  onPressed: _decrypting ? null : () => setState(() => _isEditing = true),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: _confirmDelete,
                ),
              ],
      ),
      body: _decrypting
          ? const Center(child: CircularProgressIndicator())
          : _isEditing
              ? _buildEditForm()
              : _buildViewMode(),
    );
  }

  Widget _buildViewMode() {
    final l10n = AppLocalizations.of(context);
    if (_saveError != null) {
      return AppErrorState(
        message: _saveError!,
        retryLabel: l10n.detailRetry,
        onRetry: () {
          setState(() => _saveError = null);
          _loadItem();
        },
      );
    }

    final categories = ref.watch(categoryProvider).categories;
    final currentCategoryId = _fullItem['category_id'] as String?;
    final currentCategory = currentCategoryId != null
        ? categories.firstWhere(
            (c) => c['id'] == currentCategoryId,
            orElse: () => <String, dynamic>{},
          )
        : null;
    final categoryName = currentCategory != null && currentCategory.isNotEmpty
        ? (currentCategory['name_tr'] as String? ?? currentCategory['name_en'] ?? '')
        : null;

    final cs = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      children: [
        // Klasör satırı
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: AppListCard(
            onTap: _showCategoryPicker,
            child: Row(
              children: [
                DuotoneIcon(
                  Icons.folder_outlined,
                  color: categoryName != null ? kBlaze : cs.onSurfaceVariant,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.detailCategoryLabel.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.9,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        categoryName ?? l10n.detailCategoryUncategorized,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w600,
                          color: categoryName != null
                              ? cs.onSurface
                              : cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, size: 20, color: cs.onSurfaceVariant),
              ],
            ),
          )
              .animate()
              .fadeIn(duration: AppAnim.normal)
              .slideY(begin: 0.1, curve: AppAnim.smooth),
        ),
        _infoTile(l10n.detailPasswordLabel, _decryptedPassword,
          isSecret: true,
          showSecret: _showPassword,
          onToggleSecret: () => setState(() => _showPassword = !_showPassword),
          index: 1,
        ),
        if (_customFields.isNotEmpty) ...[
          const SizedBox(height: 6),
          ..._customFields.asMap().entries.map((entry) {
            final i = entry.key;
            final field = entry.value;
            final fieldName = field['field_name'] as String? ?? '';
            final fieldValue = field['decrypted_value'] as String? ?? '';
            final isSecret = field['field_type'] == 'secret';
            return _infoTile(fieldName, fieldValue,
              isSecret: isSecret,
              showSecret: _showCustomField[i] ?? !isSecret,
              onToggleSecret: () => setState(() =>
                _showCustomField[i] = !(_showCustomField[i] ?? !isSecret)),
              index: i + 2,
            );
          }),
        ],
      ],
    );
  }

  Widget _buildEditForm() {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Başlık
          TextField(
            controller: _titleCtrl,
            decoration: InputDecoration(
              labelText: l10n.detailEditTitle,
              prefixIcon: const Icon(Icons.title, size: 20),
            ),
          )
              .animate()
              .fadeIn(duration: AppAnim.normal)
              .slideY(begin: 0.1, curve: AppAnim.smooth),
          const SizedBox(height: 12),

          // Şifre
          TextField(
            controller: _passwordCtrl,
            obscureText: !_showPassword,
            style: const TextStyle(fontFamily: 'monospace', letterSpacing: 0.6),
            decoration: InputDecoration(
              labelText: l10n.detailEditPassword,
              prefixIcon: const Icon(Icons.key_outlined, size: 20),
              suffixIcon: IconButton(
                icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _showPassword = !_showPassword),
              ),
            ),
          )
              .animate(delay: AppAnim.entranceDelay(1))
              .fadeIn(duration: AppAnim.normal)
              .slideY(begin: 0.1, curve: AppAnim.smooth),
          const SizedBox(height: 18),

          // Mevcut + yeni custom fields
          ..._editCustomFields.asMap().entries.map((entry) {
            final i = entry.key;
            final f = entry.value;
            final fieldType = i < _editFieldTypes.length ? _editFieldTypes[i] : 'text';
            final isFieldSecret = fieldType == 'secret';
            final showFieldValue = _showCustomField[i] ?? false;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: cs.surfaceContainerLow,
                  border: Border.all(color: cs.outlineVariant),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          TextField(
                            controller: f['key'],
                            decoration: InputDecoration(
                              labelText: l10n.detailEditCustomFieldKeyLabel,
                              isDense: true,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: f['value'],
                            obscureText: isFieldSecret && !showFieldValue,
                            decoration: InputDecoration(
                              labelText: l10n.detailEditCustomFieldValueLabel,
                              isDense: true,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  isFieldSecret ? Icons.visibility_off : Icons.visibility,
                                ),
                                onPressed: () => setState(() {
                                  final nowSecret = !isFieldSecret;
                                  if (i < _editFieldTypes.length) {
                                    _editFieldTypes[i] = nowSecret ? 'secret' : 'text';
                                  }
                                  _showCustomField[i] = !nowSecret;
                                }),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      color: cs.error,
                      onPressed: () => _removeEditCustomField(i),
                    ),
                  ],
                ),
              ),
            )
                .animate(delay: AppAnim.listDelay(i))
                .fadeIn(duration: AppAnim.normal)
                .slideY(begin: 0.1, curve: AppAnim.smooth);
          }),

          // Alan ekle butonu
          OutlinedButton.icon(
            onPressed: _addEditCustomField,
            icon: const Icon(Icons.add),
            label: Text(l10n.addItemAddFieldButton),
            style: OutlinedButton.styleFrom(
              foregroundColor: kBlaze,
              side: BorderSide(color: kBlaze.withAlpha(90)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
          const SizedBox(height: 24),

          if (_saveError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(_saveError!,
                style: TextStyle(color: cs.error, fontSize: 13)),
            ),

          // Kaydet
          FilledButton(
            onPressed: _saving ? null : _saveEdit,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _saving
                ? const SizedBox(height: 20, width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(l10n.detailEditSaveButton, style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
