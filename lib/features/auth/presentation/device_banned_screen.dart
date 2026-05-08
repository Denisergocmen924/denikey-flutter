import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:denikey_app/l10n/generated/app_localizations.dart';

class DeviceBannedScreen extends StatelessWidget {
  const DeviceBannedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
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
                  l10n.deviceBannedTitle,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.deviceBannedDescription,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => context.go('/login'),
                    child: Text(l10n.deviceBannedBackButton),
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
