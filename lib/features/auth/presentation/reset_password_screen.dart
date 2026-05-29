import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:denikey_app/l10n/generated/app_localizations.dart';
import '../data/auth_repository.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;

  const ResetPasswordScreen({
    super.key,
    required this.email,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _codeCtrl        = TextEditingController();
  final _passwordCtrl    = TextEditingController();
  final _confirmCtrl     = TextEditingController();
  final _formKey         = GlobalKey<FormState>();
  final _repo            = AuthRepository();
  bool _loading          = false;
  bool _obscurePassword  = true;
  bool _obscureConfirm   = true;

  @override
  void dispose() {
    _codeCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await _repo.resetPassword(
        email: widget.email,
        code: _codeCtrl.text.trim(),
        newMasterPassword: _passwordCtrl.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).resetPasswordSuccess)),
      );
      context.go('/login');
    } on DioException catch (e) {
      if (!mounted) return;
      final msg = e.response?.data['detail'] ?? AppLocalizations.of(context).resetPasswordApiError;
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
      appBar: AppBar(title: Text(l10n.resetPasswordTitle)),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  const Icon(Icons.verified_outlined, size: 64, color: Color(0xFFFF5900)),
                  const SizedBox(height: 16),
                  Text(
                    l10n.resetPasswordHeading,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.resetPasswordDescription(widget.email),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 40),
                  TextFormField(
                    controller: _codeCtrl,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    decoration: InputDecoration(
                      labelText: l10n.resetPasswordCodeLabel,
                      prefixIcon: const Icon(Icons.pin_outlined),
                      border: const OutlineInputBorder(),
                      counterText: '',
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return l10n.resetPasswordCodeError;
                      if (v.length < 6) return l10n.resetPasswordCodeMinError;
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordCtrl,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: l10n.resetPasswordNewLabel,
                      prefixIcon: const Icon(Icons.key_outlined),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return l10n.resetPasswordNewError;
                      if (v.length < 8) return l10n.resetPasswordNewMinError;
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmCtrl,
                    obscureText: _obscureConfirm,
                    decoration: InputDecoration(
                      labelText: l10n.resetPasswordConfirmLabel,
                      prefixIcon: const Icon(Icons.key_outlined),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return l10n.resetPasswordConfirmError;
                      if (v != _passwordCtrl.text) return l10n.resetPasswordConfirmMismatch;
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
                        : Text(l10n.resetPasswordSubmitButton, style: const TextStyle(fontSize: 16)),
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
