import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/api_constants.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider() {
    _bootstrap();
  }

  static const _tokenKey = 'token';
  static const _profileKey = 'userProfile';

  String? _token;
  Map<String, dynamic>? _profile;
  bool _loading = false;
  Map<String, dynamic>? _errors;
  Timer? _balanceTimer;

  String? get token => _token;
  Map<String, dynamic>? get profile => _profile;
  bool get isAuthenticated => _token != null && _token!.isNotEmpty;
  bool get isLoading => _loading;
  Map<String, dynamic>? get errors => _errors;

  String get displayName {
    final name = _profile?['name'] ?? _profile?['user_name'];
    if (name is String) return name;
    return 'Player';
  }

  double get balance {
    final raw = _profile?['balance'];
    if (raw == null) return 0;
    return double.tryParse(raw.toString()) ?? 0;
  }

  double get mainBalance {
    final raw = _profile?['main_balance'];
    if (raw == null) return 0;
    return double.tryParse(raw.toString()) ?? 0;
  }

  Future<void> _bootstrap() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
    final profileJson = prefs.getString(_profileKey);
    if (profileJson != null) {
      _profile = jsonDecode(profileJson) as Map<String, dynamic>;
    }
    if (_token != null) {
      await refreshProfile();
      _startBalanceTimer();
    } else {
      notifyListeners();
    }
  }

  Map<String, String> _headers({bool includeAuth = false}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (includeAuth && _token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  Future<bool> login(String username, String password) async {
    _loading = true;
    _errors = null;
    notifyListeners();
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.url(ApiConstants.login)),
        headers: _headers(),
        body: jsonEncode({
          'user_name': username,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 && data['data'] != null) {
        final payload = data['data'] as Map<String, dynamic>;
        _token = payload['token'] as String?;
        _profile = (payload['user'] as Map<String, dynamic>?);
        await _persist();
        _startBalanceTimer();
        _loading = false;
        notifyListeners();
        return true;
      } else {
        _errors = data['errors'] as Map<String, dynamic>?;
      }
    } catch (e) {
      _errors = {'message': e.toString()};
    }
    _loading = false;
    notifyListeners();
    return false;
  }

  Future<Map<String, dynamic>?> register({
    required String name,
    required String phone,
    required String password,
    required String confirmPassword,
    String? referralCode,
  }) async {
    _loading = true;
    _errors = null;
    notifyListeners();
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.url(ApiConstants.register)),
        headers: _headers(),
        body: jsonEncode({
          'name': name,
          'phone': phone,
          'password': password,
          'password_confirmation': confirmPassword,
          'referral_code': referralCode,
        }),
      );
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 && data['data'] != null) {
        final payload = data['data'] as Map<String, dynamic>;
        _token = payload['token'] as String?;
        _profile = payload['user'] as Map<String, dynamic>?;
        await _persist();
        _startBalanceTimer();
        _loading = false;
        notifyListeners();
        // Return account info for display
        return {
          'user': _profile,
          'password': password, // Include password for display
        };
      } else {
        _errors = data['errors'] as Map<String, dynamic>?;
      }
    } catch (e) {
      _errors = {'message': e.toString()};
    }
    _loading = false;
    notifyListeners();
    return null;
  }

  Future<void> refreshProfile({bool silent = false}) async {
    if (_token == null) return;
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.url(ApiConstants.user)),
        headers: _headers(includeAuth: true),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        _profile = data['data'] as Map<String, dynamic>?;
        await _persist();
      } else if (response.statusCode == 401) {
        await clearSession();
      }
    } catch (_) {
      if (!silent) {
        // ignore network errors silently for now
      }
    }
    notifyListeners();
  }

  Future<void> logout() async {
    try {
      if (_token != null) {
        await http.post(
          Uri.parse(ApiConstants.url(ApiConstants.logout)),
          headers: _headers(includeAuth: true),
        );
      }
    } catch (_) {
      // ignore
    }
    await clearSession();
  }

  Future<void> clearSession() async {
    _token = null;
    _profile = null;
    _balanceTimer?.cancel();
    _balanceTimer = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_profileKey);
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    if (_token != null) {
      await prefs.setString(_tokenKey, _token!);
    }
    if (_profile != null) {
      await prefs.setString(_profileKey, jsonEncode(_profile));
    }
  }

  void _startBalanceTimer() {
    _balanceTimer?.cancel();
    if (_token == null || _token!.isEmpty) return;
    _balanceTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => refreshProfile(silent: true),
    );
  }
}

