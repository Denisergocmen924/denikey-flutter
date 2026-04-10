import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/password_generator_provider.dart';

class PasswordGeneratorScreen extends ConsumerWidget {
  const PasswordGeneratorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(passwordGeneratorProvider);
    final notifier = ref.read(passwordGeneratorProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Şifre Üretici')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Üretilen şifre gösterimi
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  if (state.isLoading)
                    const CircularProgressIndicator()
                  else if (state.generatedPassword != null)
                    Text(
                      state.generatedPassword!,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2,
                        fontFamily: 'monospace',
                      ),
                      textAlign: TextAlign.center,
                    )
                  else
                    Text(
                      'Şifre üretmek için butona basın',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  if (state.generatedPassword != null) ...[
                    const SizedBox(height: 12),
                    IconButton.filled(
                      icon: const Icon(Icons.copy_outlined),
                      tooltip: 'Kopyala',
                      onPressed: () {
                        Clipboard.setData(
                          ClipboardData(text: state.generatedPassword!),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Şifre kopyalandı')),
                        );
                      },
                    ),
                  ],
                  if (state.error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        state.error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Uzunluk seçici
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Uzunluk', style: TextStyle(fontWeight: FontWeight.w600)),
                Text(
                  '${state.length}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            Slider(
              value: state.length.toDouble(),
              min: 8,
              max: 64,
              divisions: 56,
              activeColor: Colors.deepPurple,
              onChanged: (v) => notifier.setLength(v.round()),
            ),

            const SizedBox(height: 16),
            const Text(
              'Karakter Tipleri',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),

            // Karakter tipi seçenekleri
            _OptionTile(
              label: 'Büyük Harf (A–Z)',
              value: state.uppercase,
              onTap: notifier.toggleUppercase,
            ),
            _OptionTile(
              label: 'Küçük Harf (a–z)',
              value: state.lowercase,
              onTap: notifier.toggleLowercase,
            ),
            _OptionTile(
              label: 'Rakam (0–9)',
              value: state.numbers,
              onTap: notifier.toggleNumbers,
            ),
            _OptionTile(
              label: 'Sembol (!@#\$...)',
              value: state.symbols,
              onTap: notifier.toggleSymbols,
            ),

            const SizedBox(height: 32),

            FilledButton.icon(
              onPressed: state.isLoading ? null : notifier.generate,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.deepPurple,
              ),
              icon: const Icon(Icons.autorenew),
              label: const Text('Şifre Üret', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String label;
  final bool value;
  final VoidCallback onTap;

  const _OptionTile({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: Text(label),
      value: value,
      activeColor: Colors.deepPurple,
      controlAffinity: ListTileControlAffinity.leading,
      onChanged: (_) => onTap(),
    );
  }
}
