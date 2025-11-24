import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../core/constants/api_constants.dart';

class GameProvider extends ChangeNotifier {
  String? _token;
  bool _initialised = false;

  bool _loadingTypes = false;
  bool _loadingGames = false;
  bool _loadingMore = false;
  String? _error;

  final List<Map<String, dynamic>> _types = [];
  final Map<int, List<Map<String, dynamic>>> _providersCache = {};
  final Map<int, String> _typeCodeLookup = {};

  final List<Map<String, dynamic>> _hotGames = [];
  List<Map<String, dynamic>> _currentGames = [];

  String _viewMode = 'all'; // all, hot, type
  int? _selectedTypeId;
  int? _selectedProviderId;

  int _currentPage = 1;
  bool _hasMoreGames = false;

  static const int _pageSizeFallback = 20;

  bool get isLoadingTypes => _loadingTypes;
  bool get isLoadingGames => _loadingGames;
  bool get isLoadingMoreGames => _loadingMore;
  String? get error => _error;
  List<Map<String, dynamic>> get types => List.unmodifiable(_types);
  List<Map<String, dynamic>> get hotGames => List.unmodifiable(_hotGames);
  List<Map<String, dynamic>> get currentGames => List.unmodifiable(_currentGames);
  String get viewMode => _viewMode;
  int? get selectedTypeId => _selectedTypeId;
  int? get selectedProviderId => _selectedProviderId;
  bool get hasMoreGames => _hasMoreGames;

