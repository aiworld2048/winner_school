<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\DictionaryEntry;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class DictionaryController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = DictionaryEntry::query();

        if ($search = $request->get('q')) {
            $query->where(function ($builder) use ($search) {
                $builder->where('english_word', 'like', "%{$search}%")
                    ->orWhere('myanmar_meaning', 'like', "%{$search}%");
            });
        }

        $entries = $query->orderBy('english_word')
            ->paginate($request->integer('per_page', 50), ['id', 'english_word', 'myanmar_meaning', 'example']);

        return response()->json([
            'data' => $entries->items(),
            'meta' => [
                'current_page' => $entries->currentPage(),
                'last_page' => $entries->lastPage(),
                'per_page' => $entries->perPage(),
                'total' => $entries->total(),
            ],
        ]);
    }
}

