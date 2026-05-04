import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DeviceBannedScreen extends StatelessWidget {
  const DeviceBannedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.block, size: 72, color: cs.error),
                const SizedBox(height: 24),
                Text(
                  'Cihaz Yasaklandı',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Bu hesap için bu cihaz kullanılamıyor.\nHesap sahibi tarafından erişiminiz kısıtlanmıştır.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => context.go('/login'),
                    child: const Text('Geri Dön'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
