import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

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

class _VideoLessonContent extends StatelessWidget {
  const _VideoLessonContent({required this.videoLesson});

  final VideoLesson videoLesson;

  void _playVideo(BuildContext context, String videoUrl) {
    // Note: For video playback, you may want to add a video player package
    // such as 'video_player' for direct video URLs or 'youtube_player_flutter' for YouTube
    // For now, we'll show a message to open the URL externally
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Video URL: $videoUrl'),
        action: SnackBarAction(
          label: 'Copy',
          onPressed: () {
            // You can add clipboard functionality here
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final date = videoLesson.lessonDate != null
        ? DateFormat('MMM d, y').format(videoLesson.lessonDate!)
        : null;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Video Thumbnail/Player Area
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: AppColors.outline.withValues(alpha: 0.5)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                if (videoLesson.thumbnailUrl != null && videoLesson.thumbnailUrl!.isNotEmpty)
                  Image.network(
                    videoLesson.thumbnailUrl!,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        height: 200,
                        color: Colors.grey[300],
                        child: const Icon(Icons.video_library, size: 64, color: Colors.grey),
                      );
                    },
                  )
                else
                  Container(
                    width: double.infinity,
                    height: 200,
                    color: Colors.grey[300],
                    child: const Icon(Icons.video_library, size: 64, color: Colors.grey),
                  ),
                // Play button overlay
                Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _playVideo(context, videoLesson.videoUrl),
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
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Title
        Text(
          videoLesson.title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        // Subject and Class
        Text(
          [
            if (videoLesson.subject.name.isNotEmpty) videoLesson.subject.name,
            if (videoLesson.classInfo.name.isNotEmpty) videoLesson.classInfo.name,
          ].join(' • '),
          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
        ),
        if (date != null) ...[
          const SizedBox(height: 4),
          Text('Lesson date: $date', style: theme.textTheme.bodySmall),
        ],
        if (videoLesson.durationMinutes != null) ...[
          const SizedBox(height: 4),
          Text('Duration: ${videoLesson.formattedDuration}',
              style: theme.textTheme.bodySmall),
        ],
        if (videoLesson.viewsCount != null) ...[
          const SizedBox(height: 4),
          Text('Views: ${videoLesson.viewsCount}',
              style: theme.textTheme.bodySmall),
        ],
        const SizedBox(height: 16),
        // Play Video Button
        FilledButton.icon(
          onPressed: () => _playVideo(context, videoLesson.videoUrl),
          icon: const Icon(Icons.play_arrow),
          label: const Text('Play Video'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        const SizedBox(height: 16),
        // Description
        if (videoLesson.description != null && videoLesson.description!.isNotEmpty) ...[
          Text(
            'Description',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            videoLesson.description!,
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.justify,
          ),
          const SizedBox(height: 16),
        ],
        // Attachments
        if (videoLesson.attachments != null && videoLesson.attachments!.isNotEmpty) ...[
          Text(
            'Attachments',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...videoLesson.attachments!.map((attachment) {
            return Card(
              elevation: 0,
              child: ListTile(
                leading: const Icon(Icons.attachment),
                title: Text(attachment.name),
                trailing: const Icon(Icons.download),
                onTap: () {
                  // Open attachment URL - you may want to add url_launcher package
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Opening: ${attachment.url}')),
                  );
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

