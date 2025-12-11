import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:intl/intl.dart';

import '../../../../common/widgets/async_value_widget.dart';
import '../../../../core/theme/app_colors.dart';
import '../../providers/essay_providers.dart';
import '../widgets/teacher_essay_form_sheet.dart';

class TeacherEssayDetailScreen extends ConsumerStatefulWidget {
  const TeacherEssayDetailScreen({required this.essayId, super.key});

  final int essayId;

  @override
  ConsumerState<TeacherEssayDetailScreen> createState() => _TeacherEssayDetailScreenState();
}

class _TeacherEssayDetailScreenState extends ConsumerState<TeacherEssayDetailScreen> {
  late final FlutterTts _flutterTts;
  bool _isSpeaking = false;
  String? _currentSpeakingText;

  @override
  void initState() {
    super.initState();
    _flutterTts = FlutterTts();
    _flutterTts.setLanguage('en-US');
    _flutterTts.setSpeechRate(0.5);
    _flutterTts.setPitch(1.0);
    _flutterTts.setVolume(1.0);

    _flutterTts.setCompletionHandler(() {
      if (mounted) {
        setState(() {
          _isSpeaking = false;
          _currentSpeakingText = null;
        });
      }
    });

    _flutterTts.setErrorHandler((msg) {
      if (mounted) {
        setState(() {
          _isSpeaking = false;
          _currentSpeakingText = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('TTS Error: $msg')),
        );
      }
    });
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  String _stripHtmlTags(String htmlString) {
    // Simple HTML tag removal - for more complex HTML, consider using html package
    return htmlString
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .trim();
  }

  Future<void> _speak(String text, String sectionName) async {
    if (text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No content to read in $sectionName')),
      );
      return;
    }

    // Stop any current speech
    await _flutterTts.stop();

    // Strip HTML tags if present
    final cleanText = _stripHtmlTags(text);

    setState(() {
      _isSpeaking = true;
      _currentSpeakingText = sectionName;
    });

    await _flutterTts.speak(cleanText);
  }

  Future<void> _stopSpeaking() async {
    await _flutterTts.stop();
    if (mounted) {
      setState(() {
        _isSpeaking = false;
        _currentSpeakingText = null;
      });
    }
  }

  Widget _buildTtsButton({
    required String text,
    required String sectionName,
    required IconData icon,
  }) {
    final isCurrentlySpeaking = _isSpeaking && _currentSpeakingText == sectionName;

    return IconButton(
      icon: Icon(isCurrentlySpeaking ? Icons.stop : icon),
      tooltip: isCurrentlySpeaking ? 'Stop reading' : 'Read $sectionName',
      color: isCurrentlySpeaking ? Colors.red : AppColors.primary,
      onPressed: () {
        if (isCurrentlySpeaking) {
          _stopSpeaking();
        } else {
          _speak(text, sectionName);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final essayAsync = ref.watch(teacherEssayProvider(widget.essayId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Essay Details'),
        actions: [
          if (_isSpeaking)
            IconButton(
              icon: const Icon(Icons.stop),
              tooltip: 'Stop reading',
              color: Colors.red,
              onPressed: _stopSpeaking,
            ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => TeacherEssayFormSheet(essayId: widget.essayId),
              );
            },
          ),
        ],
      ),
      body: AsyncValueWidget(
        value: essayAsync,
        builder: (essay) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: essay.status == 'published'
                          ? AppColors.primary.withValues(alpha: 0.3)
                          : AppColors.outline.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          essay.title,
                                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ),
                                      _buildTtsButton(
                                        text: essay.title,
                                        sectionName: 'title',
                                        icon: Icons.volume_up,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: essay.status == 'published'
                                              ? AppColors.primary.withValues(alpha: 0.1)
                                              : AppColors.outline.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          essay.statusDisplay,
                                          style: TextStyle(
                                            color: essay.status == 'published'
                                                ? AppColors.primary
                                                : AppColors.muted,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      if (essay.isOverdue) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.red.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: const Text(
                                            'Overdue',
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
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
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(Icons.book_outlined, size: 16, color: AppColors.muted),
                            const SizedBox(width: 6),
                            Text(
                              essay.subject.name,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.muted,
                                  ),
                            ),
                            const SizedBox(width: 16),
                            Icon(Icons.class_outlined, size: 16, color: AppColors.muted),
                            const SizedBox(width: 6),
                            Text(
                              essay.classInfo.name,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.muted,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.muted),
                            const SizedBox(width: 6),
                            Text(
                              DateFormat('MMM d, y').format(essay.dueDate) +
                                  (essay.dueTime != null ? ' • ${essay.dueTime}' : ''),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.muted,
                                  ),
                            ),
                            const SizedBox(width: 16),
                            Icon(Icons.grade_outlined, size: 16, color: AppColors.muted),
                            const SizedBox(width: 6),
                            Text(
                              '${essay.totalMarks.toStringAsFixed(0)} marks',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.muted,
                                  ),
                            ),
                          ],
                        ),
                        if (essay.wordCountMin != null || essay.wordCountMax != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.text_fields_outlined, size: 16, color: AppColors.muted),
                              const SizedBox(width: 6),
                              Text(
                                essay.wordCountDisplay,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.muted,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                if (essay.description != null && essay.description!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: AppColors.outline.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Description',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                              _buildTtsButton(
                                text: essay.description!,
                                sectionName: 'description',
                                icon: Icons.volume_up,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            essay.description!,
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.justify,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                if (essay.instructions != null && essay.instructions!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: AppColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Instructions',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                              _buildTtsButton(
                                text: essay.instructions!,
                                sectionName: 'instructions',
                                icon: Icons.volume_up,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            essay.instructions!,
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.justify,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                if (essay.attachments != null && essay.attachments!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: AppColors.outline.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Attachments',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 12),
                          ...essay.attachments!.map((attachment) {
                            return ListTile(
                              leading: const Icon(Icons.attach_file),
                              title: Text(attachment.name),
                              trailing: const Icon(Icons.download),
                              onTap: () {
                                // TODO: Implement file download functionality
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Download: ${attachment.name}'),
                                    action: SnackBarAction(
                                      label: 'Open',
                                      onPressed: () {
                                        // Open URL in browser
                                      },
                                    ),
                                  ),
                                );
                              },
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: AppColors.outline.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        if (essay.submissionsCount != null) ...[
                          Expanded(
                            child: Row(
                              children: [
                                Icon(Icons.assignment_outlined, color: AppColors.primary),
                                const SizedBox(width: 12),
                                Text(
                                  '${essay.submissionsCount} Submissions',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        if (essay.viewsCount != null) ...[
                          if (essay.submissionsCount != null) const SizedBox(width: 24),
                          Expanded(
                            child: Row(
                              children: [
                                Icon(Icons.visibility_outlined, color: AppColors.primary),
                                const SizedBox(width: 12),
                                Text(
                                  '${essay.viewsCount} Views',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

