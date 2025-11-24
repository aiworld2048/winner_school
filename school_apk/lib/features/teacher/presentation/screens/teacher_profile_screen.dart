import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/widgets/async_value_widget.dart';
import '../../../auth/providers/auth_controller.dart';
import '../../../auth/presentation/widgets/change_password_dialog.dart';
import '../../../student/presentation/screens/student_wallet_screen.dart';

class TeacherProfileScreen extends ConsumerWidget {
  const TeacherProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    return AsyncValueWidget(
      value: authState,
      builder: (user) {
        if (user == null) {
          return const Center(child: Text('Not logged in.'));
        }

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Teacher profile', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    _ProfileRow(label: 'Name', value: user.name),
                    _ProfileRow(label: 'Phone', value: user.phone),
                    _ProfileRow(label: 'Role', value: user.role.name),
                    _ProfileRow(label: 'Wallet balance', value: '${user.balance.toStringAsFixed(0)} MMK'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.account_balance_wallet_outlined),
                title: const Text('Manage wallet'),
                subtitle: const Text('Deposit or withdraw funds'),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const StudentWalletScreen()),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () async {
                final success = await showDialog<bool>(
                  context: context,
                  builder: (_) => const ChangePasswordDialog(),
                );
                if (success == true && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Password updated')),
                  );
                }
              },
              icon: const Icon(Icons.lock_outline),
              label: const Text('Change password'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => ref.read(authControllerProvider.notifier).logout(),
              icon: const Icon(Icons.logout),
              label: const Text('Log out'),
            ),
          ],
        );
      },
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

