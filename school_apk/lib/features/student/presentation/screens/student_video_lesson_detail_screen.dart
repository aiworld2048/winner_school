import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../common/widgets/cached_thumbnail.dart';
import '../../../../core/theme/app_colors.dart';
import '../../models/video_lesson_models.dart';
import '../../providers/video_lesson_providers.dart';

class StudentVideoLessonDetailScreen extends ConsumerWidget {
  const StudentVideoLessonDetailScreen({super.key, required this.videoLessonId});

  final int videoLessonId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final videoLessonAsync = ref.watch(studentVideoLessonDetailProvider(videoLessonId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Lesson'),
      ),
      body: videoLessonAsync.when(
        data: (videoLesson) => _VideoLessonContent(videoLesson: videoLesson),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) {
          String errorMessage = 'Unable to load video lesson.';
          if (error.toString().contains('402')) {
            errorMessage = 'Insufficient balance. Required: 100 MMK to view this video lesson.';
          } else if (error.toString().contains('403')) {
            errorMessage = 'You do not have access to this video lesson.';
          } else if (error.toString().contains('404')) {
            errorMessage = 'Video lesson not found.';
          }

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    errorMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.red[700],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      ref.invalidate(studentVideoLessonDetailProvider(videoLessonId));
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _VideoLessonContent extends StatefulWidget {
  const _VideoLessonContent({required this.videoLesson});

  final VideoLesson videoLesson;

  @override
  State<_VideoLessonContent> createState() => _VideoLessonContentState();
}

class _VideoLessonContentState extends State<_VideoLessonContent> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isInitializing = false;
  bool _showPlayer = false;

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  Future<void> _initializeVideoPlayer(String videoUrl) async {
    // Check if it's YouTube or Vimeo
    if (videoUrl.contains('youtube.com') || videoUrl.contains('youtu.be') || 
        videoUrl.contains('vimeo.com')) {
      // Open in external app
      await _openExternalVideo(videoUrl);
      return;
    }

    // For direct video URLs, use video player
    setState(() {
      _isInitializing = true;
    });

    try {
      _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      await _videoPlayerController!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        looping: false,
        aspectRatio: _videoPlayerController!.value.aspectRatio,
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 8),
                Text(
                  'Error loading video',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  errorMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _openExternalVideo(videoUrl),
                  child: const Text('Open in Browser'),
                ),
              ],
            ),
          );
        },
      );

      if (mounted) {
        setState(() {
          _isInitializing = false;
          _showPlayer = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
        // If video player fails, try opening externally
        await _openExternalVideo(videoUrl);
      }
    }
  }

  Future<void> _openExternalVideo(String videoUrl) async {
    String url = videoUrl.trim();
    
    // Convert YouTube short URLs to full URLs
    if (url.contains('youtu.be/')) {
      final videoId = url.split('youtu.be/')[1].split('?')[0];
      url = 'https://www.youtube.com/watch?v=$videoId';
    }
    
    // Ensure URL has proper scheme
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }

    Uri? uri;
    try {
      uri = Uri.parse(url);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invalid video URL format: $url'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    // Try multiple launch modes with fallback
    bool launched = false;

    // First try: External application (browser or YouTube app)
    try {
      launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (launched) return;
    } catch (e) {
      debugPrint('Error with external application mode: $e');
    }

    // Second try: Platform default
    if (!launched) {
      try {
        launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
        if (launched) return;
      } catch (e) {
        debugPrint('Error with platform default mode: $e');
      }
    }

    // Third try: In-app web view
    if (!launched) {
      try {
        launched = await launchUrl(uri, mode: LaunchMode.inAppWebView);
        if (launched) return;
      } catch (e) {
        debugPrint('Error with web view mode: $e');
      }
    }

    // If all methods failed
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open video URL. Please check your internet connection.'),
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Copy URL',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: url));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('URL copied to clipboard')),
              );
            },
          ),
        ),
      );
    }
  }

  void _playVideo() {
    if (widget.videoLesson.isYouTube || widget.videoLesson.isVimeo) {
      _openExternalVideo(widget.videoLesson.videoUrl);
    } else {
      _initializeVideoPlayer(widget.videoLesson.videoUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final date = widget.videoLesson.lessonDate != null
        ? DateFormat('MMM d, y').format(widget.videoLesson.lessonDate!)
        : null;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Video Player Area
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: AppColors.outline.withValues(alpha: 0.5)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: _showPlayer && _chewieController != null
                ? SizedBox(
                    height: 250,
                    child: Chewie(controller: _chewieController!),
                  )
                : Stack(
                    children: [
                      if (widget.videoLesson.thumbnailUrl != null && 
                          widget.videoLesson.thumbnailUrl!.isNotEmpty)
                        CachedThumbnail(
                          imageUrl: widget.videoLesson.thumbnailUrl!,
                          width: double.infinity,
                          height: 250,
                          fit: BoxFit.cover,
                          borderRadius: BorderRadius.circular(16),
                        )
                      else
                        Container(
                          width: double.infinity,
                          height: 250,
                          color: Colors.grey[300],
                          child: const Icon(Icons.video_library, size: 64, color: Colors.grey),
                        ),
                      // Play button overlay
                      if (!_isInitializing)
                        Positioned.fill(
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _playVideo,
                              child: Container(
                                color: Colors.black.withValues(alpha: 0.3),
                                child: const Center(
                                  child: Icon(
                                    Icons.play_circle_filled,
                                    size: 64,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      else
                        const Positioned.fill(
                          child: Center(
                            child: CircularProgressIndicator(color: Colors.white),
                          ),
                        ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 16),
        // Title
        Text(
          widget.videoLesson.title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        // Subject and Class
        Text(
          [
            if (widget.videoLesson.subject.name.isNotEmpty) widget.videoLesson.subject.name,
            if (widget.videoLesson.classInfo.name.isNotEmpty) widget.videoLesson.classInfo.name,
          ].join(' • '),
          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
        ),
        if (date != null) ...[
          const SizedBox(height: 4),
          Text('Lesson date: $date', style: theme.textTheme.bodySmall),
        ],
        if (widget.videoLesson.durationMinutes != null) ...[
          const SizedBox(height: 4),
          Text('Duration: ${widget.videoLesson.formattedDuration}',
              style: theme.textTheme.bodySmall),
        ],
        if (widget.videoLesson.viewsCount != null) ...[
          const SizedBox(height: 4),
          Text('Views: ${widget.videoLesson.viewsCount}',
              style: theme.textTheme.bodySmall),
        ],
        const SizedBox(height: 16),
        // Play Video Button (only show if player is not initialized)
        if (!_showPlayer)
          FilledButton.icon(
            onPressed: _isInitializing ? null : _playVideo,
            icon: _isInitializing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.play_arrow),
            label: Text(_isInitializing ? 'Loading...' : 'Play Video'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        const SizedBox(height: 16),
        // Description
        if (widget.videoLesson.description != null && widget.videoLesson.description!.isNotEmpty) ...[
          Text(
            'Description',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.videoLesson.description!,
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.justify,
          ),
          const SizedBox(height: 16),
        ],
        // Attachments
        if (widget.videoLesson.attachments != null && widget.videoLesson.attachments!.isNotEmpty) ...[
          Text(
            'Attachments',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...widget.videoLesson.attachments!.map((attachment) {
            return Card(
              elevation: 0,
              child: ListTile(
                leading: const Icon(Icons.attachment),
                title: Text(attachment.name),
                trailing: const Icon(Icons.download),
                onTap: () async {
                  final uri = Uri.parse(attachment.url);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Could not open attachment URL')),
                      );
                    }
                  }
                },
              ),
            );
          }),
        ],
        const SizedBox(height: 24),
      ],
    );
  }
}

