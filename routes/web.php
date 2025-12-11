<?php

use App\Http\Controllers\Admin\LoginController;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Teacher\StudentClassAssignmentController;
use App\Http\Controllers\Teacher\LessonController;
use App\Http\Controllers\NotificationController;

// Redirect root route to login
Route::get('/', function () {
    return redirect()->route('login');
});

// Auth routes (for admin login)
Route::get('/login', [LoginController::class, 'showLogin'])->name('login');
Route::post('/login', [LoginController::class, 'login'])->name('login.post');
Route::post('logout', [LoginController::class, 'logout'])->name('logout');

// Password change routes
Route::get('get-change-password', [LoginController::class, 'changePassword'])->name('getChangePassword');
Route::post('update-password/{user}', [LoginController::class, 'updatePassword'])->name('updatePassword');



// Include admin routes
require_once __DIR__.'/admin.php';

Route::middleware(['auth', 'teacher'])->prefix('teacher')->as('teacher.')->group(function () {
    Route::get('students', [StudentClassAssignmentController::class, 'index'])->name('students.assign.index');
    Route::get('students/create', [StudentClassAssignmentController::class, 'create'])->name('students.assign.create');
    Route::post('students', [StudentClassAssignmentController::class, 'store'])->name('students.assign.store');
    Route::put('students/{student}', [StudentClassAssignmentController::class, 'update'])->name('students.assign.update');

    Route::resource('lessons', LessonController::class)->only(['index', 'create', 'store', 'show', 'edit', 'update']);
});

Route::middleware('auth')->prefix('notifications')->name('notifications.')->group(function () {
    Route::get('unread', [NotificationController::class, 'unread'])->name('unread');
    Route::post('mark-read', [NotificationController::class, 'markAsRead'])->name('mark-read');
});


