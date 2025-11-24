import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../core/constants/api_constants.dart';
import '../../providers/language_provider.dart';
import '../../utils/game_launcher.dart';

class AdsVideoScreen extends StatefulWidget {
  const AdsVideoScreen({super.key});

  @override
  State<AdsVideoScreen> createState() => _AdsVideoScreenState();
}

class _AdsVideoScreenState extends State<AdsVideoScreen> {
  late Future<List<Map<String, dynamic>>> _videosFuture;

  @override
  void initState() {
    super.initState();
    _videosFuture = _fetchVideos();
  }

  Future<List<Map<String, dynamic>>> _fetchVideos() async {
    final response =
        await http.get(Uri.parse(ApiConstants.url(ApiConstants.videoAds)));
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final data = body['data'];
      if (data is List) {
        return data.cast<Map<String, dynamic>>();
      }
    }
    throw Exception('Failed to load videos');
  }

  void _openVideo(BuildContext context, String url) {
    final videoHtml = '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width,initial-scale=1.0">
  <style>
    body { margin:0; background:#000; display:flex; align-items:center; justify-content:center; height:100vh; }
    video { width:100%; height:100%; }
  </style>
</head>
<body>
  <video src="$url" controls autoplay loop playsinline></video>
</body>
</html>
''';
    GameLauncher.launch(
      context,
      title: 'Ads Video',
      htmlContent: videoHtml,
    );
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().content;

    return Scaffold(
      backgroundColor: const Color(0xFF101223),
      appBar: AppBar(
        backgroundColor: const Color(0xFF181A29),
        title: Text(language['nav']?['ads_video'] as String? ?? 'Ads Video'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _videosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                language['error']?.toString() ??
                    'Failed to load videos. Please try again.',
                style: const TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            );
          }
          final videos = snapshot.data ?? [];
          if (videos.isEmpty) {
            return Center(
              child: Text(
                language['no_data']?.toString() ??
                    'No ads videos available right now.',
                style: const TextStyle(color: Colors.white70),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: videos.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final item = videos[index];
              final url = ApiConstants.baseUrl.replaceFirst('/api', '') +
                  (item['video_url']?.toString() ?? '');
              return GestureDetector(
                onTap: () => _openVideo(context, url),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: const Color(0xFF181A29),
                    border: Border.all(color: Colors.white12),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFD700), Color(0xFFFF8A00)],
                            ),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.play_circle_fill,
                            size: 64,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${language['nav']?['ads_video'] ?? 'Ads Video'} ${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Tap to watch the latest promotion video.',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

