<?php

use App\Http\Controllers\Admin\AcademicYearController;
use App\Http\Controllers\Admin\AdsVedioController;
use App\Http\Controllers\Admin\BankController;
use App\Http\Controllers\Admin\BannerAdsController;
use App\Http\Controllers\Admin\BannerController;
use App\Http\Controllers\Admin\BannerTextController;
use App\Http\Controllers\Admin\ClassTeacherController;
use App\Http\Controllers\Admin\SchoolClassController;
use App\Http\Controllers\Admin\ContactController;
use App\Http\Controllers\Admin\DepositRequestController;
use App\Http\Controllers\Admin\PaymentTypeController;
use App\Http\Controllers\Admin\PromotionController;
use App\Http\Controllers\Admin\SubjectController;
use App\Http\Controllers\Admin\TeacherController;
use App\Http\Controllers\Admin\TeacherSubjectController;
use App\Http\Controllers\Admin\DictionaryEntryController;
use App\Http\Controllers\Admin\TransferLogController;
use App\Http\Controllers\Admin\WithDrawRequestController;
use Illuminate\Support\Facades\Route;

Route::group([
    'prefix' => 'admin',
    'as' => 'admin.',
    'middleware' => ['auth', 'checkBanned', 'preventPlayerAccess'],
], function () {

    // ==================== Dashboard ====================
    Route::get('/', [App\Http\Controllers\Admin\DashboardController::class, 'index'])->name('home');

    
    
    // ==================== Profile Management ====================
    Route::get('profile/{id}', [App\Http\Controllers\Admin\ProfileController::class, 'index'])->name('profile_index');
    Route::put('profile/{id}', [App\Http\Controllers\Admin\ProfileController::class, 'update'])->name('profile_update');

    

    // ==================== Banks & Payment Types ====================
    Route::resource('banks', BankController::class);
    Route::resource('paymentTypes', PaymentTypeController::class);

    // ==================== Teacher Management ====================
    Route::resource('teachers', TeacherController::class);
    Route::resource('academic-years', AcademicYearController::class)->except(['show']);
    Route::resource('subjects', SubjectController::class)->except(['show']);
    Route::resource('school-classes', SchoolClassController::class)->except(['show']);
    Route::get('school-classes/{schoolClass}/teacher', [ClassTeacherController::class, 'edit'])->name('school-classes.teacher.edit');
    Route::put('school-classes/{schoolClass}/teacher', [ClassTeacherController::class, 'update'])->name('school-classes.teacher.update');
    Route::get('teachers/{teacher}/subjects', [TeacherSubjectController::class, 'create'])->name('teachers.subjects.create');
    Route::post('teachers/{teacher}/subjects', [TeacherSubjectController::class, 'store'])->name('teachers.subjects.store');

   

    // ==================== Banner & Promotion Management ====================
    Route::resource('video-upload', AdsVedioController::class);
    Route::resource('banners', BannerController::class);
    Route::resource('adsbanners', BannerAdsController::class);
    Route::resource('text', BannerTextController::class);
    Route::resource('promotions', PromotionController::class);

    // ==================== Contact Management ====================
    Route::resource('contacts', ContactController::class);
    Route::get('contact', [ContactController::class, 'playerContact'])->name('contact.index');

    // ==================== Dictionary ====================
    Route::resource('dictionary', DictionaryEntryController::class)->except(['show']);

    // ==================== Deposit Management ====================
    Route::middleware(['permission:agent_wallet_deposit'])->group(function () {
        Route::get('finicialdeposit', [DepositRequestController::class, 'index'])->name('agent.deposit');
        Route::get('finicialdeposit/{deposit}', [DepositRequestController::class, 'view'])->name('agent.depositView');
        Route::post('finicialdeposit/{deposit}', [DepositRequestController::class, 'statusChangeIndex'])->name('agent.depositStatusUpdate');
        Route::post('finicialdeposit/reject/{deposit}', [DepositRequestController::class, 'statusChangeReject'])->name('agent.depositStatusreject');
        Route::get('finicialdeposit/{deposit}/log', [DepositRequestController::class, 'DepositShowLog'])->name('agent.depositLog');
    });

    // ==================== Withdraw Management ====================
    Route::middleware(['permission:agent_wallet_withdraw'])->group(function () {
        Route::get('finicialwithdraw', [WithDrawRequestController::class, 'index'])->name('agent.withdraw');
        Route::post('finicialwithdraw/{withdraw}', [WithDrawRequestController::class, 'statusChangeIndex'])->name('agent.withdrawStatusUpdate');
        Route::post('finicialwithdraw/reject/{withdraw}', [WithDrawRequestController::class, 'statusChangeReject'])->name('agent.withdrawStatusreject');
        Route::get('finicialwithdraw/{withdraw}', [WithDrawRequestController::class, 'WithdrawShowLog'])->name('agent.withdrawLog');
    });

});
