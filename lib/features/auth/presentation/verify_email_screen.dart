import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:denikey_app/l10n/generated/app_localizations.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/crypto/encryption_service.dart';
import '../data/auth_repository.dart';

// purpose: 'register' | 'new_device'
class VerifyEmailScreen extends ConsumerStatefulWidget {
  final String userId;
  final String email;
  final String purpose;
  final String? masterPassword;
  final String? encryptionKeySalt;
  final String? emailVerifyToken;

  const VerifyEmailScreen({
    super.key,
    required this.userId,
    required this.email,
    this.purpose = 'register',
    this.masterPassword,
    this.encryptionKeySalt,
    this.emailVerifyToken,
  });

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  final _codeCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (_codeCtrl.text.trim().length != 6) {
      setState(() => _error = AppLocalizations.of(context).verifyCodeError);
      return;
    }
    setState(() { _loading = true; _error = null; });
    final networkErrorMsg = AppLocalizations.of(context).networkError;

    try {
      if (widget.purpose == 'new_device') {
        await AuthRepository().verifyDevice(
          userId: widget.userId,
          code: _codeCtrl.text.trim(),
          masterPassword: widget.masterPassword ?? '',
          encryptionKeySalt: widget.encryptionKeySalt ?? '',
        );
      } else {
        final deviceId = await SecureStorage.instance.getDeviceId();
        final response = await DioClient.instance.dio.post(
          ApiConstants.verifyEmail,
          data: {
            'user_id': widget.userId,
            'code': _codeCtrl.text.trim(),
            'device_id': deviceId,
            'device_type': AuthRepository().getDeviceType(),
          },
        );
        final token = response.data['access_token'] as String;
        final refresh = response.data['refresh_token'] as String;
        final salt = response.data['encryption_key_salt'] as String;
        await SecureStorage.instance.saveToken(token);
        await SecureStorage.instance.saveRefreshToken(refresh);
        await SecureStorage.instance.saveEmail(widget.email);
        if (widget.masterPassword != null && widget.masterPassword!.isNotEmpty) {
          final masterKey = await EncryptionService.instance.deriveMasterKey(
            widget.masterPassword!,
            salt,
          );
          await SecureStorage.instance.saveMasterKey(masterKey);
          await SecureStorage.instance.saveEncryptionSalt(salt);
          final blob = await EncryptionService.instance.encrypt('denikey-verify', masterKey);
          await SecureStorage.instance.saveVerificationBlob(blob['encrypted']!, blob['iv']!);
        }
      }

      if (mounted) context.go('/vault');
    } on DioException catch (e) {
      final msg = e.response?.data?['detail']?.toString()
          ?? e.message
          ?? networkErrorMsg;
      setState(() { _error = msg; _loading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _resend() async {
    setState(() { _loading = true; _error = null; });
    try {
      await DioClient.instance.dio.post(
        ApiConstants.resendVerification,
        data: {'temp_token': widget.emailVerifyToken ?? ''},
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).verifySendSuccess)),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).verifySendError)),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _title(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (widget.purpose == 'new_device') return l10n.verifyDeviceTitle;
    return l10n.verifyEmailTitle;
  }

  String _subtitle(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (widget.purpose == 'new_device') {
      return l10n.verifyDeviceSubtitle(widget.email);
    }
    return l10n.verifyEmailSubtitle(widget.email);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_title(context)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              Icon(
                widget.purpose == 'new_device'
                    ? Icons.devices_outlined
                    : Icons.mark_email_read_outlined,
                size: 64,
                color: const Color(0xFFFF5900),
              ),
              const SizedBox(height: 24),
              Text(
                _title(context),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                _subtitle(context),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline, size: 14, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(
                    l10n.verifySpamWarning,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              TextField(
                controller: _codeCtrl,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(fontSize: 28, letterSpacing: 12, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  counterText: '',
                  errorText: _error,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _loading ? null : _verify,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _loading
                    ? const SizedBox(height: 20, width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(l10n.verifySubmitButton, style: const TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _loading ? null : _resend,
                child: Text(l10n.verifyResendButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
