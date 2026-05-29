import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/password_generator_provider.dart';
import 'package:denikey_app/l10n/generated/app_localizations.dart';
import '../../../core/presentation/app_nav_bar.dart';
import '../../../core/providers/clipboard_timeout_provider.dart';

class PasswordGeneratorScreen extends ConsumerStatefulWidget {
  const PasswordGeneratorScreen({super.key});

  @override
  ConsumerState<PasswordGeneratorScreen> createState() => _PasswordGeneratorScreenState();
}

class _PasswordGeneratorScreenState extends ConsumerState<PasswordGeneratorScreen> {
  Timer? _clipboardTimer;

  @override
  void dispose() {
    _clipboardTimer?.cancel();
    super.dispose();
  }

  void _copyToClipboard(String password) {
    final timeout = ref.read(clipboardTimeoutProvider);
    Clipboard.setData(ClipboardData(text: password));
    _clipboardTimer?.cancel();
    if (timeout != null) {
      _clipboardTimer = Timer(Duration(seconds: timeout), () {
        Clipboard.setData(const ClipboardData(text: ''));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(passwordGeneratorProvider);
    final notifier = ref.read(passwordGeneratorProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.passwordGeneratorTitle)),
      bottomNavigationBar: const AppNavBar(currentIndex: 3),
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
                      l10n.passwordGeneratorHint,
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
                      tooltip: l10n.passwordGeneratorCopy,
                      onPressed: () {
                        _copyToClipboard(state.generatedPassword!);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.check_circle_outline,
                                    color: Colors.white, size: 18),
                                const SizedBox(width: 8),
                                Text(l10n.passwordGeneratorCopySuccess),
                              ],
                            ),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
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
                Text(l10n.passwordGeneratorLength, style: const TextStyle(fontWeight: FontWeight.w600)),
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
              activeColor: Theme.of(context).colorScheme.primary,
              onChanged: (v) => notifier.setLength(v.round()),
            ),

            const SizedBox(height: 16),
            Text(
              l10n.passwordGeneratorCharacterTypes,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),

            // Karakter tipi seçenekleri
            _OptionTile(
              label: l10n.passwordGeneratorUppercase,
              value: state.uppercase,
              onTap: notifier.toggleUppercase,
            ),
            _OptionTile(
              label: l10n.passwordGeneratorLowercase,
              value: state.lowercase,
              onTap: notifier.toggleLowercase,
            ),
            _OptionTile(
              label: l10n.passwordGeneratorNumbers,
              value: state.numbers,
              onTap: notifier.toggleNumbers,
            ),
            _OptionTile(
              label: l10n.passwordGeneratorSymbols,
              value: state.symbols,
              onTap: notifier.toggleSymbols,
            ),

            const SizedBox(height: 32),

            FilledButton.icon(
              onPressed: state.isLoading ? null : notifier.generate,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              icon: const Icon(Icons.autorenew),
              label: Text(l10n.passwordGeneratorGenerate, style: const TextStyle(fontSize: 16)),
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
      activeColor: Theme.of(context).colorScheme.primary,
      controlAffinity: ListTileControlAffinity.leading,
      onChanged: (_) => onTap(),
    );
  }
}
