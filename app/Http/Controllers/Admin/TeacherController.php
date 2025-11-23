<?php

namespace App\Http\Controllers\Admin;

use App\Enums\UserType;
use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;

class TeacherController extends Controller
{
    public function __construct()
    {
        $this->middleware(function ($request, $next) {
            if (!Auth::user()?->isType(UserType::HeadTeacher)) {
                abort(403, 'Only head teachers can manage teachers.');
            }

            return $next($request);
        });
    }

    public function index()
    {
        $teachers = User::where('type', UserType::Teacher->value)
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
            'user_name' => ['required', 'string', 'max:50', 'unique:users,user_name'],
            'phone' => ['nullable', 'string', 'max:20', 'unique:users,phone'],
            'email' => ['nullable', 'email', 'max:255', 'unique:users,email'],
            'password' => ['required', 'string', 'min:6', 'confirmed'],
            'status' => ['required', 'boolean'],
        ]);

        User::create([
            'name' => $data['name'],
            'user_name' => $data['user_name'],
            'phone' => $data['phone'] ?? null,
            'email' => $data['email'] ?? null,
            'password' => Hash::make($data['password']),
            'status' => $data['status'],
            'is_changed_password' => 0,
            'teacher_id' => Auth::id(),
            'type' => UserType::Teacher->value,
        ]);

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
            'user_name' => ['required', 'string', 'max:50', 'unique:users,user_name,'.$teacher->id],
            'phone' => ['nullable', 'string', 'max:20', 'unique:users,phone,'.$teacher->id],
            'email' => ['nullable', 'email', 'max:255', 'unique:users,email,'.$teacher->id],
            'password' => ['nullable', 'string', 'min:6', 'confirmed'],
            'status' => ['required', 'boolean'],
        ]);

        $payload = [
            'name' => $data['name'],
            'user_name' => $data['user_name'],
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
}

