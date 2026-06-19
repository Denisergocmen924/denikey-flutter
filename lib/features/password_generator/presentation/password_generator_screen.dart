import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/password_generator_provider.dart';
import 'package:denikey_app/l10n/generated/app_localizations.dart';
import '../../../core/presentation/app_nav_bar.dart';
import '../../../core/presentation/app_animations.dart';
import '../../../core/providers/clipboard_timeout_provider.dart';

const _blaze = Color(0xFFFF5900);
const _teal  = Color(0xFF24C9B5);

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
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.passwordGeneratorTitle)),
      bottomNavigationBar: const AppNavBar(currentIndex: 3),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Üretilen şifre gösterimi — derinlikli, turuncu aksanlı kart ──
            Container(
              padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [const Color(0xFF161D1A), const Color(0xFF0E1310)]
                      : [Colors.white, const Color(0xFFF3F2EE)],
                ),
                border: Border.all(color: _blaze.withAlpha(state.generatedPassword != null ? 90 : 40)),
                boxShadow: [
                  BoxShadow(
                    color: _blaze.withAlpha(state.generatedPassword != null ? 36 : 0),
                    blurRadius: 28,
                    spreadRadius: -8,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                children: [
                  if (state.isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: CircularProgressIndicator(),
                    )
                  else if (state.generatedPassword != null)
                    Text(
                      state.generatedPassword!,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                        fontFamily: 'monospace',
                        color: cs.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        l10n.passwordGeneratorHint,
                        style: TextStyle(
                          fontSize: 14,
                          color: cs.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  if (state.generatedPassword != null) ...[
                    const SizedBox(height: 18),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 46),
                        padding: const EdgeInsets.symmetric(horizontal: 22),
                      ),
                      icon: const Icon(Icons.copy_outlined, size: 18),
                      label: Text(l10n.passwordGeneratorCopy),
                      onPressed: () {
                        _copyToClipboard(state.generatedPassword!);
                        final timeout = ref.read(clipboardTimeoutProvider);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.check_circle_outline,
                                    color: Colors.white, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    timeout != null
                                        ? l10n.passwordGeneratorCopySuccess(timeout)
                                        : l10n.passwordGeneratorCopySuccessNoTimeout,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                  if (state.error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        state.error!,
                        style: TextStyle(color: cs.error, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            )
            .animate()
            .fadeIn(duration: AppAnim.slow, curve: AppAnim.smooth)
            .slideY(begin: 0.12, curve: AppAnim.smooth),

            const SizedBox(height: 28),

            // ── Uzunluk seçici ──
            Row(
              children: [
                Text(l10n.passwordGeneratorLength,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _blaze.withAlpha(28),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _blaze.withAlpha(70)),
                  ),
                  child: Text(
                    '${state.length}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 15, color: _blaze),
                  ),
                ),
              ],
            )
            .animate(delay: AppAnim.entranceDelay(1))
            .fadeIn(duration: AppAnim.normal),

            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 6,
                activeTrackColor: _blaze,
                inactiveTrackColor: _blaze.withAlpha(40),
                thumbColor: _blaze,
                overlayColor: _blaze.withAlpha(36),
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 11),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 22),
              ),
              child: Slider(
                value: state.length.toDouble(),
                min: 8,
                max: 64,
                divisions: 56,
                onChanged: (v) => notifier.setLength(v.round()),
              ),
            )
            .animate(delay: AppAnim.entranceDelay(1))
            .fadeIn(duration: AppAnim.normal),

            const SizedBox(height: 18),
            Text(
              l10n.passwordGeneratorCharacterTypes,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            )
            .animate(delay: AppAnim.entranceDelay(2))
            .fadeIn(duration: AppAnim.normal),
            const SizedBox(height: 12),

            // ── Karakter tipi seçenekleri — premium toggle kartları ──
            _OptionTile(
              icon: Icons.text_fields,
              accent: _blaze,
              label: l10n.passwordGeneratorUppercase,
              sample: 'A B C',
              value: state.uppercase,
              onTap: notifier.toggleUppercase,
            )
            .animate(delay: AppAnim.entranceDelay(3))
            .fadeIn(duration: AppAnim.normal).slideY(begin: 0.15, curve: AppAnim.smooth),
            const SizedBox(height: 10),
            _OptionTile(
              icon: Icons.text_format,
              accent: _teal,
              label: l10n.passwordGeneratorLowercase,
              sample: 'a b c',
              value: state.lowercase,
              onTap: notifier.toggleLowercase,
            )
            .animate(delay: AppAnim.entranceDelay(4))
            .fadeIn(duration: AppAnim.normal).slideY(begin: 0.15, curve: AppAnim.smooth),
            const SizedBox(height: 10),
            _OptionTile(
              icon: Icons.pin_outlined,
              accent: const Color(0xFF8B7CF6),
              label: l10n.passwordGeneratorNumbers,
              sample: '1 2 3',
              value: state.numbers,
              onTap: notifier.toggleNumbers,
            )
            .animate(delay: AppAnim.entranceDelay(5))
            .fadeIn(duration: AppAnim.normal).slideY(begin: 0.15, curve: AppAnim.smooth),
            const SizedBox(height: 10),
            _OptionTile(
              icon: Icons.tag,
              accent: const Color(0xFFFFB020),
              label: l10n.passwordGeneratorSymbols,
              sample: '# \$ &',
              value: state.symbols,
              onTap: notifier.toggleSymbols,
            )
            .animate(delay: AppAnim.entranceDelay(6))
            .fadeIn(duration: AppAnim.normal).slideY(begin: 0.15, curve: AppAnim.smooth),

            const SizedBox(height: 30),

            FilledButton.icon(
              onPressed: state.isLoading ? null : notifier.generate,
              icon: const Icon(Icons.autorenew),
              label: Text(l10n.passwordGeneratorGenerate, style: const TextStyle(fontSize: 16)),
            )
            .animate(delay: AppAnim.entranceDelay(7))
            .fadeIn(duration: AppAnim.normal)
            .slideY(begin: 0.15, curve: AppAnim.smooth),
          ],
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final Color accent;
  final String label;
  final String sample;
  final bool value;
  final VoidCallback onTap;

  const _OptionTile({
    required this.icon,
    required this.accent,
    required this.label,
    required this.sample,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: value ? accent.withAlpha(18) : cs.surfaceContainer,
            border: Border.all(
              color: value ? accent.withAlpha(120) : cs.outlineVariant,
              width: value ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              // Duotone ikon kümesi
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [accent.withAlpha(55), accent.withAlpha(20)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: accent.withAlpha(60)),
                ),
                child: Icon(icon, color: accent, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                      style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(sample,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontFamily: 'monospace',
                        letterSpacing: 1,
                        color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
              Switch(
                value: value,
                activeThumbColor: accent,
                onChanged: (_) => onTap(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
