<?php

namespace App\Http\Controllers\Api\V1\Teacher;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ClassController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $teacher = $request->user();

        $classes = $teacher->classesAsTeacher()
            ->select('id', 'name', 'grade_level', 'section')
            ->orderBy('grade_level')
            ->orderBy('section')
            ->get()
            ->map(function ($class) {
                return [
                    'id' => $class->id,
                    'name' => $class->name ?? $class->full_name,
                    'grade_level' => $class->grade_level,
                    'section' => $class->section,
                ];
            });

        return response()->json(['data' => $classes]);
    }
}

