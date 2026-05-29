import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:denikey_app/l10n/generated/app_localizations.dart';
import '../data/auth_repository.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  final _formKey   = GlobalKey<FormState>();
  final _repo      = AuthRepository();
  bool _loading    = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await _repo.forgotPassword(email: _emailCtrl.text.trim());
      if (!mounted) return;
      context.push('/reset-password', extra: {
        'email': _emailCtrl.text.trim(),
      });
    } on DioException catch (e) {
      if (!mounted) return;
      final msg = e.response?.data['detail'] ?? AppLocalizations.of(context).forgotPasswordApiError;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg.toString())),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.forgotPasswordTitle)),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.lock_reset, size: 64, color: Color(0xFFFF5900)),
                  const SizedBox(height: 16),
                  Text(
                    l10n.forgotPasswordHeading,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.forgotPasswordDescription,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 40),
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: l10n.forgotPasswordEmailLabel,
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return l10n.forgotPasswordEmailError;
                      if (!v.contains('@')) return l10n.forgotPasswordEmailFormatError;
                      return null;
                    },
                  ),
                  const SizedBox(height: 28),
                  FilledButton(
                    onPressed: _loading ? null : _submit,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(l10n.forgotPasswordSubmitButton, style: const TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
