<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

use App\Http\Controllers\Api\V1\Auth\AuthController;

use App\Http\Controllers\Api\V1\BannerController;
use App\Http\Controllers\Api\V1\ContactController;

use App\Http\Controllers\Api\V1\DepositRequestController;

use App\Http\Controllers\Api\V1\Game\GSCPlusProviderController;
use App\Http\Controllers\Api\V1\PromotionController;
use App\Http\Controllers\Api\V1\Bank\BankController;
use App\Http\Controllers\Api\V1\Teacher\ClassController as TeacherClassApiController;
use App\Http\Controllers\Api\V1\Teacher\DashboardController as TeacherDashboardApiController;
use App\Http\Controllers\Api\V1\Teacher\LessonController as TeacherLessonApiController;
use App\Http\Controllers\Api\V1\Teacher\StudentController as TeacherStudentApiController;
use App\Http\Controllers\Api\V1\Teacher\SubjectController as TeacherSubjectApiController;
use App\Http\Controllers\Api\V1\Student\LessonController as StudentLessonApiController;
use App\Http\Controllers\Api\V1\WithDrawRequestController;


Route::post('/login', [AuthController::class, 'login']);
Route::post('/register', [AuthController::class, 'register']);
Route::post('/player-change-password', [AuthController::class, 'playerChangePassword']);
Route::post('/logout', [AuthController::class, 'logout']);


Route::middleware(['auth:sanctum'])->group(function () {

    // user api
    Route::get('user', [AuthController::class, 'getUser']);
    Route::get('/banks', [GSCPlusProviderController::class, 'banks']);
    Route::get('contact', [ContactController::class, 'get']);
    Route::get('promotion', [PromotionController::class, 'index']);

    // financial api
    Route::get('agentfinicialPaymentType', [BankController::class, 'all']);
    Route::post('depositfinicial', [DepositRequestController::class, 'FinicialDeposit']);
    Route::get('depositlogfinicial', [DepositRequestController::class, 'log']);
    Route::get('paymentTypefinicial', [GSCPlusProviderController::class, 'paymentType']);
    Route::post('withdrawfinicial', [WithDrawRequestController::class, 'FinicalWithdraw']);
    Route::get('withdrawlogfinicial', [WithDrawRequestController::class, 'log']);

    Route::post('change-password', [AuthController::class, 'changePassword']);
    Route::post('update-password', [AuthController::class, 'changePassword']);

    Route::prefix('teacher')->middleware('teacher')->group(function () {
        Route::get('dashboard', TeacherDashboardApiController::class);
        Route::get('classes', [TeacherClassApiController::class, 'index']);
        Route::get('subjects', [TeacherSubjectApiController::class, 'index']);
        Route::get('students', [TeacherStudentApiController::class, 'index']);
        Route::post('students', [TeacherStudentApiController::class, 'store']);
        Route::get('lessons', [TeacherLessonApiController::class, 'index']);
        Route::post('lessons', [TeacherLessonApiController::class, 'store']);
    });

    Route::prefix('student')->group(function () {
        Route::get('lessons', [StudentLessonApiController::class, 'index']);
        Route::get('lessons/{lesson}', [StudentLessonApiController::class, 'show']);
    });
});

Route::get('banner_Text', [BannerController::class, 'bannerText']);
Route::get('popup-ads-banner', [BannerController::class, 'AdsBannerIndex']);
Route::get('banner', [BannerController::class, 'index']);
Route::get('videoads', [BannerController::class, 'ApiVideoads']);
