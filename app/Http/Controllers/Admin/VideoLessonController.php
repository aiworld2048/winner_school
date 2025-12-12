<?php

namespace App\Http\Controllers\Admin;

use App\Enums\UserType;
use App\Http\Controllers\Controller;
use App\Models\AcademicYear;
use App\Models\SchoolClass;
use App\Models\Subject;
use App\Models\VideoLesson;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\View\View;
use Illuminate\Http\RedirectResponse;

class VideoLessonController extends Controller
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

    public function index(Request $request): View
    {
        $user = Auth::user();
        $userType = (int) $user->type;
        
        $query = VideoLesson::with(['subject', 'class', 'academicYear', 'teacher'])
            ->withCount('views');

        // Teachers can only see their own video lessons
        if ($userType === UserType::Teacher->value) {
            $query->where('teacher_id', $user->id);
        }

        // Filter by academic year
        if ($request->filled('academic_year_id')) {
            $query->where('academic_year_id', $request->academic_year_id);
        }

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

        $videoLessons = $query->latest('lesson_date')->paginate(15);

        // Get filter options
        $academicYears = AcademicYear::where('is_active', true)->orderBy('name')->get();
        
        if ($userType === UserType::Teacher->value) {
            $subjectIds = $user->subjects()->pluck('subjects.id')->all();
            $classIds = $user->classesAsTeacher()->pluck('id')->all();
            $subjects = Subject::where('is_active', true)
                ->whereIn('id', $subjectIds)
                ->orderBy('name')
                ->get();
            $classes = SchoolClass::where('is_active', true)
                ->whereIn('id', $classIds)
                ->orderBy('name')
                ->get();
        } else {
            $subjects = Subject::where('is_active', true)->orderBy('name')->get();
            $classes = SchoolClass::where('is_active', true)->orderBy('name')->get();
        }

        return view('admin.video-lessons.index', compact('videoLessons', 'academicYears', 'subjects', 'classes'));
    }

    public function create(): View
    {
        $user = Auth::user();
        $userType = (int) $user->type;

        $academicYears = AcademicYear::where('is_active', true)->orderBy('name')->get();
        
        if ($userType === UserType::Teacher->value) {
            $subjectIds = $user->subjects()->pluck('subjects.id')->all();
            $classIds = $user->classesAsTeacher()->pluck('id')->all();
            $subjects = Subject::where('is_active', true)
                ->whereIn('id', $subjectIds)
                ->orderBy('name')
                ->get();
            $classes = SchoolClass::where('is_active', true)
                ->whereIn('id', $classIds)
                ->orderBy('name')
                ->get();
        } else {
            $subjects = Subject::where('is_active', true)->orderBy('name')->get();
            $classes = SchoolClass::where('is_active', true)->orderBy('name')->get();
        }

        return view('admin.video-lessons.create', compact('academicYears', 'subjects', 'classes'));
    }

    public function store(Request $request): RedirectResponse
    {
        $user = Auth::user();
        $userType = (int) $user->type;

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
        if ($userType === UserType::Teacher->value) {
            $subjectIds = $user->subjects()->pluck('subjects.id')->all();
            $classIds = $user->classesAsTeacher()->pluck('id')->all();
            
            abort_unless(in_array($data['subject_id'], $subjectIds), 403, 'You do not have access to this subject.');
            abort_unless(in_array($data['class_id'], $classIds), 403, 'You do not have access to this class.');
        }

        // Handle file uploads
        if ($request->hasFile('attachments')) {
            $attachments = [];
            foreach ($request->file('attachments') as $file) {
                $path = $file->store('video-lessons/attachments', 'public');
                $attachments[] = $path;
            }
            $data['attachments'] = $attachments;
        }

        $data['teacher_id'] = $user->id;
        $videoLesson = VideoLesson::create($data);

        return redirect()
            ->route('admin.video-lessons.index')
            ->with('success', 'Video lesson created successfully.');
    }

    public function show(VideoLesson $videoLesson): View
    {
        $user = Auth::user();
        $userType = (int) $user->type;
        
        // Teachers can only view their own video lessons
        if ($userType === UserType::Teacher->value) {
            abort_unless($videoLesson->teacher_id === $user->id, 403, 'You can only view your own video lessons.');
        }

        $videoLesson->load(['subject', 'class', 'academicYear', 'teacher', 'views']);
        $videoLesson->loadCount('views');

        return view('admin.video-lessons.show', compact('videoLesson'));
    }

    public function edit(VideoLesson $videoLesson): View
    {
        $user = Auth::user();
        $userType = (int) $user->type;
        
        // Teachers can only edit their own video lessons
        if ($userType === UserType::Teacher->value) {
            abort_unless($videoLesson->teacher_id === $user->id, 403, 'You can only edit your own video lessons.');
        }

        $academicYears = AcademicYear::where('is_active', true)->orderBy('name')->get();
        
        if ($userType === UserType::Teacher->value) {
            $subjectIds = $user->subjects()->pluck('subjects.id')->all();
            $classIds = $user->classesAsTeacher()->pluck('id')->all();
            $subjects = Subject::where('is_active', true)
                ->whereIn('id', $subjectIds)
                ->orderBy('name')
                ->get();
            $classes = SchoolClass::where('is_active', true)
                ->whereIn('id', $classIds)
                ->orderBy('name')
                ->get();
        } else {
            $subjects = Subject::where('is_active', true)->orderBy('name')->get();
            $classes = SchoolClass::where('is_active', true)->orderBy('name')->get();
        }

        return view('admin.video-lessons.edit', compact('videoLesson', 'academicYears', 'subjects', 'classes'));
    }

    public function update(Request $request, VideoLesson $videoLesson): RedirectResponse
    {
        $user = Auth::user();
        $userType = (int) $user->type;
        
        // Teachers can only update their own video lessons
        if ($userType === UserType::Teacher->value) {
            abort_unless($videoLesson->teacher_id === $user->id, 403, 'You can only update your own video lessons.');
        }

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
        if ($userType === UserType::Teacher->value) {
            $subjectIds = $user->subjects()->pluck('subjects.id')->all();
            $classIds = $user->classesAsTeacher()->pluck('id')->all();
            
            abort_unless(in_array($data['subject_id'], $subjectIds), 403, 'You do not have access to this subject.');
            abort_unless(in_array($data['class_id'], $classIds), 403, 'You do not have access to this class.');
        }

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

        return redirect()
            ->route('admin.video-lessons.index')
            ->with('success', 'Video lesson updated successfully.');
    }

    public function destroy(VideoLesson $videoLesson): RedirectResponse
    {
        $user = Auth::user();
        $userType = (int) $user->type;
        
        // Teachers can only delete their own video lessons
        if ($userType === UserType::Teacher->value) {
            abort_unless($videoLesson->teacher_id === $user->id, 403, 'You can only delete your own video lessons.');
        }

        $videoLesson->delete();

        return redirect()
            ->route('admin.video-lessons.index')
            ->with('success', 'Video lesson deleted successfully.');
    }
}
