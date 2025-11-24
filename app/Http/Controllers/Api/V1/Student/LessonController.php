<?php

namespace App\Http\Controllers\Api\V1\Student;

use App\Enums\TransactionName;
use App\Enums\UserType;
use App\Http\Controllers\Controller;
use App\Http\Resources\LessonResource;
use App\Http\Resources\Student\LessonSummaryResource;
use App\Models\Lesson;
use App\Models\LessonView;
use App\Models\User;
use App\Services\CustomWalletService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class LessonController extends Controller
{
    public function __construct(private readonly CustomWalletService $wallet)
    {
        $this->middleware('auth:sanctum');
    }

    public function index(Request $request)
    {
        $student = $this->authStudent();

        $teacherId = $student->teacher_id;

        abort_unless($teacherId, 403, 'You are not assigned to a teacher yet.');

        $lessons = Lesson::with(['class', 'subject'])
            ->where('teacher_id', $teacherId)
            ->when($student->class_id, function ($query) use ($student) {
                $query->where('class_id', $student->class_id);
            })
            ->latest()
            ->paginate($request->get('per_page', 15));

        return LessonSummaryResource::collection($lessons);
    }

    public function show(Lesson $lesson)
    {
        $student = $this->authStudent();

        abort_unless($lesson->teacher_id === $student->teacher_id, 403);
        if ($student->class_id) {
            abort_unless($lesson->class_id === $student->class_id, 403);
        }

        $this->chargeLessonAccess($student, $lesson);

        $lesson->load(['class', 'subject']);

        return new LessonResource($lesson);
    }

    private function authStudent()
    {
        $user = Auth::user();

        abort_unless($user && (int) $user->type === UserType::Student->value, 403, 'Only students can access this resource.');

        return $user;
    }

    private function chargeLessonAccess(User $student, Lesson $lesson): void
    {
        $alreadyViewed = LessonView::where('student_id', $student->id)
            ->where('lesson_id', $lesson->id)
            ->exists();

        if ($alreadyViewed) {
            return;
        }

        $teacher = User::find($lesson->teacher_id);

        if (!$teacher) {
            return;
        }

        $cost = 100;

        if (!$this->wallet->hasBalance($student, $cost)) {
            abort(402, 'Insufficient balance to view this lesson.');
        }

        $this->wallet->transfer($student, $teacher, $cost, TransactionName::DebitTransfer);

        LessonView::create([
            'lesson_id' => $lesson->id,
            'student_id' => $student->id,
            'amount' => $cost,
        ]);
    }
}

