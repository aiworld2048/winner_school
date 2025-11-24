<?php

namespace App\Http\Controllers\Api\V1\Teacher;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class SubjectController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $teacher = $request->user();

        $subjects = $teacher->subjects()
            ->select('subjects.id', 'subjects.name')
            ->orderBy('subjects.name')
            ->get()
            ->map(fn ($subject) => [
                'id' => $subject->id,
                'name' => $subject->name,
            ]);

        return response()->json(['data' => $subjects]);
    }
}

