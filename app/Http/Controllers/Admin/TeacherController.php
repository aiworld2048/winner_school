<?php

namespace App\Http\Controllers\Admin;

use App\Enums\UserType;
use App\Enums\TransactionName;
use App\Http\Controllers\Controller;
use App\Http\Requests\TransferLogRequest;
use App\Models\User;
use App\Models\SchoolClass;
use App\Models\TransferLog;
use App\Services\CustomWalletService;
use Illuminate\Support\Str;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use App\Models\AcademicYear;
use Illuminate\View\View;
use Illuminate\Http\RedirectResponse;
use Exception;

class TeacherController extends Controller
{
    private const TEACHER_ROLE = 2;
    public function __construct()
    {
        $this->middleware('head_teacher');
    }

    public function index()
    {
        $teachers = User::where('type', UserType::Teacher->value)
            ->withCount(['subjects as subjects_count'])
            ->withCount(['classesAsTeacherMany as classes_count'])
            ->latest()
            ->paginate(15);

        return view('admin.teachers.index', compact('teachers'));
    }

    public function create()
    {
        $referralCode = $this->generateUniqueReferralCode();
        return view('admin.teachers.create', compact('referralCode'));
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'phone' => ['nullable', 'string', 'max:20', 'unique:users,phone'],
            'email' => ['nullable', 'email', 'max:255', 'unique:users,email'],
            'password' => ['required', 'string', 'min:6', 'confirmed'],
            'status' => ['required', 'boolean'],
        ]);

        $userName = $this->generateTeacherUsername();
        $referralCode = $this->generateUniqueReferralCode();

        $user = User::create([
            'name' => $data['name'],
            'user_name' => $userName,
            'phone' => $data['phone'] ?? null,
            'email' => $data['email'] ?? null,
            'password' => Hash::make($data['password']),
            'status' => $data['status'],
            'is_changed_password' => 0,
            'teacher_id' => Auth::id(),
            'type' => UserType::Teacher->value,
            'referral_code' => $referralCode,
        ]);

        // Assign Teacher role to the user
        $user->roles()->sync(self::TEACHER_ROLE);

        return redirect()
            ->route('admin.teachers.index')
            ->with('success', 'Teacher created successfully.');
    }

    public function edit(User $teacher)
    {
        abort_unless($teacher->type === UserType::Teacher->value, 404);

        return view('admin.teachers.edit', compact('teacher'));
    }

    public function update(Request $request, User $teacher)
    {
        abort_unless($teacher->type === UserType::Teacher->value, 404);

        $data = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'phone' => ['nullable', 'string', 'max:20', 'unique:users,phone,'.$teacher->id],
            'email' => ['nullable', 'email', 'max:255', 'unique:users,email,'.$teacher->id],
            'password' => ['nullable', 'string', 'min:6', 'confirmed'],
            'status' => ['required', 'boolean'],
        ]);

        $payload = [
            'name' => $data['name'],
            'phone' => $data['phone'] ?? null,
            'email' => $data['email'] ?? null,
            'status' => $data['status'],
        ];

        if (!empty($data['password'])) {
            $payload['password'] = Hash::make($data['password']);
            $payload['is_changed_password'] = 0;
        }

        $teacher->update($payload);

        return redirect()
            ->route('admin.teachers.index')
            ->with('success', 'Teacher updated successfully.');
    }

    public function destroy(User $teacher)
    {
        abort_unless($teacher->type === UserType::Teacher->value, 404);

        $teacher->delete();

        return redirect()
            ->route('admin.teachers.index')
            ->with('success', 'Teacher deleted successfully.');
    }

    public function show(User $teacher)
    {
        abort_unless((int) $teacher->type === UserType::Teacher->value, 404);

        // Load subjects with pivot and creator
        $teacher->load([
            'subjects' => function ($query) {
                $query->withPivot('academic_year_id');
            },
            'subjects.creator',
        ]);

        // Get classes from both legacy and many-to-many relationships
        $legacyClasses = SchoolClass::where('class_teacher_id', $teacher->id)
            ->with('academicYear')
            ->get();
        
        $manyToManyClasses = $teacher->classesAsTeacherMany()
            ->with('academicYear')
            ->get();
        
        // Merge and deduplicate classes
        $allClasses = $legacyClasses->merge($manyToManyClasses)->unique('id');
        
        // Add classes to teacher model as a dynamic attribute for the view
        $teacher->setRelation('classesAsTeacher', $allClasses);

        $academicYears = AcademicYear::whereIn(
            'id',
            $teacher->subjects->pluck('pivot.academic_year_id')->filter()->unique()
        )->get()->keyBy('id');

        $students = User::where('teacher_id', $teacher->id)
            ->with('schoolClass')
            ->get();

        return view('admin.teachers.show', compact('teacher', 'academicYears', 'students'));
    }

    private function generateTeacherUsername(): string
    {
        do {
            $candidate = 'T-' . Str::upper(Str::random(5));
        } while (User::where('user_name', $candidate)->exists());

        return $candidate;
    }

    // deposit withdraw 

    public function getCashIn(string $teacher): View
    {
        $owner = Auth::user();
        $this->ensureOwner($owner);

        $agent = User::where('type', UserType::Teacher->value)
            ->where('teacher_id', $owner->id)
            ->findOrFail($teacher);

        return view('admin.teachers.cash_in', compact('agent'));
    }

    public function getCashOut(string $teacher): View
    {
        $owner = Auth::user();
        $this->ensureOwner($owner);

        $agent = User::where('type', UserType::Teacher->value)
            ->where('teacher_id', $owner->id)
            ->findOrFail($teacher);

        return view('admin.teachers.cash_out', compact('agent'));
    }

    public function makeCashIn(Request $request, $id): RedirectResponse
    {
        

        try {
            $owner = Auth::user();
            $this->ensureOwner($owner);

            $agent = User::where('type', UserType::Teacher->value)
                ->where('teacher_id', $owner->id)
                ->findOrFail($id);

            $request->validate([
                'amount' => ['required', 'numeric', 'min:1'],
                'note' => ['nullable', 'string', 'max:255'],
            ]);

            $amount = (int) $request->amount;

            if ($amount > (int) $owner->balance) {
                throw new \Exception('You do not have enough balance to transfer!');
            }

            app(CustomWalletService::class)->transfer(
                $owner,
                $agent,
                $amount,
                TransactionName::CreditTransfer,
                [
                    'note' => $request->note,
                    'description' => $request->note ?? 'Owner to agent top up',
                ]
            );

            return redirect()->route('admin.teachers.index')->with('success', 'Money fill request submitted successfully!');
        } catch (Exception $e) {
            return redirect()->back()->with('error', $e->getMessage());
        }
    }

    public function makeCashOut(TransferLogRequest $request, string $id): RedirectResponse
    {
        // if (! Gate::allows('make_transfer')) {
        //     abort(403);
        // }

        try {
            $owner = Auth::user();
            $this->ensureOwner($owner);

            $agent = User::where('type', UserType::Teacher->value)
                ->where('teacher_id', $owner->id)
                ->findOrFail($id);

            $request->validate([
                'amount' => ['required', 'numeric', 'min:1'],
                'note' => ['nullable', 'string', 'max:255'],
            ]);

            $amount = (int) $request->amount;

            if ($amount > (int) $agent->balance) {
                return redirect()->back()->with('error', 'You do not have enough balance to transfer!');
            }

            app(CustomWalletService::class)->transfer(
                $agent,
                $owner,
                $amount,
                TransactionName::DebitTransfer,
                [
                    'note' => $request->note,
                    'description' => $request->note ?? 'Teacher cash out to owner',
                ]
            );

            return redirect()->back()->with('success', 'Money fill request submitted successfully!');
        } catch (Exception $e) {
            session()->flash('error', $e->getMessage());

            return redirect()->back()->with('error', $e->getMessage());
        }
    }

    public function getTransferDetail($id)
    {

        $transfer_detail = TransferLog::where('from_user_id', $id)
            ->orWhere('to_user_id', $id)
            ->get();

        return view('admin.teachers.transfer_detail', compact('transfer_detail'));
    }

    private function generateRandomString()
    {
        $randomNumber = mt_rand(10000000, 99999999);

        return 'T-'.$randomNumber;
    }

    public function banAgent($id): RedirectResponse
    {
        $owner = Auth::user();
        $this->ensureOwner($owner);

        $user = User::where('type', UserType::Teacher->value)
            ->where('teacher_id', $owner->id)
            ->findOrFail($id);
        $user->update(['status' => $user->status == 1 ? 0 : 1]);

        return redirect()->back()->with(
            'success',
            'User '.($user->status == 1 ? 'activate' : 'inactive').' successfully'
        );
    }

    public function getChangePassword($id)
    {
        // abort_if(
        //     Gate::denies('owner_access') || ! $this->ifChildOfParent(request()->user()->id, $id),
        //     Response::HTTP_FORBIDDEN,
        //     '403 Forbidden |You cannot  Access this page because you do not have permission'
        // );

        $owner = Auth::user();
        $this->ensureOwner($owner);

        $agent = User::where('type', UserType::Teacher->value)
            ->where('teacher_id', $owner->id)
            ->findOrFail($id);

        return view('admin.teachers.change_password', compact('agent'));
    }

    public function makeChangePassword($id, Request $request)
    {
        

        $request->validate([
            'password' => 'required|min:6|confirmed',
        ]);

        $owner = Auth::user();
        $this->ensureOwner($owner);

        $agent = User::where('type', UserType::Agent->value)
            ->where('teacher_id', $owner->id)
            ->findOrFail($id);
        $agent->update([
            'password' => Hash::make($request->password),
        ]);

        return redirect()->route('admin.agent.index')
            ->with('successMessage', 'Agent Change Password successfully')
            ->with('password', $request->password)
            ->with('username', $agent->user_name);
    }

    
    
    private function generateReferralCode($length = 8)
    {
        $characters = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
        $charactersLength = strlen($characters);
        $randomString = '';

        for ($i = 0; $i < $length; $i++) {
            $randomString .= $characters[rand(0, $charactersLength - 1)];
        }

        return $randomString;
    }

    private function generateUniqueReferralCode($length = 8): string
    {
        do {
            $candidate = $this->generateReferralCode($length);
        } while (User::where('referral_code', $candidate)->exists());

        return $candidate;
    }

    // agent profile
    public function agentProfile($id)
    {
        $owner = Auth::user();
        $this->ensureOwner($owner);

        $agent = User::where('type', UserType::Agent->value)
            ->where('agent_id', $owner->id)
            ->findOrFail($id);

        return view('admin.agent.agent_profile', compact('agent'));
    }

    private function ensureOwner(User $user): void
    {
        if ((int) $user->type !== UserType::HeadTeacher->value) {
            abort(
                Response::HTTP_FORBIDDEN,
                'Unauthorized action. || ဤလုပ်ဆောင်ချက်အား သင့်မှာ လုပ်ဆောင်ပိုင်ခွင့်မရှိပါ, ကျေးဇူးပြု၍ သက်ဆိုင်ရာ Head Teacher များထံ ဆက်သွယ်ပါ'
            );
        }
    }

    private function assignAgentRole(User $agent): void
    {
        $roleId = Role::where('title', 'Agent')->value('id');

        if ($roleId) {
            $agent->roles()->sync($roleId);
        }
    }

    private function assignAgentPermissions(User $agent): void
    {
        $permissionIds = Permission::whereIn('title', self::DEFAULT_AGENT_PERMISSION_TITLES)->pluck('id');
        $agent->permissions()->sync($permissionIds);
    }
}

