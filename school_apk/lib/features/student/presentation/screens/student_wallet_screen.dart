import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/widgets/async_value_widget.dart';
import '../../../../common/widgets/empty_state.dart';
import '../../../../core/providers/session_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/providers/auth_controller.dart';
import '../../providers/wallet_providers.dart';

class StudentWalletScreen extends ConsumerStatefulWidget {
  const StudentWalletScreen({super.key});

  @override
  ConsumerState<StudentWalletScreen> createState() => _StudentWalletScreenState();
}

class _StudentWalletScreenState extends ConsumerState<StudentWalletScreen> {
  final _depositAmountController = TextEditingController();
  final _depositReferenceController = TextEditingController();
  final _withdrawAmountController = TextEditingController();
  final _withdrawAccountNameController = TextEditingController();
  final _withdrawAccountNumberController = TextEditingController();
  final _withdrawPasswordController = TextEditingController();

  int? _selectedAgentPaymentTypeId;
  int? _selectedPaymentTypeId;
  int? _selectedBankId;
  bool _depositing = false;
  bool _withdrawing = false;
  bool _withdrawPasswordVisible = false;

  @override
  void dispose() {
    _depositAmountController.dispose();
    _depositReferenceController.dispose();
    _withdrawAmountController.dispose();
    _withdrawAccountNameController.dispose();
    _withdrawAccountNumberController.dispose();
    _withdrawPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleDeposit() async {
    final amount = double.tryParse(_depositAmountController.text);
    final reference = _depositReferenceController.text.trim();
    final typeId = _selectedAgentPaymentTypeId;
    if (typeId == null) return _showError('Please select a payment method.');
    if (amount == null || amount < 1000) {
      return _showError('Enter a valid amount (minimum 1000 MMK).');
    }
    if (reference.length != 6 || int.tryParse(reference) == null) {
      return _showError('Reference number must be 6 digits.');
    }
    setState(() => _depositing = true);
    try {
      final repo = ref.read(walletRepositoryProvider);
      await repo.submitDeposit(
        agentPaymentTypeId: typeId,
        amount: amount,
        referenceNo: reference,
      );
      await ref.read(authControllerProvider.notifier).refreshUser();
      ref.invalidate(_depositLogsProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Deposit submitted')));
      _depositAmountController.clear();
      _depositReferenceController.clear();
    } catch (error) {
      _showError(error.toString());
    } finally {
      if (mounted) setState(() => _depositing = false);
    }
  }

  Future<void> _handleWithdraw() async {
    final amount = double.tryParse(_withdrawAmountController.text);
    final paymentTypeId = _selectedPaymentTypeId;
    if (paymentTypeId == null) return _showError('Select withdraw payment type.');
    if (amount == null || amount < 10000) {
      return _showError('Enter a valid amount (minimum 10000 MMK).');
    }
    final accountName = _withdrawAccountNameController.text.trim();
    final accountNumber = _withdrawAccountNumberController.text.trim();
    final password = _withdrawPasswordController.text;
    if (accountName.isEmpty || accountNumber.isEmpty || password.isEmpty) {
      return _showError('Please fill out all withdraw fields.');
    }

    setState(() => _withdrawing = true);
    try {
      final repo = ref.read(walletRepositoryProvider);
      await repo.submitWithdraw(
        paymentTypeId: paymentTypeId,
        amount: amount,
        accountName: accountName,
        accountNumber: accountNumber,
        password: password,
      );
      await ref.read(authControllerProvider.notifier).refreshUser();
      ref.invalidate(_withdrawLogsProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Withdraw submitted')));
      _withdrawAmountController.clear();
      _withdrawAccountNameController.clear();
      _withdrawAccountNumberController.clear();
      _withdrawPasswordController.clear();
    } catch (error) {
      _showError(error.toString());
    } finally {
      if (mounted) setState(() => _withdrawing = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionManagerProvider);
    final profile = session.profile;
    final balance = profile?['balance']?.toString() ?? '0';

    final depositLogs = ref.watch(_depositLogsProvider);
    final withdrawLogs = ref.watch(_withdrawLogsProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Wallet balance'),
                Text(
                  '$balance MMK',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildDepositCard(ref),
        const SizedBox(height: 16),
        _buildWithdrawCard(ref),
        const SizedBox(height: 24),
        Text('Deposit history', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        AsyncValueWidget(
          value: depositLogs,
          builder: (logs) {
            if (logs.isEmpty) {
              return const EmptyState(
                title: 'No deposit history',
                icon: Icons.history,
              );
            }
            return _buildLogList(logs);
          },
        ),
        const SizedBox(height: 24),
        Text('Withdraw history', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        AsyncValueWidget(
          value: withdrawLogs,
          builder: (logs) {
            if (logs.isEmpty) {
              return const EmptyState(
                title: 'No withdraw history',
                icon: Icons.history,
              );
            }
            return _buildLogList(logs);
          },
        ),
      ],
    );
  }

  Widget _buildLogList(List<dynamic> logs) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final log = logs[index] as Map<String, dynamic>;
        final amount = log['amount']?.toString() ?? '0';
        final status = log['status']?.toString() ?? '';
        return ListTile(
          title: Text('$amount MMK'),
          subtitle: Text(status),
          leading: const Icon(Icons.receipt_long),
        );
      },
      separatorBuilder: (_, __) => const Divider(),
      itemCount: logs.length,
    );
  }

  Widget _buildDepositCard(WidgetRef ref) {
    final agentTypes = ref.watch(agentPaymentTypesProvider);
    final paymentTypes = ref.watch(paymentTypesProvider);
    final banks = ref.watch(banksProvider);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Deposit', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            AsyncValueWidget(
              value: paymentTypes,
              builder: (types) {
                if (types.isEmpty) {
                  return const Text('No payment types available.');
                }
                if (_selectedPaymentTypeId == null) {
                  _selectedPaymentTypeId = types.first['id'] as int;
                }
                return DropdownButtonFormField<int>(
                  value: _selectedPaymentTypeId,
                  decoration: const InputDecoration(labelText: 'Payment type'),
                  items: types
                      .map(
                        (item) => DropdownMenuItem(
                          value: item['id'] as int,
                          child: Text(item['name']?.toString() ?? 'Payment'),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPaymentTypeId = value;
                      _selectedAgentPaymentTypeId = null;
                      _selectedBankId = null;
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 12),
            AsyncValueWidget(
              value: banks,
              builder: (items) {
                if (items.isEmpty || _selectedPaymentTypeId == null) {
                  return const Text('No banks available for this type.');
                }
                final filtered = items
                    .where(
                      (item) =>
                          item['bank_id']?.toString() == _selectedPaymentTypeId.toString(),
                    )
                    .toList();
                if (filtered.isEmpty) {
                  return const Text('No banks available for this type.');
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<int>(
                      value: _selectedBankId,
                      decoration: const InputDecoration(labelText: 'Bank / wallet'),
                      items: filtered
                          .map(
                            (item) => DropdownMenuItem(
                              value: item['id'] as int,
                              child: Text('${item['bank_name']} • ${item['no']}'),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => setState(() => _selectedBankId = value),
                    ),
                    if (_selectedBankId != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          'Account name: ${_findBankName(filtered, _selectedBankId!)}',
                          style: const TextStyle(color: AppColors.muted),
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            AsyncValueWidget(
              value: agentTypes,
              builder: (types) {
                if (types.isEmpty || _selectedPaymentTypeId == null) {
                  return const Text('No payment channels available.');
                }
                final filtered = types
                    .where(
                      (item) =>
                          item['payment_type_id']?.toString() ==
                          _selectedPaymentTypeId.toString(),
                    )
                    .toList();
                if (filtered.isEmpty) {
                  return const Text('No payment channels available.');
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<int>(
                      value: _selectedAgentPaymentTypeId,
                      decoration: const InputDecoration(labelText: 'Payment channel'),
                      items: filtered
                          .map(
                            (item) => DropdownMenuItem(
                              value: item['id'] as int,
                              child: Text('${item['payment_type']} • ${item['account_number']}'),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => setState(() => _selectedAgentPaymentTypeId = value),
                    ),
                    if (_selectedAgentPaymentTypeId != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          'Account name: ${_findAccountName(filtered, _selectedAgentPaymentTypeId!)}',
                          style: const TextStyle(color: AppColors.muted),
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _depositAmountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount (MMK)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _depositReferenceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Reference no.'),
              maxLength: 6,
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _depositing ? null : _handleDeposit,
              child: _depositing
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Submit deposit request'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWithdrawCard(WidgetRef ref) {
    final paymentTypes = ref.watch(paymentTypesProvider);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Withdraw', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            AsyncValueWidget(
              value: paymentTypes,
              builder: (types) {
                if (types.isEmpty) {
                  return const Text('No withdraw payment types available.');
                }
                return DropdownButtonFormField<int>(
                  value: _selectedPaymentTypeId,
                  decoration: const InputDecoration(labelText: 'Payment type'),
                  items: types
                      .map(
                        (item) => DropdownMenuItem(
                          value: item['id'] as int,
                          child: Text(item['name']?.toString() ?? 'Payment'),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _selectedPaymentTypeId = value),
                );
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _withdrawAccountNameController,
              decoration: const InputDecoration(labelText: 'Account holder name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _withdrawAccountNumberController,
              decoration: const InputDecoration(labelText: 'Account number'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _withdrawAmountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount (MMK)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _withdrawPasswordController,
              obscureText: !_withdrawPasswordVisible,
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: IconButton(
                  icon: Icon(_withdrawPasswordVisible ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _withdrawPasswordVisible = !_withdrawPasswordVisible),
                ),
              ),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _withdrawing ? null : _handleWithdraw,
              child: _withdrawing
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Submit withdraw request'),
            ),
          ],
        ),
      ),
    );
  }

  String _findAccountName(List<dynamic> types, int id) {
    final match = types.cast<Map<String, dynamic>>().firstWhere(
          (element) => element['id'] == id,
          orElse: () => const {},
        );
    return (match['account_name']?.toString() ?? '').isEmpty ? '—' : match['account_name'].toString();
  }

  String _findBankName(List<dynamic> banks, int id) {
    final match = banks.cast<Map<String, dynamic>>().firstWhere(
          (element) => element['id'] == id,
          orElse: () => const {},
        );
    return [
      match['name']?.toString(),
      match['bank_name']?.toString(),
    ].whereType<String>().where((value) => value.trim().isNotEmpty).join(' • ');
  }
}

final _depositLogsProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final repo = ref.watch(walletRepositoryProvider);
  return repo.fetchDepositLogs();
});

final _withdrawLogsProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final repo = ref.watch(walletRepositoryProvider);
  return repo.fetchWithdrawLogs();
});

