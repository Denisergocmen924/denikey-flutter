import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/biometric/biometric_service.dart';
import '../../../core/crypto/encryption_service.dart';
import '../../../core/storage/secure_storage.dart';
import 'package:denikey_app/l10n/generated/app_localizations.dart';
import '../data/auth_repository.dart';
import '../../../core/presentation/app_animations.dart';
import '../../../core/presentation/aurora_background.dart';

class MasterLockScreen extends StatefulWidget {
  const MasterLockScreen({super.key});

  @override
  State<MasterLockScreen> createState() => _MasterLockScreenState();
}

class _MasterLockScreenState extends State<MasterLockScreen>
    with SingleTickerProviderStateMixin {
  final _ctrl    = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscure  = true;
  bool _loading  = false;
  String? _error;
  ({IconData icon, String label})? _biometric;
  bool _biometricExpired = false;
  int _remainingDays = 0;
  int _failedAttempts = 0;

  // Hatalı giriş sarsma animasyonu
  late final AnimationController _shakeCtrl;
  late final Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _loadBiometric();
    _loadFailedAttempts();

    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _shakeAnim = CurvedAnimation(parent: _shakeCtrl, curve: Curves.easeOut);
  }

  // Sinüsoidal sarsma: 5 titreşim, azalan genlik
  double _shakeOffset(double t) =>
      10.0 * math.sin(t * math.pi * 6) * (1.0 - t);

  Future<void> _loadFailedAttempts() async {
    final count = await SecureStorage.instance.getMasterLockAttempts();
    if (count >= 3) {
      await _logout();
      return;
    }
    if (mounted) setState(() => _failedAttempts = count);
  }

  Future<void> _saveFailedAttempts(int count) =>
      SecureStorage.instance.saveMasterLockAttempts(count);

  Future<void> _clearFailedAttempts() =>
      SecureStorage.instance.clearMasterLockAttempts();

  Future<void> _loadBiometric() async {
    final enabled = await BiometricService.instance.isEnabled();
    if (!enabled) return;
    final expired = await BiometricService.instance.isMasterPasswordExpired();
    if (expired) {
      if (mounted) setState(() => _biometricExpired = true);
      return;
    }
    final bio = await BiometricService.instance.getBiometricLabel();
    final days = await BiometricService.instance.remainingDays();
    if (mounted) setState(() { _biometric = bio; _remainingDays = days; });
  }

  Future<void> _logout() async {
    await SecureStorage.instance.clearAll();
    if (mounted) context.go('/login');
  }

  Future<void> _navigateAfterUnlock() async {
    try {
      final result = await AuthRepository().totpTrustCheck();
      if (!mounted) return;
      final totpEnabled = result['totp_enabled'] as bool;
      final trustValid = result['trust_valid'] as bool;
      if (totpEnabled && !trustValid) {
        context.go('/totp-verify-unlock');
      } else {
        context.go('/vault');
      }
    } catch (_) {
      if (mounted) context.go('/vault');
    }
  }

  Future<void> _biometricUnlock() async {
    setState(() { _loading = true; _error = null; });
    final ok = await BiometricService.instance.authenticate();
    if (!mounted) return;
    if (ok) {
      final masterKey = await SecureStorage.instance.getMasterKey();
      if (!mounted) return;
      if (masterKey == null) {
        setState(() {
          _error = AppLocalizations.of(context).masterLockBiometricNeeded;
          _loading = false;
        });
        _shakeCtrl.forward(from: 0);
        return;
      }
      await _navigateAfterUnlock();
    } else {
      setState(() { _error = AppLocalizations.of(context).masterLockAuthFailed; _loading = false; });
      _shakeCtrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _shakeCtrl.dispose();
    super.dispose();
  }

  Future<void> _unlock() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });

    try {
      final salt = await SecureStorage.instance.getEncryptionSalt();
      final blobData = await SecureStorage.instance.getVerificationBlob();

      if (salt == null || blobData == null) {
        await SecureStorage.instance.clearAll();
        if (mounted) context.go('/login');
        return;
      }

      final masterKey = await EncryptionService.instance.deriveMasterKey(
        _ctrl.text.trim(),
        salt,
      );

      final plaintext = await EncryptionService.instance.decrypt(
        blobData['encrypted']!,
        blobData['iv']!,
        masterKey,
      );

      if (plaintext != 'denikey-verify') {
        _failedAttempts++;
        await _saveFailedAttempts(_failedAttempts);
        if (_failedAttempts >= 3) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(AppLocalizations.of(context).masterLockTooManyAttempts),
              backgroundColor: Colors.red,
            ));
          }
          await _logout();
          return;
        }
        setState(() { _error = AppLocalizations.of(context).masterLockWrongPassword; _loading = false; });
        _shakeCtrl.forward(from: 0);
        return;
      }

      await _clearFailedAttempts();
      await SecureStorage.instance.saveMasterKey(masterKey);
      await BiometricService.instance.saveMasterPasswordTimestamp();
      if (mounted) await _navigateAfterUnlock();
    } catch (_) {
      _failedAttempts++;
      await _saveFailedAttempts(_failedAttempts);
      if (_failedAttempts >= 3) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(AppLocalizations.of(context).masterLockTooManyAttempts),
            backgroundColor: Colors.red,
          ));
        }
        await _logout();
        return;
      }
      setState(() { _error = AppLocalizations.of(context).masterLockWrongPassword; _loading = false; });
      _shakeCtrl.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: AuroraBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo — kilit simgesi, halka ışıltısıyla
                      Center(
                        child: Container(
                          width: 92,
                          height: 92,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF161D1A), Color(0xFF090C08)],
                            ),
                            borderRadius: BorderRadius.circular(26),
                            border: Border.all(
                              color: const Color(0xFFFF5900).withAlpha(70),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF5900).withAlpha(80),
                                blurRadius: 36,
                                spreadRadius: -6,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(14),
                          child: Image.asset('assets/icon/denikey_emblem.png'),
                        ),
                      )
                      .animate()
                      .fadeIn(duration: AppAnim.slow, curve: AppAnim.smooth)
                      .scale(
                        begin: const Offset(0.78, 0.78),
                        curve: AppAnim.spring,
                        duration: AppAnim.slow,
                      ),

                      const SizedBox(height: 22),

                      // Başlık
                      Text(
                        l10n.masterLockTitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.6,
                          color: cs.onSurface,
                        ),
                      )
                      .animate(delay: AppAnim.entranceDelay(1))
                      .fadeIn(duration: AppAnim.normal)
                      .slideY(begin: 0.25, curve: AppAnim.smooth),

                      const SizedBox(height: 6),

                      // Alt başlık
                      Text(
                        _biometricExpired
                            ? l10n.masterLockBiometricExpired
                            : l10n.masterLockPassword,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
                      )
                      .animate(delay: AppAnim.entranceDelay(2))
                      .fadeIn(duration: AppAnim.normal),

                      const SizedBox(height: 30),

                      // Şifre alanı + kilit açma butonu — buzlu cam kart, sarsma burada
                      AnimatedBuilder(
                        animation: _shakeAnim,
                        builder: (ctx, child) => Transform.translate(
                          offset: Offset(_shakeOffset(_shakeAnim.value), 0),
                          child: child,
                        ),
                        child: GlassCard(
                          padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TextFormField(
                                controller: _ctrl,
                                obscureText: _obscure,
                                autofocus: true,
                                decoration: InputDecoration(
                                  labelText: l10n.masterLockPasswordLabel,
                                  prefixIcon: const Icon(Icons.key_outlined),
                                  suffixIcon: IconButton(
                                    icon: Icon(_obscure
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined),
                                    onPressed: () => setState(() => _obscure = !_obscure),
                                  ),
                                  errorText: _error,
                                ),
                                onFieldSubmitted: (_) => _loading ? null : _unlock(),
                                validator: (v) {
                                  if (v == null || v.isEmpty) return l10n.masterLockPasswordError;
                                  return null;
                                },
                              ),
                              const SizedBox(height: 22),
                              FilledButton(
                                onPressed: _loading ? null : _unlock,
                                child: _loading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(l10n.masterLockButton,
                                        style: const TextStyle(fontSize: 16)),
                              ),

                              // Şifre türetme mesajı
                              if (_loading) ...[
                                const SizedBox(height: 12),
                                Text(
                                  l10n.masterLockDeriving,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
                                ),
                              ],

                              // Biyometrik butonu
                              if (_biometric != null) ...[
                                const SizedBox(height: 14),
                                OutlinedButton.icon(
                                  onPressed: _loading ? null : _biometricUnlock,
                                  icon: Icon(_biometric!.icon),
                                  label: Text(_biometric!.label),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Center(
                                  child: Text(
                                    _remainingDays > 1
                                        ? l10n.masterLockBiometricDaysRemaining(_remainingDays)
                                        : l10n.masterLockBiometricTomorrow,
                                    style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      )
                      .animate(delay: AppAnim.entranceDelay(3))
                      .fadeIn(duration: AppAnim.slow)
                      .slideY(begin: 0.12, curve: AppAnim.smooth),

                      const SizedBox(height: 18),

                      // Farklı hesap butonu
                      TextButton(
                        onPressed: _loading ? null : _logout,
                        child: Text(
                          l10n.masterLockDifferentAccount,
                          style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
                        ),
                      )
                      .animate(delay: AppAnim.entranceDelay(5))
                      .fadeIn(duration: AppAnim.normal),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
