<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\Admin\Promotion;
use App\Traits\HttpResponses;
use Illuminate\Support\Facades\Auth;

class PromotionController extends Controller
{
    use HttpResponses;

    public function index()
    {
            $user = Auth::user();

        $admin = $user->teacher_id;

        $data = Promotion::where('agent_id', $teacher->id)->get();
        // $data = Promotion::get();

        return $this->success($data, 'Promotion retrieved successfully.');
    }

    public function show($id)
    {
        $promotion = Promotion::find($id);

        return $this->success($promotion);
    }
}
