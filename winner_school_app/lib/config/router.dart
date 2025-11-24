import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/home/home_screen.dart';
import '../screens/buffalo/buffalo_game_screen.dart';
import '../screens/promotion/promotion_screen.dart';
import '../screens/contact/contact_screen.dart';
import '../screens/ads/ads_video_screen.dart';
import '../screens/wallet/wallet_screen.dart';
import '../screens/wallet/deposit_screen.dart';
import '../screens/wallet/withdraw_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        name: 'home',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: HomeScreen()),
      ),
      GoRoute(
        path: '/buffalo',
        name: 'buffalo',
        builder: (context, state) => const BuffaloGameScreen(),
      ),
      GoRoute(
        path: '/promotion',
        name: 'promotion',
        builder: (context, state) => const PromotionScreen(),
      ),
      GoRoute(
        path: '/contact',
        name: 'contact',
        builder: (context, state) => const ContactScreen(),
      ),
      GoRoute(
        path: '/ads-video',
        name: 'ads_video',
        builder: (context, state) => const AdsVideoScreen(),
      ),
      GoRoute(
        path: '/wallet',
        name: 'wallet',
        builder: (context, state) => const WalletScreen(),
      ),
      GoRoute(
        path: '/wallet/deposit',
        name: 'wallet_deposit',
        builder: (context, state) => const DepositScreen(),
      ),
      GoRoute(
        path: '/wallet/withdraw',
        name: 'wallet_withdraw',
        builder: (context, state) => const WithdrawScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text(state.error?.toString() ?? 'Page not found'),
      ),
    ),
  );
}

