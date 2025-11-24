import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/providers/session_provider.dart';
import 'core/services/session_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sessionManager = SessionManager();
  await sessionManager.init();

  runApp(
    ProviderScope(
      overrides: [
        sessionManagerProvider.overrideWithValue(sessionManager),
      ],
      child: const SchoolApp(),
    ),
  );
}
