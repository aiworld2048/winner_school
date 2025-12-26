<?php

namespace App\Http\Controllers\Teacher;

use App\Enums\UserType;
use App\Http\Controllers\Controller;
use App\Models\Lesson;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class LessonController extends Controller
{
    public function __construct()
    {
        $this->middleware('teacher');
    }

    private function teacherClasses()
    {
        return Auth::user()->classesAsTeacher()->with('subjects')->get();
    }

    public function index()
    {
        $teacher = Auth::user();

        $lessons = Lesson::where('teacher_id', $teacher->id)
            ->with(['class', 'subject'])
            ->latest()
            ->paginate(15);

        return view('teacher.lessons.index', compact('lessons'));
    }

    public function create()
    {
        $classes = $this->teacherClasses();

        return view('teacher.lessons.create', compact('classes'));
    }

    public function store(Request $request)
    {
        $teacher = Auth::user();
        $classIds = $teacher->classesAsTeacher()->pluck('id')->all();
        $subjectIds = $teacher->subjects()->pluck('subjects.id')->all();

        $data = $request->validate([
            'title' => ['required', 'string', 'max:255'],
            'description' => ['nullable', 'string'],
            'content' => ['nullable', 'string'],
            'class_id' => ['required', 'in:'.implode(',', $classIds)],
            'subject_id' => ['required', 'in:'.implode(',', $subjectIds)],
            'lesson_date' => ['required', 'date'],
            'duration_minutes' => ['nullable', 'integer'],
        ]);

        // Handle PDF file upload
        if ($request->hasFile('pdf_file')) {
            $pdfFile = $request->file('pdf_file');
            $pdfFilename = time() . '_' . uniqid() . '.' . $pdfFile->getClientOriginalExtension();
            $pdfFile->move(public_path('storage/lessons/pdfs'), $pdfFilename);
            $data['pdf_file'] = 'lessons/pdfs/' . $pdfFilename;
        }

        Lesson::create([
            'title' => $data['title'],
            'description' => $data['description'] ?? null,
            'content' => $data['content'] ?? null,
            'class_id' => $data['class_id'],
            'subject_id' => $data['subject_id'],
            'teacher_id' => $teacher->id,
            'lesson_date' => $data['lesson_date'],
            'duration_minutes' => $data['duration_minutes'] ?? null,
            'status' => 'draft',
            'pdf_file' => $data['pdf_file'] ?? null,
        ]);

        return redirect()
            ->route('teacher.lessons.index')
            ->with('success', 'Lesson created.');
    }

    public function show(Lesson $lesson)
    {
        $this->authorizeLesson($lesson);
        $lesson->load(['class.academicYear', 'subject']);

        return view('teacher.lessons.show', compact('lesson'));
    }

    public function edit(Lesson $lesson)
    {
        $this->authorizeLesson($lesson);
        $classes = $this->teacherClasses();

        return view('teacher.lessons.edit', compact('lesson', 'classes'));
    }

    public function update(Request $request, Lesson $lesson)
    {
        $this->authorizeLesson($lesson);

        $teacher = Auth::user();
        $classIds = $teacher->classesAsTeacher()->pluck('id')->all();
        $subjectIds = $teacher->subjects()->pluck('subjects.id')->all();

        $data = $request->validate([
            'title' => ['required', 'string', 'max:255'],
            'description' => ['nullable', 'string'],
            'content' => ['nullable', 'string'],
            'class_id' => ['required', 'in:'.implode(',', $classIds)],
            'subject_id' => ['required', 'in:'.implode(',', $subjectIds)],
            'lesson_date' => ['required', 'date'],
            'duration_minutes' => ['nullable', 'integer'],
            'pdf_file' => ['nullable', 'file', 'mimes:pdf', 'max:10240'], // 10MB max
        ]);

        // Handle PDF file upload
        if ($request->hasFile('pdf_file')) {
            // Delete old PDF if exists
            if ($lesson->pdf_file && file_exists(public_path('storage/' . $lesson->pdf_file))) {
                unlink(public_path('storage/' . $lesson->pdf_file));
            }
            
            $pdfFile = $request->file('pdf_file');
            $pdfFilename = time() . '_' . uniqid() . '.' . $pdfFile->getClientOriginalExtension();
            $pdfFile->move(public_path('storage/lessons/pdfs'), $pdfFilename);
            $data['pdf_file'] = 'lessons/pdfs/' . $pdfFilename;
        }

        $lesson->update($data);

        return redirect()
            ->route('teacher.lessons.index')
            ->with('success', 'Lesson updated.');
    }

    private function authorizeLesson(Lesson $lesson): void
    {
        abort_unless($lesson->teacher_id === Auth::id(), 403);
    }
}

