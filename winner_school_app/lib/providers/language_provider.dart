import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/language_data.dart';

class LanguageProvider extends ChangeNotifier {
  LanguageProvider() {
    _bootstrap();
  }

  static const _storageKey = 'lan';

  String _locale = 'en';
  Map<String, dynamic> _content = enLanguage;

  String get locale => _locale;
  Map<String, dynamic> get content => _content;

  List<Map<String, String>> get supportedLanguages => availableLanguages.entries
      .map((entry) => {
            'code': entry.key,
            'label': entry.value['label'] as String,
          })
      .toList();

  Future<void> updateLanguage(String code) async {
    if (!availableLanguages.containsKey(code)) return;
    if (_locale == code) return;
    _locale = code;
    _content = availableLanguages[code]!;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, code);
  }

  Future<void> _bootstrap() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_storageKey);
    if (code != null && availableLanguages.containsKey(code)) {
      _locale = code;
      _content = availableLanguages[code]!;
    }
    notifyListeners();
  }

  String translate(String path) {
    final segments = path.split('.');
    dynamic current = _content;
    for (final segment in segments) {
      if (current is Map<String, dynamic> && current.containsKey(segment)) {
        current = current[segment];
      } else {
        return path;
      }
    }
    return current is String ? current : path;
  }
}

