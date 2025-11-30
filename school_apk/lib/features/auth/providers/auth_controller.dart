import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/providers/session_provider.dart';
import '../data/auth_repository.dart';
import '../models/auth_user.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final api = ref.watch(apiClientProvider);
  final session = ref.watch(sessionManagerProvider);
  return AuthRepository(api, session);
});

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<AuthUser?>>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  final controller = AuthController(repo);
  controller.bootstrap();
  return controller;
});

class AuthController extends StateNotifier<AsyncValue<AuthUser?>> {
  AuthController(this._repository) : super(const AsyncLoading());

  final AuthRepository _repository;

  Future<void> bootstrap() async {
    state = const AsyncLoading();
    final user = await _repository.currentUser();
    state = AsyncData(user);
  }

  Future<void> login(String phone, String password) async {
    state = const AsyncLoading();
    try {
      final user = await _repository.login(phone: phone, password: password);
      state = AsyncData(user);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> register(String name, String phone, String password) async {
    state = const AsyncLoading();
    try {
      final user = await _repository.register(
        name: name,
        phone: phone,
        password: password,
      );
      state = AsyncData(user);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AsyncData(null);
  }

  Future<void> refreshUser() async {
    final current = state.valueOrNull;
    final user = await _repository.currentUser();
    if (user != null) {
      state = AsyncData(user);
    } else if (current == null) {
      state = const AsyncData(null);
    }
  }

  void updateBalance(double balance) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(balance: balance));
  }
}

