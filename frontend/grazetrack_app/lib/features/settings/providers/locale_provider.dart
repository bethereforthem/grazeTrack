import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _prefKey = 'app_locale';

const List<Locale> kSupportedLocales = [
  Locale('en'),
  Locale('fr'),
  Locale('rw'),
];

const Map<String, String> kLocaleNames = {
  'en': 'English',
  'fr': 'Français',
  'rw': 'Kinyarwanda',
};

const Map<String, String> kLocaleNativeNames = {
  'en': 'English',
  'fr': 'Français',
  'rw': 'Ikinyarwanda',
};

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('en')) {
    _restore();
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefKey);
    if (saved != null &&
        kSupportedLocales.any((l) => l.languageCode == saved)) {
      state = Locale(saved);
    }
  }

  Future<void> setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, locale.languageCode);
    state = locale;
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>(
  (ref) => LocaleNotifier(),
);
