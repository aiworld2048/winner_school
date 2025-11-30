<?php

namespace App\Http\Controllers\Admin;

use App\Enums\UserType;
use App\Http\Controllers\Controller;
use App\Models\LessonView;
use App\Models\SchoolClass;
use App\Models\Subject;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class LessonViewController extends Controller
{
    public function index(Request $request)
    {
        $user = Auth::user();

        abort_unless(
            $user->hasRole('HeadTeacher') || $user->hasRole('Teacher'),
            403,
            'Only teaching staff can access lesson analytics.'
        );

        $query = LessonView::query()
            ->with([
                'lesson.class',
                'lesson.subject',
                'lesson.teacher',
                'student',
            ]);

        if ($classId = $request->integer('class_id')) {
            $query->whereHas('lesson', fn ($builder) => $builder->where('class_id', $classId));
        }

        if ($subjectId = $request->integer('subject_id')) {
            $query->whereHas('lesson', fn ($builder) => $builder->where('subject_id', $subjectId));
        }

        if ($request->filled('student')) {
            $searchStudent = $request->string('student')->value();
            $query->whereHas('student', function ($builder) use ($searchStudent) {
                $builder->where('name', 'like', "%{$searchStudent}%")
                    ->orWhere('user_name', 'like', "%{$searchStudent}%")
                    ->orWhere('phone', 'like', "%{$searchStudent}%");
            });
        }

        if ($request->filled('lesson')) {
            $searchLesson = $request->string('lesson')->value();
            $query->whereHas('lesson', function ($builder) use ($searchLesson) {
                $builder->where('title', 'like', "%{$searchLesson}%");
            });
        }

        if (
            $user->hasRole('Teacher')
            && UserType::from($user->type) === UserType::Teacher
        ) {
            $query->where(function ($builder) use ($user) {
                $builder->whereHas('lesson', fn ($q) => $q->where('teacher_id', $user->id))
                    ->orWhereHas('student', fn ($q) => $q->where('teacher_id', $user->id));
            });
        }

        $views = $query
            ->orderByDesc('updated_at')
            ->paginate(25)
            ->withQueryString();

        $classes = SchoolClass::query()
            ->orderBy('grade_level')
            ->orderBy('name')
            ->pluck('name', 'id');

        $subjects = Subject::query()
            ->orderBy('name')
            ->pluck('name', 'id');

        return view('admin.lesson_views.index', [
            'views' => $views,
            'classes' => $classes,
            'subjects' => $subjects,
            'filters' => [
                'class_id' => $request->input('class_id'),
                'subject_id' => $request->input('subject_id'),
                'student' => $request->input('student'),
                'lesson' => $request->input('lesson'),
            ],
        ]);
    }
}


