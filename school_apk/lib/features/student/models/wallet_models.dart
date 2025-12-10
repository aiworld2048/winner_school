class BankAccount {
  BankAccount({
    required this.id,
    required this.name,
    required this.accountNumber,
    required this.bankId,
    required this.bankName,
    required this.imageUrl,
  });

  final int id;
  final String name;
  final String accountNumber;
  final int bankId;
  final String bankName;
  final String imageUrl;

  factory BankAccount.fromJson(Map<String, dynamic> json) {
    return BankAccount(
      id: json['id'] as int,
      name: json['name']?.toString() ?? '',
      accountNumber: json['no']?.toString() ?? '',
      bankId: json['bank_id'] as int? ?? 0,
      bankName: json['bank_name']?.toString() ?? '',
      imageUrl: json['img']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'no': accountNumber,
      'bank_id': bankId,
      'bank_name': bankName,
      'img': imageUrl,
    };
  }
}

class DepositRequest {
  DepositRequest({
    required this.id,
    required this.agentPaymentTypeId,
    required this.userId,
    required this.teacherId,
    required this.amount,
    required this.referenceNo,
    this.image,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final int agentPaymentTypeId;
  final int userId;
  final int teacherId;
  final int amount;
  final String referenceNo;
  final String? image;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory DepositRequest.fromJson(Map<String, dynamic> json) {
    return DepositRequest(
      id: json['id'] as int,
      agentPaymentTypeId: json['agent_payment_type_id'] as int? ?? 0,
      userId: json['user_id'] as int,
      teacherId: json['teacher_id'] as int? ?? 0,
      amount: json['amount'] is int ? json['amount'] : int.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      referenceNo: json['refrence_no']?.toString() ?? '',
      image: json['image']?.toString(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}

class WithdrawRequest {
  WithdrawRequest({
    required this.id,
    required this.userId,
    required this.agentId,
    required this.amount,
    required this.accountName,
    required this.accountNumber,
    required this.paymentTypeId,
    this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final int userId;
  final int agentId;
  final int amount;
  final String accountName;
  final String accountNumber;
  final int paymentTypeId;
  final String? status;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory WithdrawRequest.fromJson(Map<String, dynamic> json) {
    return WithdrawRequest(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      agentId: json['agent_id'] as int? ?? 0,
      amount: json['amount'] is int ? json['amount'] : int.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      accountName: json['account_name']?.toString() ?? '',
      accountNumber: json['account_number']?.toString() ?? '',
      paymentTypeId: json['payment_type_id'] as int? ?? 0,
      status: json['status']?.toString(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}

