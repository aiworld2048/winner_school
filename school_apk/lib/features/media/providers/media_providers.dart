import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../data/media_repository.dart';
import '../models/media_models.dart';

final mediaRepositoryProvider = Provider<MediaRepository>((ref) {
  final api = ref.watch(apiClientProvider);
  return MediaRepository(api);
});

final mediaBannersProvider = FutureProvider.autoDispose<List<MediaBanner>>((ref) async {
  final repo = ref.watch(mediaRepositoryProvider);
  return repo.fetchBanners();
});

final mediaPromotionsProvider = FutureProvider.autoDispose<List<PromotionItem>>((ref) async {
  final repo = ref.watch(mediaRepositoryProvider);
  return repo.fetchPromotions();
});

final mediaBannerTextsProvider = FutureProvider.autoDispose<List<String>>((ref) async {
  final repo = ref.watch(mediaRepositoryProvider);
  return repo.fetchBannerTexts();
});

final mediaContactsProvider = FutureProvider.autoDispose<List<ContactInfo>>((ref) async {
  final repo = ref.watch(mediaRepositoryProvider);
  return repo.fetchContacts();
});

