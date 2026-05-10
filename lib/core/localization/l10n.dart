import 'package:denikey_app/l10n/generated/app_localizations.dart';

class L10n {
  L10n._();
  static AppLocalizations? _instance;
  static AppLocalizations get s => _instance!;
  static void update(AppLocalizations l10n) => _instance = l10n;
}
