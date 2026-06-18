import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:denikey_app/l10n/generated/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../providers/totp_provider.dart';
import '../../../core/presentation/app_animations.dart';
import '../../../core/presentation/aurora_background.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _formKey      = GlobalKey<FormState>();
  bool _obscure       = true;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authProvider.notifier).login(
      _usernameCtrl.text.trim(),
      _passwordCtrl.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authProvider);
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    ref.listen(authProvider, (_, next) {
      if (next.status == AuthStatus.success) {
        context.go('/vault');
      }
      if (next.status == AuthStatus.needsEmailVerification) {
        context.push('/verify-email', extra: {
          'user_id': next.userId,
          'email': next.email,
          'purpose': 'register',
          'email_verify_token': next.emailVerifyToken,
        });
      }
      if (next.status == AuthStatus.needsDeviceVerification) {
        final pw = ref.read(authProvider.notifier).consumeMasterPassword();
        context.push('/verify-email', extra: {
          'user_id': next.userId,
          'email': next.email,
          'purpose': 'new_device',
          'master_password': pw,
          'email_verify_token': next.emailVerifyToken,
        });
      }
      if (next.status == AuthStatus.needsTotp) {
        final pw = ref.read(authProvider.notifier).consumeMasterPassword();
        ref.read(totpPendingProvider.notifier).set(TotpPendingState(
          tempToken: next.totpTempToken!,
          masterPassword: pw ?? '',
          username: next.username!,
        ));
        context.push('/totp-verify-login');
      }
      if (next.status == AuthStatus.deviceBanned) {
        context.push('/device-banned');
      }
      if (next.status == AuthStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage ?? AppLocalizations.of(context).loginError)),
        );
      }
    });

    final isLoading = state.status == AuthStatus.loading;

    return Scaffold(
      body: AuroraBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo — turuncu halka ışıltısı
                    Center(
                      child: Container(
                        width: 104,
                        height: 104,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF161D1A), Color(0xFF090C08)],
                          ),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: const Color(0xFFFF5900).withAlpha(70),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF5900).withAlpha(90),
                              blurRadius: 44,
                              spreadRadius: -6,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(18),
                        child: Image.asset('assets/icon/denikey_emblem.png'),
                      ),
                    )
                    .animate()
                    .fadeIn(duration: AppAnim.slow, curve: AppAnim.smooth)
                    .scale(
                      begin: const Offset(0.80, 0.80),
                      curve: AppAnim.spring,
                      duration: AppAnim.slow,
                    ),

                    const SizedBox(height: 22),

                    // Başlık
                    Text(
                      'DeniKey',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: cs.onSurface,
                        letterSpacing: -1.0,
                      ),
                    )
                    .animate(delay: AppAnim.entranceDelay(1))
                    .fadeIn(duration: AppAnim.normal)
                    .slideY(begin: 0.25, curve: AppAnim.smooth),

                    const SizedBox(height: 6),

                    // Alt başlık
                    Text(
                      l10n.loginTagline,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14.5, color: cs.onSurfaceVariant),
                    )
                    .animate(delay: AppAnim.entranceDelay(2))
                    .fadeIn(duration: AppAnim.normal),

                    const SizedBox(height: 32),

                    // Form — buzlu cam kart
                    Form(
                      key: _formKey,
                      child: GlassCard(
                        padding: const EdgeInsets.fromLTRB(22, 26, 22, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Kullanıcı adı
                            TextFormField(
                              controller: _usernameCtrl,
                              decoration: InputDecoration(
                                labelText: l10n.loginUsernameLabel,
                                prefixIcon: const Icon(Icons.person_outline),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) return l10n.loginUsernameError;
                                if (v.length < 3) return l10n.loginUsernameMinError;
                                return null;
                              },
                            )
                            .animate(delay: AppAnim.entranceDelay(3))
                            .fadeIn(duration: AppAnim.normal)
                            .slideY(begin: 0.2, curve: AppAnim.smooth),

                            const SizedBox(height: 14),

                            // Şifre
                            TextFormField(
                              controller: _passwordCtrl,
                              obscureText: _obscure,
                              decoration: InputDecoration(
                                labelText: l10n.loginPasswordLabel,
                                prefixIcon: const Icon(Icons.key_outlined),
                                suffixIcon: IconButton(
                                  icon: Icon(_obscure
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined),
                                  onPressed: () => setState(() => _obscure = !_obscure),
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) return l10n.loginPasswordError;
                                if (v.length < 6) return l10n.loginPasswordMinError;
                                return null;
                              },
                            )
                            .animate(delay: AppAnim.entranceDelay(4))
                            .fadeIn(duration: AppAnim.normal)
                            .slideY(begin: 0.2, curve: AppAnim.smooth),

                            const SizedBox(height: 24),

                            // Giriş butonu
                            FilledButton(
                              onPressed: isLoading ? null : _submit,
                              child: isLoading
                                  ? const SizedBox(height: 22, width: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white))
                                  : Text(l10n.loginSubmitButton),
                            )
                            .animate(delay: AppAnim.entranceDelay(5))
                            .fadeIn(duration: AppAnim.normal)
                            .slideY(begin: 0.15, curve: AppAnim.smooth),
                          ],
                        ),
                      ),
                    )
                    .animate(delay: AppAnim.entranceDelay(3))
                    .fadeIn(duration: AppAnim.slow)
                    .slideY(begin: 0.10, curve: AppAnim.smooth),

                    const SizedBox(height: 20),

                    // Kayıt ol satırı
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(l10n.loginNoAccountQuestion,
                          style: TextStyle(color: cs.onSurfaceVariant)),
                        TextButton(
                          onPressed: () {
                            ref.read(authProvider.notifier).reset();
                            context.go('/register');
                          },
                          child: Text(l10n.loginRegisterButton),
                        ),
                      ],
                    )
                    .animate(delay: AppAnim.entranceDelay(6))
                    .fadeIn(duration: AppAnim.normal),

                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
