<?php

namespace App\Http\Controllers\Api\V1\Student;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\Student\StudentNoteStoreRequest;
use App\Http\Requests\Api\Student\StudentNoteUpdateRequest;
use App\Http\Resources\StudentNoteResource;
use App\Models\StudentNote;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class NoteController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $user = Auth::user();

        $query = StudentNote::query()
            ->where('user_id', $user->id);

        if ($search = $request->get('q')) {
            $query->where(function ($builder) use ($search) {
                $builder->where('title', 'like', "%{$search}%")
                    ->orWhere('content', 'like', "%{$search}%");
            });
        }

        if ($request->boolean('pinned')) {
            $query->where('is_pinned', true);
        }

        $notes = $query->orderByDesc('is_pinned')
            ->orderByDesc('updated_at')
            ->paginate($request->integer('per_page', 30));

        return StudentNoteResource::collection($notes)->response();
    }

    public function store(StudentNoteStoreRequest $request): JsonResponse
    {
        $user = Auth::user();

        $note = StudentNote::create([
            'user_id' => $user->id,
            ...$request->validated(),
        ]);

        return (new StudentNoteResource($note))
            ->response()
            ->setStatusCode(201);
    }

    public function update(StudentNoteUpdateRequest $request, StudentNote $note): JsonResponse
    {
        $this->authorizeNote($note);

        $note->update($request->validated());

        return (new StudentNoteResource($note))->response();
    }

    public function destroy(StudentNote $note): JsonResponse
    {
        $this->authorizeNote($note);

        $note->delete();

        return response()->json(['message' => 'Note removed.']);
    }

    private function authorizeNote(StudentNote $note): void
    {
        abort_unless($note->user_id === Auth::id(), 404, 'Note not found.');
    }
}


