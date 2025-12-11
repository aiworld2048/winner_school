<?php

namespace App\Http\Controllers\Admin;

use App\Enums\UserType;
use App\Http\Controllers\Controller;
use App\Models\Exam;
use App\Models\ExamQuestion;
use App\Models\ExamQuestionOption;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\View\View;
use Illuminate\Http\RedirectResponse;

class ExamQuestionController extends Controller
{
    public function __construct()
    {
        $this->middleware(function ($request, $next) {
            $user = Auth::user();
            $userType = (int) $user->type;
            
            // Allow both HeadTeacher and Teacher
            if ($userType === UserType::HeadTeacher->value || 
                $userType === UserType::Teacher->value) {
                return $next($request);
            }
            
            abort(403, 'Unauthorized action.');
        });
    }

    /**
     * Show all exams with question management links.
     */
    public function exams(): View
    {
        $user = Auth::user();
        $userType = (int) $user->type;
        
        $query = Exam::withCount('questions');

        // Teachers can only see their own exams
        if ($userType === UserType::Teacher->value) {
            $query->where('created_by', $user->id);
        }

        $exams = $query->latest('exam_date')->paginate(15);

        return view('admin.exams.questions.exams', compact('exams'));
    }

    /**
     * Show the form for creating a new question for an exam.
     */
    public function create(Exam $exam): View
    {
        $user = Auth::user();
        $userType = (int) $user->type;
        
        // Teachers can only add questions to their own exams
        if ($userType === UserType::Teacher->value) {
            abort_unless($exam->created_by === $user->id, 403, 'You can only add questions to your own exams.');
        }

        $exam->load('questions');
        $nextOrder = $exam->questions->max('order') + 1 ?? 1;

        return view('admin.exams.questions.create', compact('exam', 'nextOrder'));
    }

    /**
     * Store a newly created question.
     */
    public function store(Request $request, Exam $exam): RedirectResponse
    {
        $user = Auth::user();
        $userType = (int) $user->type;
        
        // Teachers can only add questions to their own exams
        if ($userType === UserType::Teacher->value) {
            abort_unless($exam->created_by === $user->id, 403, 'You can only add questions to your own exams.');
        }

        $data = $request->validate([
            'question_text' => ['required', 'string'],
            'question_description' => ['nullable', 'string'],
            'marks' => ['required', 'numeric', 'min:0.1', 'max:100'],
            'order' => ['required', 'integer', 'min:1'],
            'type' => ['required', 'in:multiple_choice,true_false,short_answer'],
            'correct_answer' => ['nullable', 'string', 'required_if:type,short_answer'],
            'options' => ['required_if:type,multiple_choice,true_false', 'array', 'min:2'],
            'options.*.option_text' => ['required', 'string'],
            'options.*.is_correct' => ['required', 'boolean'],
            'options.*.order' => ['required', 'integer'],
        ]);

        // For multiple choice and true/false, ensure at least one correct option
        if (in_array($data['type'], ['multiple_choice', 'true_false'])) {
            $hasCorrectOption = collect($data['options'])->contains(function ($option) {
                return isset($option['is_correct']) && $option['is_correct'] == true;
            });
            
            abort_unless($hasCorrectOption, 422, 'At least one option must be marked as correct.');
        }

        $question = ExamQuestion::create([
            'exam_id' => $exam->id,
            'question_text' => $data['question_text'],
            'question_description' => $data['question_description'] ?? null,
            'marks' => $data['marks'],
            'order' => $data['order'],
            'type' => $data['type'],
            'correct_answer' => $data['correct_answer'] ?? null,
        ]);

        // Create options for multiple choice and true/false questions
        if (in_array($data['type'], ['multiple_choice', 'true_false']) && isset($data['options'])) {
            foreach ($data['options'] as $optionData) {
                ExamQuestionOption::create([
                    'exam_question_id' => $question->id,
                    'option_text' => $optionData['option_text'],
                    'is_correct' => $optionData['is_correct'] ?? false,
                    'order' => $optionData['order'],
                ]);
            }
        }

        // Recalculate total marks for the exam
        $this->recalculateExamMarks($exam);

        return redirect()
            ->route('admin.exams.questions.index', $exam)
            ->with('success', 'Question added successfully.');
    }

