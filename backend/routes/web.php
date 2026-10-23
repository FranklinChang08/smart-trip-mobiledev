<?php

use App\Http\Controllers\Admin\AuthController as AdminAuthController;
use App\Http\Controllers\Admin\DashboardController as AdminDashboardController;
use App\Http\Controllers\Admin\FasilitasController;
use App\Http\Controllers\Admin\FotoDestinasiController;
use App\Http\Controllers\Admin\KategoriController;
use App\Http\Controllers\Admin\KecamatanController;
use App\Http\Controllers\Admin\RestoranController;
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

            Route::delete('/foto/{id}', [FotoDestinasiController::class, 'destroy'])->name('foto.destroy');
        });

        Route::prefix('restoran')->name('restoran.')->group(function () {
            Route::get('/', [RestoranController::class, 'index'])->name('index');
            Route::get('/form-restoran', [RestoranController::class, 'create'])->name('create');
            Route::post('/form-restoran/store', [RestoranController::class, 'store'])->name('store');
            Route::get('/{restoran}', [RestoranController::class, 'show'])->name('show');
            Route::put('/{restoran}', [RestoranController::class, 'update'])->name('update');
            Route::delete('/{restoran}', [RestoranController::class, 'destroy'])->name('destroy');

            Route::delete('/foto/{id}', [FotoDestinasiController::class, 'destroy'])->name('foto.destroy');
        });

        Route::prefix('kecamatan')->name('kecamatan.')->group(function () {
            Route::get('/', [KecamatanController::class, 'index'])->name('index');
            Route::get('/form-kecamatan', [KecamatanController::class, 'create'])->name('create');
            Route::post('/form-kecamatan/store', [KecamatanController::class, 'store'])->name('store');
            Route::get('/{kecamatan}', [KecamatanController::class, 'show'])->name('show');
            Route::put('/{kecamatan}', [KecamatanController::class, 'update'])->name('update');
            Route::delete('/{kecamatan}', [KecamatanController::class, 'destroy'])->name('destroy');
        });

        Route::prefix('kategori')->name('kategori.')->group(function () {
            Route::get('/', [KategoriController::class, 'index'])->name('index');
            Route::get('/form-kategori', [KategoriController::class, 'create'])->name('create');
            Route::post('/form-kategori/store', [KategoriController::class, 'store'])->name('store');
            Route::get('/{kategori}', [KategoriController::class, 'show'])->name('show');
            Route::put('/{kategori}', [KategoriController::class, 'update'])->name('update');
            Route::delete('/{kategori}', [KategoriController::class, 'destroy'])->name('destroy');
        });

        Route::prefix('fasilitas')->name('fasilitas.')->group(function () {
            Route::post('/store', [FasilitasController::class, 'store'])->name('store');
        });

        // Alias kompatibilitas jika ada yang memanggil route('admin.restoran')
        Route::get('/restoran-redirect', [RestoranController::class, 'index'])->name('restoran');

        Route::post('/logout', [AdminAuthController::class, 'logout'])->name('logout');
    });
});