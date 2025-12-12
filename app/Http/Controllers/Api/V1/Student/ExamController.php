<?php

namespace App\Http\Controllers\Api\V1\Student;

use App\Enums\UserType;
use App\Http\Controllers\Controller;
use App\Http\Resources\ExamResource;
use App\Models\Exam;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class ExamController extends Controller
{
    public function __construct()
    {
        $this->middleware('auth:sanctum');
    }

    public function index(Request $request)
    {
        $student = $this->authStudent();

        $query = Exam::with(['subject', 'class', 'academicYear'])
            ->where('is_published', true);

        // Only filter by class if student has a class_id
        // If no class_id, return empty result instead of all exams
        if ($student->class_id) {
            $query->where('class_id', $student->class_id);
        } else {
            // Student without class should see no exams
            $query->whereRaw('1 = 0');
        }

        // Filter by subject if provided
        if ($request->filled('subject_id')) {
            $query->where('subject_id', $request->subject_id);
        }

        // Filter by type if provided
        if ($request->filled('type')) {
            $query->where('type', $request->type);
        }

        // Filter by academic year if provided
        if ($request->filled('academic_year_id')) {
            $query->where('academic_year_id', $request->academic_year_id);
        }

        // Only show upcoming and current exams
        if ($request->boolean('upcoming_only')) {
            $query->where('exam_date', '>=', now());
        }

        $exams = $query->orderBy('exam_date', 'asc')
            ->paginate($request->get('per_page', 15));

        return ExamResource::collection($exams);
    }

    public function show(Exam $exam)
    {
        $student = $this->authStudent();

        // Verify student has access to this exam
        abort_unless($exam->is_published, 404, 'Exam not found.');
        abort_unless($exam->class_id === $student->class_id, 403, 'You do not have access to this exam.');

        // Load questions with options (but hide correct answers for students taking the exam)
        $exam->load(['subject', 'class', 'academicYear', 'creator', 'questions.options']);

        return new ExamResource($exam);
    }

    private function authStudent()
    {
        $user = Auth::user();

        abort_unless($user && (int) $user->type === UserType::Student->value, 403, 'Only students can access this resource.');

        return $user;
    }
}