    /**
     * Display all questions for an exam.
     */
    public function index(Exam $exam): View
    {
        $user = Auth::user();
        $userType = (int) $user->type;
        
        // Teachers can only view questions for their own exams
        if ($userType === UserType::Teacher->value) {
            abort_unless($exam->created_by === $user->id, 403, 'You can only view questions for your own exams.');
        }

        $questions = $exam->questions()->with('options')->ordered()->get();
        $totalQuestionMarks = $questions->sum('marks');

        return view('admin.exams.questions.index', compact('exam', 'questions', 'totalQuestionMarks'));
    }

    /**
     * Show the form for editing a question.
     */
    public function edit(Exam $exam, ExamQuestion $question): View
    {
        $user = Auth::user();
        $userType = (int) $user->type;
        
        // Verify question belongs to exam
        abort_unless($question->exam_id === $exam->id, 404, 'Question not found for this exam.');
        
        // Teachers can only edit questions for their own exams
        if ($userType === UserType::Teacher->value) {
            abort_unless($exam->created_by === $user->id, 403, 'You can only edit questions for your own exams.');
        }

        $question->load('options');

        return view('admin.exams.questions.edit', compact('exam', 'question'));
    }

    /**
     * Update a question.
     */
    public function update(Request $request, Exam $exam, ExamQuestion $question): RedirectResponse
    {
        $user = Auth::user();
        $userType = (int) $user->type;
        
        // Verify question belongs to exam
        abort_unless($question->exam_id === $exam->id, 404, 'Question not found for this exam.');
        
        // Teachers can only update questions for their own exams
        if ($userType === UserType::Teacher->value) {
            abort_unless($exam->created_by === $user->id, 403, 'You can only update questions for your own exams.');
        }

        $data = $request->validate([
            'question_text' => ['required', 'string'],
            'question_description' => ['nullable', 'string'],
            'marks' => ['required', 'numeric', 'min:0.1', 'max:100'],
            'order' => ['required', 'integer', 'min:1'],
            'type' => ['required', 'in:multiple_choice,true_false,short_answer'],
            'correct_answer' => ['nullable', 'string', 'required_if:type,short_answer'],
            'options' => ['required_if:type,multiple_choice,true_false', 'array', 'min:2'],
            'options.*.option_text' => ['required', 'string'],
            'options.*.is_correct' => ['required', 'boolean'],
            'options.*.order' => ['required', 'integer'],
        ]);

        // For multiple choice and true/false, ensure at least one correct option
        if (in_array($data['type'], ['multiple_choice', 'true_false'])) {
            $hasCorrectOption = collect($data['options'])->contains(function ($option) {
                return isset($option['is_correct']) && $option['is_correct'] == true;
            });
            
            abort_unless($hasCorrectOption, 422, 'At least one option must be marked as correct.');
        }

        $question->update([
            'question_text' => $data['question_text'],
            'question_description' => $data['question_description'] ?? null,
            'marks' => $data['marks'],
            'order' => $data['order'],
            'type' => $data['type'],
            'correct_answer' => $data['correct_answer'] ?? null,
        ]);

        // Delete existing options and create new ones
        $question->options()->delete();

        if (in_array($data['type'], ['multiple_choice', 'true_false']) && isset($data['options'])) {
            foreach ($data['options'] as $optionData) {
                ExamQuestionOption::create([
                    'exam_question_id' => $question->id,
                    'option_text' => $optionData['option_text'],
                    'is_correct' => $optionData['is_correct'] ?? false,
                    'order' => $optionData['order'],
                ]);
            }
        }

        // Recalculate total marks for the exam
        $this->recalculateExamMarks($exam);

        return redirect()
            ->route('admin.exams.questions.index', $exam)
            ->with('success', 'Question updated successfully.');
    }

    /**
     * Remove a question.
     */
    public function destroy(Exam $exam, ExamQuestion $question): RedirectResponse
    {
        $user = Auth::user();
        $userType = (int) $user->type;
        
        // Verify question belongs to exam
        abort_unless($question->exam_id === $exam->id, 404, 'Question not found for this exam.');
        
        // Teachers can only delete questions for their own exams
        if ($userType === UserType::Teacher->value) {
            abort_unless($exam->created_by === $user->id, 403, 'You can only delete questions for your own exams.');
        }

        $question->delete();

        // Recalculate total marks for the exam
        $this->recalculateExamMarks($exam);

        return redirect()
            ->route('admin.exams.questions.index', $exam)
            ->with('success', 'Question deleted successfully.');
    }

    /**
     * Recalculate and update exam total marks based on questions.
     */
    private function recalculateExamMarks(Exam $exam): void
    {
        $totalMarks = $exam->questions()->sum('marks');
        $exam->update(['total_marks' => $totalMarks]);
    }
}
