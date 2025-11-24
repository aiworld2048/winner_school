import 'package:flutter/material.dart';

import '../screens/game/game_webview_page.dart';

class GameLauncher {
  static Future<void> launch(
    BuildContext context, {
    String? url,
    String? htmlContent,
    String title = 'Game',
  }) async {
    if (url != null && url.trim().isNotEmpty) {
      if (!context.mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => GameWebViewPage(
            title: title,
            initialUrl: url.trim(),
          ),
        ),
      );
      return;
    }

    if (htmlContent != null && htmlContent.trim().isNotEmpty) {
      if (!context.mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => GameWebViewPage(
            title: title,
            htmlContent: htmlContent,
          ),
        ),
      );
      return;
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to launch game. Please try again later.'),
        ),
      );
    }
  }
}

