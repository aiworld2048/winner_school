import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/providers/session_provider.dart';
import '../data/wallet_repository.dart';

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  final api = ref.watch(apiClientProvider);
  return WalletRepository(api);
});

final walletBalanceProvider = StateProvider<double>((ref) {
  final session = ref.watch(sessionManagerProvider);
  final profile = session.profile;
  if (profile == null) return 0;
  final raw = profile['balance'];
  return raw is num ? raw.toDouble() : double.tryParse(raw?.toString() ?? '') ?? 0;
});

