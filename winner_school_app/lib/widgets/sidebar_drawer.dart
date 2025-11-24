import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/general_provider.dart';
import '../providers/language_provider.dart';

class SidebarDrawer extends StatelessWidget {
  const SidebarDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().content;
    final auth = context.watch<AuthProvider>();
    final general = context.watch<GeneralProvider>();

    return Drawer(
      backgroundColor: const Color(0xFF181A29),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
                      ),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'AZM',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    auth.isAuthenticated
                        ? auth.displayName
                        : 'Welcome, Guest',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (auth.isAuthenticated)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Balance: ${auth.balance.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                ],
              ),
            ),
            const Divider(height: 1, color: Colors.white24),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _NavTile(
                    icon: Icons.home_rounded,
                    label: language['nav']?['home'] as String? ?? 'Home',
                    onTap: () {
                      Navigator.of(context).maybePop();
                      GoRouter.of(context).go('/');
                    },
                  ),
                  if (auth.isAuthenticated)
                    _NavTile(
                      icon: Icons.account_balance_wallet_rounded,
                      label: language['wallet']?['wallet'] as String? ?? 'Wallet',
                      onTap: () {
                        Navigator.of(context).maybePop();
                        GoRouter.of(context).push('/wallet');
                      },
                    ),
                  _NavTile(
                    icon: Icons.star_rate_rounded,
                    label:
                        language['nav']?['promotion'] as String? ?? 'Promotion',
                    onTap: () {
                      Navigator.of(context).maybePop();
                      GoRouter.of(context).push('/promotion');
                    },
                  ),
                  _NavTile(
                    icon: Icons.local_phone_rounded,
                    label: language['nav']?['contact'] as String? ?? 'Contact',
                    onTap: () {
                      Navigator.of(context).maybePop();
                      GoRouter.of(context).push('/contact');
                    },
                  ),
                  _NavTile(
                    icon: Icons.video_collection_rounded,
                    label:
                        language['nav']?['ads_video'] as String? ?? 'Ads Video',
                    onTap: () {
                      Navigator.of(context).maybePop();
                      GoRouter.of(context).push('/ads-video');
                    },
                  ),
                  const Divider(height: 24, color: Colors.white24),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: const Text(
                      'Support',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xB3FFFFFF),
                      ),
                    ),
                  ),
                  ...general.contacts.map(
                    (contact) => ListTile(
                      leading: const Icon(Icons.headset_mic_rounded),
                      title: Text(contact['name']?.toString() ?? 'Contact'),
                      subtitle:
                          Text(contact['link']?.toString() ?? contact['phone']
                              ?.toString() ??
                              ''),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Colors.white24),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '© ${DateTime.now().year} AZM 999',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0x99FFFFFF),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: onTap ?? () => Navigator.of(context).maybePop(),
    );
  }
}

