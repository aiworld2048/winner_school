<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\DepositLogResource;
use App\Models\DepositRequest;
use App\Models\User;
use App\Notifications\PlayerDepositNotification;
use App\Traits\HttpResponses;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Notification;

class DepositRequestController extends Controller
{
    use HttpResponses;

    public function FinicialDeposit(Request $request)
    {
        $request->validate([
            'agent_payment_type_id' => ['required', 'integer'],
            'amount' => ['required', 'integer', 'min: 1000'],
            'refrence_no' => ['required', 'digits:6'],
        ]);
        $student = Auth::user();
        $image = null;

        if ($request->hasFile('image')) {
            $image = $request->file('image');
            $filename = uniqid('deposit').'.'.$image->getClientOriginalExtension();
            $image->move(public_path('assets/img/deposit/'), $filename);
        }

        $teacherID = $student->teacher_id ?? null;

        if (!$teacherID) {
            return $this->error('', 'Teacher information is missing. Please contact support.', 400);
        }

        $depositData = [
            'agent_payment_type_id' => $request->agent_payment_type_id,
            'user_id' => $student->id,
            'teacher_id' => $teacherID,
            'amount' => $request->amount,
            'refrence_no' => $request->refrence_no,
        ];

        if ($image) {
            $depositData['image'] = $filename;
        }

        $deposit = DepositRequest::create($depositData);

        $teacher = User::find($teacherID);
        if ($teacher) {
            Log::info('Triggering PlayerDepositNotification for teacher:', [
                'teacher_id' => $student->teacher_id,
                'student_id' => $student->id,
                'deposit_id' => $deposit->id,
            ]);
            $teacher->notify(new PlayerDepositNotification($deposit));
        }

        return $this->success($deposit, 'Deposit Request Success');

    }

    public function log()
    {
        $deposit = DepositRequest::with('bank')->where('user_id', Auth::id())->get();

        return $this->success(DepositLogResource::collection($deposit));
    }
}
