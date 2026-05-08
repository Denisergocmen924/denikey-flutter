import 'package:flutter/material.dart';
import 'package:denikey_app/l10n/generated/app_localizations.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.privacyPolicyTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        children: [
          Text(
            l10n.privacyPolicyLastUpdate,
            style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 20),
          _Section(title: l10n.privacyPolicySection1Title, body: l10n.privacyPolicySection1Body),
          _Section(title: l10n.privacyPolicySection2Title, body: l10n.privacyPolicySection2Body),
          _Section(title: l10n.privacyPolicySection3Title, body: l10n.privacyPolicySection3Body),
          _Section(title: l10n.privacyPolicySection4Title, body: l10n.privacyPolicySection4Body),
          _Section(title: l10n.privacyPolicySection5Title, body: l10n.privacyPolicySection5Body),
          _Section(title: l10n.privacyPolicySection6Title, body: l10n.privacyPolicySection6Body),
          _Section(title: l10n.privacyPolicySection7Title, body: l10n.privacyPolicySection7Body),
          _Section(title: l10n.privacyPolicySection8Title, body: l10n.privacyPolicySection8Body),
          _Section(title: l10n.privacyPolicySection9Title, body: l10n.privacyPolicySection9Body),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String body;
  const _Section({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: cs.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: TextStyle(
              fontSize: 14,
              color: cs.onSurfaceVariant,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
