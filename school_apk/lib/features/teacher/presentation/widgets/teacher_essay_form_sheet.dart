import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../common/widgets/async_value_widget.dart';
import '../../providers/essay_providers.dart';
import '../../providers/teacher_providers.dart';

class TeacherEssayFormSheet extends ConsumerStatefulWidget {
  const TeacherEssayFormSheet({this.essayId, super.key});

  final int? essayId;

  @override
  ConsumerState<TeacherEssayFormSheet> createState() => _TeacherEssayFormSheetState();
}

class _TeacherEssayFormSheetState extends ConsumerState<TeacherEssayFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _instructionsController = TextEditingController();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 7));
  TimeOfDay? _dueTime;
  int? _classId;
  int? _subjectId;
  int? _academicYearId;
  double _totalMarks = 100;
  int? _wordCountMin;
  int? _wordCountMax;
  String _status = 'draft';
  bool _submitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    if (!mounted) return;
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate == null || !mounted) return;

    if (!mounted) return;
    setState(() {
      _dueDate = pickedDate;
    });
  }

  Future<void> _pickTime() async {
    if (!mounted) return;
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _dueTime ?? TimeOfDay.now(),
    );
    if (pickedTime == null || !mounted) return;

    if (!mounted) return;
    setState(() {
      _dueTime = pickedTime;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_classId == null || _subjectId == null || _academicYearId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields.')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      final repo = ref.read(essayRepositoryProvider);
      final data = {
        'title': _titleController.text,
        'description': _descriptionController.text.isEmpty ? null : _descriptionController.text,
        'instructions': _instructionsController.text.isEmpty ? null : _instructionsController.text,
        'subject_id': _subjectId,
        'class_id': _classId,
        'academic_year_id': _academicYearId,
        'due_date': _dueDate.toIso8601String().split('T')[0],
        'due_time': _dueTime != null ? '${_dueTime!.hour.toString().padLeft(2, '0')}:${_dueTime!.minute.toString().padLeft(2, '0')}' : null,
        'total_marks': _totalMarks,
        'word_count_min': _wordCountMin,
        'word_count_max': _wordCountMax,
        'status': _status,
      };

      if (widget.essayId != null) {
        await repo.updateEssay(widget.essayId!, data);
      } else {
        await repo.createEssay(data);
      }

      if (!mounted) return;
      Navigator.of(context).pop(true);
      ref.invalidate(teacherEssaysProvider({}));
      if (widget.essayId != null) {
        ref.invalidate(teacherEssayProvider(widget.essayId!));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.essayId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadEssayData();
      });
    }
  }

  Future<void> _loadEssayData() async {
    final essayAsync = await ref.read(teacherEssayProvider(widget.essayId!).future);
    if (mounted) {
      setState(() {
        _titleController.text = essayAsync.title;
        _descriptionController.text = essayAsync.description ?? '';
        _instructionsController.text = essayAsync.instructions ?? '';
        _dueDate = essayAsync.dueDate;
        _dueTime = essayAsync.dueTime != null
            ? TimeOfDay(
                hour: int.parse(essayAsync.dueTime!.split(':')[0]),
                minute: int.parse(essayAsync.dueTime!.split(':')[1]),
              )
            : null;
        _classId = essayAsync.classInfo.id;
        _subjectId = essayAsync.subject.id;
        _academicYearId = essayAsync.academicYear.id;
        _totalMarks = essayAsync.totalMarks;
        _wordCountMin = essayAsync.wordCountMin;
        _wordCountMax = essayAsync.wordCountMax;
        _status = essayAsync.status;
      });
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
                widget.essayId != null ? 'Edit Essay' : 'Create Essay',
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
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                minLines: 2,
                maxLines: 4,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _instructionsController,
                decoration: const InputDecoration(labelText: 'Instructions'),
                minLines: 3,
                maxLines: 6,
              ),
              const SizedBox(height: 12),
              AsyncValueWidget(
                value: subjects,
                builder: (subjectsList) {
                  return DropdownButtonFormField<int>(
                    value: _subjectId,
                    decoration: const InputDecoration(labelText: 'Subject *'),
                    items: subjectsList.map((subject) {
                      return DropdownMenuItem(
                        value: subject.id,
                        child: Text(subject.name),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _subjectId = value),
                    validator: (value) => value == null ? 'Required' : null,
                  );
                },
              ),
              const SizedBox(height: 12),
              AsyncValueWidget(
                value: classes,
                builder: (classesList) {
                  return DropdownButtonFormField<int>(
                    value: _classId,
                    decoration: const InputDecoration(labelText: 'Class *'),
                    items: classesList.map((classInfo) {
                      return DropdownMenuItem(
                        value: classInfo.id,
                        child: Text(classInfo.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _classId = value;
                        if (value != null) {
                          final selectedClass = classesList.firstWhere((c) => c.id == value);
                          _academicYearId = selectedClass.academicYearId;
                        }
                      });
                    },
                    validator: (value) => value == null ? 'Required' : null,
                  );
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _pickDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Due Date *',
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(DateFormat('MMM d, y').format(_dueDate)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: _pickTime,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Due Time',
                          suffixIcon: Icon(Icons.access_time),
                        ),
                        child: Text(
                          _dueTime != null
                              ? _dueTime!.format(context)
                              : 'Not set',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Total Marks *'),
                keyboardType: TextInputType.number,
                initialValue: _totalMarks.toString(),
                onChanged: (value) {
                  _totalMarks = double.tryParse(value) ?? 100;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  final marks = double.tryParse(value);
                  if (marks == null || marks <= 0) return 'Invalid marks';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(labelText: 'Min Words'),
                      keyboardType: TextInputType.number,
                      initialValue: _wordCountMin?.toString(),
                      onChanged: (value) {
                        _wordCountMin = int.tryParse(value);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(labelText: 'Max Words'),
                      keyboardType: TextInputType.number,
                      initialValue: _wordCountMax?.toString(),
                      onChanged: (value) {
                        _wordCountMax = int.tryParse(value);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(labelText: 'Status *'),
                items: const [
                  DropdownMenuItem(value: 'draft', child: Text('Draft')),
                  DropdownMenuItem(value: 'published', child: Text('Published')),
                ],
                onChanged: (value) => setState(() => _status = value ?? 'draft'),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(widget.essayId != null ? 'Update Essay' : 'Create Essay'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

