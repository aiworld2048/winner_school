import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/widgets/async_value_widget.dart';
import '../../../../core/theme/app_colors.dart';
import '../../models/exam_models.dart';
import '../../providers/exam_providers.dart';

class StudentExamTakingScreen extends ConsumerStatefulWidget {
  const StudentExamTakingScreen({required this.examId, super.key});

  final int examId;

  @override
  ConsumerState<StudentExamTakingScreen> createState() => _StudentExamTakingScreenState();
}

class _StudentExamTakingScreenState extends ConsumerState<StudentExamTakingScreen> {
  int _currentQuestionIndex = 0;
  final Map<int, int?> _selectedAnswers = {}; // questionId -> selectedOptionId
  final Map<int, String> _shortAnswers = {}; // questionId -> answer text
  Timer? _timer;
  Duration? _remainingTime;
  bool _isSubmitted = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer(Duration duration) {
    _remainingTime = duration;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && _remainingTime != null) {
        setState(() {
          if (_remainingTime!.inSeconds > 0) {
            _remainingTime = Duration(seconds: _remainingTime!.inSeconds - 1);
          } else {
            _timer?.cancel();
            _submitExam();
          }
        });
      }
    });
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return '--:--';
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }

  void _submitExam() {
    if (_isSubmitted) return;
    
    _isSubmitted = true;
    _timer?.cancel();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Submit Exam'),
        content: const Text('Are you sure you want to submit your exam?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _isSubmitted = false;
            },
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Submit answers to API
              Navigator.of(context).pop(); // Go back to exam detail
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Exam submitted successfully!')),
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final examAsync = ref.watch(studentExamProvider(widget.examId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Taking Exam'),
        actions: [
          if (_remainingTime != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: _remainingTime!.inMinutes < 5
                    ? Colors.red
                    : AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _formatDuration(_remainingTime),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
      body: AsyncValueWidget(
        value: examAsync,
        builder: (exam) {
          final examData = exam as Exam;
          final questions = examData.questions ?? [];
          
          // Initialize timer with exam duration
          if (_remainingTime == null && _timer == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _startTimer(Duration(minutes: examData.durationMinutes));
            });
          }
          
          if (questions.isEmpty) {
            return const Center(
              child: Text('No questions available for this exam.'),
            );
          }

          final currentQuestion = questions[_currentQuestionIndex];
          final totalQuestions = questions.length;
          final progress = (_currentQuestionIndex + 1) / totalQuestions;

          return Column(
            children: [
              // Progress bar
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Question ${_currentQuestionIndex + 1} of $totalQuestions',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: AppColors.outline.withValues(alpha: 0.2),
                    ),
                  ],
                ),
              ),
              // Question content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Question header
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: AppColors.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      currentQuestion.typeDisplay,
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '${currentQuestion.marks.toStringAsFixed(0)} marks',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: AppColors.muted,
                                        ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                currentQuestion.questionText,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              if (currentQuestion.questionDescription != null &&
                                  currentQuestion.questionDescription!.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Text(
                                  currentQuestion.questionDescription!,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Answer options
                      if (currentQuestion.type == 'multiple_choice' ||
                          currentQuestion.type == 'true_false') ...[
                        if (currentQuestion.options != null)
                          ...currentQuestion.options!.map((option) {
                            final isSelected = _selectedAnswers[currentQuestion.id] == option.id;
                            return Card(
                              elevation: 0,
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.outline.withValues(alpha: 0.5),
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedAnswers[currentQuestion.id] = option.id;
                                  });
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: isSelected
                                                ? AppColors.primary
                                                : AppColors.outline,
                                            width: 2,
                                          ),
                                          color: isSelected
                                              ? AppColors.primary
                                              : Colors.transparent,
                                        ),
                                        child: isSelected
                                            ? const Icon(
                                                Icons.check,
                                                size: 16,
                                                color: Colors.white,
                                              )
                                            : null,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          option.optionText,
                                          style: Theme.of(context).textTheme.bodyLarge,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                      ] else if (currentQuestion.type == 'short_answer') ...[
                        TextField(
                          decoration: const InputDecoration(
                            labelText: 'Your Answer',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 5,
                          onChanged: (value) {
                            _shortAnswers[currentQuestion.id] = value;
                          },
                          controller: TextEditingController(
                            text: _shortAnswers[currentQuestion.id] ?? '',
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              // Navigation buttons
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    if (_currentQuestionIndex > 0)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            setState(() {
                              _currentQuestionIndex--;
                            });
                          },
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Previous'),
                        ),
                      ),
                    if (_currentQuestionIndex > 0) const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: FilledButton.icon(
                        onPressed: () {
                          if (_currentQuestionIndex < totalQuestions - 1) {
                            setState(() {
                              _currentQuestionIndex++;
                            });
                          } else {
                            _submitExam();
                          }
                        },
                        icon: Icon(
                          _currentQuestionIndex < totalQuestions - 1
                              ? Icons.arrow_forward
                              : Icons.check,
                        ),
                        label: Text(
                          _currentQuestionIndex < totalQuestions - 1
                              ? 'Next'
                              : 'Submit',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

