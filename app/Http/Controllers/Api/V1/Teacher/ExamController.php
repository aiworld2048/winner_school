<?php

namespace App\Http\Controllers\Api\V1\Teacher;

use App\Enums\UserType;
use App\Http\Controllers\Controller;
use App\Http\Requests\Api\Teacher\ExamStoreRequest;
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
        $teacher = $this->authTeacher();

        $query = Exam::with(['subject', 'class', 'academicYear'])
            ->where('created_by', $teacher->id);

        // Filter by subject if provided
        if ($request->filled('subject_id')) {
            $query->where('subject_id', $request->subject_id);
        }

        // Filter by class if provided
        if ($request->filled('class_id')) {
            $query->where('class_id', $request->class_id);
        }

        // Filter by type if provided
        if ($request->filled('type')) {
            $query->where('type', $request->type);
        }

        // Filter by published status
        if ($request->filled('is_published')) {
            $query->where('is_published', $request->is_published === '1');
        }

        $exams = $query->latest('exam_date')
            ->paginate($request->get('per_page', 15));

        return ExamResource::collection($exams);
    }

    public function store(ExamStoreRequest $request)
    {
        $teacher = $this->authTeacher();

        $data = $request->validated();

        // Verify teacher has access to the class and subject
        $classIds = $teacher->classesAsTeacher()->pluck('id')->all();
        $subjectIds = $teacher->subjects()->pluck('subjects.id')->all();

        abort_unless(in_array($data['class_id'], $classIds), 403, 'You are not assigned to this class.');
        abort_unless(in_array($data['subject_id'], $subjectIds), 403, 'You are not assigned to this subject.');

        $exam = Exam::create([
            'title' => $data['title'],
            'code' => $data['code'],
            'description' => $data['description'] ?? null,
            'subject_id' => $data['subject_id'],
            'class_id' => $data['class_id'],
            'academic_year_id' => $data['academic_year_id'],
            'exam_date' => $data['exam_date'],
            'duration_minutes' => $data['duration_minutes'],
            'total_marks' => $data['total_marks'],
            'passing_marks' => $data['passing_marks'],
            'type' => $data['type'],
            'is_published' => $data['is_published'] ?? false,
            'created_by' => $teacher->id,
        ]);

        return (new ExamResource($exam->load(['subject', 'class', 'academicYear'])))
            ->response()
            ->setStatusCode(201);
    }

    public function show(Exam $exam)
    {
        $teacher = $this->authTeacher();

        abort_unless($exam->created_by === $teacher->id, 403, 'You do not have access to this exam.');

        $exam->load(['subject', 'class', 'academicYear', 'creator', 'questions.options']);

        return new ExamResource($exam);
    }

    public function update(ExamStoreRequest $request, Exam $exam)
    {
        $teacher = $this->authTeacher();

        abort_unless($exam->created_by === $teacher->id, 403, 'You do not have access to this exam.');

        $data = $request->validated();

        // Verify teacher has access to the class and subject
        $classIds = $teacher->classesAsTeacher()->pluck('id')->all();
        $subjectIds = $teacher->subjects()->pluck('subjects.id')->all();

        abort_unless(in_array($data['class_id'], $classIds), 403, 'You are not assigned to this class.');
        abort_unless(in_array($data['subject_id'], $subjectIds), 403, 'You are not assigned to this subject.');

        $exam->update($data);

        return new ExamResource($exam->load(['subject', 'class', 'academicYear']));
    }

    public function destroy(Exam $exam)
    {
        $teacher = $this->authTeacher();

        abort_unless($exam->created_by === $teacher->id, 403, 'You do not have access to this exam.');

        $exam->delete();

        return response()->json(['message' => 'Exam deleted successfully.'], 200);
    }

    private function authTeacher()
    {
        /** @var \App\Models\User $user */
        $user = Auth::user();

        abort_unless($user && (int) $user->type === UserType::Teacher->value, 403, 'Only teachers can access this resource.');

        return $user;
    }
}

