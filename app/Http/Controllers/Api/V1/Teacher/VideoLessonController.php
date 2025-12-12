<?php

namespace App\Http\Controllers\Api\V1\Teacher;

use App\Enums\UserType;
use App\Http\Controllers\Controller;
use App\Http\Resources\VideoLessonResource;
use App\Models\VideoLesson;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Storage;

class VideoLessonController extends Controller
{
    public function __construct()
    {
        $this->middleware('auth:sanctum');
    }

    public function index(Request $request)
    {
        $teacher = $this->authTeacher();

        $query = VideoLesson::with(['subject', 'class', 'academicYear', 'teacher'])
            ->withCount('views')
            ->where('teacher_id', $teacher->id);

        // Filter by subject
        if ($request->filled('subject_id')) {
            $query->where('subject_id', $request->subject_id);
        }

        // Filter by class
        if ($request->filled('class_id')) {
            $query->where('class_id', $request->class_id);
        }

        // Filter by status
        if ($request->filled('status')) {
            $query->where('status', $request->status);
        }

        // Filter by academic year
        if ($request->filled('academic_year_id')) {
            $query->where('academic_year_id', $request->academic_year_id);
        }

        $videoLessons = $query->latest('lesson_date')->paginate($request->get('per_page', 15));

        return VideoLessonResource::collection($videoLessons);
    }

    public function store(Request $request)
    {
        $teacher = $this->authTeacher();

        $data = $request->validate([
            'title' => ['required', 'string', 'max:255'],
            'description' => ['nullable', 'string'],
            'video_url' => ['required', 'url', 'max:500'],
            'thumbnail_url' => ['nullable', 'url', 'max:500'],
            'subject_id' => ['required', 'exists:subjects,id'],
            'class_id' => ['required', 'exists:classes,id'],
            'academic_year_id' => ['nullable', 'exists:academic_years,id'],
            'lesson_date' => ['nullable', 'date'],
            'duration_minutes' => ['nullable', 'integer', 'min:1'],
            'status' => ['required', 'in:draft,published'],
            'attachments' => ['nullable', 'array'],
            'attachments.*' => ['file', 'max:10240'], // 10MB max per file
        ]);

        // Verify teacher has access to selected subject/class
        $subjectIds = $teacher->subjects()->pluck('subjects.id')->all();
        $classIds = $teacher->classesAsTeacher()->pluck('id')->all();
        
        abort_unless(in_array($data['subject_id'], $subjectIds), 403, 'You do not have access to this subject.');
        abort_unless(in_array($data['class_id'], $classIds), 403, 'You do not have access to this class.');

        // Handle file uploads
        if ($request->hasFile('attachments')) {
            $attachments = [];
            foreach ($request->file('attachments') as $file) {
                $path = $file->store('video-lessons/attachments', 'public');
                $attachments[] = $path;
            }
            $data['attachments'] = $attachments;
        }

        $data['teacher_id'] = $teacher->id;
        $videoLesson = VideoLesson::create($data);

        return (new VideoLessonResource($videoLesson->load(['subject', 'class', 'academicYear', 'teacher'])))
            ->response()
            ->setStatusCode(201);
    }

    public function show(VideoLesson $videoLesson)
    {
        $teacher = $this->authTeacher();

        abort_unless($videoLesson->teacher_id === $teacher->id, 403, 'You do not have access to this video lesson.');

        $videoLesson->load(['subject', 'class', 'academicYear', 'teacher']);
        $videoLesson->loadCount('views');

        return new VideoLessonResource($videoLesson);
    }

    public function update(Request $request, VideoLesson $videoLesson)
    {
        $teacher = $this->authTeacher();

        abort_unless($videoLesson->teacher_id === $teacher->id, 403, 'You do not have access to this video lesson.');

        $data = $request->validate([
            'title' => ['required', 'string', 'max:255'],
            'description' => ['nullable', 'string'],
            'video_url' => ['required', 'url', 'max:500'],
            'thumbnail_url' => ['nullable', 'url', 'max:500'],
            'subject_id' => ['required', 'exists:subjects,id'],
            'class_id' => ['required', 'exists:classes,id'],
            'academic_year_id' => ['nullable', 'exists:academic_years,id'],
            'lesson_date' => ['nullable', 'date'],
            'duration_minutes' => ['nullable', 'integer', 'min:1'],
            'status' => ['required', 'in:draft,published'],
            'attachments' => ['nullable', 'array'],
            'attachments.*' => ['file', 'max:10240'],
        ]);

        // Verify teacher has access to selected subject/class
        $subjectIds = $teacher->subjects()->pluck('subjects.id')->all();
        $classIds = $teacher->classesAsTeacher()->pluck('id')->all();
        
        abort_unless(in_array($data['subject_id'], $subjectIds), 403, 'You do not have access to this subject.');
        abort_unless(in_array($data['class_id'], $classIds), 403, 'You do not have access to this class.');

        // Handle file uploads
        if ($request->hasFile('attachments')) {
            $attachments = $videoLesson->attachments ?? [];
            foreach ($request->file('attachments') as $file) {
                $path = $file->store('video-lessons/attachments', 'public');
                $attachments[] = $path;
            }
            $data['attachments'] = $attachments;
        }

        $videoLesson->update($data);

        return new VideoLessonResource($videoLesson->load(['subject', 'class', 'academicYear', 'teacher']));
    }

    public function destroy(VideoLesson $videoLesson)
    {
        $teacher = $this->authTeacher();

        abort_unless($videoLesson->teacher_id === $teacher->id, 403, 'You do not have access to this video lesson.');

        // Delete attachments
        if ($videoLesson->attachments) {
            foreach ($videoLesson->attachments as $attachment) {
                Storage::disk('public')->delete($attachment);
            }
        }

        $videoLesson->delete();

        return response()->json(['message' => 'Video lesson deleted successfully.'], 200);
    }

    private function authTeacher()
    {
        $user = Auth::user();

        abort_unless($user && (int) $user->type === UserType::Teacher->value, 403, 'Only teachers can access this resource.');

        return $user;
    }
}
