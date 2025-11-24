import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../student/presentation/student_shell.dart';
import '../../teacher/presentation/teacher_shell.dart';
import '../models/auth_user.dart';
import '../providers/auth_controller.dart';
import 'login_screen.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    return authState.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(error.toString()),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => ref.read(authControllerProvider.notifier).bootstrap(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      data: (user) {
        if (user == null) {
          return const LoginScreen();
        }
        switch (user.role) {
          case UserRole.teacher:
          case UserRole.headTeacher:
            return const TeacherShell();
          case UserRole.student:
            return const StudentShell();
          default:
            return const LoginScreen();
        }
      },
    );
  }
}

