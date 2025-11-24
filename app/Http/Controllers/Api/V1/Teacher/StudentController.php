<?php

namespace App\Http\Controllers\Api\V1\Teacher;

use App\Enums\UserType;
use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;

class StudentController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $teacher = $request->user();

        $students = $teacher->students()
            ->with('schoolClass:id,name')
            ->orderBy('name')
            ->get()
            ->map(fn ($student) => [
                'id' => $student->id,
                'name' => $student->name,
                'user_name' => $student->user_name,
                'phone' => $student->phone,
                'class' => $student->schoolClass ? [
                    'id' => $student->schoolClass->id,
                    'name' => $student->schoolClass->name,
                ] : null,
            ])
            ->values();

        return response()->json(['data' => $students]);
    }

    public function store(Request $request): JsonResponse
    {
        $teacher = $request->user();

        $data = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'phone' => ['required', 'string', 'max:20', 'unique:users,phone'],
            'password' => ['required', 'string', 'min:6', 'confirmed'],
            'class_id' => [
                'nullable',
                Rule::exists('classes', 'id')->where(function ($query) use ($teacher) {
                    $query->where('class_teacher_id', $teacher->id);
                }),
            ],
        ]);

        $student = User::create([
            'name' => $data['name'],
            'user_name' => $this->generateStudentUsername(),
            'phone' => $data['phone'],
            'password' => Hash::make($data['password']),
            'teacher_id' => $teacher->id,
            'class_id' => $data['class_id'] ?? null,
            'status' => 1,
            'is_changed_password' => 0,
            'type' => UserType::Student->value,
        ])->load('schoolClass:id,name');

        return response()->json([
            'data' => [
                'id' => $student->id,
                'name' => $student->name,
                'user_name' => $student->user_name,
                'phone' => $student->phone,
                'class' => $student->schoolClass ? [
                    'id' => $student->schoolClass->id,
                    'name' => $student->schoolClass->name,
                ] : null,
            ],
        ], 201);
    }

    private function generateStudentUsername(): string
    {
        do {
            $candidate = 'S-' . Str::upper(Str::random(5));
        } while (User::where('user_name', $candidate)->exists());

        return $candidate;
    }
}

