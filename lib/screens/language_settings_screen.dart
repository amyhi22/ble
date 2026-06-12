// lib/screens/language_settings_screen.dart
//
// Changes from old version:
//   ❌ Removed: AppLanguage enum usage
//   ❌ Removed: AppLocalizations / loc.xxx
//   ❌ Removed: langProvider.language comparison
//   ✅ Added:   'key'.tr() for all strings
//   ✅ Added:   context.setLocale() for language switching
//   ✅ Added:   context.locale comparison for selected state

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class LanguageSettingsScreen extends StatelessWidget {
  const LanguageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Each entry: (locale, flag, translatedLabel, nativeLabel)
    final languages = [
      (const Locale('en'), '🇬🇧', 'language.english'.tr(), 'English'),
      (const Locale('fr'), '🇫🇷', 'language.french'.tr(),  'Français'),
      (const Locale('ar'), '🇩🇿', 'language.arabic'.tr(),  'العربية'),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF594020),
        elevation: 0,
        title: Text(
          'language.title'.tr(),                          // ← was: loc.languageTitle
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Text(
              'language.subtitle'.tr(),                   // ← was: loc.languageSubtitle
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF6B5D4F),
              ),
            ),
            const SizedBox(height: 24),

            ...languages.map((entry) {
              final (locale, flag, label, nativeLabel) = entry;
              final isSelected = context.locale == locale; // ← was: langProvider.language == lang

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _LanguageTile(
                  flag: flag,
                  label: label,
                  nativeLabel: nativeLabel,
                  isSelected: isSelected,
                  onTap: () => context.setLocale(locale), // ← was: langProvider.setLanguage(lang)
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// _LanguageTile is unchanged — no localization logic inside it
class _LanguageTile extends StatelessWidget {
  final String flag;
  final String label;
  final String nativeLabel;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.flag,
    required this.label,
    required this.nativeLabel,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF594020).withOpacity(0.08)
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF594020)
                  : const Color(0xFFE8E4DC),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF768E2E).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(flag, style: const TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? const Color(0xFF594020)
                            : const Color(0xFF2D2D2D),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      nativeLabel,
                      style: TextStyle(
                        fontSize: 13,
                        color: const Color(0xFF6B5D4F).withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: isSelected
                    ? const Icon(
                        Icons.check_circle_rounded,
                        color: Color(0xFF594020),
                        size: 26,
                        key: ValueKey('check'),
                      )
                    : const SizedBox(width: 26, key: ValueKey('empty')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
