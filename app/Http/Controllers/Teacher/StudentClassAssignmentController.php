<?php

namespace App\Http\Controllers\Teacher;

use App\Enums\UserType;
use App\Http\Controllers\Controller;
use App\Models\SchoolClass;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class StudentClassAssignmentController extends Controller
{
    private const STUDENT_ROLE = 3;
    public function index()
    {
        $teacher = Auth::user();

        $students = User::where('teacher_id', $teacher->id)
            ->with('schoolClass')
            ->orderBy('name')
            ->paginate(20);

        $classes = SchoolClass::orderBy('grade_level')
            ->orderBy('section')
            ->get();

        return view('teacher.students.assign', compact('students', 'classes'));
    }

    public function create()
    {
        return view('teacher.students.create');
    }

    public function store(Request $request)
    {
        $teacher = Auth::user();

        $data = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'phone' => ['required', 'string', 'max:20', 'unique:users,phone'],
            'password' => ['required', 'string', 'min:6', 'confirmed'],
        ]);

        $student = User::create([
            'name' => $data['name'],
            'user_name' => $this->generateStudentUsername(),
            'phone' => $data['phone'],
            'password' => Hash::make($data['password']),
            'teacher_id' => $teacher->id,
            'status' => 1,
            'is_changed_password' => 1,
            'type' => UserType::Student->value,
        ]);
        $student->roles()->sync(self::STUDENT_ROLE);

        return redirect()
            ->route('teacher.students.assign.index')
            ->with('success', 'Student created.');
    }

    public function update(Request $request, User $student)
    {
        $teacher = Auth::user();

        abort_unless($student->teacher_id === $teacher->id, 403);

        abort_unless((int) $student->type === UserType::Student->value, 404);

        $data = $request->validate([
            'class_id' => ['nullable', 'exists:classes,id'],
        ]);

        $student->update([
            'class_id' => $data['class_id'] ?? null,
        ]);

        return redirect()
            ->route('teacher.students.assign.index')
            ->with('success', 'Student updated.');
    }

    private function generateStudentUsername(): string
    {
        do {
            $candidate = 'S-' . Str::upper(Str::random(5));
        } while (User::where('user_name', $candidate)->exists());

        return $candidate;
    }
}

