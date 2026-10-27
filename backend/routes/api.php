<?php

use App\Http\Controllers\Auth\RegisterController;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\ExploreController;
use App\Http\Controllers\FotoController;
use App\Http\Controllers\RencanaPerjalananController;
use App\Models\FotoDestinasi;
use App\Models\Kategori;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::post('/register', [RegisterController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
});

Route::get('/kategori', function (Request $request) {
    $jenis = $request->query('jenis');
    $query = Kategori::query();
    if ($jenis) {
        $query->where('jenis_kategori', $jenis);
    }
    return response()->json([
        'success' => true,
        'data' => $query->get(),
    ]);
});

Route::get('/kecamatan', function () {
    return response()->json([
        'success' => true,
        'data' => \App\Models\Kecamatan::orderBy('nama_kecamatan')->get(),
    ]);
});

Route::prefix('wisata')->name('wisata.')->group(function () {
    Route::get('/', [ExploreController::class, 'index']);
    Route::get('/{id}', [ExploreController::class, 'show']);
    Route::get('/foto/{path}', [FotoController::class, 'showFotoDestinasi'])->where('path', '.*');
});
Route::prefix('restoran')->name('restoran.')->group(function () {
    Route::get('/', [ExploreController::class, 'indexRestoran']);
    Route::get('/{id}', [ExploreController::class, 'show']);
    Route::get('/foto/{path}', [FotoController::class, 'showFotoRestoran'])->where('path', '.*');
});

Route::get('/kategori-list', [ExploreController::class, 'showKategori']);

Route::get('/rencana-perjalanan', [RencanaPerjalananController::class, 'index']);
Route::get('/rencana-perjalanan/{id}', [RencanaPerjalananController::class, 'show']);
Route::post('/rencana-perjalanan', [RencanaPerjalananController::class, 'store']);
Route::put('/rencana-perjalanan/{id}/urutan', [RencanaPerjalananController::class, 'updateUrutan']);
Route::put('/rencana-perjalanan/{id}/aktif', [RencanaPerjalananController::class, 'setActive']);
Route::delete('/rencana-perjalanan/{id}', [RencanaPerjalananController::class, 'destroy']);