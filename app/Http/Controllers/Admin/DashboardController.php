<?php

namespace App\Http\Controllers\Admin;

use App\Enums\UserType;
use App\Http\Controllers\Controller;
use App\Models\AcademicYear;
use App\Models\SchoolClass;
use App\Models\Subject;
use App\Models\User;
use App\Services\CustomWalletService;
use Illuminate\Support\Facades\Auth;

class DashboardController extends Controller
{
    protected $walletService;

    public function __construct(CustomWalletService $walletService)
    {
        $this->walletService = $walletService;
    }

    public function index()
    {
        $user = Auth::user();
        $userType = UserType::from($user->type);

        // Students are not allowed to access admin dashboard
        if ($userType === UserType::Student) {
            abort(403, 'Students are not authorized to access the admin dashboard.');
        }

        // HeadTeacher Dashboard
        if ($userType === UserType::HeadTeacher) {
            return $this->headTeacherDashboard();
        }

        // SystemWallet Dashboard
        if ($userType === UserType::SystemWallet) {
            return $this->systemWalletDashboard();
        }

        // Default fallback
        abort(403, 'Unauthorized access.');
    }

    private function headTeacherDashboard()
    {
        $user = Auth::user();

        $totalStudents = User::where('type', UserType::Student->value)->count();
        $totalTeachers = User::where('type', UserType::HeadTeacher->value)->count();
        $totalClasses = SchoolClass::count();
        $totalSubjects = Subject::count();
        $totalAcademicYears = AcademicYear::count();
        $currentAcademicYear = AcademicYear::current();

        $recentClasses = SchoolClass::with(['academicYear', 'classTeacher'])
            ->latest()
            ->take(5)
            ->get();

        $recentStudents = User::where('type', UserType::Student->value)
            ->with('schoolClass')
            ->latest()
            ->take(10)
            ->get();

        return view('admin.dashboard.owner', compact(
            'user',
            'totalStudents',
            'totalTeachers',
            'totalClasses',
            'totalSubjects',
            'totalAcademicYears',
            'currentAcademicYear',
            'recentClasses',
            'recentStudents'
        ));
    }

    private function systemWalletDashboard()
    {
        $user = Auth::user();
        
        // Get system wallet statistics
        $walletStats = $this->walletService->getWalletStats();
        $systemBalance = $user->balance;
        
        // Recent transactions for system wallet
        $recentTransactions = [];
        if (class_exists(\App\Models\CustomTransaction::class)) {
            $recentTransactions = \App\Models\CustomTransaction::where('user_id', $user->id)
                                ->orWhere('target_user_id', $user->id)
                                ->with(['user', 'targetUser'])
                                ->latest()
                                ->take(20)
                                ->get();
        }

        return view('admin.dashboard.system-wallet', compact(
            'user',
            'systemBalance',
            'walletStats',
            'recentTransactions'
        ));
    }
}

