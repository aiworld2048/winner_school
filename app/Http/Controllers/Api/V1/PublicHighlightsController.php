<?php

namespace App\Http\Controllers\Api\V1;

use App\Enums\UserType;
use App\Http\Controllers\Controller;
use App\Models\Lesson;
use App\Models\SchoolClass;
use App\Models\Subject;
use App\Models\User;
use App\Traits\HttpResponses;
use Illuminate\Http\JsonResponse;

class PublicHighlightsController extends Controller
{
    use HttpResponses;

    public function __invoke(): JsonResponse
    {
        $courses = Subject::select('id', 'name', 'description')
            ->where('is_active', true)
            ->latest('updated_at')
            ->take(6)
            ->get()
            ->map(fn ($subject) => [
                'id' => $subject->id,
                'title' => $subject->name,
                'description' => $subject->description,
            ])
            ->values();

        $lessons = Lesson::with(['subject:id,name', 'class:id,name,grade_level,section'])
            ->latest('lesson_date')
            ->take(4)
            ->get()
            ->map(fn ($lesson) => [
                'id' => $lesson->id,
                'title' => $lesson->title,
                'subject_name' => $lesson->subject->name ?? null,
                'class_name' => $lesson->class?->name ?? $lesson->class?->full_name,
                'lesson_date' => optional($lesson->lesson_date)->toDateString(),
            ])
            ->values();

        $classes = SchoolClass::select('id', 'name', 'grade_level', 'section')
            ->latest('updated_at')
            ->take(5)
            ->get()
            ->map(fn ($class) => [
                'id' => $class->id,
                'name' => $class->name,
                'grade_level' => $class->grade_level,
                'section' => $class->section,
            ])
            ->values();

        $studentCount = User::where('type', UserType::Student->value)->count();
        $teacherCount = User::where('type', UserType::Teacher->value)->count();
        $lessonCount = Lesson::count();
        $classCount = SchoolClass::count();

        return $this->success([
            'stats' => [
                'students' => $studentCount,
                'teachers' => $teacherCount,
                'lessons' => $lessonCount,
                'classes' => $classCount,
            ],
            'courses' => $courses,
            'lessons' => $lessons,
            'classes' => $classes,
        ], 'Highlights retrieved.');
    }
}


