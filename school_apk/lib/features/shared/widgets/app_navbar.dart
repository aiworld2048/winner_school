import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../auth/providers/auth_controller.dart';

class AppNavbar extends ConsumerWidget implements PreferredSizeWidget {
  const AppNavbar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.onLogout,
  });

  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final VoidCallback? onLogout;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    final baseActions = <Widget>[
      authState.maybeWhen(
        data: (user) {
          if (user == null) return const SizedBox.shrink();
          final balance = NumberFormat('#,##0').format(user.balance);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  user.userName.isNotEmpty ? user.userName : user.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  'Balance: $balance MMK',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          );
        },
        orElse: () => const SizedBox.shrink(),
      ),
      IconButton(
        tooltip: 'Log out',
        icon: const Icon(Icons.logout),
        onPressed: () async {
          await ref.read(authControllerProvider.notifier).logout();
          if (onLogout != null) onLogout!();
        },
      ),
      ...?actions,
    ];

    return AppBar(
      title: Text(title),
      leading: leading,
      actions: baseActions,
    );
  }
}

