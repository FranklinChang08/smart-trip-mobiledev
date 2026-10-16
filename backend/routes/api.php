<?php

use App\Http\Controllers\Auth\RegisterController;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\ExploreController;
use App\Models\FotoDestinasi;
use App\Models\Kategori;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\Storage;

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

Route::get('/wisata', [ExploreController::class, 'index']);
Route::get('/wisata/{id}', [ExploreController::class, 'show']);