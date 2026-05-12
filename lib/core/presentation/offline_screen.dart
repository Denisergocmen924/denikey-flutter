import 'package:flutter/material.dart';
import 'package:denikey_app/l10n/generated/app_localizations.dart';

class OfflineScreen extends StatelessWidget {
  const OfflineScreen({super.key});

  static const _onyx   = Color(0xFF090C08);
  static const _orange = Color(0xFFFF5900);
  static const _cream  = Color(0xFFE8EDE9);
  static const _muted  = Color(0xFF9BABA4);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: _onyx,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),

                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: _orange, width: 2),
                    color: _orange.withAlpha(20),
                  ),
                  child: const Icon(
                    Icons.wifi_off_outlined,
                    size: 44,
                    color: _orange,
                  ),
                ),

                const SizedBox(height: 32),

                Text(
                  l10n.offlineTitle,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: _cream,
                    letterSpacing: -0.5,
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 20),

                Text(
                  l10n.offlineMessage,
                  style: const TextStyle(
                    fontSize: 15,
                    color: _muted,
                    height: 1.7,
                  ),
                  textAlign: TextAlign.center,
                ),

                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
