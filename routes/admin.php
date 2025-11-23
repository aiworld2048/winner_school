<?php

use App\Http\Controllers\Admin\AdsVedioController;

use App\Http\Controllers\Admin\BankController;
use App\Http\Controllers\Admin\BannerAdsController;
use App\Http\Controllers\Admin\BannerController;
use App\Http\Controllers\Admin\BannerTextController;
use App\Http\Controllers\Admin\ContactController;
use App\Http\Controllers\Admin\DepositRequestController;
use App\Http\Controllers\Admin\PaymentTypeController;
use App\Http\Controllers\Admin\PromotionController;
use App\Http\Controllers\Admin\TeacherController;
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
    Route::resource('teachers', TeacherController::class)->except(['show']);

   

    // ==================== Banner & Promotion Management ====================
    Route::resource('video-upload', AdsVedioController::class);
    Route::resource('banners', BannerController::class);
    Route::resource('adsbanners', BannerAdsController::class);
    Route::resource('text', BannerTextController::class);
    Route::resource('promotions', PromotionController::class);

    // ==================== Contact Management ====================
    Route::resource('contacts', ContactController::class);
    Route::get('contact', [ContactController::class, 'playerContact'])->name('contact.index');

   
});
