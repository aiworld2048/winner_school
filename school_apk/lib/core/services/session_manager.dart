import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const _tokenKey = 'auth_token';
  static const _profileKey = 'user_profile';

  SharedPreferences? _prefs;

  bool get isReady => _prefs != null;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  String? get token => _prefs?.getString(_tokenKey);

  Map<String, dynamic>? get profile {
    final raw = _prefs?.getString(_profileKey);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> saveSession({
    required String token,
    required Map<String, dynamic> profile,
  }) async {
    await _prefs?.setString(_tokenKey, token);
    await _prefs?.setString(_profileKey, jsonEncode(profile));
  }

  Future<void> updateProfile(Map<String, dynamic> profile) async {
    await _prefs?.setString(_profileKey, jsonEncode(profile));
  }

  Future<void> clear() async {
    await _prefs?.remove(_tokenKey);
    await _prefs?.remove(_profileKey);
  }
}

