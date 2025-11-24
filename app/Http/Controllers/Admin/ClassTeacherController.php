<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\SchoolClass;
use App\Models\User;
use Illuminate\Http\Request;
use App\Enums\UserType;

class ClassTeacherController extends Controller
{
    public function __construct()
    {
        $this->middleware('head_teacher');
    }

    public function edit(SchoolClass $schoolClass)
    {
        $teachers = User::where('type', UserType::Teacher->value)
            ->orderBy('name')
            ->get();

        return view('admin.class_teachers.edit', compact('schoolClass', 'teachers'));
    }

    public function update(Request $request, SchoolClass $schoolClass)
    {
        $data = $request->validate([
            'class_teacher_id' => ['nullable', 'exists:users,id'],
        ]);

        if ($data['class_teacher_id']) {
            $teacher = User::findOrFail($data['class_teacher_id']);
            abort_unless((int) $teacher->type === UserType::Teacher->value, 403);
        }

        $schoolClass->update([
            'class_teacher_id' => $data['class_teacher_id'] ?? null,
        ]);

        return redirect()
            ->route('admin.school-classes.index')
            ->with('success', 'Class teacher updated.');
    }
}

