import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../common/widgets/async_value_widget.dart';
import '../../providers/teacher_providers.dart';

class TeacherExamFormSheet extends ConsumerStatefulWidget {
  const TeacherExamFormSheet({this.examId, super.key});

  final int? examId;

  @override
  ConsumerState<TeacherExamFormSheet> createState() => _TeacherExamFormSheetState();
}

class _TeacherExamFormSheetState extends ConsumerState<TeacherExamFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _codeController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _examDate = DateTime.now().add(const Duration(days: 7));
  int? _classId;
  int? _subjectId;
  int? _academicYearId;
  String _type = 'quiz';
  int _duration = 60;
  double _totalMarks = 100;
  double _passingMarks = 40;
  bool _isPublished = false;
  bool _submitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _codeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    if (!mounted) return;
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _examDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate == null || !mounted) return;

    if (!mounted) return;
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_examDate),
    );
    if (pickedTime == null || !mounted) return;

    if (!mounted) return;
    setState(() {
      _examDate = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_classId == null || _subjectId == null || _academicYearId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields.')),
      );
      return;
    }
    if (_passingMarks > _totalMarks) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passing marks cannot be greater than total marks.')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      final repo = ref.read(teacherExamRepositoryProvider);
      final data = {
        'title': _titleController.text,
        'code': _codeController.text,
        'description': _descriptionController.text.isEmpty ? null : _descriptionController.text,
        'subject_id': _subjectId,
        'class_id': _classId,
        'academic_year_id': _academicYearId,
        'exam_date': _examDate.toIso8601String(),
        'duration_minutes': _duration,
        'total_marks': _totalMarks,
        'passing_marks': _passingMarks,
        'type': _type,
        'is_published': _isPublished,
      };

      if (widget.examId != null) {
        await repo.updateExam(widget.examId!, data);
      } else {
        await repo.createExam(data);
      }

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.examId != null ? 'Edit Exam' : 'Create Exam',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title *'),
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(labelText: 'Code *'),
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                minLines: 2,
                maxLines: 4,
              ),
              const SizedBox(height: 12),
              AsyncValueWidget(
                value: classes,
                builder: (items) => DropdownButtonFormField<int>(
                  value: _classId,
                  decoration: const InputDecoration(labelText: 'Class *'),
                  items: items
                      .map(
                        (c) => DropdownMenuItem(
                          value: c.id,
                          child: Text(c.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _classId = value;
                      if (value != null) {
                        final selectedClass = items.firstWhere((c) => c.id == value);
                        _academicYearId = selectedClass.academicYearId;
                      }
                    });
                  },
                  validator: (value) => value == null ? 'Select class' : null,
                ),
              ),
              const SizedBox(height: 12),
              AsyncValueWidget(
                value: subjects,
                builder: (items) => DropdownButtonFormField<int>(
                  value: _subjectId,
                  decoration: const InputDecoration(labelText: 'Subject *'),
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
              DropdownButtonFormField<String>(
                value: _type,
                decoration: const InputDecoration(labelText: 'Exam Type *'),
                items: const [
                  DropdownMenuItem(value: 'quiz', child: Text('Quiz')),
                  DropdownMenuItem(value: 'assignment', child: Text('Assignment')),
                  DropdownMenuItem(value: 'midterm', child: Text('Midterm')),
                  DropdownMenuItem(value: 'final', child: Text('Final')),
                  DropdownMenuItem(value: 'project', child: Text('Project')),
                ],
                onChanged: (value) => setState(() => _type = value ?? 'quiz'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Exam Date: ${DateFormat('MMM d, y • h:mm a').format(_examDate)}',
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _pickDateTime,
                    icon: const Icon(Icons.calendar_month),
                    label: const Text('Pick'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _duration.toString(),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Duration (minutes) *'),
                onChanged: (value) => _duration = int.tryParse(value) ?? 60,
                validator: (value) {
                  final d = int.tryParse(value ?? '');
                  if (d == null || d < 1) return 'Must be at least 1 minute';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: _totalMarks.toStringAsFixed(0),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Total Marks *'),
                      onChanged: (value) {
                        _totalMarks = double.tryParse(value) ?? 100;
                      },
                      validator: (value) {
                        final m = double.tryParse(value ?? '');
                        if (m == null || m < 1) return 'Must be at least 1';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      initialValue: _passingMarks.toStringAsFixed(0),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Passing Marks *'),
                      onChanged: (value) {
                        _passingMarks = double.tryParse(value) ?? 40;
                      },
                      validator: (value) {
                        final m = double.tryParse(value ?? '');
                        if (m == null || m < 0) return 'Must be at least 0';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Publish Exam'),
                subtitle: const Text('Published exams are visible to students'),
                value: _isPublished,
                onChanged: (value) => setState(() => _isPublished = value),
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
                    : Text(widget.examId != null ? 'Update Exam' : 'Create Exam'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

