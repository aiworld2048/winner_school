class ApiConstants {
  ApiConstants._();

  static const String baseOrigin =
      String.fromEnvironment('API_ORIGIN', defaultValue: 'https://lion11.site');
  static const String baseUrl = '$baseOrigin/api/';

  static String url(String path) => '$baseUrl/$path';
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

