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
use App\Http\Controllers\Api\V1\WithDrawRequestController;


Route::post('/login', [AuthController::class, 'login']);
Route::post('/register', [AuthController::class, 'register']);
Route::post('/player-change-password', [AuthController::class, 'playerChangePassword']);
Route::post('/logout', [AuthController::class, 'logout']);


Route::group(['middleware' => ['auth:sanctum']], function () {
    
    // user api
    Route::get('user', [AuthController::class, 'getUser']);
    Route::get('/banks', [GSCPlusProviderController::class, 'banks']);
    Route::get('contact', [ContactController::class, 'get']);
    Route::get('promotion', [PromotionController::class, 'index']);

    // fanicial api
    Route::get('agentfinicialPaymentType', [BankController::class, 'all']);
    Route::post('depositfinicial', [DepositRequestController::class, 'FinicialDeposit']);
    Route::get('depositlogfinicial', [DepositRequestController::class, 'log']);
    Route::get('paymentTypefinicial', [GSCPlusProviderController::class, 'paymentType']);
    Route::post('withdrawfinicial', [WithDrawRequestController::class, 'FinicalWithdraw']);
    Route::get('withdrawlogfinicial', [WithDrawRequestController::class, 'log']);

    
});

Route::get('banner_Text', [BannerController::class, 'bannerText']);
Route::get('popup-ads-banner', [BannerController::class, 'AdsBannerIndex']);
Route::get('banner', [BannerController::class, 'index']);
Route::get('videoads', [BannerController::class, 'ApiVideoads']);





Route::middleware(['auth:sanctum'])->group(function () {
   
    Route::post('/change-password', [AuthController::class, 'changePassword']); 
});



