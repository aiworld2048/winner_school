<?php

namespace App\Http\Controllers\Admin;

use App\Enums\UserType;
use App\Http\Controllers\Controller;
use App\Models\AcademicYear;
use App\Models\Essay;
use App\Models\SchoolClass;
use App\Models\Subject;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\View\View;
use Illuminate\Http\RedirectResponse;

class EssayController extends Controller
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
        
        $query = Essay::with(['subject', 'class', 'academicYear', 'teacher'])
            ->withCount('views');

        // Teachers can only see their own essays
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

        $essays = $query->latest('due_date')->paginate(15);

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

        return view('admin.essays.index', compact('essays', 'academicYears', 'subjects', 'classes'));
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

        return view('admin.essays.create', compact('academicYears', 'subjects', 'classes'));
    }

    public function store(Request $request): RedirectResponse
    {
        $user = Auth::user();
        $userType = (int) $user->type;

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
            'pdf_file' => ['nullable', 'file', 'mimes:pdf', 'max:10240'], // 10MB max
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
                $path = $file->store('essays/attachments', 'public');
                $attachments[] = $path;
            }
            $data['attachments'] = $attachments;
        }

        // Handle PDF file upload
        if ($request->hasFile('pdf_file')) {
            $pdfFile = $request->file('pdf_file');
            $pdfFilename = time() . '_' . uniqid() . '.' . $pdfFile->getClientOriginalExtension();
            $pdfFile->move(public_path('storage/essays/pdfs'), $pdfFilename);
            $data['pdf_file'] = 'essays/pdfs/' . $pdfFilename;
        }

        $data['teacher_id'] = $user->id;
        $essay = Essay::create($data);

        return redirect()
            ->route('admin.essays.index')
            ->with('success', 'Essay created successfully.');
    }

    public function show(Essay $essay): View
    {
        $user = Auth::user();
        $userType = (int) $user->type;
        
        // Teachers can only view their own essays
        if ($userType === UserType::Teacher->value) {
            abort_unless($essay->teacher_id === $user->id, 403, 'You can only view your own essays.');
        }

        $essay->load(['subject', 'class', 'academicYear', 'teacher', 'submissions']);
        $essay->loadCount('views');

        return view('admin.essays.show', compact('essay'));
    }

    public function edit(Essay $essay): View
    {
        $user = Auth::user();
        $userType = (int) $user->type;
        
        // Teachers can only edit their own essays
        if ($userType === UserType::Teacher->value) {
            abort_unless($essay->teacher_id === $user->id, 403, 'You can only edit your own essays.');
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

        return view('admin.essays.edit', compact('essay', 'academicYears', 'subjects', 'classes'));
    }

    public function update(Request $request, Essay $essay): RedirectResponse
    {
        $user = Auth::user();
        $userType = (int) $user->type;
        
        // Teachers can only update their own essays
        if ($userType === UserType::Teacher->value) {
            abort_unless($essay->teacher_id === $user->id, 403, 'You can only update your own essays.');
        }

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
            'pdf_file' => ['nullable', 'file', 'mimes:pdf', 'max:10240'], // 10MB max
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
            $attachments = $essay->attachments ?? [];
            foreach ($request->file('attachments') as $file) {
                $path = $file->store('essays/attachments', 'public');
                $attachments[] = $path;
            }
            $data['attachments'] = $attachments;
        }

        // Handle PDF file upload
        if ($request->hasFile('pdf_file')) {
            // Delete old PDF if exists
            if ($essay->pdf_file && file_exists(public_path('storage/' . $essay->pdf_file))) {
                unlink(public_path('storage/' . $essay->pdf_file));
            }
            
            $pdfFile = $request->file('pdf_file');
            $pdfFilename = time() . '_' . uniqid() . '.' . $pdfFile->getClientOriginalExtension();
            $pdfFile->move(public_path('storage/essays/pdfs'), $pdfFilename);
            $data['pdf_file'] = 'essays/pdfs/' . $pdfFilename;
        }

        $essay->update($data);

        return redirect()
            ->route('admin.essays.index')
            ->with('success', 'Essay updated successfully.');
    }

    public function destroy(Essay $essay): RedirectResponse
    {
        $user = Auth::user();
        $userType = (int) $user->type;
        
        // Teachers can only delete their own essays
        if ($userType === UserType::Teacher->value) {
            abort_unless($essay->teacher_id === $user->id, 403, 'You can only delete your own essays.');
        }

        $essay->delete();

        return redirect()
            ->route('admin.essays.index')
            ->with('success', 'Essay deleted successfully.');
    }
}

