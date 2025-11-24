<?php

namespace App\Http\Controllers\Admin;

use App\Enums\UserType;
use App\Http\Controllers\Controller;
use App\Models\AcademicYear;
use App\Models\Subject;
use App\Models\User;
use Illuminate\Http\Request;

class TeacherSubjectController extends Controller
{
    public function __construct()
    {
        $this->middleware('head_teacher');
    }

    public function create(User $teacher)
    {
        abort_unless((int) $teacher->type === UserType::Teacher->value, 404);

        $subjects = Subject::orderBy('name')->get();
        $academicYears = AcademicYear::orderByDesc('start_date')->get();

        $existing = $teacher->subjects()
            ->pluck('teacher_subject.academic_year_id', 'subjects.id')
            ->toArray();

        return view('admin.teacher_subjects.assign', compact('teacher', 'subjects', 'academicYears', 'existing'));
    }

    public function store(Request $request, User $teacher)
    {
        abort_unless((int) $teacher->type === UserType::Teacher->value, 404);

        $data = $request->validate([
            'subjects' => ['array'],
            'subjects.*.academic_year_id' => ['nullable', 'exists:academic_years,id'],
        ]);

        $syncPayload = [];

        foreach ($data['subjects'] ?? [] as $subjectId => $values) {
            $syncPayload[$subjectId] = [
                'academic_year_id' => $values['academic_year_id'] ?? null,
            ];
        }

        $teacher->subjects()->sync($syncPayload);

        return redirect()
            ->route('admin.teachers.index')
            ->with('success', 'Subjects updated for '.$teacher->name.'.');
    }
}

