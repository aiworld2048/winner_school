import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

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

  Map<String, dynamic>? _selectedDepositBank;
  int? _selectedPaymentTypeId;
  bool _depositing = false;
  bool _withdrawing = false;
  bool _withdrawPasswordVisible = false;
  File? _depositSlipImage;
  final ImagePicker _imagePicker = ImagePicker();

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
    final bank = _selectedDepositBank;
    if (bank == null) return _showError('Please choose a bank.');
    final bankId = bank['id'] as int?;
    if (bankId == null) return _showError('Invalid bank information.');
    if (amount == null || amount < 1000) {
      return _showError('Enter a valid amount (minimum 1000 MMK).');
    }
    if (reference.length != 6 || int.tryParse(reference) == null) {
      return _showError('Reference number must be 6 digits.');
    }
    setState(() => _depositing = true);
    try {
      final repo = ref.read(walletRepositoryProvider);
      MultipartFile? slipFile;
      if (_depositSlipImage != null) {
        final fileName = _depositSlipImage!.path.split('/').last;
        slipFile = await MultipartFile.fromFile(
          _depositSlipImage!.path,
          filename: fileName,
        );
      }
      await repo.submitDeposit(
        agentPaymentTypeId: bankId,
        amount: amount,
        referenceNo: reference,
        slip: slipFile,
      );
      await ref.read(authControllerProvider.notifier).refreshUser();
      ref.invalidate(_depositLogsProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Deposit submitted successfully')));
      _depositAmountController.clear();
      _depositReferenceController.clear();
      setState(() => _depositSlipImage = null);
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
    final depositBanks = ref.watch(banksProvider);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: AsyncValueWidget(
          value: depositBanks,
          builder: (banks) {
            if (banks.isEmpty) {
              return const Text('No banks available for deposit.');
            }
            final castBanks = banks.cast<Map<String, dynamic>>();
            _ensureDepositBankSelected(castBanks);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Deposit', style: Theme.of(context).textTheme.titleMedium),
                    const Spacer(),
                    FilledButton.tonal(
                      onPressed: () => _selectBank(castBanks),
                      child: const Text('Choose Bank'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_selectedDepositBank != null)
                  _BankCard(
                    bank: _selectedDepositBank!,
                    onCopy: () => _copyBankNo(_selectedDepositBank!),
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
                  decoration: const InputDecoration(labelText: 'Receipt reference (last 6 digits)'),
                  maxLength: 6,
                ),
                const SizedBox(height: 12),
                // Deposit slip image picker
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _depositing ? null : _pickDepositSlip,
                        icon: const Icon(Icons.image),
                        label: const Text('Upload Receipt (Optional)'),
                      ),
                    ),
                  ],
                ),
                if (_depositSlipImage != null) ...[
                  const SizedBox(height: 12),
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          _depositSlipImage!,
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black54,
                          ),
                          onPressed: () => setState(() => _depositSlipImage = null),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: _depositing ? null : _handleDeposit,
                  child: _depositing
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Submit deposit request'),
                ),
              ],
            );
          },
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

  void _ensureDepositBankSelected(List<Map<String, dynamic>> banks) {
    if (_selectedDepositBank == null && banks.isNotEmpty) {
      _selectedDepositBank = banks.first;
    }
  }

  Future<void> _selectBank(List<Map<String, dynamic>> banks) async {
    final selected = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      builder: (context) => ListView.separated(
        padding: const EdgeInsets.all(16),
        itemBuilder: (_, index) {
          final bank = banks[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(bank['img']?.toString() ?? ''),
              backgroundColor: AppColors.surfaceVariant,
            ),
            title: Text(bank['bank_name']?.toString() ?? ''),
            subtitle: Text(bank['no']?.toString() ?? ''),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).pop(bank),
          );
        },
        separatorBuilder: (_, __) => const Divider(),
        itemCount: banks.length,
      ),
    );

    if (selected != null && mounted) {
      setState(() {
        _selectedDepositBank = selected;
      });
    }
  }

  void _copyBankNo(Map<String, dynamic> bank) {
    final number = bank['no']?.toString() ?? '';
    if (number.isEmpty) return;
    Clipboard.setData(ClipboardData(text: number));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied account number')),
    );
  }

  Future<void> _pickDepositSlip() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      if (image != null && mounted) {
        setState(() {
          _depositSlipImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        _showError('Failed to pick image: ${e.toString()}');
      }
    }
  }
}

class _BankCard extends StatelessWidget {
  const _BankCard({required this.bank, required this.onCopy});

  final Map<String, dynamic> bank;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bankName = bank['bank_name']?.toString() ?? '';
    final holder = bank['name']?.toString() ?? '';
    final account = bank['no']?.toString() ?? '';
    final image = bank['img']?.toString();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColors.surfaceVariant,
      ),
      child: Row(
        children: [
          if (image != null && image.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(image, width: 48, height: 48, fit: BoxFit.cover),
            )
          else
            const CircleAvatar(child: Icon(Icons.account_balance)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(bankName, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(holder, style: theme.textTheme.bodyMedium),
                Text(account, style: theme.textTheme.bodySmall?.copyWith(color: AppColors.muted)),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: onCopy,
            icon: const Icon(Icons.copy, size: 18),
            label: const Text('Copy'),
          ),
        ],
      ),
    );
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

