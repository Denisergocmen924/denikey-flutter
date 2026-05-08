import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:denikey_app/l10n/generated/app_localizations.dart';
import '../providers/auth_provider.dart';

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
      if (next.status == AuthStatus.needsDeviceVerification) {
        context.push('/verify-email', extra: {
          'user_id': next.userId,
          'email': next.email,
          'purpose': 'new_device',
          'master_password': next.masterPassword,
        });
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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 48),
                  Center(
                    child: Image.asset(
                      'assets/icon/denikey_logo.png',
                      width: 160,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'DeniKey',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.loginTagline,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14,
                      color: cs.onSurfaceVariant),
                  ),
                  const SizedBox(height: 48),
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
                  ),
                  const SizedBox(height: 14),
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
                  ),
                  const SizedBox(height: 28),
                  FilledButton(
                    onPressed: isLoading ? null : _submit,
                    child: isLoading
                        ? const SizedBox(height: 22, width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                        : Text(l10n.loginSubmitButton),
                  ),
                  const SizedBox(height: 20),
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
                  ),
                  Center(
                    child: TextButton(
                      onPressed: () => context.push('/forgot-password'),
                      child: Text(l10n.loginForgotButton,
                        style: TextStyle(color: cs.onSurfaceVariant)),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
