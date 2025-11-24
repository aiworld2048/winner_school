import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/constants/api_constants.dart';

class WalletBank {
  WalletBank({
    required this.id,
    required this.name,
    required this.account,
    required this.imageUrl,
  });

  final int id;
  final String name;
  final String account;
  final String imageUrl;

  factory WalletBank.fromJson(Map<String, dynamic> json) {
    final idValue = json['id'] ?? json['bank_id'] ?? json['agent_payment_type_id'];
    final nameValue = json['name'] ?? json['bank_name'] ?? json['payment_type'] ?? '';
    final accountValue = json['no'] ?? json['account_number'] ?? json['bank_no'] ?? '';
    final imageValue = json['img'] ?? json['logo'] ?? json['image'] ?? '';

    return WalletBank(
      id: int.tryParse(idValue?.toString() ?? '') ?? 0,
      name: nameValue.toString(),
      account: accountValue.toString(),
      imageUrl: resolveImageUrl(imageValue?.toString()),
    );
  }
}

class WalletOperationResult {
  WalletOperationResult({
    required this.success,
    required this.message,
    this.fieldErrors,
  });

  final bool success;
  final String message;
  final Map<String, List<String>>? fieldErrors;
}

class WalletService {
  static Future<List<WalletBank>> fetchBanks(String token) async {
    final response = await http.get(
      Uri.parse(ApiConstants.url('banks')),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final data = decoded['data'];
      if (data is List) {
        return data
            .map((e) => WalletBank.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(growable: false);
      }
      return [];
    }
    throw Exception('Failed to load banks (${response.statusCode})');
  }

  static Future<WalletOperationResult> deposit({
    required String token,
    required int agentPaymentTypeId,
    required String amount,
    required String reference,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConstants.url('depositfinicial')),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'agent_payment_type_id': agentPaymentTypeId,
        'amount': amount,
        'refrence_no': reference,
      }),
    );

    return _parseOperationResponse(response);
  }

  static Future<WalletOperationResult> withdraw({
    required String token,
    required int paymentTypeId,
    required String accountName,
    required String accountNumber,
    required String amount,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConstants.url('withdrawfinicial')),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'payment_type_id': paymentTypeId,
        'account_name': accountName,
        'account_number': accountNumber,
        'amount': amount,
        'password': password,
      }),
    );

    return _parseOperationResponse(response);
  }

  static WalletOperationResult _parseOperationResponse(http.Response response) {
    try {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final message = decoded['message']?.toString() ?? 'Request was successful.';
        return WalletOperationResult(success: true, message: message);
      }

      Map<String, List<String>>? fieldErrors;
      final errors = decoded['errors'];
      if (errors is Map<String, dynamic>) {
        fieldErrors = errors.map((key, value) {
          if (value is List) {
            return MapEntry(key, value.map((e) => e.toString()).toList());
          }
          return MapEntry(key, [value.toString()]);
        });
      }

      final message = decoded['message']?.toString() ?? 'Request failed';
      return WalletOperationResult(
        success: false,
        message: message,
        fieldErrors: fieldErrors,
      );
    } catch (_) {
      return WalletOperationResult(
        success: false,
        message: 'Unexpected server response',
      );
    }
  }
}
