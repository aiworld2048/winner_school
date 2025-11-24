import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/general_provider.dart';
import '../../providers/game_provider.dart';
import '../../widgets/auth/login_dialog.dart';
import '../../widgets/auth/register_dialog.dart';
import '../../widgets/banner_carousel.dart';
import '../../widgets/banner_text_strip.dart';
import '../../widgets/game_section.dart';
import '../../widgets/nav_bar.dart';
import '../../widgets/sidebar_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> _onRefresh(BuildContext context) async {
    final general = context.read<GeneralProvider>();
    final game = context.read<GameProvider>();
    await Future.wait([
      general.load(),
      game.loadInitial(),
    ]);
  }

  void _openLogin() {
    showDialog(
      context: context,
      builder: (_) => const LoginDialog(),
    );
  }

  void _openRegister() {
    showDialog(
      context: context,
      builder: (_) => const RegisterDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final general = context.watch<GeneralProvider>();
    final game = context.watch<GameProvider>();
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      key: _scaffoldKey,
      drawer: const SidebarDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            NavBar(
              onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
              onLoginPressed: _openLogin,
              onRegisterPressed: _openRegister,
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => _onRefresh(context),
                child: ListView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    BannerCarousel(
                      isLoading: general.isLoading,
                      banners: general.banners,
                    ),
                    const SizedBox(height: 12),
                    BannerTextStrip(
                      texts: general.bannerTexts,
                    ),
                    const SizedBox(height: 16),
                    GameSection(
                      gameProvider: game,
                      onLoginRequired: _openLogin,
                      isAuthenticated: auth.isAuthenticated,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

