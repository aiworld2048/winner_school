class ApiConstants {
  static const String _defaultOrigin = 'http://10.0.2.2:8000';
  static const String baseOrigin =
      String.fromEnvironment('API_ORIGIN', defaultValue: _defaultOrigin);
  static const String baseUrl = '$baseOrigin/api';

  static String url(String path) => '$baseUrl/$path';

  static const banner = 'banner';
  static const bannerText = 'banner_Text';
  static const popupAds = 'popup-ads-banner';
  static const promotions = 'promotion';
  static const contacts = 'contact';
  static const videoAds = 'videoads';

  static const gameTypes = 'game_types';
  static String providers(String code) => 'providers/$code';
  static String gameList(String typeId, int providerId) =>
      'game_lists/$typeId/$providerId';
  static const hotGames = 'hot_game_lists';
  static const launchGame = 'seamless/launch-game';

  static const login = 'login';
  static const register = 'register';
  static const user = 'user';
  static const logout = 'logout';
  static const exchangeMainToGame = 'exchange-main-to-game';
  static const exchangeGameToMain = 'exchange-game-to-main';
}

String resolveImageUrl(String? path) {
  if (path == null || path.isEmpty) {
    return '';
  }
  if (path.startsWith('http')) {
    return path;
  }
  final normalized = path.replaceFirst(RegExp(r'^\.\.'), '');
  return '${ApiConstants.baseOrigin}$normalized';
}

