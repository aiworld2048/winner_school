import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../core/constants/api_constants.dart';

class GeneralProvider extends ChangeNotifier {
  String? _token;
  bool _initialized = false;
  bool _loading = false;
  String? _error;

  List<Map<String, dynamic>> _banners = [];
  List<Map<String, dynamic>> _bannerTexts = [];
  List<Map<String, dynamic>> _adsBanners = [];
  List<Map<String, dynamic>> _promotions = [];
  List<Map<String, dynamic>> _contacts = [];

  bool get isLoading => _loading;
  String? get error => _error;
  List<Map<String, dynamic>> get banners => _banners;
  List<Map<String, dynamic>> get bannerTexts => _bannerTexts;
  List<Map<String, dynamic>> get adsBanners => _adsBanners;
  List<Map<String, dynamic>> get promotions => _promotions;
  List<Map<String, dynamic>> get contacts => _contacts;

  void updateToken(String? token) {
    final hasChanged = _token != token;
    _token = token;
    if (!_initialized || hasChanged) {
      _initialized = true;
      load();
    }
  }

  Map<String, String> _headers() {
    final headers = <String, String>{
      'Accept': 'application/json',
    };
    if (_token != null && _token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final responses = await Future.wait([
        _fetch(ApiConstants.banner),
        _fetch(ApiConstants.bannerText),
        _fetch(ApiConstants.popupAds),
        _fetch(ApiConstants.promotions),
        _fetch(ApiConstants.contacts),
      ]);
      _banners = responses[0];
      _bannerTexts = responses[1];
      _adsBanners = responses[2];
      _promotions = responses[3];
      _contacts = responses[4];
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  Future<List<Map<String, dynamic>>> _fetch(String path) async {
    final response = await http.get(
      Uri.parse(ApiConstants.url(path)),
      headers: _headers(),
    );
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final data = decoded['data'];
      if (data is List) {
        return data.map<Map<String, dynamic>>(_normalizeMap).toList(
              growable: false,
            );
      }
      if (data is Map) {
        return [_normalizeMap(data)];
      }
      return [];
    } else {
      throw Exception('Failed to load $path (${response.statusCode})');
    }
  }
}

Map<String, dynamic> _normalizeMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  throw ArgumentError('Expected Map data but received ${value.runtimeType}');
}

