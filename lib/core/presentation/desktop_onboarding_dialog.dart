import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:denikey_app/l10n/generated/app_localizations.dart';

const _kKey = 'desktop_onboarding_done';

Future<void> showDesktopOnboardingIfNeeded(BuildContext context) async {
  if (!Platform.isWindows && !Platform.isLinux) return;
  final prefs = await SharedPreferences.getInstance();
  if (prefs.getBool(_kKey) == true) return;
  await prefs.setBool(_kKey, true);
  if (!context.mounted) return;
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const _DesktopOnboardingDialog(),
  );
}

class _DesktopOnboardingDialog extends StatelessWidget {
  const _DesktopOnboardingDialog();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final isWindows = Platform.isWindows;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.keyboard_outlined, color: cs.primary, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    l10n.desktopOnboardingTitle,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                l10n.desktopOnboardingDescription,
                style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 20),
              _shortcutRow(cs, 'Ctrl + 1 / 2 / 3', l10n.desktopOnboardingShortcut1),
              _shortcutRow(cs, 'Ctrl + N', l10n.desktopOnboardingShortcut2),
              _shortcutRow(cs, 'Ctrl + F', l10n.desktopOnboardingShortcut3),
              _shortcutRow(cs, 'Ctrl + G', l10n.desktopOnboardingShortcut4),
              _shortcutRow(cs, '← →', l10n.desktopOnboardingShortcut5),
              _shortcutRow(cs, 'Escape', l10n.desktopOnboardingShortcut6),
              if (isWindows) ...[
                const SizedBox(height: 16),
                Divider(color: cs.outlineVariant),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: cs.onSurfaceVariant),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.desktopOnboardingWindowsNote,
                        style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant, height: 1.5),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.desktopOnboardingButton),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _shortcutRow(ColorScheme cs, String key, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Text(
              key,
              style: TextStyle(
                fontSize: 12,
                fontFamily: 'monospace',
                color: cs.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Text(description, style: TextStyle(fontSize: 13, color: cs.onSurface)),
        ],
      ),
    );
  }
}
