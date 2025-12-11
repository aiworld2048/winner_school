<?php

namespace App\Http\Controllers\Api\V1\Teacher;

use App\Http\Controllers\Controller;
use App\Models\Lesson;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class DashboardController extends Controller
{
    public function __invoke(Request $request): JsonResponse
    {
        $teacher = $request->user();

        $data = [
            'students' => $teacher->students()->count(),
            'lessons' => Lesson::where('teacher_id', $teacher->id)->count(),
            'classes' => $teacher->classesAsTeacher()->distinct()->count(),
            'subjects' => $teacher->subjects()->count(),
        ];

        return response()->json(['data' => $data]);
    }
}

