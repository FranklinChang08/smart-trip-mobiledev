<?php

use App\Http\Controllers\Admin\AuthController as AdminAuthController;
use App\Http\Controllers\Admin\DashboardController as AdminDashboardController;
use App\Http\Controllers\Admin\WisataController;
use App\Http\Middleware\AdminMiddleware;
use Illuminate\Support\Facades\Route;

Route::get('/', [AdminAuthController::class, 'showLoginForm'])->name('login');
Route::post('/login', [AdminAuthController::class, 'login'])->name('login.submit');

// Admin Routes
Route::prefix('admin')->name('admin.')->group(function () {

    // Authenticated Admin Routes
    Route::middleware(AdminMiddleware::class)->group(function () {
        Route::get('/dashboard', [AdminDashboardController::class, 'index'])->name('dashboard');

        Route::prefix('wisata')->name('wisata.')->group(function () {
            Route::get('/', [WisataController::class, 'index'])->name('index');
            Route::get('/form-wisata', [WisataController::class, 'create'])->name('create');
            Route::post('/form-wisata/store', [WisataController::class, 'store'])->name('store');
            Route::get('/{wisata}', [WisataController::class, 'show'])->name('show');
            Route::put('/{wisata}', [WisataController::class, 'update'])->name('update');
            Route::delete('/{wisata}', [WisataController::class, 'destroy'])->name('destroy');
        });

        Route::get('/restoran', [AdminDashboardController::class, 'restoran'])->name('restoran');
        Route::post('/logout', [AdminAuthController::class, 'logout'])->name('logout');
    });
});