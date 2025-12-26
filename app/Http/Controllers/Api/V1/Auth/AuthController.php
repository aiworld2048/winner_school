<?php

namespace App\Http\Controllers\Api\V1\Auth;

use App\Models\User;
use App\Enums\UserType;
use App\Models\Contact;
use App\Models\TransferLog;
use Illuminate\Http\Request;
use App\Models\Admin\UserLog;
use App\Traits\HttpResponses;
use App\Enums\TransactionName;
use App\Services\CustomWalletService;
use Illuminate\Support\Facades\Log;
use App\Http\Controllers\Controller;
use App\Http\Resources\UserResource;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use App\Http\Resources\AgentResource;
use App\Http\Resources\PlayerResource;
use App\Http\Requests\Api\LoginRequest;
use App\Http\Resources\RegisterResource;
use App\Http\Requests\Api\ProfileRequest;
use App\Http\Requests\Api\RegisterRequest;
use App\Http\Requests\Api\ChangePasswordRequest;

class AuthController extends Controller
{
    use HttpResponses;

    private const TEACHER_ROLE = 2;

    private const STUDENT_ROLE = 3;

    public function login(LoginRequest $request)
    {
        $data = $request->validated();

        $credentials = [
            'phone' => $data['phone'],
            'password' => $data['password'],
        ];

        if (!Auth::attempt($credentials)) {
            return $this->error('', 'These credentials do not match our records.', 401);
        }

        /** @var \App\Models\User $user */
        $user = Auth::user();

        $user->load('roles');

        if ($user->roles->isEmpty() || ($user->roles[0]->id != self::STUDENT_ROLE && $user->roles[0]->id != self::TEACHER_ROLE)) {
            return $this->error('', 'You do not have permissions', 200);
        }

        UserLog::create([
            'ip_address' => $request->ip(),
            'user_id' => $user->id,
            'user_agent' => $request->userAgent(),
        ]);
        $user->tokens()->delete();

        return $this->success(new UserResource($user), 'User login successfully.');
    }

    public function register(RegisterRequest $request)
    {
        $referralCode = $request->referral_code ?? 'winnerschool';
        $teacher = User::where('referral_code', $referralCode)->first();

        if (! $teacher) {
            return $this->error('', 'Not Found Teacher', 401);
        }

        $inputs = $request->validated();

        $user = User::create([
            'phone' => $request->phone,
            'name' => $request->name ?? 'Register Student',
            'user_name' => $this->generateRandomString(),
            'password' => Hash::make($inputs['password']),
            'payment_type_id' => $request->payment_type_id,
            'account_name' => $request->account_name,
            'account_number' => $request->account_number,
            'teacher_id' => $teacher->id,
            'type' => UserType::Student,
            'class_id' => $request->class_id,
            'subject_id' => $request->subject_id,
            'academic_year_id' => $request->academic_year_id,
            'referral_code' => null,
        ]);

        $user->roles()->sync(self::STUDENT_ROLE);

        // Load roles for the resource
        $user->load('roles');

        // Create user log for registration
        UserLog::create([
            'ip_address' => $request->ip(),
            'user_id' => $user->id,
            'user_agent' => $request->userAgent(),
        ]);

        // Return user with token for auto-login
        return $this->success(new RegisterResource($user), 'User registered successfully. You are now logged in.');
    }

    public function logout()
    {
        if (Auth::check()) {
            Auth::user()->currentAccessToken()->delete();
        }

        return $this->success([
            'message' => 'Logged out successfully.',
        ]);
    }

    public function getUser()
    {
        return $this->success(new PlayerResource(Auth::user()), 'User Success');
    }

    public function changePassword(ChangePasswordRequest $request)
    {
        $player = Auth::user();

        if (! Hash::check($request->current_password, $player->password)) {
            return $this->error('', 'Old Password is incorrect', 401);
        }

        $player->update([
            'password' => Hash::make($request->password),
            'status' => 1,
        ]);

        return $this->success($player, 'Password has been changed successfully.');
    }

    public function playerChangePassword(Request $request)
    {
        $request->validate([
            'password' => ['required', 'confirmed'],
            'user_id' => ['required'],
        ]);
        $player = User::where('id', $request->user_id)->first();

        if ($player) {
            $player->update([
                'password' => Hash::make($request->password),
                'is_changed_password' => true,
            ]);

            return $this->success($player, 'Password has been changed successfully.');
        } else {
            return $this->error('', 'Not Found Player', 401);
        }
    }

    public function profile(ProfileRequest $request)
    {
        $player = Auth::user();
        $player->update([
            'name' => $request->name,
            'phone' => $request->phone,
        ]);

        return $this->success(new PlayerResource($player), 'Update profile');
    }

    public function getAgent()
    {
        $player = Auth::user();

        return $this->success(new AgentResource($player->parent), 'Agent Information List');
    }

    private function generateRandomString()
    {
        $randomNumber = mt_rand(10000000, 99999999);

        return 'Pi'.$randomNumber;
    }

    private function isExistingUserForAgent($phone, $agent_id)
    {
        return User::where('phone', $phone)->where('agent_id', $agent_id)->first();
    }


    private function cashIn($agent,$user) {

            app(CustomWalletService::class)->transfer($agent, $user,1000,
                TransactionName::CreditTransfer, [
                    'note' => "1000 MMK register promotion",
                    'old_balance' => $user->balanceFloat,
                    'new_balance' => $user->balanceFloat + 1000,
                ]);
            // Log the transfer
            TransferLog::create([
                'from_user_id' => $agent->id,
                'to_user_id' => $user->id,
                'amount' => 1000,
                'type' => 'top_up',
                'description' => 'Credit transfer from '.$agent->user_name.' to player',
                'meta' => [
                    'transaction_type' => TransactionName::Deposit->value,
                    'note' => "1000 MMK register promotion",
                    'old_balance' => $user->balanceFloat,
                    'new_balance' => $user->balanceFloat + 1000,
                ],
            ]);
    }
}
