import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/auth_repository.dart';
import '../providers/profile_provider.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/biometric/biometric_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _repo = AuthRepository();
  String? _email;
  bool _loggingOut = false;
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
              border: OutlineInputBorder(),
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
    // Dialog animasyonu bitene kadar dispose'u ertele
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

    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      body: ListView(
        children: [
          // Kullanıcı bilgisi başlığı
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.deepPurple.withValues(alpha: 0.3), width: 2),
                  ),
                  child: const Icon(Icons.person_outline, size: 32, color: Colors.deepPurple),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (profile.email != null)
                        Text(
                          profile.email!,
                          style: const TextStyle(fontSize: 13, color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(),

          // Hesap bölümü
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              'HESAP',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey),
            ),
          ),
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

          const Divider(),

          // Uygulama bölümü
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              'UYGULAMA',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey),
            ),
          ),
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
          if (_biometricAvailable)
            SwitchListTile(
              secondary: const Icon(Icons.fingerprint),
              title: const Text('Biyometrik Kilit'),
              subtitle: const Text(
                'Uygulama açılışında parmak izi / yüz tanıma',
                style: TextStyle(fontSize: 12),
              ),
              value: _biometricEnabled,
              onChanged: _toggleBiometric,
            ),
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
              ref.read(themeModeProvider.notifier).state =
                  val ? ThemeMode.dark : ThemeMode.light;
            },
          ),

          const Divider(),

          // Çıkış
          ListTile(
            leading: _loggingOut
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.logout, color: Colors.red),
            title: const Text('Çıkış Yap', style: TextStyle(color: Colors.red)),
            onTap: _loggingOut ? null : _logout,
          ),

          const SizedBox(height: 24),
          const Center(
            child: Text(
              'DeniKey v1.0.0',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
