import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/widgets/async_value_widget.dart';
import '../../../../common/widgets/empty_state.dart';
import '../../../../core/providers/session_provider.dart';
import '../../providers/wallet_providers.dart';

class StudentWalletScreen extends ConsumerStatefulWidget {
  const StudentWalletScreen({super.key});

  @override
  ConsumerState<StudentWalletScreen> createState() => _StudentWalletScreenState();
}

class _StudentWalletScreenState extends ConsumerState<StudentWalletScreen> {
  final _depositController = TextEditingController();
  final _withdrawController = TextEditingController();

  @override
  void dispose() {
    _depositController.dispose();
    _withdrawController.dispose();
    super.dispose();
  }

  Future<void> _handleDeposit() async {
    final amount = double.tryParse(_depositController.text);
    if (amount == null || amount <= 0) return;
    final repo = ref.read(walletRepositoryProvider);
    await repo.deposit(amount);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Deposit submitted')));
    _depositController.clear();
  }

  Future<void> _handleWithdraw() async {
    final amount = double.tryParse(_withdrawController.text);
    if (amount == null || amount <= 0) return;
    final repo = ref.read(walletRepositoryProvider);
    await repo.withdraw(amount);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Withdraw submitted')));
    _withdrawController.clear();
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
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Deposit', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                TextField(
                  controller: _depositController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Amount (MMK)'),
                ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: _handleDeposit,
                  child: const Text('Submit deposit request'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Withdraw', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                TextField(
                  controller: _withdrawController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Amount (MMK)'),
                ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: _handleWithdraw,
                  child: const Text('Submit withdraw request'),
                ),
              ],
            ),
          ),
        ),
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
}

final _depositLogsProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final repo = ref.watch(walletRepositoryProvider);
  return repo.fetchDepositLogs();
});

final _withdrawLogsProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final repo = ref.watch(walletRepositoryProvider);
  return repo.fetchWithdrawLogs();
});

