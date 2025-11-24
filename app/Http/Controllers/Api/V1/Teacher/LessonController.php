<?php

namespace App\Http\Controllers\Api\V1\Teacher;

use App\Enums\UserType;
use App\Http\Controllers\Controller;
use App\Http\Requests\Api\Teacher\LessonStoreRequest;
use App\Http\Resources\LessonResource;
use App\Models\Lesson;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class LessonController extends Controller
{
    public function __construct()
    {
        $this->middleware('auth:sanctum');
    }

    public function index(Request $request)
    {
        $teacher = $this->authTeacher();

        $lessons = Lesson::with(['class', 'subject'])
            ->where('teacher_id', $teacher->id)
            ->latest()
            ->paginate($request->get('per_page', 15));

        return LessonResource::collection($lessons);
    }

    public function store(LessonStoreRequest $request)
    {
        $teacher = $this->authTeacher();

        $data = $request->validated();

        $classIds = $teacher->classesAsTeacher()->pluck('id')->all();
        $subjectIds = $teacher->subjects()->pluck('subjects.id')->all();

        abort_unless(in_array($data['class_id'], $classIds), 403, 'You are not assigned to this class.');
        abort_unless(in_array($data['subject_id'], $subjectIds), 403, 'You are not assigned to this subject.');

        $lesson = Lesson::create([
            'title' => $data['title'],
            'description' => $data['description'] ?? null,
            'content' => $data['content'] ?? null,
            'class_id' => $data['class_id'],
            'subject_id' => $data['subject_id'],
            'teacher_id' => $teacher->id,
            'lesson_date' => $data['lesson_date'],
            'duration_minutes' => $data['duration_minutes'] ?? null,
            'status' => 'published',
        ]);

        return (new LessonResource($lesson->load(['class', 'subject'])))
            ->response()
            .setStatusCode(201);
    }

    private function authTeacher()
    {
        /** @var \App\Models\User $user */
        $user = Auth::user();

        abort_unless($user && (int) $user->type === UserType::Teacher->value, 403, 'Only teachers can access this resource.');

        return $user;
    }
}

