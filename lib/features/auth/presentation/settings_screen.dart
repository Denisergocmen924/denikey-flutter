import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/autofill/autofill_server.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/auth_repository.dart';
import '../providers/profile_provider.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/providers/shortcuts_provider.dart';
import '../../../core/providers/auto_lock_provider.dart';
import '../../../core/providers/app_version_provider.dart';
import '../../../core/biometric/biometric_service.dart';
import '../../../core/presentation/app_nav_bar.dart';
import '../../../core/presentation/app_shortcuts.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _repo = AuthRepository();
  String? _email;
  bool _loggingOut = false;
  bool _deletingAccount = false;
  bool _biometricAvailable = false;
  bool _biometricEnabled = false;

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
    if (mounted) {
      setState(() {
        _biometricAvailable = available;
        _biometricEnabled = enabled;
      });
    }
  }

  Future<void> _toggleBiometric(bool val) async {
    await BiometricService.instance.setEnabled(val);
    setState(() => _biometricEnabled = val);
  }

  Future<void> _startDeleteAccountFlow() async {
    // Adım 1: Kullanıcı adı
    final usernameCtrl = TextEditingController();
    final usernameOk = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Hesabı Sil — Adım 1/4'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bu işlem geri alınamaz. Tüm verileriniz kalıcı olarak silinecektir.',
              style: TextStyle(color: Colors.red, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: usernameCtrl,
              decoration: const InputDecoration(
                labelText: 'Kullanıcı adınızı girin',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('İptal')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              if (usernameCtrl.text.trim().isNotEmpty) Navigator.pop(ctx, true);
            },
            child: const Text('Devam'),
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
        title: const Text('Hesabı Sil — Adım 2/4'),
        content: TextField(
          controller: pass1Ctrl,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Master şifrenizi girin',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('İptal')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              if (pass1Ctrl.text.isNotEmpty) Navigator.pop(ctx, true);
            },
            child: const Text('Devam'),
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
        title: const Text('Hesabı Sil — Adım 4/4'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Son adım: şifrenizi bir kez daha girin.',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: pass2Ctrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Master şifrenizi tekrar girin',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('İptal')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              if (pass2Ctrl.text.isNotEmpty) Navigator.pop(ctx, true);
            },
            child: const Text('Hesabı Kalıcı Sil'),
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
        SnackBar(content: Text(err ?? 'Hesap silinemedi'), backgroundColor: Colors.red),
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

  Future<void> _showUsernameDialog() async {
    final profile = ref.read(profileProvider);
    final ctrl = TextEditingController(text: profile.username ?? '');
    final formKey = GlobalKey<FormState>();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Kullanıcı Adı Değiştir'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: ctrl,
            decoration: const InputDecoration(
              labelText: 'Yeni kullanıcı adı',
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Boş bırakılamaz';
              if (v.length < 3) return 'En az 3 karakter';
              if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(v)) {
                return 'Sadece harf, rakam ve _ kullanılabilir';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('İptal')),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) Navigator.pop(ctx, true);
            },
            child: const Text('Kaydet'),
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
        const SnackBar(content: Text('Kullanıcı adı güncellendi')),
      );
    } else {
      final err = ref.read(profileProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err ?? 'Güncellenemedi')),
      );
      ref.read(profileProvider.notifier).reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final profile = ref.watch(profileProvider);
    final displayName = profile.username ?? _email ?? '';
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      bottomNavigationBar: const AppNavBar(currentIndex: 2),
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

          _sectionHeader('HESAP'),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Kullanıcı Adı Değiştir'),
            subtitle: profile.username != null
                ? Text(profile.username!, style: const TextStyle(fontSize: 12))
                : null,
            trailing: const Icon(Icons.chevron_right),
            onTap: _showUsernameDialog,
          ),
          ListTile(
            leading: const Icon(Icons.email_outlined),
            title: const Text('E-posta Değiştir'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/change-email'),
          ),

          const Divider(height: 1),

          _sectionHeader('UYGULAMA'),
          ListTile(
            leading: const Icon(Icons.password_outlined),
            title: const Text('Şifre Üretici'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/password-generator'),
          ),
          ListTile(
            leading: const Icon(Icons.history_outlined),
            title: const Text('Aktivite Geçmişi'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/audit-log'),
          ),
          ListTile(
            leading: const Icon(Icons.support_agent_outlined),
            title: const Text('Destek Talebi'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/support-ticket'),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Gizlilik Politikası'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/privacy-policy'),
          ),
          if (_biometricAvailable)
            SwitchListTile(
              secondary: const Icon(Icons.fingerprint),
              title: const Text('Biyometrik Kilit'),
              subtitle: const Text(
                'Parmak izi / yüz tanıma ile kilitle',
                style: TextStyle(fontSize: 12),
              ),
              value: _biometricEnabled,
              onChanged: _toggleBiometric,
            ),
          Consumer(
            builder: (context, ref, _) {
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
                    title: const Text('Otomatik Kilit'),
                    subtitle: Text(
                      autoLock.enabled
                          ? (autoLock.minutes == null
                              ? 'Süresiz — odaklanmada kilitle'
                              : '${autoLock.minutes} dk sonra kilitle')
                          : 'Uygulamadan çıkınca master şifre iste',
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
                                  option == null ? 'Süresiz' : '$option dk'),
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
          if (Platform.isWindows) ...[
            ListTile(
              leading: const Icon(Icons.extension_outlined),
              title: const Text('Tarayıcı Autofill'),
              subtitle: const Text(
                'Eklentiye yapıştırılacak bağlantı token\'ı',
                style: TextStyle(fontSize: 12),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.copy_outlined),
                tooltip: 'Token\'ı kopyala',
                onPressed: () async {
                  final token = AutofillServer.instance.sessionToken;
                  if (token != null && context.mounted) {
                    await Clipboard.setData(ClipboardData(text: token));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Token kopyalandı')),
                    );
                  }
                },
              ),
            ),
          ],
          if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) ...[
            Consumer(
              builder: (context, ref, _) {
                final shortcutsEnabled = ref.watch(shortcutsProvider);
                return SwitchListTile(
                  secondary: const Icon(Icons.keyboard_outlined),
                  title: const Text('Klavye Kısayolları'),
                  subtitle: const Text(
                    'Ctrl+1/2/3, +, ←→, Esc vb.',
                    style: TextStyle(fontSize: 12),
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
            title: const Text('Karanlık Tema'),
            subtitle: Text(
              themeMode == ThemeMode.system
                  ? 'Sistem ayarına göre'
                  : themeMode == ThemeMode.dark
                      ? 'Açık'
                      : 'Kapalı',
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

          // Nasıl Kullanılır
          _sectionHeader('NASIL KULLANILIR'),
          _HelpTile(
            icon: Icons.shield_outlined,
            title: 'Şifre Ekleme',
            content:
                'Alt menüden "Kasam" sekmesine geçin. Sağ alttaki "+ Yeni Şifre" butonuna dokunun. '
                'Site adı, kullanıcı adı ve şifrenizi girin; kaydedin.',
          ),
          _HelpTile(
            icon: Icons.key_outlined,
            title: 'Şifre Üretici',
            content:
                'Uygulama → Şifre Üretici ekranından uzunluk, büyük/küçük harf, rakam ve '
                'özel karakter seçenekleriyle güçlü şifre üretebilirsiniz.',
          ),
          _HelpTile(
            icon: Icons.grid_view_outlined,
            title: 'Kategoriler ve Türler',
            content:
                '"Kütüphane" sekmesinde şifrelerinizi kategorilere ayırabilir, '
                'yeni öğe türleri oluşturabilirsiniz.',
          ),
          _HelpTile(
            icon: Icons.delete_outline,
            title: 'Çöp Kutusu',
            content:
                'Silinen şifreler 7 gün boyunca Çöp Kutusu\'nda tutulur. '
                'Kasam ekranının sağ üst köşesindeki çöp kutusu ikonundan erişebilirsiniz.',
          ),
          _HelpTile(
            icon: Icons.lock_outline,
            title: 'Sıfır Bilgi Güvenliği',
            content:
                'DeniKey\'de master şifreniz hiçbir zaman sunucuya gönderilmez ve hiçbir '
                'yerde saklanmaz. Şifreleriniz cihazınızda Argon2id algoritmasıyla türetilen '
                'bir anahtarla AES-256-GCM formatında şifrelenir; bu anahtar yalnızca sizin '
                'cihazınızda bulunur. Sunucuya yalnızca şifreli (encrypted) veri gönderilir. '
                'Master şifrenizi unutursanız verilerinizi kurtarmanın hiçbir yolu yoktur — '
                'bu, gerçek sıfır-bilgi güvenliğinin kaçınılmaz sonucudur.',
          ),

          const Divider(height: 1),

          // Çıkış
          ListTile(
            leading: _loggingOut
                ? const SizedBox(
                    width: 24, height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.logout, color: Colors.red),
            title: const Text('Çıkış Yap', style: TextStyle(color: Colors.red)),
            onTap: _loggingOut ? null : _logout,
          ),
          ListTile(
            leading: _deletingAccount
                ? const SizedBox(
                    width: 24, height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.red))
                : const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Hesabı Kalıcı Olarak Sil',
                style: TextStyle(color: Colors.red)),
            subtitle: const Text('Tüm veriler silinir, geri alınamaz',
                style: TextStyle(fontSize: 12, color: Colors.red)),
            onTap: _deletingAccount ? null : _startDeleteAccountFlow,
          ),

          const SizedBox(height: 24),
          Center(
            child: ref.watch(appVersionProvider).when(
              data: (v) => Text(
                'DeniKey v$v',
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

  @override
  void initState() {
    super.initState();
    _tick();
  }

  void _tick() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() => _seconds--);
      if (_seconds > 0) _tick();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Hesabı Sil — Adım 3/4'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Gerçekten hesabınızı silmek istiyor musunuz?',
            style: TextStyle(fontSize: 14),
          ),
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
                ? '$_seconds saniye beklemeniz gerekiyor...'
                : 'Devam edebilirsiniz.',
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
          child: const Text('İptal'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: Colors.red),
          onPressed: _seconds > 0 ? null : () => Navigator.pop(context, true),
          child: const Text('Evet, Devam Et'),
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
