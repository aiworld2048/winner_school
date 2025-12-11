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

        // Load current assigned teachers
        $schoolClass->load('teachers');
        $assignedTeacherIds = $schoolClass->teachers->pluck('id')->toArray();
        $primaryTeacherId = $schoolClass->teachers->where('pivot.is_primary', true)->first()?->id;

        return view('admin.class_teachers.edit', compact('schoolClass', 'teachers', 'assignedTeacherIds', 'primaryTeacherId'));
    }

    public function update(Request $request, SchoolClass $schoolClass)
    {
        $data = $request->validate([
            'teacher_ids' => ['nullable', 'array'],
            'teacher_ids.*' => ['exists:users,id'],
            'primary_teacher_id' => ['nullable', 'exists:users,id'],
        ]);

        // Validate all teacher IDs are actually teachers
        if (isset($data['teacher_ids']) && !empty($data['teacher_ids'])) {
            $invalidTeachers = User::whereIn('id', $data['teacher_ids'])
                ->where('type', '!=', UserType::Teacher->value)
                ->exists();
            abort_if($invalidTeachers, 403, 'All selected users must be teachers.');
        }

        // Validate primary teacher is in the list
        if (isset($data['primary_teacher_id']) && isset($data['teacher_ids'])) {
            abort_unless(
                in_array($data['primary_teacher_id'], $data['teacher_ids']),
                422,
                'Primary teacher must be selected in the teachers list.'
            );
        }

        // Sync teachers with pivot data
        $syncData = [];
        if (isset($data['teacher_ids']) && !empty($data['teacher_ids'])) {
            foreach ($data['teacher_ids'] as $teacherId) {
                $syncData[$teacherId] = [
                    'is_primary' => isset($data['primary_teacher_id']) && $data['primary_teacher_id'] == $teacherId,
                ];
            }
        }

        $schoolClass->teachers()->sync($syncData);

        // Also update the legacy class_teacher_id for backward compatibility
        $primaryTeacherId = $data['primary_teacher_id'] ?? ($data['teacher_ids'][0] ?? null);
        $schoolClass->update([
            'class_teacher_id' => $primaryTeacherId,
        ]);

        return redirect()
            ->route('admin.school-classes.index')
            ->with('success', 'Class teachers updated successfully.');
    }
}

