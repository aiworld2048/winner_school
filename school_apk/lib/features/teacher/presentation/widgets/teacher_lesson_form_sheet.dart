import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/widgets/async_value_widget.dart';
import '../../providers/teacher_providers.dart';

class TeacherLessonFormSheet extends ConsumerStatefulWidget {
  const TeacherLessonFormSheet({super.key});

  @override
  ConsumerState<TeacherLessonFormSheet> createState() => _TeacherLessonFormSheetState();
}

class _TeacherLessonFormSheetState extends ConsumerState<TeacherLessonFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contentController = TextEditingController();
  DateTime _lessonDate = DateTime.now();
  int? _classId;
  int? _subjectId;
  int _duration = 45;
  bool _submitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _lessonDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _lessonDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_classId == null || _subjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose a class and subject.')),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      final repo = ref.read(teacherRepositoryProvider);
      await repo.createLesson(
        title: _titleController.text,
        description: _descriptionController.text,
        content: _contentController.text,
        classId: _classId!,
        subjectId: _subjectId!,
        lessonDate: _lessonDate,
        durationMinutes: _duration,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final classes = ref.watch(teacherClassesProvider);
    final subjects = ref.watch(teacherSubjectsProvider);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Create lesson', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                minLines: 1,
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(labelText: 'Content / notes'),
                minLines: 4,
                maxLines: 6,
              ),
              const SizedBox(height: 12),
              AsyncValueWidget(
                value: classes,
                builder: (items) => DropdownButtonFormField<int>(
                  value: _classId,
                  decoration: const InputDecoration(labelText: 'Class'),
                  items: items
                      .map(
                        (c) => DropdownMenuItem(
                          value: c.id,
                          child: Text(c.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _classId = value),
                  validator: (value) => value == null ? 'Select class' : null,
                ),
              ),
              const SizedBox(height: 12),
              AsyncValueWidget(
                value: subjects,
                builder: (items) => DropdownButtonFormField<int>(
                  value: _subjectId,
                  decoration: const InputDecoration(labelText: 'Subject'),
                  items: items
                      .map(
                        (s) => DropdownMenuItem(
                          value: s.id,
                          child: Text(s.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _subjectId = value),
                  validator: (value) => value == null ? 'Select subject' : null,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text('Lesson date: ${_lessonDate.toLocal().toString().split(' ')[0]}'),
                  ),
                  TextButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_month),
                    label: const Text('Pick'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _duration.toString(),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Duration (minutes)'),
                onChanged: (value) => _duration = int.tryParse(value) ?? 45,
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save lesson'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

