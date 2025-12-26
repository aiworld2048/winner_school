import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../common/widgets/cached_thumbnail.dart';
import '../../../../common/widgets/content_card.dart';
import '../../../../common/widgets/refreshable_list.dart';
import '../../../../common/widgets/search_bar.dart';
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
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase().trim();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<VideoLesson> _filterVideoLessons(List<VideoLesson> lessons) {
    if (_searchQuery.isEmpty) return lessons;

    return lessons.where((videoLesson) {
      return videoLesson.title.toLowerCase().contains(_searchQuery) ||
          (videoLesson.description?.toLowerCase().contains(_searchQuery) ?? false) ||
          videoLesson.classInfo.name.toLowerCase().contains(_searchQuery) ||
          videoLesson.subject.name.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final videoLessons = ref.watch(studentVideoLessonsProvider(_filters));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Lessons'),
      ),
      body: Column(
        children: [
          // Search Bar
          AppSearchBar(
            controller: _searchController,
            hintText: 'Search video lessons by title, description, class, or subject...',
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase().trim();
              });
            },
            onClear: () {
              setState(() {
                _searchQuery = '';
              });
            },
          ),
          if (_searchQuery.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Found ${videoLessons.maybeWhen(
                  data: (lessons) => _filterVideoLessons(lessons).length,
                  orElse: () => 0,
                )} video lesson${videoLessons.maybeWhen(
                  data: (lessons) => _filterVideoLessons(lessons).length != 1 ? 's' : '',
                  orElse: () => 's',
                )}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ),
          // Video Lessons List
          Expanded(
            child: RefreshableList<VideoLesson>(
              asyncValue: videoLessons.when(
                data: (lessons) => AsyncValue.data(_filterVideoLessons(lessons)),
                loading: () => const AsyncValue.loading(),
                error: (error, stack) => AsyncValue.error(error, stack),
              ),
              onRefresh: () async {
                ref.invalidate(studentVideoLessonsProvider(_filters));
                await ref.read(studentVideoLessonsProvider(_filters).future);
              },
              itemBuilder: (context, videoLesson, index) => _VideoLessonCard(videoLesson: videoLesson),
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              emptyTitle: _searchQuery.isNotEmpty
                  ? 'No video lessons found matching "$_searchQuery"'
                  : 'No video lessons found',
              emptyIcon: _searchQuery.isNotEmpty ? Icons.search_off : Icons.video_library_outlined,
              errorTitle: 'Error loading video lessons',
              onRetry: () => ref.invalidate(studentVideoLessonsProvider(_filters)),
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

    return ContentCard(
      borderColor: videoLesson.status == 'published'
          ? AppColors.primary.withValues(alpha: 0.3)
          : AppColors.outline.withValues(alpha: 0.5),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => StudentVideoLessonDetailScreen(videoLessonId: videoLesson.id),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              if (videoLesson.thumbnailUrl != null && videoLesson.thumbnailUrl!.isNotEmpty)
                CachedThumbnail(
                  imageUrl: videoLesson.thumbnailUrl!,
                  width: 80,
                  height: 60,
                  borderRadius: BorderRadius.circular(8),
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
                        if (videoLesson.durationMinutes != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            videoLesson.formattedDuration,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.muted,
                            ),
                          ),
                        ],
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
              InfoRow(icon: Icons.book_outlined, text: videoLesson.subject.name),
              const SizedBox(width: 16),
              InfoRow(icon: Icons.class_outlined, text: videoLesson.classInfo.name),
            ],
          ),
          if (videoLesson.lessonDate != null) ...[
            const SizedBox(height: 4),
            InfoRow(
              icon: Icons.calendar_today_outlined,
              text: DateFormat('MMM d, y').format(videoLesson.lessonDate!),
            ),
          ],
          if (videoLesson.viewsCount != null) ...[
            const SizedBox(height: 4),
            InfoRow(
              icon: Icons.visibility_outlined,
              text: '${videoLesson.viewsCount} views',
            ),
          ],
        ],
      ),
    );
  }
}

