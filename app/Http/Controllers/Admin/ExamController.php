<?php

namespace App\Http\Controllers\Admin;

use App\Enums\UserType;
use App\Http\Controllers\Controller;
use App\Models\AcademicYear;
use App\Models\Exam;
use App\Models\SchoolClass;
use App\Models\Subject;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\View\View;
use Illuminate\Http\RedirectResponse;

class ExamController extends Controller
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
        
        $query = Exam::with(['subject', 'class', 'academicYear', 'creator']);

        // Teachers can only see their own exams
        if ($userType === UserType::Teacher->value) {
            $query->where('created_by', $user->id);
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

        // Filter by type
        if ($request->filled('type')) {
            $query->where('type', $request->type);
        }

        // Filter by published status
        if ($request->filled('is_published')) {
            $query->where('is_published', $request->is_published === '1');
        }

        $exams = $query->latest('exam_date')->paginate(15);
        $academicYears = AcademicYear::orderBy('name')->get();
        
        // Teachers can only see their assigned subjects and classes in filters
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

        return view('admin.exams.index', compact('exams', 'academicYears', 'subjects', 'classes'));
    }

    public function create(): View
    {
        $user = Auth::user();
        $userType = (int) $user->type;
        
        $academicYears = AcademicYear::orderBy('name')->get();
        
        // Teachers can only select their assigned subjects and classes
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

        return view('admin.exams.create', compact('academicYears', 'subjects', 'classes'));
    }

    public function store(Request $request): RedirectResponse
    {
        $user = Auth::user();
        $userType = (int) $user->type;
        
        $data = $request->validate([
            'title' => ['required', 'string', 'max:255'],
            'code' => ['required', 'string', 'max:50', 'unique:exams,code'],
            'description' => ['nullable', 'string'],
            'subject_id' => ['required', 'exists:subjects,id'],
            'class_id' => ['required', 'exists:classes,id'],
            'academic_year_id' => ['required', 'exists:academic_years,id'],
            'exam_date' => ['required', 'date'],
            'duration_minutes' => ['required', 'integer', 'min:1', 'max:600'],
            'total_marks' => ['required', 'numeric', 'min:1', 'max:1000'],
            'passing_marks' => ['required', 'numeric', 'min:0', 'lte:total_marks'],
            'type' => ['required', 'in:quiz,assignment,midterm,final,project'],
            'is_published' => ['required', 'boolean'],
        ]);

        // Verify teachers can only create exams for their assigned subjects and classes
        if ($userType === UserType::Teacher->value) {
            $subjectIds = $user->subjects()->pluck('subjects.id')->all();
            $classIds = $user->classesAsTeacher()->pluck('id')->all();
            
            abort_unless(in_array($data['subject_id'], $subjectIds), 403, 'You are not assigned to this subject.');
            abort_unless(in_array($data['class_id'], $classIds), 403, 'You are not assigned to this class.');
        }

        Exam::create([
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
            'is_published' => $data['is_published'],
            'created_by' => Auth::id(),
        ]);

        return redirect()
            ->route('admin.exams.index')
            ->with('success', 'Exam created successfully.');
    }

    public function show(Exam $exam): View
    {
        $user = Auth::user();
        $userType = (int) $user->type;
        
        // Teachers can only view their own exams
        if ($userType === UserType::Teacher->value) {
            abort_unless($exam->created_by === $user->id, 403, 'You can only view your own exams.');
        }
        
        $exam->load(['subject', 'class', 'academicYear', 'creator']);

        return view('admin.exams.show', compact('exam'));
    }

    public function edit(Exam $exam): View
    {
        $user = Auth::user();
        $userType = (int) $user->type;
        
        // Teachers can only edit their own exams
        if ($userType === UserType::Teacher->value) {
            abort_unless($exam->created_by === $user->id, 403, 'You can only edit your own exams.');
        }
        
        $academicYears = AcademicYear::orderBy('name')->get();
        
        // Teachers can only select their assigned subjects and classes
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

        return view('admin.exams.edit', compact('exam', 'academicYears', 'subjects', 'classes'));
    }

    public function update(Request $request, Exam $exam): RedirectResponse
    {
        $user = Auth::user();
        $userType = (int) $user->type;
        
        // Teachers can only update their own exams
        if ($userType === UserType::Teacher->value) {
            abort_unless($exam->created_by === $user->id, 403, 'You can only update your own exams.');
        }
        
        $data = $request->validate([
            'title' => ['required', 'string', 'max:255'],
            'code' => ['required', 'string', 'max:50', 'unique:exams,code,' . $exam->id],
            'description' => ['nullable', 'string'],
            'subject_id' => ['required', 'exists:subjects,id'],
            'class_id' => ['required', 'exists:classes,id'],
            'academic_year_id' => ['required', 'exists:academic_years,id'],
            'exam_date' => ['required', 'date'],
            'duration_minutes' => ['required', 'integer', 'min:1', 'max:600'],
            'total_marks' => ['required', 'numeric', 'min:1', 'max:1000'],
            'passing_marks' => ['required', 'numeric', 'min:0', 'lte:total_marks'],
            'type' => ['required', 'in:quiz,assignment,midterm,final,project'],
            'is_published' => ['required', 'boolean'],
        ]);

        // Verify teachers can only update exams for their assigned subjects and classes
        if ($userType === UserType::Teacher->value) {
            $subjectIds = $user->subjects()->pluck('subjects.id')->all();
            $classIds = $user->classesAsTeacher()->pluck('id')->all();
            
            abort_unless(in_array($data['subject_id'], $subjectIds), 403, 'You are not assigned to this subject.');
            abort_unless(in_array($data['class_id'], $classIds), 403, 'You are not assigned to this class.');
        }

        $exam->update($data);

        return redirect()
            ->route('admin.exams.index')
            ->with('success', 'Exam updated successfully.');
    }

    public function destroy(Exam $exam): RedirectResponse
    {
        $user = Auth::user();
        $userType = (int) $user->type;
        
        // Teachers can only delete their own exams
        if ($userType === UserType::Teacher->value) {
            abort_unless($exam->created_by === $user->id, 403, 'You can only delete your own exams.');
        }
        
        $exam->delete();

        return redirect()
            ->route('admin.exams.index')
            ->with('success', 'Exam deleted successfully.');
    }
}

