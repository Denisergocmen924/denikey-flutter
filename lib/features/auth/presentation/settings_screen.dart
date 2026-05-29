import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/auth_repository.dart';
import '../providers/profile_provider.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/providers/shortcuts_provider.dart';
import '../../../core/providers/auto_lock_provider.dart';
import '../../../core/providers/clipboard_timeout_provider.dart';
import '../../../core/providers/app_version_provider.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/biometric/biometric_service.dart';
import '../../../core/presentation/app_nav_bar.dart';
import '../../../core/presentation/app_shortcuts.dart';
import '../../devices/data/device_repository.dart';
import '../../devices/providers/device_provider.dart';
import 'package:denikey_app/l10n/generated/app_localizations.dart';
import '../providers/totp_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

const _kTotpTrustOptions = [0, 43200, 86400, 604800, 2592000, 5184000];

String _totpTrustLabel(AppLocalizations l10n, int seconds) {
  switch (seconds) {
    case 0:      return l10n.totpTrustAlways;
    case 43200:  return l10n.totpTrust12h;
    case 86400:  return l10n.totpTrust1d;
    case 604800: return l10n.totpTrust7d;
    case 2592000: return l10n.totpTrust30d;
    case 5184000: return l10n.totpTrust60d;
    default:     return l10n.totpTrustAlways;
  }
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _repo = AuthRepository();
  String? _email;
  bool _loggingOut = false;
  bool _deletingAccount = false;
  bool _biometricAvailable = false;
  bool _biometricEnabled = false;
  int _biometricRemainingDays = 0;

  @override
  void initState() {
    super.initState();
    _loadEmail();
    _loadBiometricState();
    Future.microtask(() => ref.read(profileProvider.notifier).loadProfile());
  }

  Future<void> _loadEmail() async {
    final email = await SecureStorage.instance.getEmail();
    if (mounted) setState(() => _email = email);
  }

  Future<void> _loadBiometricState() async {
    final available = await BiometricService.instance.isAvailable();
    final enabled = await BiometricService.instance.isEnabled();
    final days = enabled ? await BiometricService.instance.remainingDays() : 0;
    if (mounted) {
      setState(() {
        _biometricAvailable = available;
        _biometricEnabled = enabled;
        _biometricRemainingDays = days;
      });
    }
  }

  Future<void> _toggleBiometric(bool val) async {
    await BiometricService.instance.setEnabled(val);
    final days = val ? await BiometricService.instance.remainingDays() : 0;
    setState(() {
      _biometricEnabled = val;
      _biometricRemainingDays = days;
    });
  }

  Future<void> _showTotpDisableDialog(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final ctrl = TextEditingController();
    String? err;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: Text(l10n.totpDisableTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.totpDisableDesc, style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 16),
              TextField(
                controller: ctrl,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: l10n.totpDisableMasterPasswordLabel,
                  errorText: err,
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () async {
                try {
                  await _repo.totpDisable(masterPassword: ctrl.text);
                  ref.invalidate(totpStatusProvider);
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.totpDisabledSuccess)),
                    );
                  }
                } catch (_) {
                  setS(() => err = l10n.totpDisableMasterPasswordError);
                }
              },
              child: Text(l10n.totpDisableConfirm),
            ),
          ],
        ),
      ),
    );
    ctrl.dispose();
  }

  Future<void> _startDeleteAccountFlow() async {
    final l10n = AppLocalizations.of(context);

    // Adım 1: Kullanıcı adı
    final usernameCtrl = TextEditingController();
    final usernameOk = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.settingsDeleteAccountStep1),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.settingsDeleteAccountWarningContent,
              style: const TextStyle(color: Colors.red, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: usernameCtrl,
              decoration: InputDecoration(
                labelText: l10n.settingsDeleteAccountUsernameHint,
                border: const OutlineInputBorder(),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.settingsDeleteAccountCancel)),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              if (usernameCtrl.text.trim().isNotEmpty) Navigator.pop(ctx, true);
            },
            child: Text(l10n.settingsDeleteAccountContinue),
          ),
        ],
      ),
    );
    final username = usernameCtrl.text.trim();
    usernameCtrl.dispose();
    if (usernameOk != true || username.isEmpty) return;

    // Adım 2: Şifre (ilk kez)
    if (!mounted) return;
    final pass1Ctrl = TextEditingController();
    final pass1Ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.settingsDeleteAccountStep2),
        content: TextField(
          controller: pass1Ctrl,
          obscureText: true,
          decoration: InputDecoration(
            labelText: l10n.settingsDeleteAccountPasswordHint,
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.settingsDeleteAccountCancel)),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              if (pass1Ctrl.text.isNotEmpty) Navigator.pop(ctx, true);
            },
            child: Text(l10n.settingsDeleteAccountContinue),
          ),
        ],
      ),
    );
    final password = pass1Ctrl.text;
    pass1Ctrl.dispose();
    if (pass1Ok != true || password.isEmpty) return;

    // Adım 3: 10 saniyelik bekleme
    if (!mounted) return;
    final countdownOk = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _CountdownDialog(),
    );
    if (countdownOk != true) return;

    // Adım 4: Şifre (ikinci kez)
    if (!mounted) return;
    final pass2Ctrl = TextEditingController();
    final pass2Ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.settingsDeleteAccountStep4),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.settingsDeleteAccountFinalMessage, style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 12),
            TextField(
              controller: pass2Ctrl,
              obscureText: true,
              decoration: InputDecoration(
                labelText: l10n.settingsDeleteAccountPasswordConfirmHint,
                border: const OutlineInputBorder(),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.settingsDeleteAccountCancel)),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              if (pass2Ctrl.text.isNotEmpty) Navigator.pop(ctx, true);
            },
            child: Text(l10n.settingsDeleteAccountFinalButton),
          ),
        ],
      ),
    );
    final password2 = pass2Ctrl.text;
    pass2Ctrl.dispose();
    if (pass2Ok != true || password2.isEmpty) return;

    if (!mounted) return;
    setState(() => _deletingAccount = true);
    final success = await ref.read(profileProvider.notifier).deleteAccount(
      username: username,
      masterPassword: password2,
    );
    if (!mounted) return;
    setState(() => _deletingAccount = false);

    if (success) {
      context.go('/login');
    } else {
      final err = ref.read(profileProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err ?? l10n.settingsDeleteAccountFailed), backgroundColor: Colors.red),
      );
      ref.read(profileProvider.notifier).reset();
    }
  }

  Future<void> _logout() async {
    setState(() => _loggingOut = true);
    try {
      await _repo.logout();
    } catch (_) {}
    if (!mounted) return;
    context.go('/login');
  }

  void _showDevicesSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _DevicesSheet(),
    );
  }

  Future<void> _showUsernameDialog() async {
    final l10n = AppLocalizations.of(context);
    final profile = ref.read(profileProvider);
    final ctrl = TextEditingController(text: profile.username ?? '');
    final formKey = GlobalKey<FormState>();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.settingsUsernameChangeTitle),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: ctrl,
            decoration: InputDecoration(labelText: l10n.settingsUsernameChangeHint),
            validator: (v) {
              if (v == null || v.isEmpty) return l10n.settingsUsernameChangeError;
              if (v.length < 3) return l10n.settingsUsernameChangeMinError;
              if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(v)) {
                return l10n.settingsUsernameChangePatternError;
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.settingsDeleteAccountCancel)),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) Navigator.pop(ctx, true);
            },
            child: Text(l10n.settingsUsernameChangeSaved),
          ),
        ],
      ),
    );

    final newUsername = ctrl.text.trim();
    Future.microtask(ctrl.dispose);
    if (ok != true) return;

    final success = await ref.read(profileProvider.notifier).updateUsername(newUsername);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.settingsUsernameChangeSaved)),
      );
    } else {
      final err = ref.read(profileProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err ?? l10n.settingsUsernameChangeFailed)),
      );
      ref.read(profileProvider.notifier).reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final themeMode = ref.watch(themeModeProvider);
    final profile = ref.watch(profileProvider);
    final displayName = profile.username ?? _email ?? '';
    final cs = Theme.of(context).colorScheme;
    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      bottomNavigationBar: const AppNavBar(currentIndex: 4),
      body: ListView(
        children: [
          // Kullanıcı bilgisi
          Container(
            margin: const EdgeInsets.fromLTRB(16, 20, 16, 4),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.primaryContainer.withAlpha(60),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.person_outline, size: 28,
                    color: cs.onPrimaryContainer),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (profile.email != null)
                        Text(
                          profile.email!,
                          style: TextStyle(fontSize: 13,
                            color: cs.onSurfaceVariant),
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          _sectionHeader(l10n.settingsAccountSection),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: Text(l10n.settingsUsernameChange),
            subtitle: profile.username != null
                ? Text(profile.username!, style: const TextStyle(fontSize: 12))
                : null,
            trailing: const Icon(Icons.chevron_right),
            onTap: _showUsernameDialog,
          ),
          ListTile(
            leading: const Icon(Icons.email_outlined),
            title: Text(l10n.settingsEmailChange),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/change-email'),
          ),
          ListTile(
            leading: const Icon(Icons.devices_outlined),
            title: Text(l10n.settingsMyDevices),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showDevicesSheet,
          ),

          const Divider(height: 1),

          _sectionHeader(l10n.settingsAppSection),
          ListTile(
            leading: const Icon(Icons.password_outlined),
            title: Text(l10n.settingsPasswordGenerator),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/password-generator'),
          ),
          ListTile(
            leading: const Icon(Icons.history_outlined),
            title: Text(l10n.settingsAuditLog),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/audit-log'),
          ),
          ListTile(
            leading: const Icon(Icons.support_agent_outlined),
            title: Text(l10n.settingsSupportTicket),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/support-ticket'),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(l10n.settingsPrivacyPolicy),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/privacy-policy'),
          ),

          // Dil seçici
          ListTile(
            leading: const Icon(Icons.language_outlined),
            title: Text(l10n.settingsLanguage),
            subtitle: Text(
              localeDisplayNames[currentLocale.languageCode] ?? currentLocale.languageCode,
              style: const TextStyle(fontSize: 12),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showLanguageDialog(context, l10n, currentLocale),
          ),

          // Authenticator Koruması (TOTP)
          Consumer(
            builder: (context, ref, _) {
              final l10n = AppLocalizations.of(context);
              final totpAsync = ref.watch(totpStatusProvider);
              final cs = Theme.of(context).colorScheme;
              return totpAsync.when(
                loading: () => const ListTile(
                  leading: Icon(Icons.verified_user_outlined),
                  title: Text('Authenticator Koruması'),
                  trailing: SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                error: (_, __) => const SizedBox.shrink(),
                data: (status) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.verified_user_outlined,
                        color: status.enabled ? cs.primary : null,
                      ),
                      title: Text(l10n.totpSettingsTitle),
                      subtitle: Text(
                        status.enabled
                            ? l10n.totpSettingsActiveDesc
                            : l10n.totpSettingsInactiveDesc,
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: Switch(
                        value: status.enabled,
                        onChanged: (val) async {
                          if (val) {
                            await context.push('/totp-setup');
                            ref.invalidate(totpStatusProvider);
                          } else {
                            _showTotpDisableDialog(context, ref, l10n);
                          }
                        },
                      ),
                    ),
                    if (status.enabled)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(56, 0, 16, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.totpTrustDurationLabel,
                              style: TextStyle(
                                fontSize: 12,
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                for (final option in _kTotpTrustOptions)
                                  ChoiceChip(
                                    label: Text(_totpTrustLabel(l10n, option)),
                                    selected: status.trustDurationSeconds == option,
                                    onSelected: (_) async {
                                      await AuthRepository().setTotpTrustDuration(option);
                                      ref.invalidate(totpStatusProvider);
                                    },
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            },
          ),

          if (_biometricAvailable) ...[
            SwitchListTile(
              secondary: const Icon(Icons.fingerprint),
              title: Text(l10n.settingsBiometricLock),
              subtitle: Text(
                _biometricEnabled
                    ? (_biometricRemainingDays > 1
                        ? l10n.settingsBiometricActive(_biometricRemainingDays)
                        : _biometricRemainingDays == 1
                            ? l10n.settingsBiometricActiveTomorrow
                            : l10n.settingsBiometricExpired)
                    : l10n.settingsBiometricDescription,
                style: const TextStyle(fontSize: 12),
              ),
              value: _biometricEnabled,
              onChanged: _toggleBiometric,
            ),
          ],
          Consumer(
            builder: (context, ref, _) {
              final l10n = AppLocalizations.of(context);
              final autoLock = ref.watch(autoLockProvider);
              final cs = Theme.of(context).colorScheme;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile(
                    secondary: Icon(
                      autoLock.enabled ? Icons.lock : Icons.lock_open_outlined,
                      color: autoLock.enabled ? cs.primary : null,
                    ),
                    title: Text(l10n.settingsAutoLock),
                    subtitle: Text(
                      autoLock.enabled
                          ? (autoLock.minutes == null
                              ? l10n.settingsAutoLockFocusLoss
                              : l10n.settingsAutoLockEnabled(autoLock.minutes!))
                          : l10n.settingsAutoLockDisabled,
                      style: const TextStyle(fontSize: 12),
                    ),
                    value: autoLock.enabled,
                    onChanged: (val) =>
                        ref.read(autoLockProvider.notifier).toggle(val),
                  ),
                  if (autoLock.enabled)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(56, 0, 16, 12),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          for (final option in [
                            null, 1, 2, 5, 10, 20, 30, 60, 120
                          ])
                            ChoiceChip(
                              label: Text(
                                option == null
                                    ? l10n.settingsAutoLockUnlimited
                                    : l10n.settingsAutoLockMinutesChip(option)),
                              selected: autoLock.minutes == option,
                              onSelected: (_) => ref
                                  .read(autoLockProvider.notifier)
                                  .setMinutes(option),
                            ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
          Consumer(
            builder: (context, ref, _) {
              final l10n = AppLocalizations.of(context);
              final timeout = ref.watch(clipboardTimeoutProvider);
              final cs = Theme.of(context).colorScheme;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    leading: const Icon(Icons.content_paste_outlined),
                    title: Text(l10n.settingsClipboardTimeout),
                    subtitle: Text(
                      timeout != null
                          ? l10n.settingsClipboardTimeoutActive(timeout)
                          : l10n.settingsClipboardTimeoutDisabled,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(56, 0, 16, 12),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        for (final option in [10, 30, 60])
                          ChoiceChip(
                            label: Text(l10n.settingsClipboardSecondsChip(option)),
                            selected: timeout == option,
                            onSelected: (_) => ref
                                .read(clipboardTimeoutProvider.notifier)
                                .setTimeout(option),
                          ),
                        ChoiceChip(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.warning_amber_rounded,
                                size: 14,
                                color: timeout == null
                                    ? cs.onPrimary
                                    : Colors.orange.shade700),
                              const SizedBox(width: 4),
                              Text(l10n.settingsClipboardUnlimited),
                            ],
                          ),
                          selected: timeout == null,
                          onSelected: (_) => ref
                              .read(clipboardTimeoutProvider.notifier)
                              .setTimeout(null),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) ...[
            Consumer(
              builder: (context, ref, _) {
                final l10n = AppLocalizations.of(context);
                final shortcutsEnabled = ref.watch(shortcutsProvider);
                return SwitchListTile(
                  secondary: const Icon(Icons.keyboard_outlined),
                  title: Text(l10n.settingsKeyboardShortcuts),
                  subtitle: Text(
                    l10n.settingsKeyboardHint,
                    style: const TextStyle(fontSize: 12),
                  ),
                  value: shortcutsEnabled,
                  onChanged: (val) =>
                      ref.read(shortcutsProvider.notifier).toggle(val),
                );
              },
            ),
            Consumer(
              builder: (context, ref, _) {
                final shortcutsEnabled = ref.watch(shortcutsProvider);
                if (!shortcutsEnabled) return const SizedBox.shrink();
                return const ShortcutHintCard();
              },
            ),
          ],
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode_outlined),
            title: Text(l10n.settingsDarkMode),
            subtitle: Text(
              themeMode == ThemeMode.system
                  ? l10n.settingsDarkModeSystem
                  : themeMode == ThemeMode.dark
                      ? l10n.settingsDarkModeEnabled
                      : l10n.settingsDarkModeDisabled,
              style: const TextStyle(fontSize: 12),
            ),
            value: themeMode == ThemeMode.dark ||
                (themeMode == ThemeMode.system &&
                    WidgetsBinding.instance.platformDispatcher.platformBrightness ==
                        Brightness.dark),
            onChanged: (val) {
              ref.read(themeModeProvider.notifier).setTheme(
                  val ? ThemeMode.dark : ThemeMode.light);
            },
          ),

          const Divider(height: 1),

          _sectionHeader(l10n.settingsHowToUse),
          ListTile(
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: const Color(0xFFFF5900).withAlpha(25),
              ),
              child: const Icon(Icons.play_circle_outline_rounded,
                  color: Color(0xFFFF5900), size: 20),
            ),
            title: Text(l10n.settingsDiscoverApp,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(l10n.settingsDiscoverAppDescription),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/onboarding', extra: true),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _HelpTile(
            icon: Icons.shield_outlined,
            title: l10n.settingsHelpAddPassword,
            content: l10n.settingsHelpAddPasswordContent,
          ),
          _HelpTile(
            icon: Icons.key_outlined,
            title: l10n.settingsHelpPasswordGenerator,
            content: l10n.settingsHelpPasswordGeneratorContent,
          ),
          _HelpTile(
            icon: Icons.grid_view_outlined,
            title: l10n.settingsHelpCategories,
            content: l10n.settingsHelpCategoriesContent,
          ),
          _HelpTile(
            icon: Icons.delete_outline,
            title: l10n.settingsHelpTrash,
            content: l10n.settingsHelpTrashContent,
          ),
          _HelpTile(
            icon: Icons.lock_outline,
            title: l10n.settingsHelpZeroKnowledge,
            content: l10n.settingsHelpZeroKnowledgeContent,
          ),

          const Divider(height: 1),

          ListTile(
            leading: _loggingOut
                ? const SizedBox(
                    width: 24, height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.logout, color: Colors.red),
            title: Text(l10n.settingsLogout, style: const TextStyle(color: Colors.red)),
            onTap: _loggingOut ? null : _logout,
          ),
          ListTile(
            leading: _deletingAccount
                ? const SizedBox(
                    width: 24, height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.red))
                : const Icon(Icons.delete_forever, color: Colors.red),
            title: Text(l10n.settingsDeleteAccount,
                style: const TextStyle(color: Colors.red)),
            subtitle: Text(l10n.settingsDeleteAccountWarning,
                style: const TextStyle(fontSize: 12, color: Colors.red)),
            onTap: _deletingAccount ? null : _startDeleteAccountFlow,
          ),

          const SizedBox(height: 24),
          Center(
            child: ref.watch(appVersionProvider).when(
              data: (v) => Text(
                l10n.settingsVersion(v),
                style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
              ),
              loading: () => const SizedBox.shrink(),
              error: (e, st) => Text(
                'DeniKey',
                style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, AppLocalizations l10n, Locale currentLocale) {
    showDialog<void>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(l10n.settingsLanguage),
        children: supportedLocales.map((locale) {
          final name = localeDisplayNames[locale.languageCode] ?? locale.languageCode;
          final isSelected = locale.languageCode == currentLocale.languageCode;
          return SimpleDialogOption(
            onPressed: () {
              ref.read(localeProvider.notifier).setLocale(locale);
              Navigator.pop(ctx);
            },
            child: Row(
              children: [
                Expanded(child: Text(name)),
                if (isSelected)
                  Icon(Icons.check, color: Theme.of(context).colorScheme.primary, size: 18),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class _CountdownDialog extends StatefulWidget {
  @override
  State<_CountdownDialog> createState() => _CountdownDialogState();
}

class _CountdownDialogState extends State<_CountdownDialog> {
  int _seconds = 10;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() => _seconds--);
      if (_seconds <= 0) t.cancel();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.settingsDeleteAccountStep3),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.settingsDeleteAccountConfirm, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 24),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.red, width: 3),
            ),
            child: Center(
              child: Text(
                '$_seconds',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _seconds > 0
                ? l10n.settingsDeleteAccountCountdownWait(_seconds)
                : l10n.settingsDeleteAccountCountdownReady,
            style: TextStyle(
              fontSize: 13,
              color: _seconds > 0 ? Colors.grey : Colors.red,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l10n.settingsDeleteAccountCancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: Colors.red),
          onPressed: _seconds > 0 ? null : () => Navigator.pop(context, true),
          child: Text(l10n.settingsDeleteAccountYesConfirm),
        ),
      ],
    );
  }
}

class _HelpTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final String content;
  const _HelpTile({required this.icon, required this.title, required this.content});

  @override
  State<_HelpTile> createState() => _HelpTileState();
}

class _HelpTileState extends State<_HelpTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        ListTile(
          leading: Icon(widget.icon, color: cs.primary),
          title: Text(widget.title,
            style: const TextStyle(fontWeight: FontWeight.w500)),
          trailing: Icon(
            _expanded ? Icons.expand_less : Icons.expand_more,
            color: cs.onSurfaceVariant,
          ),
          onTap: () => setState(() => _expanded = !_expanded),
        ),
        if (_expanded)
          Padding(
            padding: const EdgeInsets.fromLTRB(56, 0, 16, 12),
            child: Text(
              widget.content,
              style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant,
                height: 1.5),
            ),
          ),
      ],
    );
  }
}

