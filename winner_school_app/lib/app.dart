import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/router.dart';
import 'providers/auth_provider.dart';
import 'providers/general_provider.dart';
import 'providers/game_provider.dart';
import 'providers/language_provider.dart';

class AzmApp extends StatelessWidget {
  const AzmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<LanguageProvider>(
          create: (_) => LanguageProvider(),
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, GeneralProvider>(
          create: (_) => GeneralProvider(),
          update: (_, auth, general) {
            general ??= GeneralProvider();
            general.updateToken(auth.token);
            return general;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, GameProvider>(
          create: (_) => GameProvider(),
          update: (_, auth, game) {
            game ??= GameProvider();
            game.updateToken(auth.token);
            return game;
          },
        ),
      ],
      child: Consumer<LanguageProvider>(
        builder: (context, language, _) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'azm_999',
            routerConfig: AppRouter.router,
            themeMode: ThemeMode.dark,
            theme: ThemeData(
              brightness: Brightness.dark,
              scaffoldBackgroundColor: const Color(0xFF101223),
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFFFFD700),
                brightness: Brightness.dark,
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF181A29),
                elevation: 0,
              ),
              cardColor: const Color(0xFF181A29),
              useMaterial3: true,
            ),
            supportedLocales: const [
              Locale('en'),
              Locale('mm'),
              Locale('th'),
              Locale('zh'),
            ],
            locale: Locale(language.locale),
          );
        },
      ),
    );
  }
}

