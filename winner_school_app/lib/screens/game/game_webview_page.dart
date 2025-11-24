import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class GameWebViewPage extends StatefulWidget {
  const GameWebViewPage({
    super.key,
    this.initialUrl,
    this.htmlContent,
    required this.title,
  });

  final String? initialUrl;
  final String? htmlContent;
  final String title;

  @override
  State<GameWebViewPage> createState() => _GameWebViewPageState();
}

class _GameWebViewPageState extends State<GameWebViewPage> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) {
              setState(() => _isLoading = false);
            }
          },
        ),
      );

    if (widget.htmlContent != null && widget.htmlContent!.isNotEmpty) {
      _controller.loadHtmlString(widget.htmlContent!);
    } else if (widget.initialUrl != null && widget.initialUrl!.isNotEmpty) {
      _controller.loadRequest(Uri.parse(widget.initialUrl!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: const Color(0xFF181A29),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}

