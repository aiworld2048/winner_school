<?php

namespace App\Http\Controllers\Api\V1\Teacher;

use App\Enums\UserType;
use App\Http\Controllers\Controller;
use App\Http\Resources\EssayResource;
use App\Models\Essay;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Storage;

class EssayController extends Controller
{
    public function __construct()
    {
        $this->middleware('auth:sanctum');
    }

    public function index(Request $request)
    {
        $teacher = $this->authTeacher();

        $query = Essay::with(['subject', 'class', 'academicYear', 'teacher'])
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

        $essays = $query->latest('due_date')->paginate($request->get('per_page', 15));

        return EssayResource::collection($essays);
    }

    public function store(Request $request)
    {
        $teacher = $this->authTeacher();

        $data = $request->validate([
            'title' => ['required', 'string', 'max:255'],
            'description' => ['nullable', 'string'],
            'instructions' => ['nullable', 'string'],
            'subject_id' => ['required', 'exists:subjects,id'],
            'class_id' => ['required', 'exists:classes,id'],
            'academic_year_id' => ['required', 'exists:academic_years,id'],
            'due_date' => ['required', 'date', 'after_or_equal:today'],
            'due_time' => ['nullable', 'date_format:H:i'],
            'word_count_min' => ['nullable', 'integer', 'min:0'],
            'word_count_max' => ['nullable', 'integer', 'min:0', 'gt:word_count_min'],
            'total_marks' => ['required', 'numeric', 'min:1', 'max:1000'],
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
                $path = $file->store('essays/attachments', 'public');
                $attachments[] = $path;
            }
            $data['attachments'] = $attachments;
        }

        $data['teacher_id'] = $teacher->id;
        $essay = Essay::create($data);

        return new EssayResource($essay->load(['subject', 'class', 'academicYear', 'teacher']));
    }

    public function show(Essay $essay)
    {
        $teacher = $this->authTeacher();

        abort_unless($essay->teacher_id === $teacher->id, 403, 'You do not have access to this essay.');

        $essay->load(['subject', 'class', 'academicYear', 'teacher', 'submissions']);
        $essay->loadCount('views');

        return new EssayResource($essay);
    }

    public function update(Request $request, Essay $essay)
    {
        $teacher = $this->authTeacher();

        abort_unless($essay->teacher_id === $teacher->id, 403, 'You do not have access to this essay.');

        $data = $request->validate([
            'title' => ['required', 'string', 'max:255'],
            'description' => ['nullable', 'string'],
            'instructions' => ['nullable', 'string'],
            'subject_id' => ['required', 'exists:subjects,id'],
            'class_id' => ['required', 'exists:classes,id'],
            'academic_year_id' => ['required', 'exists:academic_years,id'],
            'due_date' => ['required', 'date'],
            'due_time' => ['nullable', 'date_format:H:i'],
            'word_count_min' => ['nullable', 'integer', 'min:0'],
            'word_count_max' => ['nullable', 'integer', 'min:0', 'gt:word_count_min'],
            'total_marks' => ['required', 'numeric', 'min:1', 'max:1000'],
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
            $attachments = $essay->attachments ?? [];
            foreach ($request->file('attachments') as $file) {
                $path = $file->store('essays/attachments', 'public');
                $attachments[] = $path;
            }
            $data['attachments'] = $attachments;
        }

        $essay->update($data);

        return new EssayResource($essay->load(['subject', 'class', 'academicYear', 'teacher']));
    }

    public function destroy(Essay $essay)
    {
        $teacher = $this->authTeacher();

        abort_unless($essay->teacher_id === $teacher->id, 403, 'You do not have access to this essay.');

        // Delete attachments
        if ($essay->attachments) {
            foreach ($essay->attachments as $attachment) {
                Storage::disk('public')->delete($attachment);
            }
        }

        $essay->delete();

        return response()->json(['message' => 'Essay deleted successfully.'], 200);
    }

    private function authTeacher()
    {
        $user = Auth::user();

        abort_unless($user && (int) $user->type === UserType::Teacher->value, 403, 'Only teachers can access this resource.');

        return $user;
    }
}

