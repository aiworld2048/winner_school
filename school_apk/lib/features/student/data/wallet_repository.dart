import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';

class WalletRepository {
  WalletRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<void> submitDeposit({
    required int agentPaymentTypeId,
    required double amount,
    required String referenceNo,
    MultipartFile? slip,
  }) async {
    final formData = FormData.fromMap({
      'agent_payment_type_id': agentPaymentTypeId,
      'amount': amount.toInt(),
      'refrence_no': referenceNo,
      if (slip != null) 'image': slip,
    });

    await _apiClient.post('depositfinicial', data: formData);
  }

  Future<void> submitWithdraw({
    required int paymentTypeId,
    required double amount,
    required String accountName,
    required String accountNumber,
    required String password,
  }) async {
    await _apiClient.post(
      'withdrawfinicial',
      data: {
        'payment_type_id': paymentTypeId,
        'amount': amount.toInt(),
        'account_name': accountName,
        'account_number': accountNumber,
        'password': password,
      },
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

  Future<List<dynamic>> fetchPaymentTypes() async {
    final response = await _apiClient.get('paymentTypefinicial');
    return response['data'] as List<dynamic>? ?? [];
  }

  Future<List<dynamic>> fetchAgentPaymentTypes() async {
    final response = await _apiClient.get('agentfinicialPaymentType');
    return response['data'] as List<dynamic>? ?? [];
  }

  Future<List<dynamic>> fetchBanks() async {
    final response = await _apiClient.get('banks');
    return response['data'] as List<dynamic>? ?? [];
  }
}

