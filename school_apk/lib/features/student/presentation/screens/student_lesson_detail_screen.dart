import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html_table/flutter_html_table.dart';

import '../../../../common/widgets/async_value_widget.dart';
import '../../../../common/widgets/pdf_viewer.dart';
import '../../providers/lesson_providers.dart';

class StudentLessonDetailScreen extends ConsumerWidget {
  const StudentLessonDetailScreen({super.key, required this.lessonId});

  final int lessonId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lesson = ref.watch(lessonDetailProvider(lessonId));

    return Scaffold(
      appBar: AppBar(title: const Text('Lesson detail')),
      body: AsyncValueWidget(
        value: lesson,
        builder: (data) {
          final date = data.lessonDate != null
              ? DateFormat('MMM d, y').format(data.lessonDate!)
              : null;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                data.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                [
                  if (data.subjectName != null) data.subjectName,
                  if (data.className != null) data.className,
                ].whereType<String>().join(' • '),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),
              if (date != null) ...[
                const SizedBox(height: 4),
                Text('Lesson date: $date', style: Theme.of(context).textTheme.bodySmall),
              ],
              if (data.durationMinutes != null) ...[
                const SizedBox(height: 4),
                Text('Duration: ${data.durationMinutes} m',
                    style: Theme.of(context).textTheme.bodySmall),
              ],
              const SizedBox(height: 16),
              if (data.description != null && data.description!.isNotEmpty) ...[
                Text(
                  data.description!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 12),
              ],
              if (data.content != null && data.content!.isNotEmpty)
                Card(
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: _LessonContentHtml(html: data.content!),
                  ),
                )
              else
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No detailed content provided.'),
                  ),
                ),
              if (data.pdfFileUrl != null && data.pdfFileUrl!.isNotEmpty) ...[
                const SizedBox(height: 24),
                PdfViewerWidget(
                  pdfUrl: data.pdfFileUrl!,
                  title: 'PDF Document',
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _LessonContentHtml extends StatefulWidget {
  const _LessonContentHtml({required this.html});

  final String html;

  @override
  State<_LessonContentHtml> createState() => _LessonContentHtmlState();
}

class _LessonContentHtmlState extends State<_LessonContentHtml> {
  late String _html;

  @override
  void initState() {
    super.initState();
    _html = widget.html;
    _tweakHtml();
  }

  @override
  void didUpdateWidget(covariant _LessonContentHtml oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.html != widget.html) {
      _html = widget.html;
      _tweakHtml();
    }
  }

  void _tweakHtml() {
    setState(() {
      _html = widget.html.replaceAll(r'\text{', '').replaceAll('}', '');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Html(
      data: _html,
      extensions: const [
        TableHtmlExtension(),
      ],
      style: {
        'body': Style(
          textAlign: TextAlign.justify,
        ),
        'p': Style(
          textAlign: TextAlign.justify,
        ),
        'div': Style(
          textAlign: TextAlign.justify,
        ),
        'table': Style(
          backgroundColor: Colors.white,
          border: const Border.fromBorderSide(BorderSide(color: Colors.black12)),
        ),
        'th': Style(
          padding: HtmlPaddings.all(8),
          fontWeight: FontWeight.w600,
          backgroundColor: Colors.grey.shade200,
          border: const Border(bottom: BorderSide(color: Colors.black12)),
        ),
        'td': Style(
          padding: HtmlPaddings.all(8),
          border: const Border(bottom: BorderSide(color: Colors.black12)),
        ),
      },
    );
  }
}

