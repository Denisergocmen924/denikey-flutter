import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:denikey_app/l10n/generated/app_localizations.dart';

class AppNavBar extends StatelessWidget {
  final int currentIndex;
  const AppNavBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) {
        switch (index) {
          case 0:
            context.go('/vault');
          case 1:
            context.go('/categories');
          case 2:
            context.go('/settings');
        }
      },
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.shield_outlined),
          selectedIcon: const Icon(Icons.shield),
          label: l10n.navBarVault,
        ),
        NavigationDestination(
          icon: const Icon(Icons.grid_view_outlined),
          selectedIcon: const Icon(Icons.grid_view),
          label: l10n.navBarLibrary,
        ),
        NavigationDestination(
          icon: const Icon(Icons.settings_outlined),
          selectedIcon: const Icon(Icons.settings),
          label: l10n.navBarSettings,
        ),
      ],
    );
  }
}
