<?php

namespace App\Http\Controllers\Admin;

use App\Enums\UserType;
use App\Http\Controllers\Controller;
use App\Models\AcademicYear;
use App\Models\SchoolClass;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Validation\Rule;

class SchoolClassController extends Controller
{
    public function __construct()
    {
        $this->middleware('head_teacher');
    }

    public function index()
    {
        $classes = SchoolClass::with(['academicYear', 'classTeacher'])
            ->orderBy('grade_level')
            ->orderBy('section')
            ->paginate(15);

        return view('admin.school_classes.index', compact('classes'));
    }

    public function create()
    {
        $academicYears = AcademicYear::orderByDesc('start_date')->get();
        $teachers = User::where('type', UserType::Teacher->value)->orderBy('name')->get();

        return view('admin.school_classes.create', compact('academicYears', 'teachers'));
    }

    public function store(Request $request)
    {
        $data = $this->validateData($request);

        SchoolClass::create([
            'name' => $data['name'],
            'code' => $data['code'],
            'grade_level' => $data['grade_level'],
            'section' => $data['section'] ?? null,
            'capacity' => $data['capacity'],
            'is_active' => $data['is_active'],
            'academic_year_id' => $data['academic_year_id'],
            'class_teacher_id' => $data['class_teacher_id'] ?? null,
            'created_by' => Auth::id(),
        ]);

        return redirect()
            ->route('admin.school-classes.index')
            ->with('success', 'Class created successfully.');
    }

    public function edit(SchoolClass $schoolClass)
    {
        $academicYears = AcademicYear::orderByDesc('start_date')->get();
        $teachers = User::where('type', UserType::Teacher->value)->orderBy('name')->get();

        return view('admin.school_classes.edit', compact('schoolClass', 'academicYears', 'teachers'));
    }

    public function update(Request $request, SchoolClass $schoolClass)
    {
        $data = $this->validateData($request, $schoolClass->id);

        $schoolClass->update([
            'name' => $data['name'],
            'code' => $data['code'],
            'grade_level' => $data['grade_level'],
            'section' => $data['section'] ?? null,
            'capacity' => $data['capacity'],
            'is_active' => $data['is_active'],
            'academic_year_id' => $data['academic_year_id'],
            'class_teacher_id' => $data['class_teacher_id'] ?? null,
        ]);

        return redirect()
            ->route('admin.school-classes.index')
            ->with('success', 'Class updated successfully.');
    }

    public function destroy(SchoolClass $schoolClass)
    {
        $schoolClass->delete();

        return redirect()
            ->route('admin.school-classes.index')
            ->with('success', 'Class removed.');
    }

    private function validateData(Request $request, ?int $classId = null): array
    {
        return $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'code' => ['required', 'string', 'max:50', Rule::unique('classes', 'code')->ignore($classId)],
            'grade_level' => ['required', 'integer', 'min:0', 'max:12'],
            'section' => ['nullable', 'string', 'max:10'],
            'capacity' => ['required', 'integer', 'min:1', 'max:100'],
            'is_active' => ['required', 'boolean'],
            'academic_year_id' => ['required', 'exists:academic_years,id'],
            'class_teacher_id' => [
                'nullable',
                Rule::exists('users', 'id')->where(function ($query) {
                    $query->where('type', UserType::Teacher->value);
                }),
            ],
        ]);
    }
}

