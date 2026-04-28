import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _usernameCtrl = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl  = TextEditingController();
  final _formKey      = GlobalKey<FormState>();
  bool _obscure       = true;
  DateTime? _birthDate;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 18),
      firstDate: DateTime(now.year - 120),
      lastDate: DateTime(now.year - 1),
      helpText: 'Doğum Tarihinizi Seçin',
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  int? _age() {
    if (_birthDate == null) return null;
    final now = DateTime.now();
    int age = now.year - _birthDate!.year;
    if (now.month < _birthDate!.month ||
        (now.month == _birthDate!.month && now.day < _birthDate!.day)) {
      age--;
    }
    return age;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen doğum tarihinizi seçin')),
      );
      return;
    }
    if ((_age() ?? 0) < 13) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('DeniKey\'i kullanmak için en az 13 yaşında olmalısınız')),
      );
      return;
    }
    await ref.read(authProvider.notifier).register(
      _usernameCtrl.text.trim(),
      _emailCtrl.text.trim(),
      _passwordCtrl.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authProvider);
    final cs = Theme.of(context).colorScheme;

    ref.listen(authProvider, (_, next) {
      if (next.status == AuthStatus.success) {
        final userId = next.userId ?? '';
        final email = next.email ?? '';
        context.push('/verify-email', extra: {
          'user_id': userId,
          'email': email,
          'master_password': _passwordCtrl.text.trim(),
        });
      }
      if (next.status == AuthStatus.error && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage ?? 'Hata')),
        );
      }
    });

    final isLoading = state.status == AuthStatus.loading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kayıt Ol'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  Icon(Icons.shield_outlined, size: 52,
                    color: cs.primary),
                  const SizedBox(height: 12),
                  Text(
                    'Hesap Oluştur',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Kimliğiniz gizli kalır.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13,
                      color: cs.onSurfaceVariant),
                  ),
                  const SizedBox(height: 36),
                  TextFormField(
                    controller: _usernameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Kullanıcı Adı',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Kullanıcı adı gerekli';
                      if (v.trim().length < 3) return 'En az 3 karakter';
                      if (v.trim().length > 50) return 'En fazla 50 karakter';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'E-posta',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'E-posta gerekli';
                      if (!v.contains('@')) return 'Geçerli e-posta girin';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _passwordCtrl,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      labelText: 'Master Şifre',
                      prefixIcon: const Icon(Icons.key_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(_obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Şifre gerekli';
                      if (v.length < 6) return 'En az 6 karakter';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _confirmCtrl,
                    obscureText: _obscure,
                    decoration: const InputDecoration(
                      labelText: 'Şifre Tekrar',
                      prefixIcon: Icon(Icons.key_outlined),
                    ),
                    validator: (v) {
                      if (v != _passwordCtrl.text) return 'Şifreler eşleşmiyor';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: _pickBirthDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Doğum Tarihi',
                        prefixIcon: Icon(Icons.cake_outlined),
                      ),
                      child: Text(
                        _birthDate == null
                            ? 'Seçiniz'
                            : '${_birthDate!.day.toString().padLeft(2, '0')}.'
                              '${_birthDate!.month.toString().padLeft(2, '0')}.'
                              '${_birthDate!.year}',
                        style: TextStyle(
                          fontSize: 16,
                          color: _birthDate == null
                              ? Theme.of(context).colorScheme.onSurfaceVariant
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  FilledButton(
                    onPressed: isLoading ? null : _submit,
                    child: isLoading
                        ? const SizedBox(height: 22, width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                        : const Text('Kayıt Ol'),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
