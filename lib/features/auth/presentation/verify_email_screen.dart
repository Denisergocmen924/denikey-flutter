import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../core/constants/api_constants.dart';
import '../data/auth_repository.dart';

// purpose: 'register' | 'new_device'
class VerifyEmailScreen extends ConsumerStatefulWidget {
  final String userId;
  final String email;
  final String purpose;
  final String? masterPassword;
  final String? encryptionKeySalt;

  const VerifyEmailScreen({
    super.key,
    required this.userId,
    required this.email,
    this.purpose = 'register',
    this.masterPassword,
    this.encryptionKeySalt,
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
      setState(() => _error = 'Lütfen 6 haneli kodu girin');
      return;
    }
    setState(() { _loading = true; _error = null; });

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
        await SecureStorage.instance.saveToken(token);
        await SecureStorage.instance.saveRefreshToken(refresh);
      }

      if (mounted) context.go('/vault');
    } catch (e) {
      setState(() {
        _error = 'Geçersiz veya süresi dolmuş kod';
        _loading = false;
      });
    }
  }

  Future<void> _resend() async {
    setState(() { _loading = true; _error = null; });
    try {
      final endpoint = widget.purpose == 'new_device'
          ? ApiConstants.resendVerification
          : ApiConstants.resendVerification;
      await DioClient.instance.dio.post(
        endpoint,
        data: {'user_id': widget.userId},
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kod tekrar gönderildi')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kod gönderilemedi')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String get _title {
    if (widget.purpose == 'new_device') return 'Cihaz Doğrulama';
    return 'E-posta Doğrulama';
  }

  String get _subtitle {
    if (widget.purpose == 'new_device') {
      return 'Bu cihazdan ilk kez giriş yapıyorsunuz.\n${widget.email} adresine gönderilen 6 haneli kodu girin.';
    }
    return '${widget.email} adresine gönderilen\n6 haneli kodu girin';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
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
                color: Colors.deepPurple,
              ),
              const SizedBox(height: 24),
              Text(
                _title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                _subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 40),
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
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _loading
                    ? const SizedBox(height: 20, width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Doğrula', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _loading ? null : _resend,
                child: const Text('Kodu tekrar gönder'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