  void updateToken(String? token) {
    final hasChanged = _token != token;
    _token = token;
    if (!_initialised || hasChanged) {
      _initialised = true;
      loadInitial();
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

  Future<void> loadInitial() async {
    _loadingTypes = true;
    _error = null;
    notifyListeners();
    try {
      final typesResponse = await http.get(
        Uri.parse(ApiConstants.url(ApiConstants.gameTypes)),
        headers: _headers(),
      );
      if (typesResponse.statusCode == 200) {
        _types
          ..clear()
          ..addAll(_decodeList(typesResponse));
        _typeCodeLookup
          ..clear()
          ..addEntries(_types.map(
            (type) => MapEntry<int, String>(
              int.tryParse(type['id'].toString()) ?? 0,
              type['code']?.toString() ?? '',
            ),
          ));
      } else {
        throw Exception('Failed to load game types');
      }

      final hotResponse = await http.get(
        Uri.parse(ApiConstants.url(ApiConstants.hotGames)),
        headers: _headers(),
      );
      if (hotResponse.statusCode == 200) {
        _hotGames
          ..clear()
          ..addAll(_decodeList(hotResponse));
      }
      // default view resets to "all"
      _viewMode = 'all';
      _selectedTypeId = null;
      _selectedProviderId = null;
      _currentGames = [];
      _currentPage = 1;
      _hasMoreGames = false;
      _loadingMore = false;
    } catch (e) {
      _error = e.toString();
    }
    _loadingTypes = false;
    notifyListeners();
  }

  Future<List<Map<String, dynamic>>> providersForType(int typeId) async {
    if (_providersCache.containsKey(typeId)) {
      return _providersCache[typeId]!;
    }
    final code = _typeCodeLookup[typeId];
    if (code == null || code.isEmpty) return [];
    final response = await http.get(
      Uri.parse(ApiConstants.url(ApiConstants.providers(code))),
      headers: _headers(),
    );
    if (response.statusCode == 200) {
      final providers = _decodeList(response);
      _providersCache[typeId] = providers;
      notifyListeners();
      return providers;
    }
    return [];
  }

  Future<void> selectAll() async {
    _viewMode = 'all';
    _selectedTypeId = null;
    _selectedProviderId = null;
    _currentGames = [];
    _currentPage = 1;
    _hasMoreGames = false;
    _loadingMore = false;
    notifyListeners();
  }

  Future<void> selectHot() async {
    _viewMode = 'hot';
    _selectedTypeId = null;
    _selectedProviderId = null;
    _currentGames = List<Map<String, dynamic>>.from(_hotGames);
    _currentPage = 1;
    _hasMoreGames = false;
    _loadingMore = false;
    notifyListeners();
  }

  Future<void> selectType(int typeId) async {
    _viewMode = 'type';
    _selectedTypeId = typeId;
    _selectedProviderId = null;
    _currentGames = [];
    _currentPage = 1;
    _hasMoreGames = false;
    _loadingGames = false;
    _loadingMore = false;
    notifyListeners();
    await providersForType(typeId);
  }

  Future<void> selectProvider(int providerId) async {
    if (_selectedTypeId == null) return;
    _selectedProviderId = providerId;
    _loadingGames = true;
    _loadingMore = false;
    _hasMoreGames = false;
    _currentGames = [];
    _currentPage = 1;
    notifyListeners();
    try {
      final page = await _fetchGamesPage(providerId, 1);
      _currentGames = page.games;
      _currentPage = page.currentPage;
      _hasMoreGames = page.hasMore;
    } catch (_) {
      _currentGames = [];
      _hasMoreGames = false;
    }
    _loadingGames = false;
    notifyListeners();
  }

  Future<void> loadMoreGames() async {
    if (_selectedTypeId == null || _selectedProviderId == null) return;
    if (!_hasMoreGames || _loadingMore) return;
    _loadingMore = true;
    notifyListeners();
    try {
      final nextPage = _currentPage + 1;
      final page = await _fetchGamesPage(_selectedProviderId!, nextPage);
      _currentGames = List<Map<String, dynamic>>.from(_currentGames)
        ..addAll(page.games);
      _currentPage = page.currentPage;
      _hasMoreGames = page.hasMore;
    } catch (_) {
      _hasMoreGames = false;
    }
    _loadingMore = false;
    notifyListeners();
  }

  Future<_GamePage> _fetchGamesPage(int providerId, int page) async {
    final url =
        '${ApiConstants.url(ApiConstants.gameList(_selectedTypeId!.toString(), providerId))}?page=$page';
    final response = await http.get(
      Uri.parse(url),
      headers: _headers(),
    );
    if (response.statusCode == 200) {
      return _parseGameResponse(response, page);
    }
    throw Exception('Failed to load games');
  }

  List<Map<String, dynamic>> _decodeList(http.Response response) {
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final data = decoded['data'];
    if (data is List) {
      return data
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(growable: false);
    }
    return [];
  }

  _GamePage _parseGameResponse(http.Response response, int requestedPage) {
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final data = decoded['data'];
    final games = data is List
        ? data
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList(growable: false)
        : <Map<String, dynamic>>[];

    int currentPage = requestedPage;
    bool hasMore = false;

    final meta = decoded['meta'];
    if (meta is Map<String, dynamic>) {
      final metaCurrent = meta['current_page'];
      final metaLast = meta['last_page'];
      final metaNext = meta['next_page'] ?? meta['next_page_url'];
      currentPage = int.tryParse(metaCurrent?.toString() ?? '') ?? currentPage;
      final lastPage = int.tryParse(metaLast?.toString() ?? '') ?? currentPage;
      hasMore = currentPage < lastPage;
      if (!hasMore && metaNext != null && metaNext.toString().isNotEmpty) {
        hasMore = true;
      }
    }

    final links = decoded['links'];
    if (!hasMore && links is Map) {
      final next = links['next'] ?? links['next_page_url'];
      if (next != null && next.toString().isNotEmpty) {
        hasMore = true;
      }
    }

    if (!hasMore && games.length >= _pageSizeFallback) {
      hasMore = true;
    }

    return _GamePage(
      games: games,
      currentPage: currentPage,
      hasMore: hasMore,
    );
  }
}

class _GamePage {
  const _GamePage({
    required this.games,
    required this.currentPage,
    required this.hasMore,
  });

  final List<Map<String, dynamic>> games;
  final int currentPage;
  final bool hasMore;
}

