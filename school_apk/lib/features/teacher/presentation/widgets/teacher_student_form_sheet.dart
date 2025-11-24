import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/widgets/async_value_widget.dart';
import '../../providers/teacher_providers.dart';

class TeacherStudentFormSheet extends ConsumerStatefulWidget {
  const TeacherStudentFormSheet({super.key});

  @override
  ConsumerState<TeacherStudentFormSheet> createState() => _TeacherStudentFormSheetState();
}

class _TeacherStudentFormSheetState extends ConsumerState<TeacherStudentFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  int? _classId;
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_classId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose a class.')),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      final repo = ref.read(teacherRepositoryProvider);
      await repo.createStudent(
        name: _nameController.text,
        phone: _phoneController.text,
        password: _passwordController.text,
        classId: _classId!,
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

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add student', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full name'),
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone number'),
                keyboardType: TextInputType.phone,
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Temporary password'),
                obscureText: true,
                validator: (value) => value != null && value.length >= 6 ? null : 'Min 6 characters',
              ),
              const SizedBox(height: 12),
              AsyncValueWidget(
                value: classes,
                builder: (items) => DropdownButtonFormField<int>(
                  value: _classId,
                  decoration: const InputDecoration(labelText: 'Assign class'),
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
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save student'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

