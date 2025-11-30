import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../providers/auth_controller.dart';

class NavbarUserInfo extends ConsumerWidget {
  const NavbarUserInfo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    return authState.maybeWhen(
      data: (user) {
        if (user == null) return const SizedBox.shrink();
        final formattedBalance =
            NumberFormat('#,##0').format(user.balance);

        return Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  user.userName.isNotEmpty ? user.userName : user.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  'Balance: $formattedBalance MMK',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            IconButton(
              tooltip: 'Log out',
              icon: const Icon(Icons.logout),
              onPressed: () => ref.read(authControllerProvider.notifier).logout(),
            ),
          ],
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}

