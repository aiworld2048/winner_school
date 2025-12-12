import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../common/widgets/empty_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../models/video_lesson_models.dart';
import '../../providers/video_lesson_providers.dart';
import 'student_video_lesson_detail_screen.dart';

class StudentVideoLessonsScreen extends ConsumerStatefulWidget {
  const StudentVideoLessonsScreen({super.key});

  @override
  ConsumerState<StudentVideoLessonsScreen> createState() => _StudentVideoLessonsScreenState();
}

class _StudentVideoLessonsScreenState extends ConsumerState<StudentVideoLessonsScreen> {
  final Map<String, dynamic> _filters = {};

  @override
  Widget build(BuildContext context) {
    final videoLessons = ref.watch(studentVideoLessonsProvider(_filters));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Lessons'),
      ),
      body: Column(
        children: [
          // Video Lessons List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(studentVideoLessonsProvider(_filters));
                await ref.read(studentVideoLessonsProvider(_filters).future);
              },
              child: videoLessons.when(
                data: (videoLessonsList) {
                  if (videoLessonsList.isEmpty) {
                    return const EmptyState(
                      title: 'No video lessons found',
                      icon: Icons.video_library_outlined,
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: videoLessonsList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final videoLesson = videoLessonsList[index];
                      return _VideoLessonCard(videoLesson: videoLesson);
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) {
                  String errorMessage = 'Unable to load video lessons.';
                  if (error.toString().contains('TimeoutException') || 
                      error.toString().contains('timed out')) {
                    errorMessage = 'Request timed out. Please check your internet connection.';
                  } else if (error.toString().contains('Failed to fetch')) {
                    errorMessage = 'Network error. Please check your connection.';
                  } else if (error.toString().contains('402')) {
                    errorMessage = 'Insufficient balance to view video lessons.';
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
                            'Error loading video lessons',
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
                              ref.invalidate(studentVideoLessonsProvider(_filters));
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
            ),
          ),
        ],
      ),
    );
  }
}

class _VideoLessonCard extends StatelessWidget {
  const _VideoLessonCard({required this.videoLesson});

  final VideoLesson videoLesson;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: videoLesson.status == 'published'
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.outline.withValues(alpha: 0.5),
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => StudentVideoLessonDetailScreen(videoLessonId: videoLesson.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thumbnail
                  if (videoLesson.thumbnailUrl != null && videoLesson.thumbnailUrl!.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        videoLesson.thumbnailUrl!,
                        width: 80,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 80,
                            height: 60,
                            color: Colors.grey[300],
                            child: const Icon(Icons.video_library, color: Colors.grey),
                          );
                        },
                      ),
                    )
                  else
                    Container(
                      width: 80,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.video_library, color: Colors.grey),
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          videoLesson.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Chip(
                              label: Text(
                                videoLesson.statusDisplay,
                                style: const TextStyle(fontSize: 11),
                              ),
                              padding: EdgeInsets.zero,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                            ),
                            const SizedBox(width: 8),
                            if (videoLesson.durationMinutes != null)
                              Text(
                                videoLesson.formattedDuration,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.muted,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (videoLesson.description != null && videoLesson.description!.isNotEmpty) ...[
                Text(
                  videoLesson.description!,
                  style: theme.textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
              ],
              Row(
                children: [
                  Icon(Icons.book_outlined, size: 16, color: AppColors.muted),
                  const SizedBox(width: 6),
                  Text(
                    videoLesson.subject.name,
                    style: theme.textTheme.bodySmall?.copyWith(color: AppColors.muted),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.class_outlined, size: 16, color: AppColors.muted),
                  const SizedBox(width: 6),
                  Text(
                    videoLesson.classInfo.name,
                    style: theme.textTheme.bodySmall?.copyWith(color: AppColors.muted),
                  ),
                ],
              ),
              if (videoLesson.lessonDate != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.muted),
                    const SizedBox(width: 6),
                    Text(
                      DateFormat('MMM d, y').format(videoLesson.lessonDate!),
                      style: theme.textTheme.bodySmall?.copyWith(color: AppColors.muted),
                    ),
                  ],
                ),
              ],
              if (videoLesson.viewsCount != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.visibility_outlined, size: 16, color: AppColors.muted),
                    const SizedBox(width: 6),
                    Text(
                      '${videoLesson.viewsCount} views',
                      style: theme.textTheme.bodySmall?.copyWith(color: AppColors.muted),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

