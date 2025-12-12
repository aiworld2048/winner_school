<?php

namespace App\Http\Controllers\Api\V1\Student;

use App\Enums\TransactionName;
use App\Enums\UserType;
use App\Http\Controllers\Controller;
use App\Http\Resources\VideoLessonResource;
use App\Models\User;
use App\Models\VideoLesson;
use App\Models\VideoLessonView;
use App\Services\CustomWalletService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class VideoLessonController extends Controller
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

        $videoLessons = VideoLesson::with(['subject', 'class', 'academicYear', 'teacher'])
            ->withCount('views')
            ->where('teacher_id', $teacherId)
            ->where('status', 'published')
            ->when($student->class_id, function ($query) use ($student) {
                $query->where('class_id', $student->class_id);
            })
            ->latest('lesson_date')
            ->paginate($request->get('per_page', 15));

        return VideoLessonResource::collection($videoLessons);
    }

    public function show(VideoLesson $videoLesson)
    {
        $student = $this->authStudent();

        abort_unless($videoLesson->teacher_id === $student->teacher_id, 403);
        abort_unless($videoLesson->status === 'published', 404, 'Video lesson not found.');
        if ($student->class_id) {
            abort_unless($videoLesson->class_id === $student->class_id, 403);
        }

        $this->chargeVideoLessonAccess($student, $videoLesson);

        $videoLesson->load(['subject', 'class', 'academicYear', 'teacher']);
        $videoLesson->loadCount('views');

        return new VideoLessonResource($videoLesson);
    }

    private function authStudent()
    {
        $user = Auth::user();

        abort_unless($user && (int) $user->type === UserType::Student->value, 403, 'Only students can access this resource.');

        return $user;
    }

    private function chargeVideoLessonAccess(User $student, VideoLesson $videoLesson): void
    {
        $alreadyViewed = VideoLessonView::where('student_id', $student->id)
            ->where('video_lesson_id', $videoLesson->id)
            ->exists();

        if ($alreadyViewed) {
            return;
        }

        $teacher = User::find($videoLesson->teacher_id);

        if (!$teacher) {
            return;
        }

        $cost = 100;

        if (!$this->wallet->hasBalance($student, $cost)) {
            abort(402, 'Insufficient balance to view this video lesson. Required: 100 MMK');
        }

        $this->wallet->transfer($student, $teacher, $cost, TransactionName::DebitTransfer);

        VideoLessonView::create([
            'video_lesson_id' => $videoLesson->id,
            'student_id' => $student->id,
            'amount' => $cost,
        ]);

        // Increment views count
        $videoLesson->increment('views_count');
    }
}
