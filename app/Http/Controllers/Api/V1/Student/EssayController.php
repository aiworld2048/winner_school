<?php

namespace App\Http\Controllers\Api\V1\Student;

use App\Enums\TransactionName;
use App\Enums\UserType;
use App\Http\Controllers\Controller;
use App\Http\Resources\EssayResource;
use App\Models\Essay;
use App\Models\EssayView;
use App\Models\User;
use App\Services\CustomWalletService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class EssayController extends Controller
{
    public function __construct(private readonly CustomWalletService $wallet)
    {
        $this->middleware('auth:sanctum');
    }

    public function index(Request $request)
    {
        $student = $this->authStudent();

        $teacherId = $student->teacher_id;

        abort_unless($teacherId, 403, 'You are not assigned to a teacher yet.');

        $essays = Essay::with(['subject', 'class', 'academicYear', 'teacher'])
            ->withCount('views')
            ->where('teacher_id', $teacherId)
            ->where('status', 'published')
            ->when($student->class_id, function ($query) use ($student) {
                $query->where('class_id', $student->class_id);
            })
            ->latest('due_date')
            ->paginate($request->get('per_page', 15));

        return EssayResource::collection($essays);
    }

    public function show(Essay $essay)
    {
        $student = $this->authStudent();

        abort_unless($essay->teacher_id === $student->teacher_id, 403);
        abort_unless($essay->status === 'published', 404, 'Essay not found.');
        if ($student->class_id) {
            abort_unless($essay->class_id === $student->class_id, 403);
        }

        $this->chargeEssayAccess($student, $essay);

        $essay->load(['subject', 'class', 'academicYear', 'teacher']);
        $essay->loadCount('views');

        return new EssayResource($essay);
    }

    private function authStudent()
    {
        $user = Auth::user();

        abort_unless($user && (int) $user->type === UserType::Student->value, 403, 'Only students can access this resource.');

        return $user;
    }

    private function chargeEssayAccess(User $student, Essay $essay): void
    {
        $alreadyViewed = EssayView::where('student_id', $student->id)
            ->where('essay_id', $essay->id)
            ->exists();

        if ($alreadyViewed) {
            return;
        }

        $teacher = User::find($essay->teacher_id);

        if (!$teacher) {
            return;
        }

        $cost = 100;

        if (!$this->wallet->hasBalance($student, $cost)) {
            abort(402, 'Insufficient balance to view this essay. Required: 100 MMK');
        }

        $this->wallet->transfer($student, $teacher, $cost, TransactionName::DebitTransfer);

        EssayView::create([
            'essay_id' => $essay->id,
            'student_id' => $student->id,
            'amount' => $cost,
        ]);
    }
}

