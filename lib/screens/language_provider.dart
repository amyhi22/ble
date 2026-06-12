// lib/providers/language_provider.dart
//
// Thin wrapper around easy_localization.
// All translation is done via 'key'.tr() directly in widgets.
// This provider exists only if you need to read the locale
// outside of a BuildContext (e.g. in a service).

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier {
  /// Change language — persisted automatically by easy_localization.
  Future<void> setLanguage(BuildContext context, Locale locale) async {
    await context.setLocale(locale);
    notifyListeners();
  }

  /// Current locale — read directly from easy_localization.
  Locale currentLocale(BuildContext context) => context.locale;

  /// RTL check.
  bool isRtl(BuildContext context) =>
      context.locale.languageCode == 'ar';
}