// ─── Cihazlarım alt sayfa ────────────────────────────────────────────────────

class _DevicesSheet extends ConsumerStatefulWidget {
  const _DevicesSheet();

  @override
  ConsumerState<_DevicesSheet> createState() => _DevicesSheetState();
}

class _DevicesSheetState extends ConsumerState<_DevicesSheet> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.refresh(devicesProvider));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final devicesAsync = ref.watch(devicesProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (_, controller) => Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: cs.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.devices_outlined, color: cs.primary),
                  const SizedBox(width: 10),
                  Text(l10n.settingsDevicesTitle,
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: l10n.settingsDeviceRefresh,
                    onPressed: () => ref.invalidate(devicesProvider),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: devicesAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Text(l10n.settingsDevicesError,
                      style: TextStyle(color: cs.error)),
                ),
                data: (devices) => devices.isEmpty
                    ? Center(
                        child: Text(l10n.settingsDevicesEmpty,
                            style: TextStyle(color: cs.onSurfaceVariant)),
                      )
                    : ListView.builder(
                        controller: controller,
                        itemCount: devices.length,
                        itemBuilder: (_, i) =>
                            _DeviceTile(device: devices[i]),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeviceTile extends ConsumerWidget {
  final DeviceModel device;
  const _DeviceTile({required this.device});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final isActive = device.status == 'active' &&
        device.lastActiveAt != null &&
        DateTime.now().difference(device.lastActiveAt!).inMinutes < 5;
    final isBanned = device.status == 'banned';

    final indicatorColor = isBanned
        ? Colors.red
        : isActive
            ? Colors.green
            : Colors.orange;

    final statusLabel = isBanned
        ? l10n.settingsDeviceStatusBanned
        : isActive
            ? l10n.settingsDeviceStatusActive
            : l10n.settingsDeviceStatusPassive;

    return ListTile(
      leading: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(_deviceIcon(device.deviceType), size: 28,
              color: cs.onSurfaceVariant),
          Positioned(
            right: -4,
            bottom: -4,
            child: _StatusDot(color: indicatorColor, pulse: isActive),
          ),
        ],
      ),
      title: Text(device.label,
          style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(statusLabel,
              style: TextStyle(fontSize: 11, color: indicatorColor)),
          if (device.lastActiveAt != null)
            Text(_formatDate(device.lastActiveAt!, l10n),
                style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
        ],
      ),
      trailing: PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert),
        onSelected: (val) => _onAction(context, ref, val, l10n),
        itemBuilder: (_) => [
          if (device.status != 'revoked' && device.status != 'banned')
            PopupMenuItem(
              value: 'revoke',
              child: Row(children: [
                const Icon(Icons.logout, size: 18),
                const SizedBox(width: 8),
                Text(l10n.settingsDeviceRevoke),
              ]),
            ),
          if (device.status != 'banned')
            PopupMenuItem(
              value: 'ban',
              child: Row(children: [
                const Icon(Icons.block, size: 18, color: Colors.red),
                const SizedBox(width: 8),
                Text(l10n.settingsDeviceBan,
                    style: const TextStyle(color: Colors.red)),
              ]),
            ),
          if (device.status == 'banned')
            PopupMenuItem(
              value: 'unban',
              child: Row(children: [
                const Icon(Icons.check_circle_outline, size: 18, color: Colors.green),
                const SizedBox(width: 8),
                Text(l10n.settingsDeviceUnban,
                    style: const TextStyle(color: Colors.green)),
              ]),
            ),
        ],
      ),
    );
  }

  Future<void> _onAction(
      BuildContext context, WidgetRef ref, String action, AppLocalizations l10n) async {
    final repo = ref.read(deviceRepositoryProvider);
    try {
      if (action == 'revoke') {
        await repo.revokeDevice(device.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.settingsDeviceRevokeSuccess)),
          );
        }
      } else if (action == 'ban') {
        await repo.banDevice(device.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(l10n.settingsDeviceBanSuccess),
                backgroundColor: Colors.red),
          );
        }
      } else if (action == 'unban') {
        await repo.unbanDevice(device.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.settingsDeviceUnbanSuccess)),
          );
        }
      }
      ref.invalidate(devicesProvider);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(l10n.settingsDeviceActionFailed),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  IconData _deviceIcon(String? type) {
    switch (type) {
      case 'android':
        return Icons.phone_android;
      case 'ios':
        return Icons.phone_iphone;
      case 'windows':
        return Icons.computer;
      case 'macos':
        return Icons.laptop_mac;
      case 'linux':
        return Icons.computer;
      default:
        return Icons.devices;
    }
  }

  String _formatDate(DateTime dt, AppLocalizations l10n) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return l10n.settingsDeviceJustNow;
    if (diff.inMinutes < 60) return l10n.settingsDeviceMinutesAgo(diff.inMinutes);
    if (diff.inHours < 24) return l10n.settingsDeviceHoursAgo(diff.inHours);
    return l10n.settingsDeviceDaysAgo(diff.inDays);
  }
}

class _StatusDot extends StatefulWidget {
  final Color color;
  final bool pulse;
  const _StatusDot({required this.color, required this.pulse});

  @override
  State<_StatusDot> createState() => _StatusDotState();
}

class _StatusDotState extends State<_StatusDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _anim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    if (widget.pulse) _ctrl.repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.pulse) {
      return Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
          border: Border.all(
              color: Theme.of(context).colorScheme.surface, width: 1.5),
        ),
      );
    }
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, child) => Opacity(
        opacity: _anim.value,
        child: Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: widget.color,
            shape: BoxShape.circle,
            border: Border.all(
                color: Theme.of(context).colorScheme.surface, width: 1.5),
          ),
        ),
      ),
    );
  }
}
