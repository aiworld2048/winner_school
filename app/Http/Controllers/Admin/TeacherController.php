<?php

namespace App\Http\Controllers\Admin;

use App\Enums\UserType;
use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Support\Str;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use App\Models\AcademicYear;

class TeacherController extends Controller
{
    private const TEACHER_ROLE = 2;
    public function __construct()
    {
        $this->middleware('head_teacher');
    }

    public function index()
    {
        $teachers = User::where('type', UserType::Teacher->value)
            ->withCount(['subjects as subjects_count'])
            ->withCount(['classesAsTeacher as classes_count'])
            ->latest()
            ->paginate(15);

        return view('admin.teachers.index', compact('teachers'));
    }

    public function create()
    {
        return view('admin.teachers.create');
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'phone' => ['nullable', 'string', 'max:20', 'unique:users,phone'],
            'email' => ['nullable', 'email', 'max:255', 'unique:users,email'],
            'password' => ['required', 'string', 'min:6', 'confirmed'],
            'status' => ['required', 'boolean'],
        ]);

        $userName = $this->generateTeacherUsername();

        $user = User::create([
            'name' => $data['name'],
            'user_name' => $userName,
            'phone' => $data['phone'] ?? null,
            'email' => $data['email'] ?? null,
            'password' => Hash::make($data['password']),
            'status' => $data['status'],
            'is_changed_password' => 0,
            'teacher_id' => Auth::id(),
            'type' => UserType::Teacher->value,
        ]);

        // Assign Teacher role to the user
        $user->roles()->sync(self::TEACHER_ROLE);

        return redirect()
            ->route('admin.teachers.index')
            ->with('success', 'Teacher created successfully.');
    }

    public function edit(User $teacher)
    {
        abort_unless($teacher->type === UserType::Teacher->value, 404);

        return view('admin.teachers.edit', compact('teacher'));
    }

    public function update(Request $request, User $teacher)
    {
        abort_unless($teacher->type === UserType::Teacher->value, 404);

        $data = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'phone' => ['nullable', 'string', 'max:20', 'unique:users,phone,'.$teacher->id],
            'email' => ['nullable', 'email', 'max:255', 'unique:users,email,'.$teacher->id],
            'password' => ['nullable', 'string', 'min:6', 'confirmed'],
            'status' => ['required', 'boolean'],
        ]);

        $payload = [
            'name' => $data['name'],
            'phone' => $data['phone'] ?? null,
            'email' => $data['email'] ?? null,
            'status' => $data['status'],
        ];

        if (!empty($data['password'])) {
            $payload['password'] = Hash::make($data['password']);
            $payload['is_changed_password'] = 0;
        }

        $teacher->update($payload);

        return redirect()
            ->route('admin.teachers.index')
            ->with('success', 'Teacher updated successfully.');
    }

    public function destroy(User $teacher)
    {
        abort_unless($teacher->type === UserType::Teacher->value, 404);

        $teacher->delete();

        return redirect()
            ->route('admin.teachers.index')
            ->with('success', 'Teacher deleted successfully.');
    }

    public function show(User $teacher)
    {
        abort_unless((int) $teacher->type === UserType::Teacher->value, 404);

        $teacher->load([
            'classesAsTeacher.academicYear',
            'subjects' => function ($query) {
                $query->withPivot('academic_year_id');
            },
            'subjects.creator',
        ]);

        $academicYears = AcademicYear::whereIn(
            'id',
            $teacher->subjects->pluck('pivot.academic_year_id')->filter()->unique()
        )->get()->keyBy('id');

        $students = User::where('teacher_id', $teacher->id)
            ->with('schoolClass')
            ->get();

        return view('admin.teachers.show', compact('teacher', 'academicYears', 'students'));
    }

    private function generateTeacherUsername(): string
    {
        do {
            $candidate = 'T-' . Str::upper(Str::random(5));
        } while (User::where('user_name', $candidate)->exists());

        return $candidate;
    }
}

