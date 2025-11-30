import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../models/media_models.dart';

class MediaRepository {
  MediaRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<MediaBanner>> fetchBanners() async {
    final response = await _apiClient.get('banner');
    final items = _extractList(response);
    return items.map((e) => MediaBanner.fromJson(e)).toList();
  }

  Future<List<PromotionItem>> fetchPromotions() async {
    final response = await _apiClient.get('promotion');
    final items = _extractList(response);
    return items.map((e) => PromotionItem.fromJson(e)).toList();
  }

  Future<List<String>> fetchBannerTexts() async {
    final response = await _apiClient.get('banner_Text');
    final list = _extractList(response);
    if (list.isNotEmpty) {
      return list
          .map((item) => (item['title'] ?? item['text'] ?? item['message'] ?? '').toString())
          .where((text) => text.trim().isNotEmpty)
          .toList();
    }
    if (response is Map<String, dynamic>) {
      final data = response['data'];
      if (data is String && data.isNotEmpty) return [data];
    }
    return const [];
  }

  Future<List<ContactInfo>> fetchContacts() async {
    final response = await _apiClient.get('contact');
    final items = _extractList(response);
    return items.map((e) => ContactInfo.fromJson(e)).toList();
  }

  List<Map<String, dynamic>> _extractList(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      final data = payload['data'] ?? payload['items'] ?? payload['result'];
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map((item) => _resolveImage(item))
            .toList();
      }
      if (data is Map<String, dynamic>) {
        return [_resolveImage(data)];
      }
    } else if (payload is List) {
      return payload.whereType<Map<String, dynamic>>().map(_resolveImage).toList();
    }
    return const [];
  }

  Map<String, dynamic> _resolveImage(Map<String, dynamic> json) {
    final image = json['image'];
    if (image is String && image.isNotEmpty) {
      json = Map<String, dynamic>.from(json);
      json['image'] = resolveImageUrl(image);
    }
    return json;
  }
}

