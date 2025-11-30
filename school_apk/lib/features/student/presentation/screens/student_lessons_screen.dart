import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../common/widgets/async_value_widget.dart';
import '../../../../common/widgets/banner_slider.dart';
import '../../../../common/widgets/empty_state.dart';
import '../../../../common/widgets/marquee_text.dart';
import '../../../media/providers/media_providers.dart';
import '../../providers/lesson_providers.dart';
import 'student_lesson_detail_screen.dart';

class StudentLessonsScreen extends ConsumerWidget {
  const StudentLessonsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessons = ref.watch(lessonsProvider);
    final banners = ref.watch(mediaBannersProvider);
    final bannerText = ref.watch(mediaBannerTextsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(lessonsProvider);
        ref.invalidate(mediaBannersProvider);
        ref.invalidate(mediaBannerTextsProvider);
        await Future.wait([
          ref.refresh(lessonsProvider.future),
          ref.refresh(mediaBannersProvider.future),
          ref.refresh(mediaBannerTextsProvider.future),
        ]);
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AsyncValueWidget(
                    value: banners,
                    builder: (items) => BannerSlider(items: items),
                  ),
                  const SizedBox(height: 12),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: Row(
                        children: [
                          Icon(Icons.campaign_outlined,
                              color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: AsyncValueWidget(
                              value: bannerText,
                              builder: (messages) => MarqueeText(messages: messages),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Latest lessons',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
          ),
          lessons.when(
            data: (data) {
              if (data.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: EmptyState(
                      title: 'No lessons yet',
                      message: 'Your teacher has not assigned lessons. Check back soon.',
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                sliver: SliverList.separated(
                  itemCount: data.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final lesson = data[index];
                    final subtitle = [
                      if (lesson.subjectName != null) lesson.subjectName,
                      if (lesson.className != null) lesson.className,
                    ].whereType<String>().join(' • ');
                    final date = lesson.lessonDate != null
                        ? DateFormat('MMM d, y').format(lesson.lessonDate!)
                        : null;

                    return Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(
                          lesson.title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (lesson.description != null && lesson.description!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  lesson.description!,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            if (subtitle.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  subtitle,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                            if (date != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  'Lesson date: $date',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                          ],
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => StudentLessonDetailScreen(lessonId: lesson.id),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
            error: (error, _) => SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(error.toString()),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

