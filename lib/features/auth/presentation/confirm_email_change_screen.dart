import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/auth_repository.dart';
import '../../../core/storage/secure_storage.dart';
import 'package:denikey_app/l10n/generated/app_localizations.dart';

class ConfirmEmailChangeScreen extends StatefulWidget {
  final String newEmail;

  const ConfirmEmailChangeScreen({super.key, required this.newEmail});

  @override
  State<ConfirmEmailChangeScreen> createState() => _ConfirmEmailChangeScreenState();
}

class _ConfirmEmailChangeScreenState extends State<ConfirmEmailChangeScreen> {
  final _codeCtrl = TextEditingController();
  final _formKey  = GlobalKey<FormState>();
  final _repo     = AuthRepository();
  bool _loading   = false;

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await _repo.confirmEmailChange(
        code: _codeCtrl.text.trim(),
        newEmail: widget.newEmail,
      );
      await SecureStorage.instance.saveEmail(widget.newEmail);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).confirmEmailChangeSuccess)),
      );
      context.go('/settings');
    } on DioException catch (e) {
      if (!mounted) return;
      final msg = e.response?.data['detail'] ?? AppLocalizations.of(context).confirmEmailChangeApiError;
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
      appBar: AppBar(title: Text(l10n.confirmEmailChangeTitle)),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.verified_outlined, size: 64, color: Color(0xFFFF5900)),
                  const SizedBox(height: 16),
                  Text(
                    l10n.confirmEmailChangeHeading,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.confirmEmailChangeDescription(widget.newEmail),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 40),
                  TextFormField(
                    controller: _codeCtrl,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24, letterSpacing: 8),
                    decoration: InputDecoration(
                      labelText: l10n.confirmEmailChangeCodeLabel,
                      border: const OutlineInputBorder(),
                      counterText: '',
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return l10n.confirmEmailChangeCodeError;
                      if (v.length < 6) return l10n.confirmEmailChangeCodeMinError;
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
                        : Text(l10n.confirmEmailChangeSubmitButton, style: const TextStyle(fontSize: 16)),
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
