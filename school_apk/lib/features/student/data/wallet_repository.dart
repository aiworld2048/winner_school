import '../../../core/network/api_client.dart';

class WalletRepository {
  WalletRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<dynamic> deposit(double amount) {
    return _apiClient.post(
      'depositfinicial',
      data: {'amount': amount},
    );
  }

  Future<dynamic> withdraw(double amount) {
    return _apiClient.post(
      'withdrawfinicial',
      data: {'amount': amount},
    );
  }

  Future<List<dynamic>> fetchDepositLogs() async {
    final response = await _apiClient.get('depositlogfinicial');
    return response['data'] as List<dynamic>? ?? [];
  }

  Future<List<dynamic>> fetchWithdrawLogs() async {
    final response = await _apiClient.get('withdrawlogfinicial');
    return response['data'] as List<dynamic>? ?? [];
  }
}

